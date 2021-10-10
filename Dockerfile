# We are using this image with arm64 build that works on my M1 Mac
# Praise @Silex! https://github.com/NixOS/docker/issues/28#issuecomment-867135765
FROM silex/nix
COPY deps.nix /default.nix
RUN nix-build --no-out-link -A pkgs.zip -A python -A pkgs.nodejs -A mustacheJs -A pkgs.imagemagick -A pkgs.haxe -A pkgs.closurecompiler -A buildTest
# For some reason this is necessary to force Nix to fetch everything for the website build
RUN nix-shell -p pkgs.bash --command "echo ok"
