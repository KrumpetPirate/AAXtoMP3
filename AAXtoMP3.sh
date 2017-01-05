#!/usr/bin/env bash
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
    ffmpeg -i "${path}" 2> "$metadata_file"
}

get_metadata_value() {
    key="$1"
    grep --max-count=1 --only-matching "${key} *: .*" "$metadata_file" | cut --delimiter=: --fields=2 | sed -e 's#/##g;s/ (Unabridged)//' | xargs
}

get_bitrate() {
    get_metadata_value bitrate | grep --only-matching '[0-9]\+'
}

for path
do
    debug "Decoding ${path} with AUTHCODE ${auth_code}..."

    save_metadata
    title=$(get_metadata_value title)
    output_directory="$(get_metadata_value genre)/$(get_metadata_value artist)/${title}"

    ffmpeg -loglevel error -stats -activation_bytes "${auth_code}" -i "${path}" -vn -codec:a libmp3lame -ab "$(get_bitrate)k" "${title}.mp3"

    debug "Created ${title}.mp3."

    debug "Extracting chaptered mp3 files from ${title}.mp3..."
    mkdir -p "${output_directory}"
    set -x
    while read -r first _ _ start _ end
    do
        if [[ "${first}" = "Chapter" ]]
        then
            read -r
            read -r _ _ chapter
            ffmpeg -loglevel error -stats -i "${title}.mp3" -ss "${start%?}" -to "${end}" -codec:a copy "${title} - ${chapter}.mp3" < /dev/null
            mv "${title} - ${chapter}.mp3" "${output_directory}"
            set +x
        fi
    done < "$metadata_file"
    mv "${title}.mp3" "${output_directory}"
    debug "Done creating chapters. Single file and chaptered files contained in ${output_directory}."

    debug "Extracting cover into ${output_directory}/cover.jpg..."
    ffmpeg -loglevel error -activation_bytes "${auth_code}" -i "${path}" -an -codec:v copy "${output_directory}/cover.jpg"
    debug "Done."

    shift
done
