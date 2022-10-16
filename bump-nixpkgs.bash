#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
shopt -s failglob inherit_errexit

if [[ $# -ne 1 ]]; then
    cat >&2 <<EOF
bump-nixpkgs.bash: Update nixpkgs.json with latest info from given release

Usage:

./bump-nixpkgs.bash RELEASE

Example:

./bump-nixpkgs.bash 22.05
    Bumps nixpkgs within the 22.05 release.
EOF
    exit 2
fi

release="$1"

cleanup() {
    rm --force --recursive "$working_dir"
}
trap cleanup EXIT
working_dir="$(mktemp --directory)"

intermediate_file="${working_dir}/1.json"
full_file="${working_dir}/2.json"
target_file=./nixpkgs.json
curl "https://api.github.com/repos/NixOS/nixpkgs/git/refs/heads/release-${release}" |
    jq '{name: (.ref | split("/")[-1] + "-" + (now|strflocaltime("%Y-%m-%dT%H-%M-%SZ"))), url: ("https://github.com/NixOS/nixpkgs/archive/" + .object.sha + ".tar.gz")}' >"$intermediate_file"
jq '. + {sha256: $hash}' --arg hash "$(nix-prefetch-url --unpack "$(jq --raw-output .url "$intermediate_file")")" "$intermediate_file" >"$full_file"

if diff <(jq 'del(.name)' "$full_file") <(jq 'del(.name)' "$target_file"); then
    echo "No change; aborting." >&2
else
    mv "$full_file" "$target_file"
fi
