#PureFoundation

PureFoundation is a binary-compatible clone of the Foundation framework created exclusively for Darwin using Apple's open source Objective-C 2.0 runtime, AutoZone garbage collector and CFLite library. It's primary purpose is to support the PureDarwin effort to build a fully-functional Darwin distribution, by providing the support library which certain components require.

For installation instructions, see the wiki.

##Warning

PureFoundation is intended for use under Darwin only, to replicate functionality already present in OS X. Please please please do not even think about installing it on OS X. It is currently sub-alpha-class software and would cause many many bad things to happen.

## Introduction

PureFoundation is a clone of Apple's Foundation.framework. It is designed exclusively for use with Darwin, and uses CFLite and the Objective-C 2.0 runtime (and, one day, the AutoZone garbage collector). One side effect of this is binary compatibility with a subset of tools and applications compiled on OS X.

The primary goal of PureFoundation is to provide the features necessary to allow the creation of a self-contained Darwin system. Objective-C is a great programming language and Foundation is a mature and fully-featured programming library, so it's hardly surprising that Apple uses it extensively in the development of both OS X and Darwin. However, this has left us in the position where several key components released as open source as part of Darwin cannot run without Foundation, which hasn't been (and is unlikely ever to be) released as open source. The alternative to cloning Foundation is to re-write these components using another language and library.

### Hasn't this been done before?

There are already a number of open source projects which aim to achieve a similar goal. GNUStep and Cocotron are the most prominent of these. PureFoundation will certainly reuse some source code from each of these projects. PureFoundation, however, differs in that it starts by building on CFLite. This provides implementations of core library objects - collections, strings, OS abstractions - which are identical to those used by Apple, and also means development is much faster.

## PureFoundation and CFLite

To say that PureFoundation and CFLite are closely linked is an understatement. PureFoundation relies on CFLite for a large amount of its functionality (which sets this project apart from the likes of GNUStep or Cocotron), and in return the patched version of CFLite we use requires the PureFoundation version of Foundation.framework to be present. It is therefore probably fair to say that the PureFoundation project is as much about working on CFLite as it is about coding the objective-C framework.

The changes made to CFLite can be divided into 3 general categories.

### Restoring missing symbols

