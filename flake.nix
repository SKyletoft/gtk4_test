{
	description = "The relm4 libadwaita demo";

	inputs = {
		nixpkgs.url     = "github:nixos/nixpkgs/nixpkgs-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem(system:
			let pkgs = nixpkgs.legacyPackages.${system};
			in rec {
				gtk4_test = pkgs.rustPlatform.buildRustPackage {
					pname              = "gtk4_test";
					version            = "0.0.1";
					src                = self;
					cargoSha256        = "sha256-ah8IjShmivS6IWL3ku/4/j+WNr/LdUnh1YJnPdaFdcM=";
					cargoLock.lockFile = "${self}/Cargo.lock";
					nativeBuildInputs  = with pkgs; [ pkg-config ];
					buildInputs        = with pkgs; [ gtk4 libadwaita ];
				};
				defaultPackage = gtk4_test;
				devShell = pkgs.mkShell {
					shellHook         = ''PS1="\e[32;1mnix-flake: \e[34m\w \[\033[00m\]\n↳ "'';
					buildInputs       = gtk4_test.buildInputs;
					nativeBuildInputs = with pkgs; [ rustup ] ++ gtk4_test.nativeBuildInputs;
				};
			}
		);
}

