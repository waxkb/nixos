#!/usr/bin/env bash
# NixOS full-disk installer for the waxkb/nixos flake.
#
# Run as root inside the custom minimal ISO (see ~/iso/flake.nix, which
# bakes this file in at /etc/nixos-installer/install.sh):
#   sudo bash /etc/nixos-installer/install.sh
#
# What it does:
#   1. Preconditions (root, UEFI, network, tools).
#   2. Prompts: target disk (WIPED), hostname, laptop vs desktop,
#      root + max passwords (hashed into config).
#   3. Auto-detects CPU vendor (intel/amd) and GPU vendor(s)
#      (nvidia/amd/intel) for module selection.
#   4. Partitions (1G ESP + bcachefs root, + swap-as-RAM-capped-16G on
#      laptops only), formats, mounts on /mnt.
#   5. Clones the flake over HTTPS, scaffolds hosts/<name>/,
#      appends nixosConfigurations.<name> to flake.nix using only
#      modules from ./modules/*, then nixos-install --flake .#<name>.
#   6. Copies the flake to /mnt/home/max/nixos and symlinks
#      /mnt/etc/nixos -> /home/max/nixos (mirrors the current setup
#      where /etc/nixos is a symlink to ~/nixos).
#
# Constraints honored: whole-disk wipe, no encryption, UEFI only,
# HTTPS clone, swap partition + zswap on laptops only.

set -euo pipefail

readonly REPO_URL="https://github.com/waxkb/nixos.git"
readonly DOTFILES_URL="https://github.com/waxkb/dotfiles.git"
# Stowed as user max inside the target so first boot has a working
# desktop (niri autostarts foot/noctalia from these). hypr is included
# for hyprlock's config even though the session is niri, scripts for ~/scripts.
readonly STOW_PKGS="niri foot noctalia tofi starship git gita matugen yazi broot mime hypr scripts"
readonly WORKDIR="/tmp/nixos-install"
readonly STATE_FALLBACK="25.11"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
info() { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required tool '$1' not found in the ISO"
}

