#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail

auth_code=$1
shift

debug() {
    echo "$(date "+%F %T%z") ${1}"
}

if ! command -v ffmpeg 2> /dev/null
then
    debug "ABORT: ffmpeg is missing"
    exit 1
fi

trap 'rm --recursive --force "${working_directory}"' EXIT
working_directory="$(mktemp --directory)"
metadata_file="${working_directory}/metadata.txt"

save_metadata() {
    ffprobe -i "$1" 2> "$metadata_file"
}

get_metadata_value() {
    key="$1"
    grep --max-count=1 --only-matching "${key} *: .*" "$metadata_file" | cut --delimiter=: --fields=2 | sed -e 's#/##g;s/ (Unabridged)//' | xargs -0
}

get_bitrate() {
    get_metadata_value bitrate | grep --only-matching '[0-9]\+'
}

for path
do
    debug "Decoding ${path} with AUTHCODE ${auth_code}..."

    save_metadata "${path}"
    title=$(get_metadata_value title)
    output_directory="$(get_metadata_value genre)/$(get_metadata_value artist)/${title}"

    ffmpeg -loglevel error -stats -activation_bytes "${auth_code}" -i "${path}" -vn -codec:a libmp3lame -ab "$(get_bitrate)k" "${title}.mp3"

    debug "Created ${title}.mp3."

    debug "Extracting chaptered mp3 files from ${title}.mp3..."
    mkdir -p "${output_directory}"

    while read -r -u9 first _ _ start _ end
    do
        if [[ "${first}" = "Chapter" ]]
        then
            read -r -u9 _
            read -r -u9 _ _ chapter
            ffmpeg -loglevel error -stats -i "${title}.mp3" -ss "${start%?}" -to "${end}" -codec:a copy "${title} - ${chapter}.mp3"
            mv "${title} - ${chapter}.mp3" "${output_directory}"
        fi
    done 9< "$metadata_file"
    mv "${title}.mp3" "${output_directory}"
    debug "Done creating chapters. Single file and chaptered files contained in ${output_directory}."

    debug "Extracting cover into ${output_directory}/cover.jpg..."
    ffmpeg -loglevel error -activation_bytes "${auth_code}" -i "${path}" -an -codec:v copy "${output_directory}/cover.jpg"
    debug "Done."
done
