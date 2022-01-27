#!/usr/bin/env bash
set -e
set -u
set -o pipefail

this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
download_dir="$(mktemp -d)"
publish_dir="$(mktemp -d)"

echo "Downloading lottie-web..."
cd "$download_dir"
npm pack lottie-web --json > /dev/null # --json outputs to stdout
tar xzf lottie-web*.tgz

echo "Copying files to publish directory..."
cp "$this_dir/README.md" "$publish_dir"
cp "$download_dir/package/index.d.ts" "$publish_dir"
cp "$download_dir/package/build/player/lottie_light.js" "$publish_dir/index.js"

echo "Creating package.json..."
node -p "JSON.stringify({
  ...require('$this_dir/base_package.json'),
  version: require('$download_dir/package/package.json').version,
})" > "$publish_dir/package.json"

echo "Creating license..."
cat "$this_dir/license_prefix.txt" "$download_dir/package/LICENSE.md" > "$publish_dir/LICENSE.txt"

echo "Publishing..."
cd "$publish_dir"
npm publish --access=public
