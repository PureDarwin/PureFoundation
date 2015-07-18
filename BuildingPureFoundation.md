# Introduction #

PureFoundation is an XCode project. To build it, click on the little picture of a hammer.

...

PueFoundation in its current form is set-up to be developed and compiled in XCode on OS X and then copied across to the target machine. In part this is due to its reliance on Apple's Foundation headers, but it is also because I personally find working in XCode far easier and more productive than any of the alternatives. If it was for the ability to hit "build" every other line and have the compiler point out my stupid mistakes it's unlikely the project would have come this far.

## Apple's Foundation headers ##

PureFoundation is compiled using Apple's Foundation headers, but since these are copyrighted Apple material they are not (cannot be) distributed with the PureFoundation source. Instead, the XCode project includes references to the versions stored at /System/Library/Frameworks/Foundation.framework/Headers/. If you are running XCode on OS X you will have access to these files.

## Skip install step ##

The "skip install step" option should be unchecked for all build configurations. It was on the version of the project I uploaded, anyway. You might like to just double-check that it still is. Installing PureFoundation in place of Foundation.framework on OS X would be... unwise.

## Linking ##

PureFoundation links against CoreFoundation.framework, so that on Darwin it will link to CFLite. (It also links to the objective-C runtime, and will likely someday also link to the CoreServices framework to get at CFNetwork.) However, the patched CFLite upon which PureFoundation relies at runtime exports a number of symbols which CoreFoundation doesn't. In order to shut the linker the hell up, PureFoundation passes it the "`-undefined dynamic_lookup`" flags. You should therefore be extra careful, as a typo may be missed at compile time and only show up when the Framework's in Darwin.

## Build configurations ##

PureFoundation has two build configurations defined: "Debug", which spews many many comments (such as the names of methods and functions as they are called) to the console, and "Relase", which doesn't. Debug also has the side-effect of killing the X server (at least under the VMWare frame buffer used in PureDarwinXmas).

## Building PureFoundation with darwinbuild ##

At the moment, building PureFoundation either with `darwinbuild` or in the darwinbuild chroot has not been attempted. To do so would probably require a new set of Foundation headers, since Apple's versions include other non-Darwin headers files (eg. NSGeometry includes headers from CoreGraphics).