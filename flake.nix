{
  description = "Build and development environment for libpointmatcher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Or specify a specific commit/tag
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Build libpointmatcher using libnabo from nixpkgs
        libpointmatcher = pkgs.stdenv.mkDerivation rec {
          pname = "libpointmatcher";
          version = "1.3.2"; # Adjust based on the actual version

          src = ./.; # Use the current directory as source

          nativeBuildInputs = [
            pkgs.cmake
            pkgs.pkg-config
          ];
          buildInputs = [
            pkgs.boost
            pkgs.eigen
            pkgs.libnabo # Use libnabo from nixpkgs
            pkgs.yaml-cpp # Added missing dependency
            pkgs.opencl-headers # Optional
            pkgs.ocl-icd        # Optional
          ];

          # CMake should find libnabo from nixpkgs via pkg-config
          cmakeFlags = [
            "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
            # Add other libpointmatcher CMake flags as needed
            # e.g., -DUSE_OPENMP=ON, -DUSE_OPENCL=ON
          ];

          # Filter source to avoid infinite recursion if src = ./.;
          # This might need adjustment based on actual source layout and build process
          # src = pkgs.lib.sources.cleanSourceWith {
          #   src = ./.;
          #   filter = name: type:
          #     let baseName = baseNameOf (toString name);
          #     in !(
          #       # Exclude build directories, git files, nix files etc.
          #       baseName == "build" ||
          #       baseName == ".git" ||
          #       baseName == "flake.nix" ||
          #       baseName == "flake.lock" ||
          #       # Add other exclusions if necessary
          #       pkgs.lib.hasSuffix ".o" baseName ||
          #       pkgs.lib.hasSuffix ".a" baseName ||
          #       pkgs.lib.hasSuffix ".so" baseName
          #     );
          # };


          meta = with pkgs.lib; {
            description = "An Iterative Closest Point library";
            homepage = "https://github.com/ethz-asl/libpointmatcher";
            # license = licenses.bsd3; # Add appropriate license
          };
        };

      in
      {
        # Expose the built library as a package
        packages = {
          inherit libpointmatcher;
          default = libpointmatcher;
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          name = "libpointmatcher-dev";

          # Include build tools and dependencies needed for development
          packages = with pkgs; [
            # Build tools
            cmake
            gcc # Or clang
            gdb # Optional debugger
            pkg-config
            ncurses

            # Dependencies (using versions from nixpkgs)
            boost
            eigen
            libnabo # Use libnabo from nixpkgs
            yaml-cpp # Added missing dependency
            opencl-headers
            ocl-icd
          ];

          # Optionally include the locally built libpointmatcher in the shell
          # inputsFrom = [ self.packages.${system}.libpointmatcher ];

          # Environment variables (CMake should find dependencies via pkg-config)
          # BOOST_ROOT = "${pkgs.boost}";
          # EIGEN_ROOT = "${pkgs.eigen}";

          # Shell hooks (optional)
          # shellHook = ''
          #   echo "Entering libpointmatcher development shell..."
          # '';
        };
      }
    );
}
