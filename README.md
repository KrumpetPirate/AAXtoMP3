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

## Setup
You will need your four byte authitication code that comes from Audible's
servers. This will be used by ffmpeg to perform the initial audio convert. You
can obtain this string from a tool like [audible-activator](https://github.com/inAudible-NG/audible-activator).

## Requirements
* perl version 5.22.0 or later
* ffmpeg version 2.8.3 or later
* libmp3lame (came from lame package on Arch, not sure where else this is stored)

You will also require the following perl modules:
* autodie
* Getopt::Long
* File::Basename
* IO::CaptureOutput

I would suggest installing cpanminus either through CPAN or (preferably) through your
distro's repositories. Take note that many perl modules can be packaged in your repos
as well so take a look there before resorting to cpan/cpanminus.

## Usage
```
perl AAXtoMP3.pl -a AUTHCODE -i AAXFILE -v -c
```
* -a: **your** Audible auth code (it won't correctly decode otherwise) (required)
* -i: the input AAX file to be converted (required) 
* -v: verbose (optional)

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
The MIT License

Copyright (c) 2015 KrumpetPirate

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
