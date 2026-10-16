{
  pkgs,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
}:
pkgs.wrangler.overrideAttrs (finalAttrs: prevAttrs: {
  version = "4.151.1";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "workers-sdk";
    rev = "wrangler@${finalAttrs.version}";
    hash = "sha256-anGuHPoI0jM0SoG2r19Y6ig4+Xc10xQa6aax1zW6cKo=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit
      (finalAttrs)
      pname
      version
      src
      postPatch
      ;
    pnpm = pkgs.pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-gMosURkv+K3PSbwyhBhzB2k4pP+Gt3Qke2zD7dR7KEM=";
  };

  # the original postBuild specifies packages manually, let's use pnpm's `...` to not have to
  buildPhase = ''
    runHook preBuild

    NODE_ENV="production" pnpm --filter "wrangler..." run build

    runHook postBuild
  '';

  # make workerd available as well as wrangler
  postInstall = ''
    ${prevAttrs.postInstall or ""}

    WORKERD_PATH=$(find "$out/lib/node_modules/.pnpm" -path "*/@cloudflare/workerd-linux-64/bin/workerd" -type f -executable -print -quit)

    if [ -f "$WORKERD_PATH" ]; then
      # need this for `fetch` to work from Astro Actions
      makeWrapper "$WORKERD_PATH" "$out/bin/workerd" --set-default SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    else
      echo "Could not locate workerd binary"
      exit 1
    fi
  '';

  passthru =
    (prevAttrs.passthru or {})
    // {
      updateScript = nix-update-script {
        extraArgs = [
          "--flake"
          "--version-regex"
          "wrangler@(.*)"
        ];
      };
    };
})
