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

## Installing PureFoundation

The PureFoundation project consists of three components: the Foundation.framework, which reproduces the functionality of Apple's Foundation; a patched version of the open source CFLite, which supports Foundation and Darwin by exporting missing symbols; and ddistnoted, the distributed notification daemon. Each component relies on the other, so you will need to install both. However, the patches to CFLite shouldn't prevent it operating as normal for non-Foundation applications.

This page details installing the binaries. Instructions for building a patched CFLite from source can be found here.

PureFoundation has been tested with (and was developed using) the PureDarwin project's PureDarwinXmas, which is a VMWare image. These instructions assume that you are running this on a Mac, using VMWare Fusion.

* Download PureFoundation-0.xxx.root.zip (where xxx is the highest versions listed) from the downloads page and un-archive it. For the rest of these instructions we'll assume the decompressed folders are in ~/Downloads/.
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
