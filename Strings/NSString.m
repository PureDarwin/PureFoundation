/*
 *	PureFoundation -- http://puredarwin.org
 *	NSString.m
 *
 *	NSString, NSMutableString and NSCFString
 *
 *	Created by Stuart Crook on 22/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

// TODO: Audit this class and work out what still needs implementing.

/*
 *	Inheritance runs: NSObject -> NSString -> NSMutableString -> __NSCFString. A single __NSCFString
 *	instance (which is the only string instance Foundation seems to create) can therefore do double-duty
 *	as both static and mutable strings.
 *
 *	In this current version, NSString and NSMutableString contain only the dummy instance methods
 *	necessary to keep the compiler happy. All actual instance methods for both are only included in
 *	the NSCFString class. HOWEVER -- and here I'm really not sure -- it might be an idea to implement
 *	versions which just use the primative -length and -characterAtIndex: so that any subclasses expecting
 *	to provide only these will still work. Does GNUStep do this?
 */

#import "NSString.h"
#import "PureFoundation.h"

#import <objc/runtime.h>


// CoreFoundation needs to be patched to expose this function
extern Boolean _CFStringIsMutable(CFStringRef string);

@implementation NSSimpleCString
@end
@implementation NSConstantString
@end

// exception raised by -propertyList
// TODO: Check where these are meant to be defined
NSString *const NSParseErrorException = @"NSParseErrorException";
NSString *const NSCharacterConversionException = @"NSCharacterConversionException";

// TOOD: Implement all NSString instance methods in terms of the primative methods (length, character at index)

// The NSString and NSMutableString interfaces to the class cluster return CFStringRef instances

@implementation NSString

#pragma mark - primatives

- (NSUInteger)length { return 0; }
- (unichar)characterAtIndex:(NSUInteger)index { return (unichar)NULL; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder { }

- (id)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
    free(self);
    return nil;
}

#pragma mark - immutable factory methods

+ (instancetype)string {
	return @"";
}

+ (instancetype)stringWithString:(NSString *)string {
    if (!string) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
	return [(id)CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

+ (instancetype)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length {
    if (!characters) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    return [(id)CFStringCreateWithCharacters(kCFAllocatorDefault, characters, length) autorelease];
}

+ (id)stringWithUTF8String:(const char *)nullTerminatedCString {
    if (!nullTerminatedCString) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    return [(id)CFStringCreateWithCString(kCFAllocatorDefault, nullTerminatedCString, kCFStringEncodingUTF8) autorelease];
}

+ (id)stringWithFormat:(NSString *)format, ... {
    if (!format) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
	va_list args;
	va_start(args, format);
    CFStringRef string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, (CFStringRef)format, args);
	va_end(args);
    return [(id)string autorelease];
}

+ (instancetype)localizedStringWithFormat:(NSString *)format, ... {
    if (!format) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
	va_list args;
	va_start(args, format);
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFStringRef string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, args);
    CFRelease(locale);
	va_end(args);
	return [(id)string autorelease];
}

+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)encoding {
    return [(id)CFStringCreateWithCString(kCFAllocatorDefault, cString, CFStringConvertNSStringEncodingToEncoding(encoding)) autorelease];
}

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
+ (id)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
    PF_TODO
//    PF_HELLO("")
//    return [[[self alloc] initWithContentsOfFile: path encoding: enc error: error] autorelease];
    return NULL;
}

+ (id)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    PF_TODO
//    PF_HELLO("")
//
//    if( [url isFileURL] )
//        return [[[self alloc] initWithContentsOfFile: [url path] encoding: enc error: error] autorelease];
//
//    return [[[self alloc] initWithContentsOfURL: url encoding: enc error: error] autorelease];
    return NULL;
}


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
+ (id)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    PF_TODO
//    PF_HELLO("")
//    return [[[self alloc] initWithContentsOfFile: path usedEncoding: enc error: error] autorelease];
    return NULL;
}

+ (id)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    PF_TODO
//    PF_HELLO("")
//
//    if( [url isFileURL] )
//        return [[[self alloc] initWithContentsOfFile: [url path] usedEncoding: enc error: error] autorelease];
//
//    return [[[self alloc] initWithContentsOfURL: url usedEncoding: enc error: error] autorelease];
    return NULL;
}

#pragma mark - immutable init methods

- (instancetype)init {
    free(self);
    return @"";
}

- (instancetype)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer {
    free(self);
    // Passing kCFAllocatorDefault will free it, while kCFAllocatorNull won't
    CFAllocatorRef allocator = freeBuffer ? kCFAllocatorDefault : kCFAllocatorNull;    
    return (id)CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, characters, length, allocator);
}

- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length {
    free(self);
    if (!characters) {
        [NSException raise:NSInvalidArgumentException format:@"TOD"];
    }
    return (id)CFStringCreateWithCharacters(kCFAllocatorDefault, characters, length);
}

- (id)initWithUTF8String:(const char *)nullTerminatedCString {
    free(self);
    if (!nullTerminatedCString) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    return (id)CFStringCreateWithCString(kCFAllocatorDefault, nullTerminatedCString, kCFStringEncodingUTF8);
}

- (id)initWithString:(NSString *)aString {
    free(self);
    if (!aString) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    return (id)CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)aString);
}

- (id)initWithFormat:(NSString *)format, ... {
    free(self);
    if (!format) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    va_list args;
    va_start(args, format);
    CFStringRef string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, (CFStringRef)format, args);
    va_end(args);
    return (id)string;
}

- (id)initWithFormat:(NSString *)format arguments:(va_list)argList {
    free(self);
    if (!format) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    return (id)CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, (CFStringRef)format, argList);
}

- (id)initWithFormat:(NSString *)format locale:(id)locale, ... {
    free(self);
    if (!format) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    va_list args;
    va_start(args, locale);
    // Passing in a CFLocaleRef like this is apparently completely valid
    CFStringRef string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, args);
    va_end(args);
    return (id)string;
}

- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList {
    free(self);
    if (!format) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    if (!locale) locale = (id)CFLocaleGetSystem();
    return (id)CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, argList);
}

- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    free(self);
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    return (id)CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, (CFDataRef)data, cfEncoding);
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding {
    free(self);
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    return (id)CFStringCreateWithBytes(kCFAllocatorDefault, bytes, length, cfEncoding, false);
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer {
    free(self);
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    // should the string be freed once we're finished?
    CFAllocatorRef allocator = freeBuffer ? kCFAllocatorDefault : kCFAllocatorNull;
    return (id)CFStringCreateWithBytesNoCopy(kCFAllocatorDefault, bytes, length, cfEncoding, false, allocator);
}

- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    free(self);
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    return (id)CFStringCreateWithCString(kCFAllocatorDefault, nullTerminatedCString, cfEncoding);
}

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
//    PF_HELLO("")
    free(self);
    if (!path) return nil;
//    PF_CHECK_STRING(self)
    
    
    
    CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
    
    // create the data object via NSData. Could use eg. a mapped file one day
    CFDataRef data = (CFDataRef)[NSData dataWithContentsOfFile: path];
    if( data == nil ) return nil;
    
    CFStringRef string = CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
    
    [(id)data release];
    
    return (id)string;
}

- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    PF_TODO
    /*
    
    
//    free(self); <-- when we do
    
    if( url == nil ) return nil;
    if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] encoding: enc error: error];
    
    PF_CHECK_STRING(self)
    
    CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
    
    // CFDataRef data = // load data via the URL. use streams?
    
    //self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
    
    // [(id)data release];
    
    PF_RETURN_STRING_INIT
     */
    return nil;
}


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (id)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    PF_TODO
    if( path == nil ) return nil;
//    PF_CHECK_STRING(self)
    
    //CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
    
    // create the data object via NSData. Could use eg. a mapped file one day
    CFDataRef data = (CFDataRef)[NSData dataWithContentsOfFile: path];
    if( data == nil ) return nil;
    
    //self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
    
    [(id)data release];
    
//    PF_RETURN_STRING_INIT
    
    return nil;
}

- (id)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    PF_TODO
    
    if( url == nil ) return nil;
    if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] encoding: enc error: error];
    
//    PF_CHECK_STRING(self)
    
    
    //CFStringCreateFromExternalRepresentation (
    //                                          CFAllocatorRef alloc,
    //                                          CFDataRef data,
    //                                          CFStringEncoding encoding
    //);
    
//    PF_RETURN_STRING_INIT
    
    return nil;
}

#pragma mark - utility

+ (NSStringEncoding)defaultCStringEncoding {
	return NSUTF8StringEncoding;
}

+ (const NSStringEncoding *)availableStringEncodings {
    static NSStringEncoding *nsEncodings = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const CFStringEncoding *cfEncodings = CFStringGetListOfAvailableEncodings();
        int count = 0;
        while (cfEncodings[count++] != kCFStringEncodingInvalidId) {}
        if (!count) return;
        nsEncodings = malloc(count * sizeof(NSStringEncoding));
        while (count--) {
            nsEncodings[count] = CFStringConvertEncodingToNSStringEncoding(cfEncodings[count]);
        }
    });
    return nsEncodings;
}

