{
  description = "wgrib2 Flake";


  inputs.flake-utils.url = "github:numtide/flake-utils";      

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; 
          wgrib2_version = "3.1.1";
          wgrib2_sha256 = "sha256:1p923b34zv761pvpgyrl8nr2z2bqi4zpknsf7spr3zy48y276n91";  

          src = fetchTarball {
            url = "https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz.v${wgrib2_version}";
            sha256 = wgrib2_sha256;
          };
      in
      rec {
        packages = {
          wgrib2 = pkgs.stdenv.mkDerivation {
            name = "wgrib2";
            version = wgrib2_version;
            src = src;
            CC = "gcc";
            FC = "gfortran";                        
            patches = [ ./makefile.patch ];
            buildInputs = [ pkgs.gfortran pkgs.gfortran.cc ];
            buildPhase = ''
              make
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp wgrib2/wgrib2 $out/bin
            '';          
          };
        };
        devShell = pkgs.mkShell {
          buildInputs = self.packages.wgrib2.buildInputs;        
        };
        defaultPackage = packages.wgrib2;
        apps.wgrib2 = flake-utils.lib.mkApp { drv = packages.wgrib2; };
        defaultApp = apps.wgrib2;
      }
    );

}
