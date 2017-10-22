#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail

codec=libmp3lame
extension=mp3
mode=chaptered
GREP=$(grep --version | grep -q GNU && echo "grep" || echo "ggrep")

if ! [[ $(type -P "$GREP") ]]; then
    echo "$GREP (GNU grep) is not in your PATH"
    echo "Without it, this script will break."
    echo "On macOS, you may want to try: brew install grep"
    exit 1
fi

if [ "$#" -eq 0 ]; then
        echo "Usage: bash AAXtoMP3.sh [--flac] [--single] AUTHCODE {FILES}"
        exit 1
fi

if [[ "$1" = '--flac' ]]
then
    codec=flac
    extension=flac
    shift
fi

if [[ "$1" == '--single' ]]
then
    mode=single
    shift
fi

if [ ! -f .authcode ]; then
    auth_code=$1
    shift
else
    auth_code=`head -1 .authcode`
fi

debug() {
    echo "$(date "+%F %T%z") ${1}"
}

trap 'rm -r -f "${working_directory}"' EXIT
working_directory=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
metadata_file="${working_directory}/metadata.txt"

save_metadata() {
    local media_file
    media_file="$1"
    ffprobe -i "$media_file" 2> "$metadata_file"
}

get_metadata_value() {
    local key
    key="$1"
    normalize_whitespace "$($GREP --max-count=1 --only-matching "${key} *: .*" "$metadata_file" | cut -d : -f 2- | sed -e 's#/##g;s/ (Unabridged)//' | tr -s '[:blank:]' ' ')"
}

get_bitrate() {
    get_metadata_value bitrate | $GREP --only-matching '[0-9]\+'
}

normalize_whitespace() {
    echo $*
}

for path
do
    debug "Decoding ${path} with auth code ${auth_code}..."

    save_metadata "${path}"
    genre=$(get_metadata_value genre)
    artist=$(get_metadata_value artist)
    title=$(get_metadata_value title)
    output_directory="$(dirname "${path}")/${genre}/${artist}/${title}"
    mkdir -p "${output_directory}"
    full_file_path="${output_directory}/${title}.${extension}"

    </dev/null ffmpeg -loglevel error -stats -activation_bytes "${auth_code}" -i "${path}" -vn -codec:a "${codec}" -ab "$(get_bitrate)k" -map_metadata -1 -metadata title="${title}" -metadata artist="${artist}" -metadata album_artist="$(get_metadata_value album_artist)" -metadata album="$(get_metadata_value album)" -metadata date="$(get_metadata_value date)" -metadata track="1/1" -metadata genre="${genre}" -metadata copyright="$(get_metadata_value copyright)" "${full_file_path}"

    debug "Created ${full_file_path}."

    cover_path="${output_directory}/cover.jpg"
    debug "Extracting cover into ${cover_path}..."
    </dev/null ffmpeg -loglevel error -activation_bytes "${auth_code}" -i "${path}" -an -codec:v copy "${cover_path}"

    if [ "${mode}" == "chaptered" ]; then
        chaptercount=$($GREP -Pc "Chapter.*start.*end" $metadata_file)
        debug "Extracting ${chaptercount} chapter files from ${full_file_path}..."

        chapternum=1
        while read -r -u9 first _ _ start _ end
        do
            if [[ "${first}" = "Chapter" ]]
            then
                read -r -u9 _
                read -r -u9 _ _ chapter
                chapter_title="${title} - $(printf %0${#chaptercount}d $chapternum) ${chapter}"
                chapter_file="${output_directory}/${chapter_title}.${extension}"
                </dev/null ffmpeg -loglevel error -stats -i "${full_file_path}" -i "${cover_path}" -ss "${start%?}" -to "${end}" -c copy -map 0:0 -map 1:0 -id3v2_version 3 \
                    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (Front)" -metadata track="${chapternum}" -metadata title="${chapter_title}" \
                    "${chapter_file}"
                chapternum=$((chapternum + 1 ))
            fi
        done 9< "$metadata_file"
        rm "${full_file_path}"
        debug "Done creating chapters. Chaptered files contained in ${output_directory}."
    fi

    debug "Done."
    rm "${metadata_file}"
done
