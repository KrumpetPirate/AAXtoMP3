# AAXtoMP3
The purpose of this software is to convert AAX files to common MP3, M4A, M4B, flac and ogg formats
through a basic bash script frontend to FFMPEG.

Audible uses this file format to maintain DRM restrictions on their audio
books and if you download your book through your library it will be
stored in this format.

The purpose of this software is **not** to circumvent the DRM restrictions
for audio books that **you** do not own in that you do not have them on
your **personal** Audible account. The purpose of this software is to
create a method for you to download and store your books just in case
Audible fails for some reason.

## Requirements
* bash 4.3.42 or later tested
* ffmpeg version 2.8.3 or later
* libmp3lame (came from lame package on Arch, not sure where else this is stored)
* grep Some OS distributions do not have it installed.
* mp4art used to add cover art to m4a and m4b files. Optional

## OSX
Thanks to thibaudcolas, this script has been tested on OSX 10.11.6 El Capitan. YMMV, but it should work for 
conversions in OSX. It is recommended that you install GNU grep using 'brew install grep' for chapter padding to work.

## AUR
Thanks to kbabioch, this script has also been packaged in the [AUR](https://aur.archlinux.org/packages/aaxtomp3-git/). Note that you will still need to extract your activation bytes before use.

## Usage(s)
```
bash AAXtoMP3 [-f|--flac] [-o|--opus] [-a|-aac] [-s|--single] [-c|--chaptered] [-e:mp3] [-e:m4a] [-e:m4b] [-A|--authcode <AUTHCODE>] [-t|--target_dir <PATH>] [-d|--debug] [-h|--help] <AAX INPUT_FILES>...
```

* **&lt;AAX INPUT_FILES&gt;**... are considered input file(s), useful for batching!

## Options
* **-f** or **--flac**   Flac Encoding and Produces a single file.
* **-o** or **--opus**   Ogg/Opus Encoding defaults to multiple file output by chapter. The extention is .ogg
* **-a** or **--aac**    AAC Encoding and produce a m4a single files output.
* **-A** or **--authcode &lt;AUTHCODE&gt;** for this execution of the command use the provided &lt;AUTHCODE&gt; to decode the AAX file.
* **-t** or **--target_dir &lt;PATH&gt;** change the default output location to the named &lt;PATH&gt;. Note the default location is ./Audiobook of the directory to which each AAX file resides.
* **-e:mp3**         Identical to defaults.
* **-e:m4a**         Create a m4a audio file. This is identical to --aac
* **-e:m4b**         Create a m4b aduio file. This is the book version of the m4a format. 
* **-s** or **--single**    Output a single file for the entire book. If you only want a single ogg file for instance.
* **-c** or **--chaptered** Output a single file per chapter. The --chaptered will only work if it follows the -aac -e:m4a -em4b options. 


### [AUTHCODE] 
**Your** Audible auth code (it won't correctly decode otherwise) (required).

#### Determining your own AUTHCODE
You will need your authentication code that comes from Audible's servers. This 
will be used by ffmpeg to perform the initial audio convert. You can obtain 
this string from a tool like 
[audible-activator](https://github.com/inAudible-NG/audible-activator).

#### Specifying the AUTHCODE.
In order of __precidence__.
1. __--authcode [AUTHCODE]__ The command line option. With the highest precidence.
2. __.authcode__ If this file is placed in the current working directory and contains only the authcode it is used if the above is not.
3. __~/.authcode__ a global config file for all the tools. And is used as the default if none of the above are specified.
__Note:__ At least one of the above must be exist. The code must also match the encoding for the user that owns the AAX file(s). If the authcode does not match the AAX file no transcoding will occure.


### MP3 Encoding
* This is the **default** encoding
* Produces 1 or more mp3 files for the AAX title.
* The default mode is **chaptered**
* If you want a mp3 file per chapter do not use the -single option. 
* A m3u playlist file will also be created in this instance in the case of **default** chaptered ouput.

### Ogg/Opus Encoding
* Can be done by using the **-o** or **--opus** command line switches
* The default mode is **chaptered**
* Opus coded files are stored in the ogg container format for better compatibility.

### AAC Encoding
* Can be done by using the **-a** or **--aac** command line switches
* The default mode is **single**
* Designed to be the successor of the MP3 format
* Generally achieves better sound quality than MP3 at the same bit rate.
* This will only produce 1 audio file as output.

### FLAC Encoding
* Can be done by using the **-f** or **--flac** command line switches
* The default mode is **single**
* FLAC is an open format with royalty-free licensing
* Note: There is an bug with the ffmpeg software that prevents the splitting of flac files. Chaptered output of flac files will fail.

### M4A and M4B Containers ###
* These containers were created by Apple Inc. They were meant to be the successor to mp3.
* M4A is a container that is meant to hold music and is typically of a higher bitrate.
* M4B is a container that is meant to hold audiobooks and is typically has bitrates of 64k and 32k.
* Both formats are chaptered
* Both support coverart internall
* The default mode is **single**

### Defaults
* Default out put directory is the base directoy of each file listed. Plus the genre, Artist and Title of the Audio Book.
* The default codec is mp3
* The default output is by chapter.
 
## Anti-Piracy Notice
Note that this project **does NOT ‘crack’** the DRM. It simply allows the user to
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