As [this page](https://github.com/PureDarwin/PureDarwin/wiki/CFLite) from the PureDarwin project illustrates, CFLite is lacking a great number of symbols which CoreFoundation exports. Some of these represent functionality removed from CFLite by Apple, while others are specific to Foundation. The presence of these is beneficial beyond this project to the wider Darwin effort, and therefore patches for these are usually handed-off to the PureDarwin project (see [here](https://github.com/PureDarwin/PureDarwin/wiki/Integrating_patches_and_additional_sources) for a discussion, and [here](https://github.com/PureDarwin/PureDarwin) for the code).

These patches include restoring basic string constants (such as the NS...Locales and NS...Exceptions) and introducing dummy stubs for missing (this currently includes the CFNotificationCenter functions, but see below). They will probably be expanded in the near future, as we find more holes to fix. For instance, although PureFoundation now includes an implementation of NSGetSizeAndAlignment(), it appears that the linker expects to find it exported from CF. A thorough survey of what code needs to reside where is on the cards.

### Restoring missing functionality

There is a lot of CoreFoundation missing from CFLite. In some case, where Darwin components expect it (and recall that the primary goal of the PureFoundation project is to facilitate the running of a complete Darwin system with as little modification to individual component's source code as possible) our only real option is to restore that functionality.

One example of this was the somewhat obscure "serialise a binary plist via a write stream" issue which SystemConfiguration relied upon. In this case, the fix was (or at least appeared to be - there's still time for it to go hideously wrong) quite simple (2 lines of code). Reproducing CFNotificationCenter functions looks like it will be a little more difficult, although still perfectly achievable.

Where possible, we co-operate with the [OpenCFLite](http://sourceforge.net/projects/opencflite/) project, donating fixes to them where practical.

### Restoring the bridge

Unlike the previous two categories, it's unlikely that patches produced in pursuit of restoring the Foundation-CFLite bridge will find a use outside of PureFoundation. This part of the project is pretty-much complete now.

### The future

Its likely that in the near future (say in a month's time - soon after the PureDarwin boys put out their next preview release, which PureFoundation would like to be a part of) we may shift to basing the patched CFLite off of OpenCFLite rather than directly from Apple's source. This should give us the advantage that aint least the patched discussed in "Restoring missing functionality" above will already be in-place and well-tested.

## Installing PureFoundation

The PureFoundation project consists of three components: the Foundation.framework, which reproduces the functionality of Apple's Foundation; a patched version of the open source CFLite, which supports Foundation and Darwin by exporting missing symbols; and ddistnoted, the distributed notification daemon. Each component relies on the other, so you will need to install both. However, the patches to CFLite shouldn't prevent it operating as normal for non-Foundation applications.

This section details installing the binaries. Instructions for building a patched CFLite from source can be found below.

PureFoundation has been tested with (and was developed using) the PureDarwin project's PureDarwinXmas, which is a VMWare image. These instructions assume that you are running this on a Mac, using VMWare Fusion.

* Download PureFoundation-0.xxx.root.zip (where xxx is the highest versions listed) from the [downloads page](https://github.com/PureDarwin/PureFoundation/releases/tag/PureFoundation-0.0003.1) and un-archive it. For the rest of these instructions we'll assume the decompressed folders are in ~/Downloads/.
* Ensure that VMWare Fusion is not running. Find the puredarwinxmas.vmwarevm virtual machine file in the Finder. Right- (Command-) click on it and select "Show Package Contents". A new window will open. Double click on the file puredarwinxmas.vmdk. This is the virtual machine's disk image, which should now be mounted.
* You will probably want to move the existing CoreFoundation.framework somewhere safe, for if (when) something goes wrong. `mv /Volumes/PureDarwinXmas/System/Library/Frameworks/CoreFoundation.framework /Volumes/PureDarwinXmas/Users/Shared` 
* Copy the frameworks into place. I suggest using ditto from the Terminal. (These exact commands are for the v0.003 release. Obviously, use the current version number.) `ditto ~/Downloads/PureFoundation-0.003.root/ /Volumes/PureDarwinXmas/`
* Unmount the disk image.
* Boot VMWare Fusion.
* Start making notes about everything which doesn't work.

## Building CFLite

If you just want to try out PureFoundation you'll probably be better off using the pre-compiled binaries available from the downloads page. Otherwise, read on.

CFLite is built using the darwinbuild script and environment, available from MacOSForge. It is always a good idea to be running the latest version pulled from svn, since new bug-fixes and enhancements are frequently added.

You should also be building using the [PureDarwin patches]((https://github.com/PureDarwin/PureDarwin/wiki/Integrating_patches_and_additional_sources)), since these add common fixes which PureFoundation relies upon.

For the rest of this discussion we will assume that your `darwinbuild` path is `/Volumes/dbuf/9G55`. It doesn't matter if it isn't. The patch has been tested with `9F33` and `9G55`.

### Updating the PureDarwin patches

At the time of writing, it's necessary to update the patch file automatically downloaded from the PureDarwin project. When this is changed, these instructions will be removed. Until then...

* Run darwinbuild CF once, to ensure that the patch files are downloaded.
* Download the file `CF-476.15.CFBundle_Resources.p1.patch` from the downloads page.
* Copy the downloaded patch into the Sources directory, over-writing the PureDarwin patch of the same name. `cp ~/Downloads/http://code.google.com/p/purefoundation/downloads/list /Volumes/dbufs/9G55/Source/`

The updated patch will now be applied each time you build CF.

### Building the patched CFLite

* Change into the Source directory and un-tar the CFLite source tarball. `cd Sources/ ; tar xfvz CF-476.17.tar.gz`
* Download the latest PureFoundation patch from the downloads page. (At the time of writing this was `CF-476.15.pf6.patch`.) (Don't worry about the different CFLite version numbers - the source doesn't change that much between releases.)
* Change into the CFLite source directory and apply the patch. `cd CF-476.17/ ; patch -p1 -r . < ~/Downloads/CF-476.15.pf6.patch`
* Change back to the main darwinbuild directory and build CFLite. `cd ../.. ; darwinbuild CF`

darwinbuild will apply the PureDarwin patches to the patched source code.

## Building PureFoundation

PureFoundation is an XCode project. To build it, click on the little picture of a hammer.

PueFoundation in its current form is set-up to be developed and compiled in XCode on OS X and then copied across to the target machine. In part this is due to its reliance on Apple's Foundation headers, but it is also because I personally find working in XCode far easier and more productive than any of the alternatives. If it was for the ability to hit "build" every other line and have the compiler point out my stupid mistakes it's unlikely the project would have come this far.

### Apple's Foundation headers

PureFoundation is compiled using Apple's Foundation headers, but since these are copyrighted Apple material they are not (cannot be) distributed with the PureFoundation source. Instead, the XCode project includes references to the versions stored at /System/Library/Frameworks/Foundation.framework/Headers/. If you are running XCode on OS X you will have access to these files.

### Skip install step

The "skip install step" option should be unchecked for all build configurations. It was on the version of the project I uploaded, anyway. You might like to just double-check that it still is. Installing PureFoundation in place of Foundation.framework on OS X would be... unwise.

### Linking

PureFoundation links against CoreFoundation.framework, so that on Darwin it will link to CFLite. (It also links to the objective-C runtime, and will likely someday also link to the CoreServices framework to get at CFNetwork.) However, the patched CFLite upon which PureFoundation relies at runtime exports a number of symbols which CoreFoundation doesn't. In order to shut the linker the hell up, PureFoundation passes it the "-undefined dynamic_lookup" flags. You should therefore be extra careful, as a typo may be missed at compile time and only show up when the Framework's in Darwin.

### Build configurations

PureFoundation has two build configurations defined: "Debug", which spews many many comments (such as the names of methods and functions as they are called) to the console, and "Relase", which doesn't. Debug also has the side-effect of killing the X server (at least under the VMWare frame buffer used in PureDarwinXmas).

### Building PureFoundation with darwinbuild

At the moment, building PureFoundation either with darwinbuild or in the darwinbuild chroot has not been attempted. To do so would probably require a new set of Foundation headers, since Apple's versions include other non-Darwin headers files (eg. NSGeometry includes headers from CoreGraphics).

## TODO

Yes, there's an awful lot to do. This file is for noting improvements which we could go back and apply to code we've already written.

* NSFileManager -- change attribute methods to call fstat64/lstat64, if possible, to retrieve eg. file creation date
* Collections -- expose setCapacity functions in CFLite and call them in the corresponding initWithCapacity: methods.
* NSArray -- sort with hint; NSIndexSet methods; NSSortDescriptor methods; URL methods
* NSDictionary -- keysSortedByValue; descriptions; URL methods
* NSCalendar -- auto-updating callendar
* NSError -- recovery options and recovery attempt
* NSLocale -- auto-updating locale; something needs to set the actual locale
* NSSet -- descriptions
* NSCountedSet -- everything (based on CFBag).
