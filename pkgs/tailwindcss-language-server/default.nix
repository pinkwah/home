{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_latest,
  pnpm_9,
  cacert,
}:

let
  version = "0.14.17";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tailwindcss-language-server";
  inherit version;

  src = fetchFromGitHub {
    owner = "tailwindlabs";
    repo = "tailwindcss-intellisense";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1NFBywVFmymTXgNx/MnedtvtG43nMPJrcFxwYLSDNo0=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      prePnpmInstall
      ;
    hash = "sha256-TxWaapm/nkyMi3JCj6TE56DhJYPBWBDGXOnzgB9uPjs=";
  };

  nativeBuildInputs = [
    nodejs_latest
    pnpm_9.configHook
  ];

  buildInputs = [
    nodejs_latest
  ];

  pnpmWorkspaces = [ "@tailwindcss/language-server..." ];
  prePnpmInstall = ''
    # Warning section for "pnpm@v8"
    # https://pnpm.io/cli/install#--filter-package_selector
    pnpm config set dedupe-peer-dependents false
    export NODE_EXTRA_CA_CERTS="${cacert}/etc/ssl/certs/ca-bundle.crt"
  '';

  buildPhase = ''
    runHook preBuild

    # Must build the "@tailwindcss/language-service" package. Dependency is linked via workspace by "pnpm"
    # (https://github.com/tailwindlabs/tailwindcss-intellisense/blob/%40tailwindcss/language-server%40v0.0.27/pnpm-lock.yaml#L47)
    pnpm --filter "@tailwindcss/language-server..." build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/tailwindcss-language-server}
    cp -r {packages,node_modules} $out/lib/tailwindcss-language-server
    chmod +x $out/lib/tailwindcss-language-server/packages/tailwindcss-language-server/bin/tailwindcss-language-server
    ln -s $out/lib/tailwindcss-language-server/packages/tailwindcss-language-server/bin/tailwindcss-language-server $out/bin/tailwindcss-language-server

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tailwind CSS Language Server";
    homepage = "https://github.com/tailwindlabs/tailwindcss-intellisense";
    license = licenses.mit;
    maintainers = with maintainers; [ happysalada ];
    mainProgram = "tailwindcss-language-server";
    platforms = platforms.all;
  };
})

