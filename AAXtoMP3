#!/usr/bin/env bash


# ========================================================================
# Command Line Options

# Usage Synopsis.
usage=$'\nUsage: AAXtoMP3 [--flac] [--aac] [--opus ] [--single] [--chaptered]\n[-e:m4a] [-e:m4b] [--authcode <AUTHCODE>] [--output_dir <PATH>] {FILES}\n'
codec=libmp3lame            # Default encoder.
extension=mp3               # Default encoder extention.
mode=chaptered              # Multi file output
auth_code=                  # Required to be set via file or option.
targetdir=                  # Optional output location.  Note default is basedir of AAX file.
DEBUG=0                     # Default off, If set extremely verbose output.
container=mp3               # Just in case we need to change the container.  Used for M4A to M4B

# -----
# Code tip Do not have any script above this point that calls a function or a binary.  If you do
# the $1 will no longer be a ARGV element.  So you should only do basic variable setting above here.
#
# Process the command line options.  This allows for un-ordered options. Sorta like a getops style
while true; do
  case "$1" in 
                      # Flac encoding
    -f | --flac       ) codec=flac; extension=flac; mode=single; container=flac;    shift ;;        
                      # Apple m4a music format.
    -a | --aac        ) codec=copy; extension=m4a; mode=single; container=m4a;      shift ;;        
                      # Ogg Format
    -o | --opus       ) codec=libopus; extension=ogg; container=flac;               shift ;;        
                      # If appropriate use only a single file output.
    -s | --single     ) mode=single;                                                shift ;;        
                      # If appropriate use only a single file output.
    -c | --chaptered  ) mode=chaptered;                                             shift ;;
                      # This is the same as --single option.
    -e:mp3            ) codec=libmp3lame; extension=mp3; mode=single; container=mp3; shift ;;
                      # Identical to --acc option.
    -e:m4a            ) codec=copy; extension=m4a; mode=single; container=m4a;      shift ;;
                      # Similiar to --aac but specific to audio books
    -e:m4b            ) codec=copy; extension=m4a; mode=single; container=m4b;      shift ;;
                      # Change the working dir from AAX directory to what you choose.
    -t | --target_dir ) targetdir="$2";                                             shift 2 ;;      
                      # Authorization code associate with the AAX file(s)
    -A | --authcode   ) auth_code="$2";                                             shift 2 ;;      
                      # Extremely verbose output.
    -d | --debug      ) DEBUG=1;                                                    shift ;;        
                      # Command synopsis.
    -h | --help       ) printf "$usage" $0 ;                                        exit ;;         
                      # Standard flag signifying the end of command line processing.
    --                )                                                             shift; break ;; 
                      # Anything else stops command line processing.
    *                 )                                                             break ;;        

  esac
done

# -----
# Empty argv means we have nothing to do so lets bark some help.
if [ "$#" -eq 0 ]; then
  printf "$usage" $0
  exit 1
fi

# ========================================================================
# Variable validation
set -o errexit -o noclobber -o nounset -o pipefail

# -----
# Detect which annoying version fo grep we have
GREP=$(grep --version | grep -q GNU && echo "grep" || echo "ggrep")
if ! [[ $(type -P "$GREP") ]]; then
  echo "$GREP (GNU grep) is not in your PATH"
  echo "Without it, this script will break."
  echo "On macOS, you may want to try: brew install grep"
  exit 1
fi

# -----
# Detect if we need mp4art for cover additions to m4a & m4b files.
if [[ "x${extension}" == "xm4a" && "x$(type -P mp4art)" == "x" ]]; then
  echo "WARN mp4art was not found on your env PATH variable"
  echo "Without it, this script will not be able to add cover art to"
  echo "m4b files. Note if there are no other errors the AAXtoMP3 will"
  echo "continue. However no cover art will be added to the output."
  echo "INSTALL:" 
  echo "MacOS:   brew install mp4v2"
  echo "Ubuntu:  sudo apt-get install mp4v2-utils"
fi

# -----
# Obtain the authcode from either the command line,  local directory or home directory.
# See Readme.md for details on how to aquire your personal authcode for your personal
# audible AAX files.
if [ -z $auth_code ]; then
  if [ -r .authcode ]; then
    auth_code=`head -1 .authcode`
  elif [ -r ~/.authcode ]; then
    auth_code=`head -1 ~/.authcode`
  fi
fi
# No point going on if no authcode found.
if [ -z $auth_code ]; then
  echo "ERROR Missing authcode"
  echo "$usage"
  exit 1  
