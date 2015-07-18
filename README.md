#PureFoundation

PureFoundation is a binary-compatible clone of the Foundation framework created exclusively for Darwin using Apple's open source Objective-C 2.0 runtime, AutoZone garbage collector and CFLite library. It's primary purpose is to support the PureDarwin effort to build a fully-functional Darwin distribution, by providing the support library which certain components require.

For installation instructions, see the wiki.

##Warning

PureFoundation is intended for use under Darwin only, to replicate functionality already present in OS X. Please please please do not even think about installing it on OS X. It is currently sub-alpha-class software and would cause many many bad things to happen.

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
