#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail

auth_code=$1
shift

codec=libmp3lame
extension=mp3

debug() {
    echo "$(date "+%F %T%z") ${1}"
}

trap 'rm --recursive --force "${working_directory}"' EXIT
working_directory="$(mktemp --directory)"
metadata_file="${working_directory}/metadata.txt"

save_metadata() {
    local media_file
    media_file="$1"
    ffprobe -i "$media_file" 2> "$metadata_file"
}

get_metadata_value() {
    local key
    key="$1"
    normalize_whitespace "$(grep --max-count=1 --only-matching "${key} *: .*" "$metadata_file" | cut --delimiter=: --fields=2 | sed -e 's#/##g;s/ (Unabridged)//' | tr -s '[:blank:]' ' ')"
}

get_bitrate() {
    get_metadata_value bitrate | grep --only-matching '[0-9]\+'
}

normalize_whitespace() {
    echo $*
}

for path
do
    debug "Decoding ${path} with auth code ${auth_code}..."

    save_metadata "${path}"
    title=$(get_metadata_value title)
    output_directory="$(get_metadata_value genre)/$(get_metadata_value artist)/${title}"
    mkdir -p "${output_directory}"
    full_file_path="${output_directory}/${title}.${extension}"
    ffmpeg -loglevel error -stats -activation_bytes "${auth_code}" -i "${path}" -vn -codec:a "${codec}" -ab "$(get_bitrate)k" "${full_file_path}"

    debug "Created ${full_file_path}."

    debug "Extracting chapter files from ${full_file_path}..."

    while read -r -u9 first _ _ start _ end
    do
        if [[ "${first}" = "Chapter" ]]
        then
            read -r -u9 _
            read -r -u9 _ _ chapter
            chapter_file="${output_directory}/${title} - ${chapter}.${extension}"
            ffmpeg -loglevel error -stats -i "${full_file_path}" -ss "${start%?}" -to "${end}" -codec:a copy "${chapter_file}"
        fi
    done 9< "$metadata_file"
    debug "Done creating chapters. Single file and chaptered files contained in ${output_directory}."

    cover_path="${output_directory}/cover.jpg"
    debug "Extracting cover into ${cover_path}..."
    ffmpeg -loglevel error -activation_bytes "${auth_code}" -i "${path}" -an -codec:v copy "${cover_path}"
    debug "Done."
done