+ (NSString *)localizedNameOfStringEncoding:(NSStringEncoding)encoding {
	CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    return (id)CFStringGetNameOfEncoding(cfEncoding);
}

+ (NSString *)pathWithComponents:(NSArray *)components {
	return [components componentsJoinedByString:@"/"];
}

@end


@implementation NSMutableString

#pragma mark - mutable factory methods

+ (id)string {
    return [(id)CFStringCreateMutable(kCFAllocatorDefault, 0) autorelease];
}

+ (id)stringWithCapacity:(NSUInteger)capacity {
	return [(id)CFStringCreateMutable(kCFAllocatorDefault, capacity) autorelease];
}

+ (id)stringWithString:(NSString *)string {
    if (!string) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
	return [(id)CFStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFStringRef)string) autorelease];
}

+ (id)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length {
    if (!characters) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    CFStringRef string = CFStringCreateWithCharacters(kCFAllocatorDefault, characters, length);
    CFMutableStringRef mString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
    CFRelease(string);
    return [(id)mString autorelease];
}

+ (id)stringWithUTF8String:(const char *)nullTerminatedCString {
    if (!nullTerminatedCString) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    CFStringRef string = CFStringCreateWithCString(kCFAllocatorDefault, nullTerminatedCString, kCFStringEncodingUTF8);
    CFMutableStringRef mString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
    CFRelease(string);
    return [(id)mString autorelease];
}

// NOTE: Done up to here so far


+ (id)stringWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    
    CFStringRef string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, (CFStringRef)format, args);
    CFStringRef mString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
    
    //    id string = [[[self alloc] initWithFormat: format arguments: argList] autorelease];
    
    va_end(args);
    CFRelease(string);
    
    return [(id)mString autorelease];
}

// TODO: Haven't checked return from any of these below here

+ (instancetype)localizedStringWithFormat:(NSString *)format, ... {
    PF_HELLO("")
    PF_TODO // Need to check that this works
    
    va_list argList;
    va_start( argList, format );
    
    // retrieve the user's default locale
    //    id locale = nil; // [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]
    //    id string = [[[self alloc] initWithFormat: format locale: locale arguments: argList] autorelease];
    
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFStringRef string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, argList);
    CFRelease(locale);
    
    va_end( argList );
    
    return (id)string;
}


/*
 *    "Returns a string containing the bytes in a given C array, interpreted according to a given encoding."
 *
 *    This method was introduced in 10.4. Since we're targeting compatibility with 10.5, we can include it
 *    without making any checks.
 *
 *    As well as doing all the work for NSCFString -initWithCString:encoding:, this is also call from
 *    NSCFString -initWithUTF8String: and NSString +stringWithUTF8String:
 */
+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)encoding {
    PF_HELLO("")
    //    return [[[self alloc] initWithCString: cString encoding: enc] autorelease];
//    return (id)CFStringCreateWithCString(kCFAllocatorDefault, cString, CFStringConvertNSStringEncodingToEncoding(encoding));
    return [[super stringWithCString:cString encoding:encoding] mutableCopy];
}

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
+ (id)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error {
    PF_TODO
    //    PF_HELLO("")
    //    return [[[self alloc] initWithContentsOfFile: path encoding: enc error: error] autorelease];
    return [[super stringWithContentsOfFile:path encoding:enc error:error] mutableCopy];
}

+ (id)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    PF_TODO
    //    PF_HELLO("")
    //
    //    if( [url isFileURL] )
    //        return [[[self alloc] initWithContentsOfFile: [url path] encoding: enc error: error] autorelease];
    //
    //    return [[[self alloc] initWithContentsOfURL: url encoding: enc error: error] autorelease];
    return [[super stringWithContentsOfURL:url encoding:enc error:error] mutableCopy];
}


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
+ (id)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    PF_TODO
    //    PF_HELLO("")
    //    return [[[self alloc] initWithContentsOfFile: path usedEncoding: enc error: error] autorelease];
    return [[super stringWithContentsOfFile:path usedEncoding:enc error:error] mutableCopy];
}

+ (id)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    PF_TODO
    //    PF_HELLO("")
    //
    //    if( [url isFileURL] )
    //        return [[[self alloc] initWithContentsOfFile: [url path] usedEncoding: enc error: error] autorelease];
    //
    //    return [[[self alloc] initWithContentsOfURL: url usedEncoding: enc error: error] autorelease];
    return [[super stringWithContentsOfURL:url usedEncoding:enc error:error] mutableCopy];
}


