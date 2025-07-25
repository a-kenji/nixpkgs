{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  autoreconfHook,
  yodl,
  perl,
  groff,
  util-linux,
  texinfo,
  ncurses,
  pcre2,
  pkg-config,
  buildPackages,
  nixosTests,
}:

let
  version = "5.9";
in

stdenv.mkDerivation {
  pname = "zsh";
  inherit version;
  outputs = [
    "out"
    "doc"
    "info"
    "man"
  ];

  src = fetchurl {
    url = "mirror://sourceforge/zsh/zsh-${version}.tar.xz";
    sha256 = "sha256-m40ezt1bXoH78ZGOh2dSp92UjgXBoNuhCrhjhC1FrNU=";
  };

  patches = [
    # fix location of timezone data for TZ= completion
    ./tz_completion.patch
    # Fixes configure misdetection when using clang 16, resulting in broken subshells on Darwin.
    # This patch can be dropped with the next release of zsh.
    (fetchpatch {
      url = "https://github.com/zsh-users/zsh/commit/ab4d62eb975a4c4c51dd35822665050e2ddc6918.patch";
      hash = "sha256-nXB4w7qqjZJC7/+CDxnNy6wu9qNwmS3ezjj/xK7JfeU=";
      excludes = [ "ChangeLog" ];
    })
    # Fixes compatibility with texinfo 7.1. This patch can be dropped with the next release of zsh.
    (fetchpatch {
      url = "https://github.com/zsh-users/zsh/commit/ecd3f9c9506c7720dc6c0833dc5d5eb00e4459c4.patch";
      hash = "sha256-oA8GC8LmuqNKGuPqGfiQVhL5nWb7ArLWGUI6wjpsIW8=";
      excludes = [ "ChangeLog" ];
    })
    # PCRE 2.x support
    (fetchpatch {
      url = "https://github.com/zsh-users/zsh/commit/1b421e4978440234fb73117c8505dad1ccc68d46.patch";
      hash = "sha256-jqTXnz56L3X21e3kXtzrT1jKEq+K7ittFjL7GdHVq94=";
      excludes = [ "ChangeLog" ];
    })
    (fetchpatch {
      url = "https://github.com/zsh-users/zsh/commit/b62e911341c8ec7446378b477c47da4256053dc0.patch";
      hash = "sha256-MfyiLucaSNNfdCLutgv/kL/oi/EVoxZVUd1KjGzN9XI=";
      excludes = [ "ChangeLog" ];
    })
    (fetchpatch {
      url = "https://github.com/zsh-users/zsh/commit/10bdbd8b5b0b43445aff23dcd412f25cf6aa328a.patch";
      hash = "sha256-bl1PG9Zk1wK+2mfbCBhD3OEpP8HQboqEO8sLFqX8DmA=";
      excludes = [ "ChangeLog" ];
    })
  ]
  ++ lib.optionals stdenv.cc.isGNU [
    # Fixes compilation with gcc >= 14.
    (fetchpatch {
      url = "https://github.com/zsh-users/zsh/commit/4c89849c98172c951a9def3690e8647dae76308f.patch";
      hash = "sha256-l5IHQuIXo0N6ynLlZoQA7wJd/C7KrW3G7nMzfjQINkw=";
      excludes = [ "ChangeLog" ];
    })
  ];

  strictDeps = true;
  nativeBuildInputs = [
    autoreconfHook
    perl
    groff
    texinfo
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    util-linux
    yodl
  ];

  buildInputs = [
    ncurses
    pcre2
  ];

  env.PCRE_CONFIG = lib.getExe' (lib.getDev pcre2) "pcre2-config";

  configureFlags = [
    "--enable-maildir-support"
    "--enable-multibyte"
    "--with-tcsetpgrp"
    "--enable-pcre"
    "--enable-zshenv=${placeholder "out"}/etc/zshenv"
    "--disable-site-fndir"
    # --enable-function-subdirs is not enabled due to it being slow at runtime in some cases
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform && !stdenv.hostPlatform.isStatic) [
    # Also see: https://github.com/buildroot/buildroot/commit/2f32e668aa880c2d4a2cce6c789b7ca7ed6221ba
    "zsh_cv_shared_environ=yes"
    "zsh_cv_shared_tgetent=yes"
    "zsh_cv_shared_tigetstr=yes"
    "zsh_cv_sys_dynamic_clash_ok=yes"
    "zsh_cv_sys_dynamic_rtld_global=yes"
    "zsh_cv_sys_dynamic_execsyms=yes"
    "zsh_cv_sys_dynamic_strip_exe=yes"
    "zsh_cv_sys_dynamic_strip_lib=yes"
  ];

  # the zsh/zpty module is not available on hydra
  # so skip groups Y Z
  checkFlags = map (T: "TESTNUM=${T}") (lib.stringToCharacters "ABCDEVW");

  # XXX: think/discuss about this, also with respect to nixos vs nix-on-X
  postInstall = ''
        make install.info install.html
        mkdir -p $out/etc/
        cat > $out/etc/zshenv <<EOF
    if test -e /etc/NIXOS; then
      if test -r /etc/zshenv; then
        . /etc/zshenv
      else
        emulate bash
        alias shopt=false
        if [ -z "\$__NIXOS_SET_ENVIRONMENT_DONE" ]; then
          . /etc/set-environment
        fi
        unalias shopt
        emulate zsh
      fi
      if test -r /etc/zshenv.local; then
        . /etc/zshenv.local
      fi
    else
      # on non-nixos we just source the global /etc/zshenv as if we did
      # not use the configure flag
      if test -r /etc/zshenv; then
        . /etc/zshenv
      fi
    fi
    EOF
        ${
          if stdenv.hostPlatform == stdenv.buildPlatform then
            ''
              $out/bin/zsh -c "zcompile $out/etc/zshenv"
            ''
          else
            ''
              ${lib.getBin buildPackages.zsh}/bin/zsh -c "zcompile $out/etc/zshenv"
            ''
        }
        mv $out/etc/zshenv $out/etc/zshenv_zwc_is_used

        rm $out/bin/zsh-${version}
        mkdir -p $out/share/doc/
        mv $out/share/zsh/htmldoc $out/share/doc/zsh-$version
  '';
  # XXX: patch zsh to take zwc if newer _or equal_

  postFixup = ''
    HOST_PATH=$out/bin:$HOST_PATH patchShebangs --host $out/share/zsh/*/functions
  '';

  meta = {
    description = "Z shell";
    longDescription = ''
      Zsh is a UNIX command interpreter (shell) usable as an interactive login
      shell and as a shell script command processor.  Of the standard shells,
      zsh most closely resembles ksh but includes many enhancements.  Zsh has
      command line editing, builtin spelling correction, programmable command
      completion, shell functions (with autoloading), a history mechanism, and
      a host of other features.
    '';
    license = "MIT-like";
    homepage = "https://www.zsh.org/";
    maintainers = with lib.maintainers; [
      pSub
      artturin
    ];
    platforms = lib.platforms.unix;
    mainProgram = "zsh";
  };

  passthru = {
    shellPath = "/bin/zsh";
    tests = {
      inherit (nixosTests) oh-my-zsh;
    };
  };
}
