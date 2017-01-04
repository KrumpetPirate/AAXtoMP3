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

trap 'rm -f "tmp.txt"' EXIT TERM INT

for path
do
    debug "Decoding ${path} with AUTHCODE ${auth_code}..."

    ffmpeg -i "${path}" 2> tmp.txt
    title=$(grep -a -m1 -h -r "title" tmp.txt | head -1 | cut -d: -f2- | xargs echo )
    title=$(echo "${title}" | sed -e 's/ (Unabridged)//' | xargs echo )
    artist=$(grep -a -m1 -h -r "artist" tmp.txt | head -1 | cut -d: -f2- | xargs echo )
    genre=$(grep -a -m1 -h -r "genre" tmp.txt | head -1 | cut -d: -f2- | xargs echo )
    bitrate=$(grep -a -m1 -h -r "bitrate" tmp.txt | head -1 | rev | cut -d: -f 1 | rev | egrep -o [0-9]+ | xargs echo )
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
    done < tmp.txt
    mv "${output}.mp3" "${output_directory}"
    debug "Done creating chapters. Single file and chaptered files contained in ${output_directory}."

    rm tmp.txt

    debug "Extracting cover into ${output_directory}/cover.jpg..."
    ffmpeg -v error -activation_bytes "${auth_code}" -i "${path}" -an -vcodec copy "${output_directory}/cover.jpg"
    debug "Done."

    shift
done