#pragma mark - init

- (instancetype)init {
    return (id)CFStringCreateMutable(kCFAllocatorDefault, 0);
}

/*
 *    "Returns an initialized NSString object that contains a given number of bytes from a given C array
 *    of bytes in a given encoding, and optionally frees the array on deallocation."
 */
- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer {
    PF_HELLO("")
    //    PF_CHECK_STRING(self)

    free(self);

    // Passing kCFAllocatorDefault will free it, while kCFAllocatorNull won't
    CFAllocatorRef allocator = freeBuffer ? kCFAllocatorDefault : kCFAllocatorNull;

    return (id)CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault, characters, length, 0, allocator);
}


/*
 *    "Returns an initialized NSString object that contains a given number of characters from a given
 *    C array of Unicode characters." "Raises an exception [NSInvalidArgumentException?] if characters
 *    is NULL, even if length is 0."
 */
- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length {
    PF_HELLO("")
    //    PF_NIL_ARG(characters)
    //    PF_CHECK_STRING(self)
//    free(self);
//    return (id)CFStringCreateWithCharacters(kCFAllocatorDefault, characters, length);
    return [[super initWithCharacters:characters length:length] mutableCopy];
}

// "Returns an NSString object initialized by copying the characters a given C array of UTF8-encoded bytes."
- (id)initWithUTF8String:(const char *)nullTerminatedCString {
    PF_HELLO("")
    //    PF_CHECK_STRING(self)
//    free(self);
//    return (id)CFStringCreateWithCString(kCFAllocatorDefault, nullTerminatedCString, kCFStringEncodingUTF8);
    return [[super initWithUTF8String:nullTerminatedCString] mutableCopy];
}


// "Returns an NSString object initialized by copying the characters from another given string."
- (id)initWithString:(NSString *)aString {
    PF_HELLO("")
    //    PF_CHECK_STRING(self)
    free(self);
//    return (id)CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)aString);
    return (id)CFStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFStringRef)aString);
}


/*
 *    "Returns an NSString object initialized by using a given format string as a template into which
 *    the remaining argument values are substituted." "Raises an NSInvalidArgumentException if format
 *    is nil."
 */
- (id)initWithFormat:(NSString *)format, ...
{
    PF_HELLO("")
    PF_TODO // Because we need to pass the va_list into something which produces a mutable string
    
//    PF_CHECK_STRING(self)
    
    free(self);
    
    va_list argList;
    va_start( argList, format );
    
    self = (id)CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, argList );
    
    va_end( argList );
//    PF_RETURN_STRING_INIT
    return self;
}


/*
 *    "Returns an NSString object initialized by using a given format string as a template into which
 *    the remaining argument values are substituted according to the user’s default locale."
 */
- (id)initWithFormat:(NSString *)format arguments:(va_list)argList
{
    PF_HELLO("")
    PF_TODO // Because this needs to return a mutable string
//    PF_CHECK_STRING(self)
    
    free(self);
    
    self = (id)CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, argList );
    
//    PF_RETURN_STRING_INIT
    return self;
}


/*
 *    "Returns an NSString object initialized by using a given format string as a template into which
 *    the remaining argument values are substituted according to given locale information."
 */
- (id)initWithFormat:(NSString *)format locale:(id)locale, ...
{
    PF_HELLO("")
    PF_TODO // Because this needs to return a mutable string
//    PF_CHECK_STRING(self)
    
    free(self);
    
    va_list argList;
    va_start( argList, locale );
    
    // trawling through the CF code, it seems that it can take a locale object here, so...
    self = (id)CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, argList );
    
    va_end( argList );
//    PF_RETURN_STRING_INIT
    return self;
}


/*
 *    "Returns an NSString object initialized by using a given format string as a template into which
 *    the remaining argument values are substituted according to given locale information."
 *
 *    This method actually does all of the work for the other ...Format... NSString and NSCFString
 *    methods.
 */
- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList {
    free(self);
    if (!format) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    if (!locale) locale = (id)CFLocaleGetSystem();
    CFStringRef string = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, argList);
    CFMutableStringRef mString = CFStringCreateMutableCopy(kCFAllocatorNull, 0, string);
    CFRelease(string);
    return (id)mString;
}

- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    free(self);
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    CFStringRef string = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, (CFDataRef)data, cfEncoding);
    CFMutableStringRef mString = CFStringCreateMutableCopy(kCFAllocatorNull, 0, string);
    CFRelease(string);
    return (id)mString;
}


