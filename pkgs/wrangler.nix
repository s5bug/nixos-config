{
  pkgs,
  symlinkJoin,
  makeWrapper,
}:
symlinkJoin {
  inherit (pkgs.wrangler) pname version meta;

  paths = [pkgs.wrangler];

  nativeBuildInputs = [makeWrapper];

  postBuild = ''
    WORKERD_PATH=$(find "${pkgs.wrangler}/lib/node_modules/.pnpm" -path "*/@cloudflare/workerd-linux-64/bin/workerd" -type f -executable -print -quit)

    if [ -f "$WORKERD_PATH" ]; then
      # need this for `fetch` to work from Astro Actions
      makeWrapper "$WORKERD_PATH" "$out/bin/workerd" \
        --set-default SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    else
      echo "Could not locate workerd binary"
      exit 1
    fi
  '';
}
