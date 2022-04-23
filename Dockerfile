FROM nixos/nix
COPY deps.nix /default.nix
RUN nix-build --no-out-link -A pkgs.zip -A python -A pkgs.nodejs -A mustacheJs -A pkgs.imagemagick -A pkgs.haxe -A pkgs.closurecompiler -A buildTest
# For some reason this is necessary to force Nix to fetch everything for the website build
RUN nix-shell -p pkgs.bash --command "echo ok"
