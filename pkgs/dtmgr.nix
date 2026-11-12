{
  callPackage,
  dtmgr-pkg,
}:
(callPackage "${dtmgr-pkg}/package.nix" {}).overrideAttrs {
  inherit (dtmgr-pkg) version src;
}
