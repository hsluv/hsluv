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
node website/generate-images.js avatar200 >build/avatar200.pam
node website/generate-images.js avatar500 >build/avatar500.pam
magick build/avatar200.pam dist/static/images/avatar200.jpeg
magick build/avatar200.pam dist/static/images/avatar200.png
magick build/avatar500.pam dist/static/images/avatar500.jpeg
magick build/avatar500.pam dist/static/images/avatar500.png
node website/generate-images.js favicon >build/favicon.pam
magick build/favicon.pam dist/favicon.png
node website/generate-images.js hsluv >build/hsluv.pam
magick build/hsluv.pam dist/images/hsluv.png
node website/generate-images.js hpluv >build/hpluv.pam
magick build/hpluv.pam dist/images/hpluv.png
node website/generate-images.js hsluv-chroma >build/hsluv-chroma.pam
magick build/hsluv-chroma.pam dist/images/hsluv-chroma.png
node website/generate-images.js cielchuv-chroma >build/cielchuv-chroma.pam
magick build/cielchuv-chroma.pam dist/images/cielchuv-chroma.png
node website/generate-images.js cielchuv >build/cielchuv.pam
magick build/cielchuv.pam dist/images/cielchuv.png
node website/generate-images.js hsl >build/hsl.pam
magick build/hsl.pam dist/images/hsl.png
node website/generate-images.js hsl-lightness >build/hsl-lightness.pam
magick build/hsl-lightness.pam dist/images/hsl-lightness.png
node website/generate-images.js cielchuv-lightness >build/cielchuv-lightness.pam
magick build/cielchuv-lightness.pam dist/images/cielchuv-lightness.png
node website/generate-images.js hsluv-lightness >build/hsluv-lightness.pam
magick build/hsluv-lightness.pam dist/images/hsluv-lightness.png
node website/generate-images.js hpluv-lightness >build/hpluv-lightness.pam
magick build/hpluv-lightness.pam dist/images/hpluv-lightness.png
node website/generate-images.js hsl-chroma >build/hsl-chroma.pam
magick build/hsl-chroma.pam dist/images/hsl-chroma.png
node website/generate-images.js hpluv-chroma >build/hpluv-chroma.pam
magick build/hpluv-chroma.pam dist/images/hpluv-chroma.png
