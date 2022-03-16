{
	description = "A very basic flake";

	outputs = { self, nixpkgs }:
		let
			version = builtins.substring 0 8 self.lastModifiedDate;
			supportedSystems = [ "x86_64-linux" "x86-linux" "aarch64-linux" ];
			forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
			nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
		in {
			packages = forAllSystems (system:
				let pkgs = nixpkgsFor.${system};
				in {
					gtk4_test = pkgs.rustPlatform.buildRustPackage rec {
						pname = "gtk4_test";
						inherit version;
						src = self;
						cargoSha256 = "sha256-ah8IjShmivS6IWL3ku/4/j+WNr/LdUnh1YJnPdaFdcM=";
						cargoLock.lockFile = "${self}/Cargo.lock";
						buildInputs = with pkgs; [ pkgconfig ];
						nativeBuildInputs = with pkgs; [ gtk4 libadwaita pkgconfig ];
					};
				});

			defaultPackage = forAllSystems (system: self.packages.${system}.gtk4_test);
			defaultApp = forAllSystems (system: {
				type = "app";
				program = "${self.packages.${system}.gtk4_test}/target/release/gtk4_test";
			});
			devShell = forAllSystems (system:
				let
					pkgs = nixpkgsFor.${system};
					gtk4_test = self.packages.${system}.gtk4_test;
				in pkgs.mkShell {
					shellHook = ''PS1="\e[32;1mnix-flake: \e[34m\w \[\033[00m\]\n↳ "'';
					buildInputs = with pkgs; [ rustup ] ++ gtk4_test.buildInputs;
					nativeBuildInputs = gtk4_test.nativeBuildInputs;

				});
		};
}

