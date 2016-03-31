# AAXtoMP3
The purpose of this software is to convert AAX files to a more common MP3 format
through a basic perl script frontend to FFMPEG.

Audible uses this file format to maintain DRM restrictions on their audio
books and if you download your book through your library it will be
stored in this format.

The purpose of this software is **not** to circumvent the DRM restrictions
for audio books that **you** do not own in that you do not have them on
your **personal** Audible account. The purpose of this software is to
create a method for you to download and store your books just in case
Audible fails for some reason.

I recently converted this script to bash instead of perl. Something about more people knowing bash or something rather.
Additionally I put some work into creating chaptered files as well as the mp3 version. A directory of structure GENRE/WRITER/TITLE
will contain the large mp3 as well as chaptered mp3s extracted from the AAX file metadata.

TODO: Automatically fix the MP3 tags on the generated audio files. For now I use easytag which seems to work okay.

## Setup
You will need your four byte authitication code that comes from Audible's
servers. This will be used by ffmpeg to perform the initial audio convert. You
can obtain this string from a tool like [audible-activator](https://github.com/inAudible-NG/audible-activator).

## Requirements
* bash 4.3.42 or later tested
* ~~perl version 5.22.0 or later~~ (Converted the script to bash for greater readability!)
* ffmpeg version 2.8.3 or later
* libmp3lame (came from lame package on Arch, not sure where else this is stored)

## Usage
```
bash AAXtoMP3.sh <AUTHCODE> {INPUT_FILES}
```
* AUTHCODE: **your** Audible auth code (it won't correctly decode otherwise) (required)
* Everything else is considered an input file, useful for batching!

Tested on Linux with the above requirements. No effort will be made to
port this work to any other operating system, though it may work fine. Want a Windows/
OSX port? You'll have to fork the work.

## Anti-Piracy Notice
Note that this project does NOT ‘crack’ the DRM. It simplys allows the user to
use their own encryption key (fetched from Audible servers) to decrypt the
audiobook in the same manner that the official audiobook playing software does.

Please only use this application for gaining full access to your own audiobooks
for archiving/converson/convenience. DeDRMed audiobooks should not be uploaded
to open servers, torrents, or other methods of mass distribution. No help will
be given to people doing such things. Authors, retailers, and publishers all
need to make a living, so that they can continue to produce audiobooks for us to
hear, and enjoy. Don’t be a parasite.

This blurb is borrowed from the https://apprenticealf.wordpress.com/ page.

## License
Changed the license to the WTFPL, do whatever you like with this script. Ultimately it's just a front-end for ffmpeg after all.

## Need Help?
I'll help out if you are having issues, just submit and issue and I'll get back to you when I can.