/*
 *    "Returns an initialized NSString object containing a given number of bytes from a given C array
 *    of bytes in a given encoding."
 */
- (id)initWithBytes:(const void *)bytes
             length:(NSUInteger)len
           encoding:(NSStringEncoding)encoding
{
    PF_HELLO("")
    PF_TODO // return a mutable version
//    PF_CHECK_STRING(self)
    
    free(self);
    
    // convert the string encoding
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    
    // yes, we're just assuming that this isn't an external representation
    self = (id)CFStringCreateWithBytes( kCFAllocatorDefault, bytes, len, enc, FALSE );
//    PF_RETURN_STRING_INIT
    return self;
}


/*
 *    "Returns an initialized NSString object that contains a given number of bytes from a given C array
 *    of bytes in a given encoding, and optionally frees the array on deallocation."
 *
 *    //#if MAC_OS_X_VERSION_10_3 <= MAC_OS_X_VERSION_MAX_ALLOWED
 */
- (id)initWithBytesNoCopy:(void *)bytes
                   length:(NSUInteger)len
                 encoding:(NSStringEncoding)encoding
             freeWhenDone:(BOOL)freeBuffer
{
    PF_HELLO("")
    PF_TODO // return a mutable version
//    PF_CHECK_STRING(self)
    
    free(self);
    
    // convert the string encoding
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    
    // should the string be freed once we're finished?
    CFAllocatorRef allocator = freeBuffer ? kCFAllocatorDefault : kCFAllocatorNull;
    
    // again, we're just assuming that this isn't an external representation
    self = (id)CFStringCreateWithBytesNoCopy( kCFAllocatorDefault, bytes, len, enc, FALSE, allocator );
//    PF_RETURN_STRING_INIT
    return self;
}

/*
 *    "Returns an NSString object initialized using the characters in a given C array, interpreted
 *    according to a given encoding."
 *
 *    Like -initWithUTF8String: this invokes NSString +stringWithCString:encoding:
 */
- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding
{
    PF_HELLO("")
    PF_TODO // Return a mutable version
//    PF_CHECK_STRING(self)
    
    free(self);
    
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    
    self = (id)CFStringCreateWithCString( kCFAllocatorDefault, nullTerminatedCString, enc );
    
    //NSLog(@"0x%X", self);
    
//    PF_RETURN_STRING_INIT
    return self;
}


- (id)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFStringCreateMutable(kCFAllocatorDefault, capacity);
}


/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
    PF_HELLO("")
    PF_TODO // return a mutable version
    if( path == nil ) return nil;
//    PF_CHECK_STRING(self)
    
    free(self);
    
    CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
    
    // create the data object via NSData. Could use eg. a mapped file one day
    CFDataRef data = (CFDataRef)[NSData dataWithContentsOfFile: path];
    if( data == nil ) return nil;
    
    self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
    
    [(id)data release];
    
//    PF_RETURN_STRING_INIT
    return nil;
}


- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    PF_TODO // return a mutable version
    
    //    free(self); <-- when we do
    
    if( url == nil ) return nil;
    if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] encoding: enc error: error];
    
//    PF_CHECK_STRING(self)
    
    CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
    
    // CFDataRef data = // load data via the URL. use streams?
    
    //self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
    
    // [(id)data release];
    
//    PF_RETURN_STRING_INIT
    return nil;
}


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (id)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    PF_TODO // return mutable version
    if( path == nil ) return nil;
//    PF_CHECK_STRING(self)
    
    //CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
    
    // create the data object via NSData. Could use eg. a mapped file one day
    CFDataRef data = (CFDataRef)[NSData dataWithContentsOfFile: path];
    if( data == nil ) return nil;
    
    //self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
    
    [(id)data release];
    
//    PF_RETURN_STRING_INIT
    return nil;
}

- (id)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error {
    PF_TODO // return a mutable version
    
    if( url == nil ) return nil;
    if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] encoding: enc error: error];
    
//    PF_CHECK_STRING(self)
    
    
    //CFStringCreateFromExternalRepresentation (
    //                                          CFAllocatorRef alloc,
    //                                          CFDataRef data,
    //                                          CFStringEncoding encoding
    //);
    
//    PF_RETURN_STRING_INIT
    return nil;
}


#pragma mark - primative

// NSMutableString's sole defining feature. (Dummy method to please the compiler.)
// TODO: Do we want to implement this with CFString's version? If we implement all NSString and NSMutableString methods in terms of their atomic methods (the ones described in the notes on subclassing NSString) then we'll need these to test that they work
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString { }

@end
