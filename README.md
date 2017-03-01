# AAXtoMP3
The purpose of this software is to convert AAX files to a more common MP3 format
through a basic bash script frontend to FFMPEG.

Audible uses this file format to maintain DRM restrictions on their audio
books and if you download your book through your library it will be
stored in this format.

The purpose of this software is **not** to circumvent the DRM restrictions
for audio books that **you** do not own in that you do not have them on
your **personal** Audible account. The purpose of this software is to
create a method for you to download and store your books just in case
Audible fails for some reason.

TODO: Automatically fix the MP3 tags on the generated audio files. For now I use easytag which seems to work okay.

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
conversions in OSX.

## Usage
```
bash AAXtoMP3.sh <AUTHCODE> {INPUT_FILES}
```
* AUTHCODE: **your** Audible auth code (it won't correctly decode otherwise) (required)
* Everything else is considered an input file, useful for batching!

You can also convert the output to FLAC encoding instead of MP3 by doing the following *in order*:
```
bash AAXtoMP3.sh --flac <AUTHCODE> {INPUT_FILES}
```
Note that FLAC encoding is typically a little faster, at the cost of compatibility with some players.

If you wish to convert to a single file you can add --single to the input. This will prevent chaptered content from being extracted.

Additionally, if you have a .authcode file available in the current working directory, it will read the first line of
that line and treat it like your auth_code. When you do this you do not need to specify an AUTHCODE input.

Here is the full usage (NOTE: Order matters!)
```
bash AAXtoMP3.sh [--flac] [--single] AUTHCODE {FILES}
```

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