fi

# -----
# Check the target dir for if set if it is writable
if [[ "x${targetdir}" != "x"  ]]; then 
  if [[ ! -w "${targetdir}" || ! -d "${targetdir}" ]] ; then
    echo "ERROR Target Directory is not writable: \"$targetdir\""
    echo "$usage"
    exit 1 
  fi
fi

# ========================================================================
# Utility Functions

# -----
# debug
debug() {
  if [ $DEBUG == 1 ] ; then
    echo "$(date "+%F %T%z") DEBUG ${1}"
  fi
}

# -----
# debug dump contents of a file to STDOUT
debug_file() {
  if [ $DEBUG == 1 ] ; then
    echo "$(date "+%F %T%z") DEBUG"
    echo "================================================================================"
    cat "${1}"
    echo "================================================================================"
  fi
}

# -----
# log
log() {
  echo "$(date "+%F %T%z") ${1}"
}

# -----
# Clean up if someone hits ^c
trap 'rm -r -f "${working_directory}"' EXIT
working_directory=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
metadata_file="${working_directory}/metadata.txt"

# -----
# Inspect the AAX and extract the metadata associated with the file.
save_metadata() {
  local media_file
  media_file="$1"
  ffprobe -i "$media_file" 2> "$metadata_file"
  debug "Metadata file $metadata_file"
  debug_file "$metadata_file"
}

# -----
# Reach into the meta data and extract a specific value.
#   Note the white space clean up could be well cleaner.
get_metadata_value() {
  local key
  key="$1"
  normalize_whitespace "$($GREP --max-count=1 --only-matching "${key} *: .*" "$metadata_file" | cut -d : -f 2- | sed -e 's#/##g;s/ (Unabridged)//' | tr -s '[:blank:]' ' ')"
}

# -----
# specific varient of get_metadata_value bitrate is important for transcoding.
get_bitrate() {
  get_metadata_value bitrate | $GREP --only-matching '[0-9]\+'
}

# -----
# simple function to turn tabs and multiple spaces into a single space.
normalize_whitespace() {
  echo $*
}

