# description: LaTeX toolchain (texliveSmall)
{
  pkgs,
  ...
}:
let
  tex = pkgs.texliveSmall.withPackages (
    ps: with ps; [
      latexmk
      thmtools
      tikz-cd
      mdframed
      newtx
      zref
      needspace
      mhchem
      siunitx
      latexindent
      fancyhdr
      biblatex
      biblatex-chicago
      biber
      csquotes
      babel
      xstring
    ]
  );
in
{
  environment.systemPackages = [ tex ];
}
