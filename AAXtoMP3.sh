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

for path
do
    debug "Decoding ${path} with AUTHCODE ${auth_code}..."

    ffmpeg -i "${path}" 2> "$metadata_file"
    title=$(grep -a -m1 -h -r "title" "$metadata_file" | head -1 | cut -d: -f2- | xargs echo )
    title=$(echo "${title}" | sed -e 's/ (Unabridged)//' | xargs echo )
    artist=$(grep -a -m1 -h -r "artist" "$metadata_file" | head -1 | cut -d: -f2- | xargs echo )
    genre=$(grep -a -m1 -h -r "genre" "$metadata_file" | head -1 | cut -d: -f2- | xargs echo )
    bitrate=$(grep -a -m1 -h -r "bitrate" "$metadata_file" | head -1 | rev | cut -d: -f 1 | rev | egrep -o [0-9]+ | xargs echo )
    bitrate="${bitrate}k"
    output=$(echo "${title}" | sed -e 's/\:/-/g' | xargs echo )
    output_directory="${genre}/${artist}/${title}"

    ffmpeg -v error -stats -activation_bytes "${auth_code}" -i "${path}" -vn -c:a libmp3lame -ab "${bitrate}" "${output}.mp3"

    debug "Created ${output}.mp3."

    debug "Extracting chaptered mp3 files from ${output}.mp3..."
    mkdir -p "${output_directory}"
    set -x
    while read -r first _ _ start _ end
    do
        if [[ "${first}" = "Chapter" ]]
        then
            read -r
            read -r _ _ chapter
            ffmpeg -v error -stats -i "${output}.mp3" -ss "${start%?}" -to "${end}" -acodec copy "${output} - ${chapter}.mp3" < /dev/null
            mv "${output} - ${chapter}.mp3" "${output_directory}"
            set +x
        fi
    done < "$metadata_file"
    mv "${output}.mp3" "${output_directory}"
    debug "Done creating chapters. Single file and chaptered files contained in ${output_directory}."

    debug "Extracting cover into ${output_directory}/cover.jpg..."
    ffmpeg -v error -activation_bytes "${auth_code}" -i "${path}" -an -vcodec copy "${output_directory}/cover.jpg"
    debug "Done."

    shift
done
