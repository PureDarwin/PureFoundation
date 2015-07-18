# PureFoundation #

PureFoundation is a binary-compatible clone of the Foundation framework created exclusively for Darwin using Apple's open source Objective-C 2.0 runtime, AutoZone garbage collector and CFLite library. It's primary purpose is to support the PureDarwin effort to build a fully-functional Darwin distribution, by providing the support library which certain components require.

For installation instructions, see the wiki.

## Warning ##

PureFoundation is intended for use under Darwin _**only**_, to replicate functionality already present in OS X. Please please please do not even think about installing it on OS X. It is currently sub-alpha-class software and would cause many many bad things to happen.

## Current Version ##

**v0.0009 5/3/09** Changed memory management procedure to favour CF types, leading to large stability improvements. Built from source [r10](https://code.google.com/p/purefoundation/source/detail?r=10).