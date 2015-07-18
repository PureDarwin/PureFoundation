# Introduction #

The main difference between PureFoundation and other Foundation/Cocoa clones (such as GNUStep or Cocotron) is that PureFoundation implements a bridge to the open-source CFLite in the same way that Apple's Foundation bridges to the full CoreFoundation. This page details how this was achieved, and some of the points you need to consider when developing PureFoundation. (When developing _with_ PureFoundation you should treat it exactly as you would 'proper' Foundation.)

## Bridged classes ##

As of v0.0009 (5/3/09) the following CFLite types have been bridged to their Foundation equivalents: CFArray, CFCalendar, CFCharacterSet, CFData, CFDate, CFDictionary, CFError, CFLocale, CFNumber (and CFBoolean), CFReadStream, CFWriteStream, CFRunLoopTimer, CFSet, CFTimeZone and CFURL. (CFAttributedString is not supported by CFLite.)

## Bridging to CFLite ##

For the basics of bridging you can do far worse than reading [this](http://www.cocoadev.com/index.pl?BridgingForFunAndProfit) discussion. The key to bridging is that CF type structures reserve room for the most important feature of objective-C objects: the isa pointer. This is a 4- (or under 64-bit, 8-) byte pointer at the start of the type/object data. This points to the class table for an object, and is used by the runtime to bind messages to the appropriate methods. Under CFLite, this is always set to 0. (Okay, _almost_ always. The exception is for constant strings, which we'll mention a little later.)

In order to get the obj-C runtime to treat CFLite types as first-class objects, we're going to have to fill this with a pointer to the appropriate bridged class. Rummaging through the CFLite source code, we find that in a couple of places (most notably, in `_CFRuntimeCreateInstance()` in CFRuntime.c) this value is set to the return from `__CFISAForTypeID()`. This in turn is defined in CFInternal.h as a no-op, returning 0 no matter what. Luckily it is still correctly passed the CFTypeID wherever it appears in the code, so it's just a matter of replacing this with a function which returns a pointer to the relevant Class structure.

The other function which plays a key role in bridging is `_CFRuntimeBridgeClasses()`. This is also to be found in CFRuntime.c, and is also a no-op in CFLite. (You can still find a couple of calls to it, commented out, in the 476.17 source.) How exactly Apple handled the bridging is not clear, however, so if you check the patch you'll see we just cobbled-together a simple table of CFTypeID-Class pointer pairs. Not particularly elegant, but it works.

Calls to `_CFRuntimeBridgeClasses()` are made (mostly) during the `__CFInitialize()` function, as the types they bridge to are added to CFLite's runtime environment.

### Constant strings ###

Getting constant, compiler-created strings (@"these" and CFSTR("these")) to bridge had me puzzled for a while. The clue was that even while all other CFLite types had their class pointer set to 0, in constant strings this had another value. A blog post I've unfortunately lost track of finally pointed me towards the `__CFConstantStringClassReference[]` array (again, in CFRuntime.c). It is to this which the constant strings' isa points. By filling it with the same Class info as PureFoundation's own NSCFConstantString class it was able to inherit all of its behaviour. (We used a sub-class of the NSCFString class to short-circuit certain methods which wouldn't make sense if invoked on a constant object, such as adding them to an autorelease pool.)

### The bridged classes ###

Many classes in Cocoa (and before it NeXT/OpenStep) are described as class clusters: public front-ends to groups of opaque private classes. What this basically means is that even though you think you're creating (for instance) an NSString, what you actually get back is one of NSString's private subclasses (very often an NSCFString). This is how the magic of bridging happens. (It's also just as well, because NSString doesn't declare any extra ivars beyond its isa, and implementing a string store without any kind of storage is likely to be tricky.) Under PureFoundation, when you ask for an NSString, what you actually get back is a CFString with an isa set up to tell the obj-C runtime that it is an NSCFString. Without much effort proper OS X-style toll-free bridging is achieved: pass it into a CF function or send it an obj-C message, either way it will behave as expected.

One point to note is that there are no explicitly-mutable bridged classes. As far as CF is concerned, a CFString and a CFMutableString are exactly the same type (they even share the same type ID), with the only difference existing as a mutable flag tucked-away somewhere in their headers. This makes life both easier and harder for us. Our inheritance tree can be simplified for one thing. Inheritance simply runs: NSObject -> NSString -> NSMutableString -> NSCFString -> NSCFConstantString. But we still need to know whether the underlying CF type is mutable and whether we should allow code to invoke mutable-class methods. CF provides private functions for just this (eg. `_CFStringIsMutable()`), and a quick patch makes them available to PureFoundation.

Of the bridged classes, CFURL/NSCFURL is an anomaly. NSCFURL is not actually a CFURL type. Instead, it is an obj-C object which holds a reference to a CFURL type. This is what CFLite expects: it includes the code needed to send the NSCFURL object the private `_cfurl` message needed to return the CFURL type.

### Foundation vs. CoreFoundation ###

Even looking at the eviscerated CFLite source it's clear to see that as far as Apple is concerned Foundation wears the trousers in the Foundation-CoreFoundation marriage. Whenever possible, CF will despatch an obj-C message to fulfil a CF function rather than using its own code. Now, this is fine when you've got a well-developed obj-C library to call upon, but it's of absolutely no use to us. Luckily, all these message despatches are #defined as no-ops in the CFLite source.

In PureFoundation, CFLite is clearly in the driving seat, with CF functions used to satisfy almost all requests. The majority of the bridged classes' methods simply wrap CF function calls, checking and translating arguments on their way in and out. All bridged classes also use the CF retain/release mechanism. (This was adopted around v0.0009 of PureFoundation. Prior to that, all bridged classes used the obj-C retain/release mechanism... which lead to their deallocator functions never being called, resulting in a veritable plethora of seg faults and bus errors. The new way is better.)

All obj-C objects are also allocated from the default CF memory pool. It is hoped that this will magically bless them with garbage-collectability, although this has yet to be put to the test.

### Almost-bridged classes ###

CFLite is the gift that keeps on giving. In addition to the toll-free bridged types, it also provides a number of types which do things Foundation does, just not using the same objects. Among these are runloops, number formatters, and sockets. They all help to reduce the amount of work needed to replicate the functionality of Foundation.