#!/usr/bin/env sh

set -e

rm -rf build dist
mkdir -p build dist dist/images

echo "Generating HTML"
node website/generate-html.js dist
cp -R website/static dist/static
echo "www.hsluv.org" >dist/CNAME
touch dist/.nojekyll # Disable default GitHub pages build

echo "Compiling picker.js"
npx esbuild website/picker.js --bundle --minify --outfile=dist/static/picker.min.js

echo "Generating images"
node website/generate-images.js avatar >build/avatar.pam
node website/generate-images.js favicon >build/favicon.pam
convert build/favicon.pam dist/favicon.png
node website/generate-images.js hsluv >build/hsluv.pam
convert build/hsluv.pam dist/images/hsluv.png
node website/generate-images.js hpluv >build/hpluv.pam
convert build/hpluv.pam dist/images/hpluv.png
node website/generate-images.js hsluv-chroma >build/hsluv-chroma.pam
convert build/hsluv-chroma.pam dist/images/hsluv-chroma.png
node website/generate-images.js cielchuv-chroma >build/cielchuv-chroma.pam
convert build/cielchuv-chroma.pam dist/images/cielchuv-chroma.png
node website/generate-images.js cielchuv >build/cielchuv.pam
convert build/cielchuv.pam dist/images/cielchuv.png
node website/generate-images.js hsl >build/hsl.pam
convert build/hsl.pam dist/images/hsl.png
node website/generate-images.js hsl-lightness >build/hsl-lightness.pam
convert build/hsl-lightness.pam dist/images/hsl-lightness.png
node website/generate-images.js cielchuv-lightness >build/cielchuv-lightness.pam
convert build/cielchuv-lightness.pam dist/images/cielchuv-lightness.png
node website/generate-images.js hsluv-lightness >build/hsluv-lightness.pam
convert build/hsluv-lightness.pam dist/images/hsluv-lightness.png
node website/generate-images.js hpluv-lightness >build/hpluv-lightness.pam
convert build/hpluv-lightness.pam dist/images/hpluv-lightness.png
node website/generate-images.js hsl-chroma >build/hsl-chroma.pam
convert build/hsl-chroma.pam dist/images/hsl-chroma.png
node website/generate-images.js hpluv-chroma >build/hpluv-chroma.pam
convert build/hpluv-chroma.pam dist/images/hpluv-chroma.png