# ========================================================================
# Main Transcode Loop
for path
do
  log "Decoding ${path} with auth code ${auth_code}..."

  # Check for Presense of Audiobook.  Note this break the processing of 
  # of a list of books once a single missing file is found.
  if [[ ! -r "${path}" ]] ; then 
    echo "ERROR: Input Audiobook file $path missing"
    exit 1
  fi

  # -----
  # Make sure everything is a variable.  Simplifying Command interpretation
  save_metadata "${path}"
  genre=$(get_metadata_value genre)
  artist=$(get_metadata_value artist)
  title=$(get_metadata_value title | sed 's/'\:'/'-'/g' | sed 's/  / /g' | sed 's/- /-/g' | xargs -0)
  if [ "x${targetdir}" != "x" ] ; then
    output_directory="${targetdir}/${genre}/${artist}/${title}"
  else
    output_directory="$(dirname "${path}")/${genre}/${artist}/${title}"
  fi
  full_file_path="${output_directory}/${title}.${extension}"
  bitrate="$(get_bitrate)k"
  album_artist="$(get_metadata_value album_artist)"
  album="$(get_metadata_value album)"
  album_date="$(get_metadata_value date)"
  copyright="$(get_metadata_value copyright)"

  mkdir -p "${output_directory}"

  # Big long DEBUG output.  Fully describes the settings used for transcoding.  I could probably do this better.
  # Not this is a long debug command. It's not critical to operation. It's purely for people debugging
  # and coders wanting to extend the script.
  debug "$(printf '\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %sn%-18s: %s' title "${title}" auth_code "${auth_code}" mode "${mode}" path "${path}" container ${container} codec "${codec}" bitrate "${bitrate}" artist "${artist}" album_artist "${album_artist}" album "${album}" album_date "${album_date}" genre "${genre}" copyright "${copyright}" full_file_path "${full_file_path}" metadata_file "${metadata_file}" working_directory "${working_directory}" )"

  # -----
  # This is the main work horse command.  This is the primary transcoder.
  # This is the primary transcode. All the heavy lifting is here.
  </dev/null ffmpeg -loglevel error -stats -activation_bytes "${auth_code}" -i "${path}" -vn -codec:a "${codec}" -ab ${bitrate} -map_metadata -1 -metadata title="${title}" -metadata artist="${artist}" -metadata album_artist="${album_artist}" -metadata album="${album}" -metadata date="${album_date}" -metadata track="1/1" -metadata genre="${genre}" -metadata copyright="${copyright}" "${full_file_path}"

  log "Created ${full_file_path}."
  # -----

  # Grab the cover art if available.
  cover_path="${output_directory}/cover.jpg"
  log "Extracting cover into ${cover_path}..."
  </dev/null ffmpeg -loglevel error -activation_bytes "${auth_code}" -i "${path}" -an -codec:v copy "${cover_path}"    

  # -----
  # OK now spit the file if that's what you want.
  # If we want multiple file we take the big mp3 and split it by chapter.
  # Not all audio encodings make sense with multiple chapter outputs.  See options section
  # for more detail
  if [ "${mode}" == "chaptered" ]; then
    # Playlist m3u support
    playlist_file="${output_directory}/${title}.m3u"
    log "Creating PlayList ${title}.m3u"
    echo '#EXTM3U' > "${playlist_file}"

    # Determine the number of chapters.
    chaptercount=$($GREP -Pc "Chapter.*start.*end" $metadata_file)
    log "Extracting ${chaptercount} chapter files from ${full_file_path}..."

    chapternum=1
    while read -r -u9 first _ _ start _ end
    do
      if [[ "${first}" = "Chapter" ]]; then
        read -r -u9 _
        read -r -u9 _ _ chapter

        # The formating of the chapters names and the file names.  
        # Chapter names are used in a few place.
        chapter_title="${title}-$(printf %0${#chaptercount}d $chapternum) ${chapter}"
        chapter_file="${output_directory}/${chapter_title}.${extension}"

                
        # the ID3 tags must only be specified for *.mp3 files,
        # the other container formats come with their own
        # tagging mechanisms.
        id3_version_param=""
        if test "${extension}" = "mp3"; then
          id3_version_param="-id3v2_version 3"
        fi

        # Big Long chapter debug  I could probably do this better.
        debug "$(printf '\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s\n%-18s: %s' cover_path "${cover_path}" start "${start%?}" end "${end}" id3_version_param "${id3_version_param}" chapternum "${chapternum}" chapter_title "${chapter_title}" chapter_file "${chapter_file}" )"

        # Extract chapter by time stamps start and finish of chapter.
        # This extracts based on time stamps start and end.
        log "Spliting chapter ${chapternum} start:${start%?}(s) end:${end}(s)"
        </dev/null ffmpeg -loglevel quiet -nostats -i "${full_file_path}" -i "${cover_path}" -ss "${start%?}" -to "${end}" -map 0:0 -map 1:0 -acodec copy ${id3_version_param} \
        -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (Front)" -metadata track="${chapternum}" -metadata title="${chapter_title}" \
        "${chapter_file}"
        
        # -----
        # OK lets get what need for the next chapter in the Playlist m3u file.
        # Playlist creation.        
        duration=$(echo "${end} - ${start%?}" | bc)
        echo "#EXTINF:${duration%.*},${title} - ${chapter}" >>  "${playlist_file}"
        echo "${chapter_title}.${container}" >> "${playlist_file}"
        chapternum=$((chapternum + 1 ))

        # ----
        # Add the cover art to m4a and m4b file types.
        if [[ ${extension} == "m4a" && $(type -P mp4art) ]]; then
          mp4art -q --add "${cover_path}" "${chapter_file}"
          log "Added cover art to ${chapter_title}"
        fi 

        # ----
        # Detect if we are actuall m4b instead of m4a Then rename the file.
        if [[ ${extension} == "m4a" && ${container}="m4b" ]]; then
          mv "${chapter_file}" "${chapter_file/.m4a/.m4b}"
        fi

      fi
    done 9< "$metadata_file"

    # Clean up of working directoy stuff.
    rm "${full_file_path}"
    log "Done creating chapters for ${output_directory}."
  else
    # Perform file tasks on output file.
    # ----
    # Add the cover art to m4a and m4b file types.
    if [[ ${extension} == "m4a" && $(type -P mp4art) ]]; then
      mp4art -q --add "${cover_path}" "${full_file_path}"
      log "Added cover art to ${title}.${extension}"
    fi 
    # ----
    # Detect if we are actuall m4b instead of m4a Then rename the file.
    if [[ ${extension} == "m4a" && ${container}="m4b" ]]; then
      mv "${full_file_path}" "${full_file_path/.m4a/.m4b}"
    fi
  fi


  log "Done ${title}"
  # Lastly get rid of any extra stuff.
  rm "${metadata_file}"
done
