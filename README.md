# PureFoundation

#### Warning

**PureFoundation is intended for use under Darwin only, to replicate functionality already present in macOS. Please please please do not even think about installing it on macOS. It is currently sub-alpha-class software and would cause many many bad things to happen.**

#### About

PureFoundation is a minimum viable product reimplmentation of Apple's Foundation objective-C library. The project was originally started to allow those few strange programs (like `arch`) which required it to run on Darwin. It is the intention that in the future it will provide the features necessary to allow swift programs to also run unmodifed on Darwin.

PureFoundation is chiefly built on top of CFLite, the parts of CoreFoundation which Apple has opensourced. All [bridged](https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html) CoreFoundation types will be availble. Other Foundation classes will be built on the non-bridged functionality exposed.

#### Prerequisites

You will need a version of CoreFoundation / CFLite with the objective-C bridge re-enabled, such as [this one](https://github.com/sjc/CoreFoundation).

You will also need a version of libobjc.dylib.

#### Instalation

Install the `Foundation.framework` into `/System/Library/Frameworks/` of a Darwin image. **But as it says above, do not install on macOS.**

#### Known Issues

Too many to mention. All classes are only partial implementations. Implemented methods quite probably vary in behaviour from their Apple equivalents. If you find a bug which is stopping you from whatever you want to do with PureFoundation, please let us know and we'll do our best to fix it.

#### TODO

A non-exhaustive list. If there's a feature you need adding, let us know and we'll make it a priority.

* Finish bridging all CFLite classes (including implementing `NSAttributtedString`)
* Fix all the compiler warnings
* Write tests for everything (preferably in a form which can be compared with masOS Foundation)
