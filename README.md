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

Its likely that in the near future (say in a month's time - soon after the PureDarwin boys put out their next preview release, which PureFoundation would like to be a part of) we may shift to basing the patched CFLite off of OpenCFLite rather than directly from Apple's source. This should give us the advantage that at least the patched discussed in "Restoring missing functionality" above will already be in-place and well-tested.

## Installing PureFoundation

The PureFoundation project consists of three components: the Foundation.framework, which reproduces the functionality of Apple's Foundation; a patched version of the open source CFLite, which supports Foundation and Darwin by exporting missing symbols; and ddistnoted, the distributed notification daemon. Each component relies on the other, so you will need to install both. However, the patches to CFLite shouldn't prevent it operating as normal for non-Foundation applications.

This page details installing the binaries. Instructions for building a patched CFLite from source can be found here.

PureFoundation has been tested with (and was developed using) the PureDarwin project's PureDarwinXmas, which is a VMWare image. These instructions assume that you are running this on a Mac, using VMWare Fusion.

* Download PureFoundation-0.xxx.root.zip (where xxx is the highest versions listed) from the [downloads page](https://github.com/PureDarwin/PureFoundation/releases/tag/PureFoundation-0.0003.1) and un-archive it. For the rest of these instructions we'll assume the decompressed folders are in ~/Downloads/.
* Ensure that VMWare Fusion is not running. Find the puredarwinxmas.vmwarevm virtual machine file in the Finder. Right- (Command-) click on it and select "Show Package Contents". A new window will open. Double click on the file puredarwinxmas.vmdk. This is the virtual machine's disk image, which should now be mounted.
* You will probably want to move the existing CoreFoundation.framework somewhere safe, for if (when) something goes wrong. `mv /Volumes/PureDarwinXmas/System/Library/Frameworks/CoreFoundation.framework /Volumes/PureDarwinXmas/Users/Shared` 
* Copy the frameworks into place. I suggest using ditto from the Terminal. (These exact commands are for the v0.003 release. Obviously, use the current version number.) `ditto ~/Downloads/PureFoundation-0.003.root/ /Volumes/PureDarwinXmas/`
* Unmount the disk image.
* Boot VMWare Fusion.
* Start making notes about everything which doesn't work.

##TODO

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
