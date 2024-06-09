{ lib
, stdenv
, pkgs
, callPackage
, fetchFromGitHub
, fetchurl
, buildGoModule
, makeWrapper
, breakpointHook
, jq
, curl
, kubectl
, eksctl
, kind
, k3sup
, coreutils
}:

let
  branch = "3.0.0";
  version = "3.0.1-beta.2405292059";
in
buildGoModule rec {
  pname = "nuv";
  inherit version;

  src = fetchFromGitHub {
    owner = "nuvolaris";
    repo = "nuv";
    rev = version;
    hash = "sha256-MdnBvlA4S2Mi/bcbE+O02x+wvlIrsK1Zc0dySz4FB/w=";
  };

  subPackages = [ "." ];
  vendorHash = "sha256-JkQbQ2NEaumXbAfsv0fNiQf/EwMs3SDLHvu7c/bU7fU=";

  nativeBuildInputs = [ makeWrapper jq curl breakpointHook ];

  buildInputs = [ kubectl eksctl kind k3sup coreutils ];

  ldflags = [
    "-X main.NuvVersion=${version}"
    "-X main.NuvBranch=${branch}"
  ];

  # false because tests require some modificationsrun inside nix-env
  doCheck = false;

  postInstall = ''
    makeWrapper ${coreutils}/bin/coreutils $out/bin/coreutils
    makeWrapper ${kubectl}/bin/kubectl $out/bin/kubectl
    makeWrapper ${eksctl}/bin/eksctl $out/bin/eksctl
    makeWrapper ${kind}/bin/kind $out/bin/kind
    makeWrapper ${k3sup}/bin/k3sup $out/bin/k3sup
  '';

  passthru.tests = {
    simple = callPackage ./tests.nix { inherit pname version; };
  };

  meta = {
    homepage = "https://nuvolaris.io/";
    description = "Nuvolaris Almighty CLI tool";
    license = lib.licenses.asl20;
    mainProgram = "nuv";
    maintainers = with lib.maintainers; [ msciabarra d4rkstar ];
  };
}
