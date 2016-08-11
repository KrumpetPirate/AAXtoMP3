#!/usr/bin/env bash
AUTHCODE=$1
shift
while [ $# -gt 0 ]; do
    FILE=$1
    echo "Decoding $FILE with AUTHCODE $AUTHCODE..."

    ffmpeg -i "$FILE" 2> tmp.txt
    TITLE=`grep -a -m1 -h -r "title" tmp.txt | head -1 | cut -d: -f2- | xargs -0`
    TITLE=`echo $TITLE | sed -e 's/(Unabridged)//' | xargs -0`
    ARTIST=`grep -a -m1 -h -r "artist" tmp.txt | head -1 | cut -d: -f2- | xargs`
    GENRE=`grep -a -m1 -h -r "genre" tmp.txt | head -1 | cut -d: -f2- | xargs`
    BITRATE=`grep -a -m1 -h -r "bitrate" tmp.txt | head -1 | rev | cut -d: -f 1 | rev | egrep -o [0-9]+ | xargs`
    BITRATE="${BITRATE}k"
    OUTPUT=`echo $TITLE | sed -e 's/\:/-/g' | xargs -0`
    OUTPUT_DIR="${GENRE}/${ARTIST}/${TITLE}"

    ffmpeg -v error -stats -activation_bytes $AUTHCODE -i "${FILE}" -vn -c:a libmp3lame -ab $BITRATE "${OUTPUT}.mp3"

    echo "Created ${OUTPUT}.mp3."

    echo "Extracting chaptered mp3 files from ${OUTPUT}.mp3..."
    mkdir -p "${OUTPUT_DIR}"
    while read -r first _ _ start _ end; do
        if [[ $first = Chapter ]]; then
            read
            read _ _ chapter
            ffmpeg -v error -stats -i "${OUTPUT}.mp3" -ss "${start%?}" -to "$end" -acodec copy "${OUTPUT} - $chapter.mp3" < /dev/null
            mv "${OUTPUT} - $chapter.mp3" "${OUTPUT_DIR}"
        fi
    done < tmp.txt
    mv "${OUTPUT}.mp3" "${OUTPUT_DIR}"
    echo "Done creating chapters. Single file and chaptered files contained in ${OUTPUT_DIR}."

    rm tmp.txt

    echo "Extracting cover into ${OUTPUT_DIR}/cover.jpg..."
    ffmpeg -v error -activation_bytes $AUTHCODE -i "$FILE" -an -vcodec copy "${OUTPUT_DIR}/cover.jpg"
    echo "Done."

    shift
done
