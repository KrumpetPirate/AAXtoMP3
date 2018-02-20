# AAXtoMP3 AAXtoM4A AAxtoM4B
The purpose of this software is to convert AAX files to common MP3, M4A and M4B formats
through a basic bash script frontend to FFMPEG.

Audible uses this file format, AAX to maintain DRM restrictions on their audio
books and if you download your book through your library it will be
stored in this format.

The purpose of this software is **not** to circumvent the DRM restrictions
for audio books that **you** do not own in that you do not have them on
your **personal** Audible account. The purpose of this software is to
create a method for you to download and store your books just in case
Audible fails for some reason.

## Setup
You will need your four byte authentication code that comes from Audible's
servers. This will be used by ffmpeg to perform the initial audio convert. You
can obtain this string from a tool like [audible-activator](https://github.com/inAudible-NG/audible-activator).

## Requirements
* bash 4.3.42 or later tested
* ffmpeg version 2.8.3 or later
* libmp3lame (came from lame package on Arch, not sure where else this is stored)

## OSX
Thanks to thibaudcolas, this script has been tested on OSX 10.11.6 El Capitan. YMMV, but it should work for 
conversions in OSX. It is recommended that you install GNU grep using 'brew install grep' for chapter padding to work.

## AUR
Thanks to kbabioch, this script has also been packaged in the [AUR](https://aur.archlinux.org/packages/aaxtomp3-git/). Note that you will still need to extract your activation bytes before use.

## Usage(s)
```
bash AAXtoMP3 [--flac] [--single] [AUTHCODE]* <AAX INPUT_FILES>
bash AAXtoM4A [AUTHCODE] <AAX INPUT_FILES>
bash AAXtoM4B [AUTHCODE] <AAX INPUT_FILES>
```

* AUTHCODE: **your** Audible auth code (it won't correctly decode otherwise) (required), See below for more information on setting the AUTHCODE.
* Everything else is considered an input file, useful for batching!


### MP3 Encoding
    - Produces 1 or more mp3 files for the AAX title.  If you desire a single file use the --single option
    - If you want a mp3 file per chapter do not use the -single option. Note a m3u playlist file will also
      be created in this instance.
    - If you desire flac encoding. use the --flac option.  It's a bit faster but also a bit less compatible.

### M4A Encoding

### M4B Encoding

### Defaults
*Specifying the AUTHCODE.
In order of precidence.
**[AUTHCODE]
**.authcode
**~/.aaxto_config

## Anti-Piracy Notice
Note that this project does NOT ‘crack’ the DRM. It simply allows the user to
use their own encryption key (fetched from Audible servers) to decrypt the
audiobook in the same manner that the official audiobook playing software does.

Please only use this application for gaining full access to your own audiobooks
for archiving/conversion/convenience. DeDRMed audiobooks should not be uploaded
to open servers, torrents, or other methods of mass distribution. No help will
be given to people doing such things. Authors, retailers, and publishers all
need to make a living, so that they can continue to produce audiobooks for us to
hear, and enjoy. Don’t be a parasite.

This blurb is borrowed from the https://apprenticealf.wordpress.com/ page.

## License
Changed the license to the WTFPL, do whatever you like with this script. Ultimately it's just a front-end for ffmpeg after all.

## Need Help?
I'll help out if you are having issues, just submit and issue and I'll get back to you when I can.
