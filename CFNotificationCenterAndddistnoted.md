# Introduction #

CFLite does not contain the code for the CFNotificationCenter types. This is a pain because at least a couple of key components (one of configd's children and DirectoryServices) are big fans of the whole "distributed notifications" thing. So I guess we'd better patch support back in.

# Daemons and notifications #

Under grown-up OS X, distributed (system-wide) notifications are handled by two components: there's the client code in CoreFoundation and Foundation, and the daemon `distnoted` which handles passing the notifications between interested parties. Of curse, `distnoted` is not open source.

`ddistnoted` (note that cunning extra 'd') is our version. The binary root available from the downloads page includes the .plist necessary to have launchd launch it at system start. To make use of it you will also need a patched CFLite. Any of the versions available from here with a patch level beyond 9 will include the necessary client code.

Examining the output produced by passing the `-verbose` argument shows that both `configd` and `DirectoryService` connect to `ddistnoted` at start-up.