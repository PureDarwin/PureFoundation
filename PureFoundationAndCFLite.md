# Introduction #

To say that PureFoundation and CFLite are closely linked is an understatement. PureFoundation relies on CFLite for a large amount of its functionality (which sets this project apart from the likes of GNUStep or Cocotron), and in return the patched version of CFLite we use requires the PureFoundation version of Foundation.framework to be present. It is therefore probably fair to say that the PureFoundation project is as much about working on CFLite as it is about coding the objective-C framework.

The changes made to CFLite can be divided into 3 general categories.

## Restoring missing symbols ##

As [this page](http://www.puredarwin.org/developers/cf-lite) from the PureDarwin project illustrates, CFLite is lacking a great number of symbols which CoreFoundation exports. Some of these represent functionality removed from CFLite by Apple, while others are specific to Foundation. The presence of these is beneficial beyond this project to the wider Darwin effort, and therefore patches for these are usually handed-off to the PureDarwin project (see [here](http://www.puredarwin.org/developers/darwinbuild/patchfiles) for a discussion, and [here](http://code.google.com/p/puredarwin/) for the code).

These patches include restoring basic string constants (such as the NS...Locales and NS...Exceptions) and introducing dummy stubs for missing (this currently includes the CFNotificationCenter functions, but see below). They will probably be expanded in the near future, as we find more holes to fix. For instance, although PureFoundation now includes an implementation of NSGetSizeAndAlignment(), it appears that the linker expects to find it exported from CF. A thorough survey of what code needs to reside where is on the cards.

## Restoring missing functionality ##

There is a lot of CoreFoundation missing from CFLite. In some case, where Darwin components expect it (and recall that the primary goal of the PureFoundation project is to facilitate the running of a complete Darwin system with as little modification to individual component's source code as possible) our only real option is to restore that functionality.

One example of this was the somewhat obscure "serialise a binary plist via a write stream" issue which SystemConfiguration relied upon. In this case, the fix was (or at least appeared to be - there's still time for it to go hideously wrong) quite simple (2 lines of code). Reproducing CFNotificationCenter functions looks like it will be a little more difficult, although still perfectly achievable.

Where possible, we co-operate with the [OpenCFLite](http://sourceforge.net/projects/opencflite/) project, donating fixes to them where practical.

## Restoring the bridge ##

Unlike the previous two categories, it's unlikely that patches produced in pursuit of restoring the Foundation-CFLite bridge will find a use outside of PureFoundation. This part of the project is pretty-much complete now.

# The future #

Its likely that in the near future (say in a month's time - soon after the PureDarwin boys put out their next preview release, which PureFoundation would like to be a part of) we may shift to basing the patched CFLite off of OpenCFLite rather than directly from Apple's source. This should give us the advantage that at least the patched discussed in "Restoring missing functionality" above will already be in-place and well-tested.