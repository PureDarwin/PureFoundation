# Introduction #

If you just want to try out PureFoundation you'll probably be better off using the pre-compiled binaries available from the [downloads page](http://code.google.com/p/purefoundation/downloads/list). Otherwise, read on.

## Building CFLite ##

CFLite is built using the `darwinbuild` script and environment, available from [MacOSForge](http://darwinbuild.macosforge.org/). It is always a good idea to be running the latest version pulled from svn, since new bug-fixes and enhancements are frequently added.

You should also be building using the [PureDarwin patches](http://www.puredarwin.org/developers/darwinbuild/patchfiles), since these add common fixes which PureFoundation relies upon.

For the rest of this discussion we will assume that your `darwinbuild` path is `/Volumes/dbuf/9G55`. It doesn't matter if it isn't. The patch has been tested with 9F33 and 9G55.

### Updating the PureDarwin patches ###

At the time of writing, it's necessary to update the patch file automatically downloaded from the PureDarwin project. When this is changed, these instructions will be removed. Until then...

  1. Run `darwinbuild CF` once, to ensure that the patch files are downloaded.
  1. Download the file "`CF-476.15.CFBundle_Resources.p1.patch`" from the [downloads page](http://code.google.com/p/purefoundation/downloads/list).
  1. Copy the downloaded patch into the Sources directory, over-writing the PureDarwin patch of the same name.
```
cp ~/Downloads/http://code.google.com/p/purefoundation/downloads/list /Volumes/dbufs/9G55/Source/
```

The updated patch will now be applied each time you build CF.

### Building the patched CFLite ###

  1. Change into the Source directory and un-tar the CFLite source tarball.
```
cd Sources/
tar xfvz CF-476.17.tar.gz
```
  1. Download the latest PureFoundation patch from the [downloads page](http://code.google.com/p/purefoundation/downloads/list). (At the time of writing this was "`CF-476.15.pf6.patch`".) (Don't worry about the different CFLite version numbers - the source doesn't change that much between releases.)
  1. Change into the CFLite source directory and apply the patch.
```
cd CF-476.17/
patch -p1 -r . < ~/Downloads/CF-476.15.pf6.patch
```
  1. Change back to the main `darwinbuild` directory and build CFLite.
```
cd ../..
darwinbuild CF
```

`darwinbuild` will apply the PureDarwin patches to the patched source code.