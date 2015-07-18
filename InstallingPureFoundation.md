# Introduction #

The PureFoundation project consists of three components: the Foundation.framework, which reproduces the functionality of Apple's Foundation; a patched version of the open source CFLite, which supports Foundation and Darwin by exporting missing symbols; and ddistnoted, the distributed notification daemon. Each component relies on the other, so you will need to install both. However, the patches to CFLite _shouldn't_ prevent it operating as normal for non-Foundation applications.

This page details installing the binaries. Instructions for building a patched CFLite from source can be found [here](http://code.google.com/p/purefoundation/wiki/BuildingCFLite).

# Details #

PureFoundation has been tested with (and was developed using) the PureDarwin project's [PureDarwinXmas](http://www.puredarwin.org/downloads/xmas), which is a VMWare image. These instructions assume that you are running this on a Mac, using VMWare Fusion.

  1. Download `PureFoundation-0.xxx.root.zip` (where xxx is the highest versions listed) from the [downloads](http://code.google.com/p/purefoundation/downloads/list) page and un-archive it. For the rest of these instructions we'll assume the decompressed folders are in `~/Downloads/`.
  1. Ensure that VMWare Fusion is not running. Find the `puredarwinxmas.vmwarevm` virtual machine file in the Finder. Right- (Command-) click on it and select "Show Package Contents". A new window will open. Double click on the file `puredarwinxmas.vmdk`. This is the virtual machine's disk image, which should now be mounted.
  1. You will probably want to move the existing CoreFoundation.framework somewhere safe, for if (when) something goes wrong.
```
    mv /Volumes/PureDarwinXmas/System/Library/Frameworks/CoreFoundation.framework /Volumes/PureDarwinXmas/Users/Shared
```
  1. Copy the frameworks into place. I suggest using `ditto` from the Terminal. (These exact commands are for the v0.003 release. Obviously, use the current version number.)
```
    ditto ~/Downloads/PureFoundation-0.003.root/ /Volumes/PureDarwinXmas/
```
  1. Unmount the disk image.
  1. Boot VMWare Fusion.
  1. Start making notes about everything which doesn't work.