ask() { # $1=prompt $2=var_name $3=default(optional)
  local prompt="$1" var="$2" def="${3:-}" ans
  if [ -n "$def" ]; then
    printf '%s [%s]: ' "$prompt" "$def"
  else
    printf '%s: ' "$prompt"
  fi
  IFS= read -r ans || die "input aborted"
  # Strip leading/trailing whitespace: pasted paths often carry a
  # trailing space or CR, which would fail the -b check below.
  ans="${ans#"${ans%%[![:space:]]*}"}"
  ans="${ans%"${ans##*[![:space:]]}"}"
  if [ -z "$ans" ] && [ -n "$def" ]; then ans="$def"; fi
  printf -v "$var" '%s' "$ans"
}

ask_secret() { # $1=prompt $2=var_name (hidden, confirmed, non-empty)
  local prompt="$1" var="$2" a b
  while true; do
    printf '%s: ' "$prompt"
    IFS= read -rs a || die "input aborted"
    printf '\n'
    [ -n "$a" ] || { echo "password must not be empty"; continue; }
    printf '%s (confirm): ' "$prompt"
    IFS= read -rs b || die "input aborted"
    printf '\n'
    if [ "$a" = "$b" ]; then
      printf -v "$var" '%s' "$a"
      return
    fi
    echo "passwords do not match, try again"
  done
}

hash_pw() { # $1=password; prints $6$ SHA-512 crypt hash
  local pw="$1" salt
  salt="$(tr -dc 'a-zA-Z0-9./' </dev/urandom | head -c 16)"
  if command -v mkpasswd >/dev/null 2>&1; then
    mkpasswd -m sha-512 -S "$salt" "$pw"
  elif command -v openssl >/dev/null 2>&1; then
    openssl passwd -6 -salt "$salt" "$pw"
  else
    die "neither mkpasswd (whois) nor openssl found; rebuild the ISO from ~/iso/flake.nix"
  fi
}

chown_as_max() { # $1=path on the target; best effort (uid may not resolve in the ISO)
  chown -R 1000:100 "$1" 2>/dev/null || \
    chown -R 1000:users "$1" 2>/dev/null || true
}

(( $# == 0 )) || die "this installer takes no arguments (usage: sudo bash install.sh)"

# ---------- preconditions ----------
[ "$(id -u)" -eq 0 ] || die "run as root (sudo bash install.sh)"
[ -d /sys/firmware/efi ] || die "no UEFI detected (/sys/firmware/efi missing). BIOS installs are not supported"
for t in git sgdisk partprobe wipefs mkfs.vfat mkfs.bcachefs mkswap swapon \
         nixos-generate-config nixos-install lspci python3 mount umount; do
  need_cmd "$t"
done
command -v mkpasswd >/dev/null 2>&1 || command -v openssl >/dev/null 2>&1 \
  || die "need mkpasswd (whois) or openssl for password hashing; rebuild the ISO from ~/iso/flake.nix"

info "checking network (need it for the HTTPS clone)..."
if ! getent hosts github.com >/dev/null 2>&1; then
  warn "cannot resolve github.com; attempting anyway (nmcli may be needed for Wi-Fi)"
fi

# ---------- disk selection (numbered menu, loops until valid) ----------
CANDIDATES=()
while read -r dev dtype; do
  [ "$dtype" = "disk" ] || continue
  case "$dev" in
    /dev/loop*|/dev/ram*|/dev/fd*|/dev/sr*|/dev/dm-*) continue ;;
  esac
  CANDIDATES+=("$dev")
done < <(lsblk -dnr -o PATH,TYPE 2>/dev/null || lsblk -dnr -o NAME,TYPE 2>/dev/null | sed 's|^|/dev/|')
[ "${#CANDIDATES[@]}" -gt 0 ] || die "no candidate disks found (lsblk showed nothing usable)"

info "candidate disks (in a QEMU VM this is usually /dev/vda):"
for idx in "${!CANDIDATES[@]}"; do
  printf '  %d) %s  [%s]\n' "$((idx + 1))" "${CANDIDATES[idx]}" \
    "$(lsblk -dnr -o SIZE,MODEL "${CANDIDATES[idx]}" 2>/dev/null | tr -s ' ' | tr '\n' ' ')"
done
printf '\n'

DISK=""
while true; do
  pick=""
  ask "target disk to WIPE: number from the list, or a full /dev/... path (q to abort)" pick
  case "$pick" in
    q|Q|quit|abort|exit) die "aborted (nothing was touched)" ;;
  esac
  if [[ "$pick" =~ ^[0-9]+$ ]]; then
    num=$((10#$pick)) # base-10: avoids octal misparse of 08/09
    if (( num >= 1 && num <= ${#CANDIDATES[@]} )); then
      DISK="${CANDIDATES[$((num - 1))]}"
      break
    fi
  elif [[ "$pick" == /dev/* ]] && [ -b "$pick" ]; then
    DISK="$pick"
    if ! printf '%s\n' "${CANDIDATES[@]}" | grep -qxF "$DISK"; then
      warn "$DISK was not in the detected list, but it is a block device; continuing"
    fi
    break
  fi
  printf "'%s' is neither a menu number nor an existing block device.\n" "$pick"
  echo "Pick a NUMBER from the list above (in this VM, probably the /dev/vda entry)."
done
case "$DISK" in
  *loop*|*ram*|*sr[0-9]*|*dm-*) die "refusing to install onto $DISK" ;;
esac
info "current layout of $DISK:"
lsblk "$DISK" || true
sgdisk -p "$DISK" || true
printf '\n'
echo "ALL DATA ON $DISK WILL BE DESTROYED. No encryption, UEFI only."
CONFIRM=""
ask "type the disk path again to confirm the wipe ($DISK)" CONFIRM
[ "$CONFIRM" = "$DISK" ] || die "confirmation mismatch, aborting (nothing was touched)"

# Partition device names: nvme0n1 -> p1, sda -> 1.
if [[ "$DISK" =~ [0-9]$ ]]; then PSEP="p"; else PSEP=""; fi
ESP="${DISK}${PSEP}1"
ROOT_PART="${DISK}${PSEP}2"
SWAP_PART="${DISK}${PSEP}3"

# ---------- hostname ----------
HOSTNAME=""
while true; do
  ask "hostname for the new machine (flake attr + hosts/<name>)" HOSTNAME
  if [[ "$HOSTNAME" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then break; fi
  echo "invalid hostname: use lowercase letters, digits, dashes (max 63 chars)"
done

# ---------- form factor (user-chosen per requirements) ----------
FORM=""
while true; do
  ask "is this a laptop or a desktop? (laptop gets swap partition + zswap + power/bluetooth stack) [desktop]" FORM "desktop"
  FORM="$(printf '%s' "$FORM" | tr '[:upper:]' '[:lower:]')"
  case "$FORM" in laptop|desktop) break;; *) echo "answer 'laptop' or 'desktop'";; esac
done
IS_LAPTOP=0
[ "$FORM" = "laptop" ] && IS_LAPTOP=1

# ---------- passwords ----------
ROOT_PW=""; USER_PW=""
ask_secret "password for root" ROOT_PW
ask_secret "password for user max" USER_PW

# ---------- auto-detect CPU (read once, match case-insensitively) ----------
CPUINFO="$(cat /proc/cpuinfo 2>/dev/null || true)"
has_intel=0; has_amd_cpu=0
if grep -qi genuineintel <<<"$CPUINFO"; then has_intel=1; fi
if grep -qi authenticamd <<<"$CPUINFO"; then has_amd_cpu=1; fi
if (( has_intel && has_amd_cpu )); then
  warn "mixed CPU vendors seen; including both cpu modules"
  CPU_VENDOR="both"
elif (( has_intel )); then
  CPU_VENDOR="intel"
elif (( has_amd_cpu )); then
  CPU_VENDOR="amd"
else
  warn "could not detect CPU vendor; including both cpu modules"
  CPU_VENDOR="both"
fi
info "CPU vendor: $CPU_VENDOR"

# ---------- auto-detect GPUs (lowercase once, match by substring) ----------
GPU_PCI="$(lspci -nn 2>/dev/null | grep -iE 'vga|3d|display' || true)"
printf '%s\n' "$GPU_PCI"
gpu_lc="$(printf '%s' "$GPU_PCI" | tr '[:upper:]' '[:lower:]')"
HAVE_NVIDIA=0; HAVE_AMD=0; HAVE_INTEL=0
case "$gpu_lc" in *nvidia*) HAVE_NVIDIA=1 ;; esac
case "$gpu_lc" in *amd*|*ati*|*radeon*) HAVE_AMD=1 ;; esac
case "$gpu_lc" in *intel*) HAVE_INTEL=1 ;; esac
if (( ! HAVE_NVIDIA && ! HAVE_AMD && ! HAVE_INTEL )); then
  warn "no known GPU detected (VM/unknown?). Continuing with generic modesetting only."
fi
info "GPUs detected: nvidia=$HAVE_NVIDIA amd=$HAVE_AMD intel=$HAVE_INTEL"

# ---------- swap size (laptops only): RAM size capped at 16G ----------
SWAP_GIB=0
if [ "$IS_LAPTOP" -eq 1 ]; then
  MEM_KB="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null || true)"
  MEM_KB="${MEM_KB:-0}"
  SWAP_GIB=$(( (MEM_KB + 1048575) / 1048576 ))
  [ "$SWAP_GIB" -lt 1 ] && SWAP_GIB=1
  [ "$SWAP_GIB" -gt 16 ] && SWAP_GIB=16
  info "RAM-based swap size: ${SWAP_GIB}G (capped at 16G)"
fi

printf '\n'
info "summary: disk=$DISK host=$HOSTNAME form=$FORM cpu=$CPU_VENDOR gpus=(nvidia=$HAVE_NVIDIA amd=$HAVE_AMD intel=$HAVE_INTEL) swap=${SWAP_GIB}G"
GO=""
ask "proceed with WIPE + INSTALL? type YES" GO
[ "$GO" = "YES" ] || die "aborted (nothing was touched)"

# ---------- partition / format ----------
info "wiping $DISK..."
swapoff -a || true
umount -R /mnt 2>/dev/null || true
sgdisk --zap-all "$DISK"
wipefs -a "$DISK"
partprobe "$DISK" || true
sleep 2

info "creating partitions (1G ESP + root${IS_LAPTOP:+ + swap})..."
if [ "$IS_LAPTOP" -eq 1 ]; then
  sgdisk -n1:0:+1G -t1:EF00 -c1:boot \
         -n2:0:-"${SWAP_GIB}"G -t2:8300 -c2:nixos \
         -n3:0:0 -t3:8200 -c3:swap "$DISK"
else
  sgdisk -n1:0:+1G -t1:EF00 -c1:boot \
         -n2:0:0 -t2:8300 -c2:nixos "$DISK"
fi
partprobe "$DISK" || true
udevadm settle || sleep 3

info "formatting..."
mkfs.vfat -F32 -n boot "$ESP"
mkfs.bcachefs -f -L nixos "$ROOT_PART"
if [ "$IS_LAPTOP" -eq 1 ]; then
  mkswap -L swap "$SWAP_PART"
fi

info "mounting on /mnt..."
mount -L nixos /mnt
mkdir -p /mnt/boot
mount -L boot /mnt/boot
if [ "$IS_LAPTOP" -eq 1 ]; then
  swapon -L swap || swapon "$SWAP_PART"
fi
lsblk "$DISK"

# ---------- clone flake over HTTPS ----------
info "cloning $REPO_URL over HTTPS..."
rm -rf "${WORKDIR:?}"
git clone "$REPO_URL" "$WORKDIR" || die "git clone failed (check network)"
cd "$WORKDIR" || die "could not cd to $WORKDIR"
if [ -d "hosts/$HOSTNAME" ]; then
  die "hosts/$HOSTNAME already exists in the repo; pick another hostname"
fi
if grep -qE "^[[:space:]]*$HOSTNAME = " flake.nix; then
  die "flake.nix already has an entry for '$HOSTNAME'"
fi

# ---------- password hashes (mkpasswd preferred, openssl fallback; both baked into the ISO) ----------
info "hashing passwords..."
ROOT_HASH="$(hash_pw "$ROOT_PW")"
USER_HASH="$(hash_pw "$USER_PW")"
ROOT_PW=""; USER_PW=""
[ -n "$ROOT_HASH" ] && [ -n "$USER_HASH" ] || die "password hashing failed"

# ---------- hardware-configuration.nix ----------
info "generating hardware-configuration.nix..."
mkdir -p "hosts/$HOSTNAME"
nixos-generate-config --root /mnt --show-hardware-config > "hosts/$HOSTNAME/hardware-configuration.nix" \
  || die "nixos-generate-config failed"
info "generated hosts/$HOSTNAME/hardware-configuration.nix (kept as-is; mounts are forced by-label in configuration.nix like the existing hosts)"

# ---------- stateVersion from the installer image ----------
STATEVER="$(nixos-version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || true)"
if ! [[ "$STATEVER" =~ ^[0-9]+\.[0-9]+$ ]]; then STATEVER="$STATE_FALLBACK"; fi
info "using system.stateVersion = \"$STATEVER\""

# ---------- hosts/<name>/configuration.nix ----------
info "writing hosts/$HOSTNAME/configuration.nix..."
SWAP_NIX=""
if [ "$IS_LAPTOP" -eq 1 ]; then
  SWAP_NIX='
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];'
fi
cat > "hosts/$HOSTNAME/configuration.nix" <<EOF
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "$HOSTNAME";

  system.stateVersion = "$STATEVER";

  # Installed via install.sh: whole-disk bcachefs install, by-label
  # mounts (mirrors the existing hosts). hardware-configuration.nix is
  # the raw nixos-generate-config output; these mkForce mounts win.
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
      "noatime"
    ];
  };
$SWAP_NIX

  users.users.max.hashedPassword = "$USER_HASH";
  users.users.root.hashedPassword = "$ROOT_HASH";
}
EOF

# ---------- hosts/<name>/default.nix + packages.nix ----------
cat > "hosts/$HOSTNAME/default.nix" <<'EOF'
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    ./packages.nix
  ];
}
EOF

if [ -f hosts/nixos/packages.nix ]; then
  cp hosts/nixos/packages.nix "hosts/$HOSTNAME/packages.nix"
  info "copied hosts/nixos/packages.nix template"
else
  cat > "hosts/$HOSTNAME/packages.nix" <<'EOF'
{
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    vim
  ];
}
EOF
fi

# ---------- flake.nix entry (module list from detection) ----------
info "adding nixosConfigurations.$HOSTNAME to flake.nix..."
HOST="$HOSTNAME" CPU="$CPU_VENDOR" NVIDIA="$HAVE_NVIDIA" AMDGPU="$HAVE_AMD" INTELGPU="$HAVE_INTEL" LAPTOP="$IS_LAPTOP" python3 - <<'PYEOF'
import os, re

host = os.environ["HOST"]
cpu = os.environ["CPU"]
nvidia = os.environ["NVIDIA"] == "1"
amdgpu = os.environ["AMDGPU"] == "1"
intelgpu = os.environ["INTELGPU"] == "1"
laptop = os.environ["LAPTOP"] == "1"

mods = ["./hosts/" + host, "./modules/global"]
if cpu == "intel":
    mods.append("./modules/hardware/cpu-intel.nix")
elif cpu == "amd":
    mods.append("./modules/hardware/cpu-amd.nix")
else:
    mods += ["./modules/hardware/cpu-intel.nix", "./modules/hardware/cpu-amd.nix"]
if nvidia:
    mods.append("./modules/hardware/gpu-nvidia.nix")
if amdgpu:
    mods.append("./modules/hardware/gpu-amd.nix")
if intelgpu:
    mods.append("./modules/hardware/gpu-intel.nix")
if laptop:
    mods.append("./modules/hardware/laptop.nix")
mods += [
    "./modules/optional/ccache.nix",
    "./modules/optional/desktop.nix",
    "./modules/optional/direnv.nix",
    "./modules/optional/fonts.nix",
    "./modules/optional/greetd.nix",
    "./modules/optional/java.nix",
    "./modules/optional/latestkernel.nix",
    "./modules/optional/nh.nix",
    "./modules/optional/nix-ld.nix",
    "./modules/optional/pi.nix",
    "./modules/optional/podman.nix",
]

mod_lines = "\n".join(f"            {m}" for m in mods)
entry = (
    f"        {host} = nixpkgs.lib.nixosSystem {{\n"
    f"          inherit system;\n"
    f"          modules = [\n{mod_lines}\n"
    f"            {{\n"
    f"              nixpkgs.overlays = [\n"
    f"                noctalia.overlays.default\n"
    f"              ];\n"
    f"            }}\n"
    f"          ];\n\n"
    f"          specialArgs = {{\n"
    f"            inherit inputs;\n"
    f"          }};\n"
    f"        }};\n"
)

with open("flake.nix") as f:
    src = f.read()

if re.search(rf"(?m)^\s*{re.escape(host)}\s*=\s*nixpkgs\.lib\.nixosSystem", src):
    raise SystemExit(f"flake.nix already contains '{host}'")

# Insert before the closing of nixosConfigurations. Anchor on the
# existing 'server' entry so formatting stays consistent.
anchor = re.search(r"(?m)^(\s*)server = nixpkgs\.lib\.nixosSystem", src)
if not anchor:
    raise SystemExit("could not find 'server = nixpkgs.lib.nixosSystem' anchor in flake.nix")
src = src[:anchor.start()] + entry + src[anchor.start():]

with open("flake.nix", "w") as f:
    f.write(src)
print(f"inserted nixosConfigurations.{host} with {len(mods)} modules")
PYEOF

git add "hosts/$HOSTNAME" flake.nix || true
git -c user.name=installer -c user.email=installer@localhost commit -m "add $HOSTNAME via install.sh" || \
  warn "git commit failed (continuing; install uses the working tree)"

# ---------- install ----------
# programs.ccache (included in every generated host) wraps compilers such as
# noctalia's with a wrapper that hard-errors when $CCACHE_DIR is missing or
# unwritable in the build sandbox. That dir is normally created by the
# TARGET system's activation, which hasn't run yet, and the target's
# nix.settings.extra-sandbox-paths is not in effect for the LIVE installer's
# nix daemon -- so without this, ccache-built packages die during
# nixos-install with e.g. meson's "Unknown compiler(s): [['gcc']]", then
# build fine on every later nixos-rebuild. Provide the dir on the live
# system (throwaway tmpfs; 0777 just needs to make ccache functional,
# cache hits are irrelevant for a one-shot install) and mount it into the
# installer's sandbox. Must match cacheDir in modules/optional/ccache.nix.
mkdir -p /var/cache/ccache
chmod 0777 /var/cache/ccache
info "running nixos-install --flake .#$HOSTNAME (this takes a while)..."
nixos-install --flake ".#$HOSTNAME" --no-root-passwd --show-trace \
  --option extra-sandbox-paths /var/cache/ccache

# ---------- ~/nixos + /etc/nixos symlink on the target ----------
info "setting up /home/max/nixos + /etc/nixos symlink on the target..."
mkdir -p /mnt/home/max
if [ -e /mnt/home/max/nixos ] && [ ! -L /mnt/home/max/nixos ]; then
  rm -rf /mnt/home/max/nixos
fi
cp -a "$WORKDIR" /mnt/home/max/nixos
chown_as_max /mnt/home/max/nixos
rm -rf /mnt/etc/nixos
ln -s /home/max/nixos /mnt/etc/nixos
info "target: /etc/nixos -> /home/max/nixos"

# ---------- dotfiles (without these, first login lands in a bare niri
# session: niri autostarts foot/noctalia/tofi bindings from stowed config) ----------
info "cloning dotfiles..."
if [ -e /mnt/home/max/dotfiles ] && [ ! -L /mnt/home/max/dotfiles ]; then
  rm -rf /mnt/home/max/dotfiles
fi
if git clone "$DOTFILES_URL" /mnt/home/max/dotfiles; then
  chown_as_max /mnt/home/max/dotfiles
  info "stowing dotfiles as max inside the target ($STOW_PKGS)..."
  if command -v nixos-enter >/dev/null 2>&1 && \
    nixos-enter --root /mnt -c "su max -s /bin/sh -c 'cd /home/max/dotfiles && stow $STOW_PKGS'"; then
    info "dotfiles stowed: ~/.config wired to ~/dotfiles"
  else
    warn "automatic stow failed; on first boot run: cd ~/dotfiles && stow $STOW_PKGS"
  fi
else
  warn "dotfiles clone failed; on first boot run: git clone $DOTFILES_URL ~/dotfiles && cd ~/dotfiles && stow $STOW_PKGS"
fi

printf '\n'
info "DONE. Installed '$HOSTNAME' ($FORM) onto $DISK."
info "Unmount with: swapoff -a; umount -R /mnt ; then reboot and remove the ISO."
info "First boot: log in as max (password you set). Push when ready: cd ~/nixos && git push."
