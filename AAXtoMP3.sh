#!/usr/bin/env bash
AUTHCODE=$1
shift

if ! command -v ffmpeg 2> /dev/null ; then
    date "+%F %Tz ABORT: ffmpeg is missing"
    exit 1
fi

while [ $# -gt 0 ]; do
    FILE="$1"
    echo "$(date "+%F %T%z") Decoding ${FILE} with AUTHCODE ${AUTHCODE}..."

    ffmpeg -i "${FILE}" 2> tmp.txt
    TITLE=$(grep -a -m1 -h -r "title" tmp.txt | head -1 | cut -d: -f2- | xargs echo )
    TITLE=$(echo "${TITLE}" | sed -e 's/ (Unabridged)//' | xargs echo )
    ARTIST=$(grep -a -m1 -h -r "artist" tmp.txt | head -1 | cut -d: -f2- | xargs echo )
    GENRE=$(grep -a -m1 -h -r "genre" tmp.txt | head -1 | cut -d: -f2- | xargs echo )
    BITRATE=$(grep -a -m1 -h -r "bitrate" tmp.txt | head -1 | rev | cut -d: -f 1 | rev | egrep -o [0-9]+ | xargs echo )
    BITRATE="${BITRATE}k"
    OUTPUT=$(echo "${TITLE}" | sed -e 's/\:/-/g' | xargs echo )
    OUTPUT_DIR="${GENRE}/${ARTIST}/${TITLE}"

    ffmpeg -v error -stats -activation_bytes "${AUTHCODE}" -i "${FILE}" -vn -c:a libmp3lame -ab "${BITRATE}" "${OUTPUT}.mp3"

    echo "$(date "+%F %T%z") Created ${OUTPUT}.mp3."

    echo "$(date "+%F %T%z") Extracting chaptered mp3 files from ${OUTPUT}.mp3..."
    mkdir -p "${OUTPUT_DIR}"
    set -x
    while read -r first _ _ start _ end; do
        if [[ "${first}" = "Chapter" ]]; then
            read
            read _ _ chapter
            ffmpeg -v error -stats -i "${OUTPUT}.mp3" -ss "${start%?}" -to "${end}" -acodec copy "${OUTPUT} - ${chapter}.mp3" < /dev/null
            mv "${OUTPUT} - ${chapter}.mp3" "${OUTPUT_DIR}"
            set +x
        fi
    done < tmp.txt
    mv "${OUTPUT}.mp3" "${OUTPUT_DIR}"
    echo "$(date "+%F %T%z") Done creating chapters. Single file and chaptered files contained in ${OUTPUT_DIR}."

    rm tmp.txt

    echo "$(date "+%F %T%z") Extracting cover into ${OUTPUT_DIR}/cover.jpg..."
    ffmpeg -v error -activation_bytes "${AUTHCODE}" -i "${FILE}" -an -vcodec copy "${OUTPUT_DIR}/cover.jpg"
    echo "$(date "+%F %T%z") Done."

    shift
done
