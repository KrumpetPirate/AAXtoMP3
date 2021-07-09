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
* sed Some OS versions will need to install gnu sed.
* mp4art used to add cover art to m4a and m4b files. Optional
* mediainfo used to add additional media tags like narrator. Optional

## OSX
Thanks to thibaudcolas, this script has been tested on OSX 10.11.6 El Capitan. YMMV, but it should work for 
conversions in OSX. It is recommended that you install GNU grep using 'brew install grep' for chapter padding to work.

## AUR
Thanks to kbabioch, this script has also been packaged in the [AUR](https://aur.archlinux.org/packages/aaxtomp3-git/). Note that you will still need to extract your activation bytes before use.

## Usage(s)
```
bash AAXtoMP3 [-f|--flac] [-o|--opus] [-a|-aac] [-s|--single] [--level <COMPRESSIONLEVEL>] [-c|--chaptered] [-e:mp3] [-e:m4a] [-e:m4b] [-A|--authcode <AUTHCODE>] [-n|--no-clobber] [-t|--target_dir <PATH>] [-C|--complete_dir <PATH>] [-V|--validate] [-d|--debug] [-h|--help] [--continue <CHAPTERNUMBER>] <AAX INPUT_FILES>...
```
or if you want to get guided through the options
```
bash interactiveAAXtoMP3 [-a|--advanced] [-h|--help]
```

* **&lt;AAX INPUT_FILES&gt;**... are considered input file(s), useful for batching!

## Options for AAXtoMP3
* **-f** or **--flac**   Flac Encoding and as default produces a single file.
* **-o** or **--opus**   Ogg/Opus Encoding defaults to multiple file output by chapter. The extension is .ogg
* **-a** or **--aac**    AAC Encoding and produce a m4a single files output.
* **-A** or **--authcode &lt;AUTHCODE&gt;** for this execution of the command use the provided &lt;AUTHCODE&gt; to decode the AAX file.
* **-n** or **--no-clobber** If set and the target directory already exists, AAXtoMP3 will exit without overwriting anything.
* **-t** or **--target_dir &lt;PATH&gt;** change the default output location to the named &lt;PATH&gt;. Note the default location is ./Audiobook of the directory to which each AAX file resides.
* **-C** or **--complete_dir &lt;PATH&gt;** a directory to place aax files after they have been decoded successfully. Note make a back up of your aax files prior to using this option. Just in case something goes wrong.
* **-V** or **--validate** Perform 2 validation tests on the supplied aax files. This is more extensive than the normal validation as we attempt to transcode the aax file to a null file.  This can take a long period of time. However it is useful when inspecting a large set of aax files prior to transcoding. As download errors are common with Audible servers.
* **-e:mp3**         Identical to defaults.
* **-e:m4a**         Create a m4a audio file. This is identical to --aac
* **-e:m4b**         Create a m4b audio file. This is the book version of the m4a format.
* **-s** or **--single**    Output a single file for the entire book. If you only want a single ogg file for instance.
* **-c** or **--chaptered** Output a single file per chapter. The `--chaptered` will only work if it follows the `--aac -e:m4a -e:m4b --flac` options.
* **--continue &lt;CHAPTERNUMBER&gt;**      If the splitting into chapters gets interrupted (e.g. by a weak battery on your laptop) you can go on where the process got interrupted. Just delete the last chapter (which was incompletely generated) and redo the task with "--continue &lt;CHAPTERNUMBER&gt;" where CHAPTERNUMBER is the chapter that got interrupted.
* **--level &lt;COMPRESSIONLEVEL&gt;**      Set compression level. May be given for mp3, flac and opus.
* **--keep-author &lt;FIELD&gt;**           If a book has multiple authors and you don't want all of them in the metadata, with this flag you can specify a specific author (1 is the first, 2 is the second...) to keep while discarding the others.
* **--author &lt;AUTHOR&gt;**               Manually set the author metadata field, useful if you have multiple books of the same author but the name reported is different (eg. spacing, accents..). Has precedence over `--keep-author`.
* **-l** or **--loglevel &lt;LOGLEVEL&gt;** Set loglevel: 0 = progress only, 1 (default) = more information, output of chapter splitting progress is limitted to a progressbar, 2 = more information, especially on chapter splitting, 3 = debug mode
* **--dir-naming-scheme &lt;STRING&gt;** or **-D**      Use a custom directory naming scheme, with variables. See [below](#custom-naming-scheme) for more info.
* **--file-naming-scheme &lt;STRING&gt;** or **-F**    Use a custom file naming scheme, with variables. See [below](#custom-naming-scheme) for more info.
* **--chapter-naming-scheme &lt;STRING&gt;**  Use a custom chapter naming scheme, with variables. See [below](#custom-naming-scheme) for more info.
* **--use-audible-cli-data** Use additional data got with mkb79/audible-cli. See [below](#audible-cli-integration) for more infos.

## Options for interactiveAAXtoMP3
* **-a** or **--advanced** Get more options to choose. Not used right now.
* **-h** or **--help** Get a help prompt.
This script presents you the options you chose last time as default.
When you get asked for the aax-file you may just drag'n'drop it to the terminal.

### [AUTHCODE]
**Your** Audible auth code (it won't correctly decode otherwise) (required).

#### Determining your own AUTHCODE
You will need your authentication code that comes from Audible's servers. This 
will be used by ffmpeg to perform the initial audio convert. You can obtain 
this string from a tool like 
[audible-activator](https://github.com/inAudible-NG/audible-activator).

#### Specifying the AUTHCODE.
In order of __precidence__.
1. __--authcode [AUTHCODE]__ The command line option. With the highest precedence.
2. __.authcode__ If this file is placed in the current working directory and contains only the authcode it is used if the above is not.
3. __~/.authcode__ a global config file for all the tools. And is used as the default if none of the above are specified.
__Note:__ At least one of the above must be exist. The code must also match the encoding for the user that owns the AAX file(s). If the authcode does not match the AAX file no transcoding will occur.

### MP3 Encoding
* This is the **default** encoding
* Produces 1 or more mp3 files for the AAX title.
* The default mode is **chaptered**
* If you want a mp3 file per chapter do not use the **--single** option. 
* A m3u playlist file will also be created in this instance in the case of **default** chaptered output.
* **--level** has to be in range 0-9, where 9 is fastest and 0 is highest quality. Please note: The quality can **never** become higher than the qualitiy of the original aax file!

### Ogg/Opus Encoding
* Can be done by using the **-o** or **--opus** command line switches
* The default mode is **chaptered**
* Opus coded files are stored in the ogg container format for better compatibility.
* **--level** has to be in range 0-10, where 0 is fastest and 10 is highest quality. Please note: The quality can **never** become higher than the qualitiy of the original aax file!

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
* This will only produce 1 audio file as output. If you want a flac file per chapter do use **-c** or **--chaptered**.
* **--level** has to be in range 0-12, where 0 is fastest and 12 is highest compression. Since flac is lossless, the quality always remains the same.

### M4A and M4B Containers
* These containers were created by Apple Inc. They were meant to be the successor to mp3.
* M4A is a container that is meant to hold music and is typically of a higher bitrate.
* M4B is a container that is meant to hold audiobooks and is typically has bitrates of 64k and 32k.
* Both formats are chaptered
* Both support coverart internal
* The default mode is **single**

### Validating AAX files
* The **--validate** option will result in only a validation pass over the supplied aax file(s). No transcoding will occur. This is useful when you wish to ensure you have a proper download of your personal Audible audio books. With this option all supplied books are validated.
* If you do NOT supply the **--validate** option all audio books are still validated when they are processed. However if there is an invalid audio book in the supplied list of books the processing will stop at that point.
* A third test is performed on the file where the entire file is inspected to see if it is valid. This is a lengthy process. However it will not break the script when an invalid file is found.
* The 3 test current are:
    1. aax present
    1. meta data header in file is valid and complete
    1. entire file is valid and complete.  _only executed with the **--validate** option._

### Defaults
* Default out put directory is the base directory of each file listed. Plus the genre, Artist and Title of the Audio Book.
* The default codec is mp3
* The default output is by chapter.

### Custom naming scheme
The following flags can modify the default naming scheme:
* **--dir-naming-scheme** or **-D**  
* **--file-naming-scheme** or **-F** 
* **--chapter-naming-scheme** 

Each flag takes a string as argument. If the string contains a variable defined in the script (eg. artist, title, chapter, narrator...), the corresponding value is used.
The default options correspond to the following flags:
* `--dir-naming-scheme '$genre/$artist/$title'`
* `--file-naming-scheme '$title'`
* `--chapter-naming-scheme '$title-$(printf %0${#chaptercount}d $chapternum) $chapter'`

Additional notes:
* If a command substitution is present in the passed string, (for example `$(printf %0${#chaptercount}d $chapternum)`, used to pad with zeros the chapter number), the commands are executed.
So you can use `--dir-naming-scheme '$(date +%Y)/$artist'`, but using `--file-naming-scheme '$(rm -rf /)'` is a really bad idea. Be careful.
* You can use basic text, like `--dir-naming-scheme 'Converted/$title'`
* You can also use shell variables as long as you escape them properly: `CustomGenre=Horror ./AAXtoMP3 --dir-naming-scheme "$CustomGenre/\$artist/\$title" *.aax`
* If you want shorter chapter names, use `--chapter-naming-scheme '$(printf %0${#chaptercount}d $chapternum) $chapter'`: only chapter number and chapter name
* If you want to append the narrator name to the title, use `--dir-naming-scheme '$genre/$artist/$title-$narrator' --file-naming-scheme '$title-$narrator'`
* If you don't want to have the books separated by author, use `--dir-naming-scheme '$genre/$title'`

### Installing Dependencies.
#### FFMPEG,FFPROBE
__Ubuntu, Linux Mint, Debian__
```
sudo apt-get update
sudo apt-get install ffmpeg libav-tools x264 x265 bc
```

__Fedora__

Fedora users need to enable the rpm fusion repository to install ffmpeg. Version 22 and upwards are currently supported. The following command works independent of your current version:
```
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Afterwards use the package manager to install ffmpeg:
```
sudo dnf install ffmpeg
```

__RHEL or compatible like CentOS__

RHEL version 6 and 7 are currently able to use rpm fusion.
In order to use rpm fusion you have to enable EPEL, see http://fedoraproject.org/wiki/EPEL

Add the rpm fusion repositories in version 6
```
sudo yum localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-6.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-6.noarch.rpm
```
or version 7:
```
sudo yum localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
```
then install ffmpeg:
```
sudo yum install ffmpeg
```

__MacOS__
```
brew install ffmpeg
brew install gnu-sed
brew install grep
```

#### mp4art/mp4chaps
_Note: This is an optional dependency._

__Ubuntu, Linux Mint, Debian__
```
sudo apt-get update
sudo apt-get install mp4v2-utils
```
__CentOS, RHEL & Fedora__
```
# CentOS/RHEL and Fedora users make sure that you have enabled atrpms repository in system. Let’s begin installing FFmpeg as per your operating system.
yum install mp4v2-utils
```
__MacOS__
```
brew install mp4v2
```

## Audible-cli integration
Some information are not present in the AAX file. For example the chapters's
title, additional chapters division (Opening and End credits, Copyright and
more).  Those information are avaiable via a non-public audible API. This
[repo](https://github.com/mkb79/Audible) provides a python API wrapper, and the
[audible-cli](https://github.com/mkb79/audible-cli) packege makes easy to get
more info. In particular the flags **--cover --cover-size 1215 --chapter**
downloads a better-quality cover (.jpg) and detailed chapter infos (.json).
More info are avaiable on the package page.

To make AAXtoMP3 use the additional data, specify the **--use-audible-cli-data**
flag: it expects the cover and the chapter files to be in the same location of
the AAX file.  The naming of these files must be the one set by audible-cli.

Please note that right now audible-cli is in dev stage, so keep in mind that the
naming scheme of the additional files, the flags syntax and other things can
change without warning.
 
#### mediainfo
_Note: This is an optional dependency._

__Ubuntu, Linux Mint, Debian__
```
sudo apt-get update
sudo apt-get install mediainfo
```
__CentOS, RHEL & Fedora__
```
yum install mediainfo
```
__MacOS__
```
brew install mediainfo
```


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
