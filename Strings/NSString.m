/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSString.m
 *
 *	NSString, NSMutableString and NSCFString
 *
 *	Created by Stuart Crook on 22/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/*
 *	Inheritance runs: NSObject -> NSString -> NSMutableString -> NSCFString. A single NSCFString
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

//#include "../CF-476.15.patched/CFString.h" // PF_PATH_TO_CF

/*
 *	This macro will check whether an NSCFString is mutable and raise an exception if it isn't. This
 *	will require patching CFLite to have it export __CFStringIsMutable
 *
 *	Alter to display _cmd as part of output?
 */
#define PF_CHECK_STRING(str) BOOL isMutable; \
	if( str == (id)&_PFNSCFStringClass ) isMutable = NO; \
	else if( str == (id)&_PFNSCFMutableStringClass ) isMutable = YES; \
	else { isMutable = __CFStringIsMutable((CFStringRef)str); [str autorelease]; }

// we're okay straight releasing this object because we only just created it
#define PF_RETURN_STRING_INIT if( isMutable == YES ) { id old = self; self = (id)CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)old ); [old release]; } \
	PF_RETURN_NEW(self)

#define PF_CHECK_STR_MUTABLE(str) if( !__CFStringIsMutable((CFStringRef)str) ) \
	[NSException raise: NSInvalidArgumentException format: [NSString stringWithCString: "Attempting mutable string op on a static NSString" encoding: NSUTF8StringEncoding]];


/*
 *	The NSCFString class. Has no instance variables, because it's never actually created as an
 *	objective-C object -- instead, a CFString object is created and used it its place.
 */
@interface NSCFString : NSMutableString
@end


/*
 *	Attempt to get constant strings working, generally ignored
 */
@implementation NSSimpleCString
@end
@implementation NSConstantString
@end



/*
 *	These variables hold the NSCFString Class objects. Their addresses are returned by +alloc so that
 *	the runtime can direct -init... calls to the correct object methods, because a pointer to a single
 *	Class var is basically all most objects are.
 */
static Class _PFNSCFStringClass = nil;
static Class _PFNSCFMutableStringClass = nil;


/*
 *	exception raised by -propertyList
 */
NSString * const NSParseErrorException = @"NSParseErrorException";
NSString * const NSCharacterConversionException = @"NSCharacterConversionException";


/*
 *	NSString is an abstract class cluster factory wossname. Its sole purpose in life is to crank out
 *	private subclasses.
 */
@implementation NSString

/*
 *	Set up the _PFNSStringClass dummy object
 */
+ (void)initialize {
	PF_HELLO("")
    if (self == [NSString class]) {
		_PFNSCFStringClass = objc_getClass("NSCFString");
    }
}

/*
 *	Return a pointer to _PFNSStringClass, which will act exactly like a newly-allocated NSString
 *	object, with out us going to the trouble of allocating one.
 */
+ (id)alloc {
	PF_HELLO("")
    if (self == [NSString class]) {
		return (id)&_PFNSCFStringClass;
    }
	return [super alloc];
}


/** 
 *	THE PRIMATIVE FUNCTION -- These are basically no-ops to satisfy the compiler, and so anyone else's
 *	NSString subclass doesn't inherit our screwy CFString-based version.
 **/
- (NSUInteger)length { return 0; }
- (unichar)characterAtIndex:(NSUInteger)index { return (unichar)NULL; }

/**	NSCopying COMPLIANCE **/
- (id)copyWithZone:(NSZone *)zone { return nil; }

/** NSMutableCopying COMPLIANCE **/
- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }


/*
 *	CLASS METHODS
 *
 *	These methods call the relevant CF function, bless the returned CFString (to turn it into an
 *	NSCFString) and then return it.
 */


/*
 *	Similar to -init... compiler optimisations should mean it returns the exact same object.
 */
+ (id)string
{
	PF_HELLO("")
	return @"";
}


/*
 *	Create a new NSCFString with the contents of string, using the CF function. Also invoked by
 *	NSCFString -initWithString:.
 */
+ (id)stringWithString:(NSString *)string
{
	PF_HELLO("")
	CFStringRef str = CFStringCreateCopy( kCFAllocatorDefault, (CFStringRef)string );
	PF_RETURN_TEMP(str)
}


/*
 *	Create a new NSCFString from an array of unicode characters
 */
+ (id)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length
{
	PF_HELLO("")
	PF_NIL_ARG(characters)
	
	return [[[self alloc] initWithCharacters: characters length: length] autorelease];
}


/*
 *	Create a new string from a NULL-terminated C string of UTF8 characters
 *
 *	Calls [NSString +stringWithCString: ~ encoding: NSUTF8...] ????
 */
+ (id)stringWithUTF8String:(const char *)nullTerminatedCString
{
	PF_HELLO("")
	return [[[self alloc] initWithUTF8String: nullTerminatedCString] autorelease];
}


/*
 *	"Returns a string created by using a given format string as a template into which the remaining 
 *	argument values are substituted."
 */
+ (id)stringWithFormat:(NSString *)format, ...
{
	PF_HELLO("")
	
	va_list argList;
	va_start( argList, format );

	id string = [[[self alloc] initWithFormat: format arguments: argList] autorelease];
	
	va_end( argList );
	return string;
}


/*
 *	"Returns a string created by using a given format string as a template into which the remaining
 *	argument values are substituted according to the user's default locale."
 */
+ (id)localizedStringWithFormat:(NSString *)format, ...
{
	PF_HELLO("")
	
	va_list argList;
	va_start( argList, format );
	
	// retrieve the user's default locale
	id locale = nil; // [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]
	
	id string = [[[self alloc] initWithFormat: format locale: locale arguments: argList] autorelease];

	va_end( argList );
	return string;
}


/*
 *	"Returns a string containing the bytes in a given C array, interpreted according to a given encoding."
 *
 *	This method was introduced in 10.4. Since we're targeting compatibility with 10.5, we can include it
 *	without making any checks.
 *
 *	As well as doing all the work for NSCFString -initWithCString:encoding:, this is also call from
 *	NSCFString -initWithUTF8String: and NSString +stringWithUTF8String:
 */
+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc
{
	PF_HELLO("")
	return [[[self alloc] initWithCString: cString encoding: enc] autorelease];
}

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
+ (id)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfFile: path encoding: enc error: error] autorelease];
}

+ (id)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
	PF_HELLO("")
	
	if( [url isFileURL] ) 
		return [[[self alloc] initWithContentsOfFile: [url path] encoding: enc error: error] autorelease];
	
	return [[[self alloc] initWithContentsOfURL: url encoding: enc error: error] autorelease];
}


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
+ (id)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfFile: path usedEncoding: enc error: error] autorelease];
}

+ (id)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
	PF_HELLO("")

	if( [url isFileURL] ) 
		return [[[self alloc] initWithContentsOfFile: [url path] usedEncoding: enc error: error] autorelease];
	
	return [[[self alloc] initWithContentsOfURL: url usedEncoding: enc error: error] autorelease];
}



/* User-dependent encoding who value is derived from user's default language and potentially other factors. The use of this encoding might sometimes be needed when interpreting user documents with unknown encodings, in the absence of other hints.  This encoding should be used rarely, if at all. Note that some potential values here might result in unexpected encoding conversions of even fairly straightforward NSString content --- for instance, punctuation characters with a bidirectional encoding.
 */

/*
 *	Returns the C-string encoding assumed for any method accepting a C string as an argument. Currently this 
 *	always returns NSUTF8StringEncoding, which we will be using as the default encoding until we get user
 *	locales up and running.
 */
+ (NSStringEncoding)defaultCStringEncoding	// Should be rarely used
{
	PF_HELLO("")
	return NSUTF8StringEncoding;
}

/*
 *	"Returns a zero-terminated list of the encodings string objects support in the application’s 
 *	environment."
 *
 *	Calls the CF function, then walks the returned list converting each to their corresponding version.
 *
 *	Allocate a block of memory and store this after the first time we build it?
 */
+ (const NSStringEncoding *)availableStringEncodings
{
	PF_TODO

	int i = 0;
	const CFStringEncoding *cf_encs = CFStringGetListOfAvailableEncodings();
	
	// claculate the length of the encoding we just recieved
	while( cf_encs[i] != kCFStringEncodingInvalidId ) i++;
	
	if( i == 0 ) return NULL;
	
	//printf("-- encoding returned %d encodings\n");
	
	NSStringEncoding *ns_encs = calloc( i, sizeof(NSStringEncoding) );

	while( *cf_encs != 0 )
		*ns_encs++ = CFStringConvertEncodingToNSStringEncoding( *cf_encs++ );

	return (const NSStringEncoding *)cf_encs;
}

/*
 *	"Returns a human-readable string giving the name of a given encoding."
 */
+ (NSString *)localizedNameOfStringEncoding:(NSStringEncoding)encoding
{
	CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	
	if( cf_enc == kCFStringEncodingInvalidId )
		return [NSString stringWithString: @"Unknown Encoding"];	// should localised
	else
		PF_RETURN_NEW( CFStringGetNameOfEncoding(cf_enc) )	// should localise
}



/*
 *	NSString (NSStringPathExtensions) methods, defined in NSPathUtilities. From the docs
 *	this is meant to be really simple, with the caller responsible for it working correctly. 
 */
+ (NSString *)pathWithComponents:(NSArray *)components 
{
	PF_HELLO("")
	return [components componentsJoinedByString: @"/"];
}

@end





/*
 *	NSMutableString is an abstract class which will produce NSCFStrings from its class methods, most of
 *	which it inherits from NSString.
 *
 *	This class should (can?) never be instiantated. The only instance methods defined are therefore dummies
 *	designed to keep the compiler happy.
 *
 *	Should this re-implement all of NSString class creation methods to return a mutable version? Because I
 *	think CFStrings and CFMutableStrings are the same item. Need to test whether a NSCFString created via
 *	an NSString method works correctly with NSMutableString functions.
 */

/*
 *	"Returns an empty NSMutableString object with initial storage for a given number of characters."
 *
 *	Since capacity is meant to be a hint, and CFString doesn't take that hint, capacity is ignored.
 */
@implementation NSMutableString

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSMutableString class] )
		_PFNSCFMutableStringClass = objc_getClass("NSCFString");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSMutableString class] )
		return (id)&_PFNSCFMutableStringClass;
	return [super alloc];
}

// NSMutableString specific
+ (id)stringWithCapacity:(NSUInteger)capacity
{
	PF_HELLO("")
	CFMutableStringRef str = CFStringCreateMutable( kCFAllocatorDefault, 0 );
	// apply capacity hint here...
	PF_RETURN_TEMP(str)
}


/*
 *	NSString factory creation methods, re-implemented to return mutable copies
 */
+ (id)string
{
	PF_HELLO("")
	CFMutableStringRef str = CFStringCreateMutable( kCFAllocatorDefault, 0 );
	PF_RETURN_TEMP(str)
}
 
+ (id)stringWithString:(NSString *)string
{
	PF_HELLO("")
	CFMutableStringRef str = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)string );
	PF_RETURN_TEMP(str)
}


/*
 *	NSMutableString's sole defining feature. (Dummy method to please the compiler.)
 */
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString { }

@end





/*
 *	NSCFString is basically a CFString with its _cfisa set to NSCFString. When you talk about toll-free
 *	bridging it is actually this class (and not NSString, which can never be created) which can be used
 *	between CF and Foundation.
 *
 *	Defined here -- before NSString -- to please the compiler, because NSString calls it.
 *
 *	Because we never create an NSCFString as an objective-C object, we don't need to allocate it any
 *	storage.
 */

@implementation NSCFString

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

/*
 *	Undocumented method used by Apple to support bridging
 */
-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFStringGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

// "Returns the receiver." We give it an extra retain because CF functions will expect
//	a copy
-(NSString *)description
{
	PF_HELLO("")
	return (NSString *)CFRetain((CFTypeRef)self);
	//(NSString *)CFStringCreateCopy( kCFAllocatorDefault, (CFStringRef)self ); //CFCopyDescription((CFTypeRef)self);
}

/**	NSCopying COMPLIANCE **/

/*
 *	Return a copy of self, via the CF function. Zone is ignored and the string is allocated from the
 *	default zone.
 */
- (id)copyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	PF_RETURN_NEW(CFStringCreateCopy( kCFAllocatorDefault, (CFStringRef)self ))
}

/** NSMutableCopying COMPLIANCE **/

/*
 *	Return an NSCFMutableString via the CF function
 */
- (id)mutableCopyWithZone:(NSZone *)zone
{
	//PF_HELLO("")
	//NSLog( @"Copying '%@'", self );
	PF_RETURN_NEW(CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self ))
}

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder
{

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}


/*
 *	Returns an empty NSString. To be exact, it returns a reference to this common empty NSString.
 *
 *	Which currently makes no checks to see if this chould be mutable or not... two _PFNSCFStringClass vars,
 *	one for mutable, the other for immutable ???
 */
-(id)init
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	if( isMutable == NO )
		self = (id)CFStringCreateCopy( kCFAllocatorDefault, CFSTR("") );
	else
		self = (id)CFStringCreateMutable( kCFAllocatorDefault, 0 );
	
	PF_RETURN_NEW(self)
}


/*
 *	"Returns an initialized NSString object that contains a given number of bytes from a given C array 
 *	of bytes in a given encoding, and optionally frees the array on deallocation."
 */
- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	/*	Should the string be freed upon deallocation? Passing kCFAllocatorDefault will free it, while
	 kCFAllocatorNull won't */
	CFAllocatorRef allocator = freeBuffer ? kCFAllocatorDefault : kCFAllocatorNull;
	
	self = (id)CFStringCreateWithCharactersNoCopy( kCFAllocatorDefault, characters, length, allocator );

	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an initialized NSString object that contains a given number of characters from a given 
 *	C array of Unicode characters." "Raises an exception [NSInvalidArgumentException?] if characters 
 *	is NULL, even if length is 0."
 */
- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length
{
	PF_HELLO("")
	PF_NIL_ARG(characters)
	PF_CHECK_STRING(self)
	
	self = (id)CFStringCreateWithCharacters( kCFAllocatorDefault, characters, length );

	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an NSString object initialized by copying the characters a given C array of UTF8-encoded 
 *	bytes."
 */
- (id)initWithUTF8String:(const char *)nullTerminatedCString
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	self = (id)CFStringCreateWithCString( kCFAllocatorDefault, nullTerminatedCString, kCFStringEncodingUTF8 );

	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an NSString object initialized by copying the characters from another given string."
 */
- (id)initWithString:(NSString *)aString
{
	PF_HELLO("")	
	PF_CHECK_STRING(self)
	
	if( isMutable == NO )
		self = (id)CFStringCreateCopy( kCFAllocatorDefault, (CFStringRef)aString );
	else
		self = (id)CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)aString );
	
	PF_RETURN_NEW(self)
}


/*
 *	"Returns an NSString object initialized by using a given format string as a template into which 
 *	the remaining argument values are substituted." "Raises an NSInvalidArgumentException if format 
 *	is nil."
 */
- (id)initWithFormat:(NSString *)format, ...
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	va_list argList;
	va_start( argList, format );
	
	self = (id)CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, argList );

	va_end( argList );
	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an NSString object initialized by using a given format string as a template into which 
 *	the remaining argument values are substituted according to the user’s default locale."
 */
- (id)initWithFormat:(NSString *)format arguments:(va_list)argList
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	self = (id)CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, argList );

	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an NSString object initialized by using a given format string as a template into which 
 *	the remaining argument values are substituted according to given locale information."
 */
- (id)initWithFormat:(NSString *)format locale:(id)locale, ...
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	va_list argList;
	va_start( argList, locale );
	
	// trawling through the CF code, it seems that it can take a locale object here, so...
	self = (id)CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, argList );

	va_end( argList );
	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an NSString object initialized by using a given format string as a template into which
 *	the remaining argument values are substituted according to given locale information."
 *
 *	This method actually does all of the work for the other ...Format... NSString and NSCFString
 *	methods.
 */
- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList
{
	PF_HELLO("Ignores locale")
	PF_CHECK_STRING(self)
	
	// set up the locale
	if( locale == nil ) locale = CFLocaleCopyCurrent();

	self = (id)CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, (CFDictionaryRef)locale, (CFStringRef)format, argList );

	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an NSString object initialized by converting given data into Unicode characters using 
 *	a given encoding."
 */
- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	// fix the string encoding
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	
	self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, (CFDataRef)data, enc );

	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an initialized NSString object containing a given number of bytes from a given C array 
 *	of bytes in a given encoding."
 */
- (id)initWithBytes:(const void *)bytes 
			 length:(NSUInteger)len 
		   encoding:(NSStringEncoding)encoding
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	// convert the string encoding
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	
	// yes, we're just assuming that this isn't an external representation
	self = (id)CFStringCreateWithBytes( kCFAllocatorDefault, bytes, len, enc, FALSE );
	PF_RETURN_STRING_INIT
}


/*
 *	"Returns an initialized NSString object that contains a given number of bytes from a given C array 
 *	of bytes in a given encoding, and optionally frees the array on deallocation."
 *
 *	//#if MAC_OS_X_VERSION_10_3 <= MAC_OS_X_VERSION_MAX_ALLOWED
 */
- (id)initWithBytesNoCopy:(void *)bytes 
				   length:(NSUInteger)len 
				 encoding:(NSStringEncoding)encoding 
			 freeWhenDone:(BOOL)freeBuffer
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	// convert the string encoding
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	
	// should the string be freed once we're finished?
	CFAllocatorRef allocator = freeBuffer ? kCFAllocatorDefault : kCFAllocatorNull;
	
	// again, we're just assuming that this isn't an external representation
	self = (id)CFStringCreateWithBytesNoCopy( kCFAllocatorDefault, bytes, len, enc, FALSE, allocator );
	PF_RETURN_STRING_INIT
}

/*
 *	"Returns an NSString object initialized using the characters in a given C array, interpreted 
 *	according to a given encoding."
 *
 *	Like -initWithUTF8String: this invokes NSString +stringWithCString:encoding:
 */
- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	
	self = (id)CFStringCreateWithCString( kCFAllocatorDefault, nullTerminatedCString, enc );
	
	//NSLog(@"0x%X", self);
	
	PF_RETURN_STRING_INIT
}


- (id)initWithCapacity:(NSUInteger)capacity
{
	PF_HELLO("")
	PF_CHECK_STRING(self)
	
	if( isMutable == NO )
		[NSException raise: NSInternalInconsistencyException format: @""];
	
	self = (id)CFStringCreateMutable( kCFAllocatorDefault, 0 );
	// apply capacity hint...
	PF_RETURN_NEW(self)
}


/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
	PF_HELLO("")
	if( path == nil ) return nil;
	PF_CHECK_STRING(self)
	
	CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
	
	// create the data object via NSData. Could use eg. a mapped file one day
	CFDataRef data = (CFDataRef)[NSData dataWithContentsOfFile: path];
	if( data == nil ) return nil;
	
	self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
	
	[(id)data release];
	
	PF_RETURN_STRING_INIT
}


- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
	PF_TODO
	
	if( url == nil ) return nil;
	if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] encoding: enc error: error];
	
	PF_CHECK_STRING(self)
	
	CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);

	// CFDataRef data = // load data via the URL. use streams?

	//self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
	
	// [(id)data release];
	
	PF_RETURN_STRING_INIT
}


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (id)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
	PF_TODO
	if( path == nil ) return nil;
	PF_CHECK_STRING(self)
	
	//CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
	
	// create the data object via NSData. Could use eg. a mapped file one day
	CFDataRef data = (CFDataRef)[NSData dataWithContentsOfFile: path];
	if( data == nil ) return nil;
	
	//self = (id)CFStringCreateFromExternalRepresentation( kCFAllocatorDefault, data, cf_enc );
	
	[(id)data release];
	
	PF_RETURN_STRING_INIT
}

- (id)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
	PF_TODO

	if( url == nil ) return nil;
	if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] encoding: enc error: error];

	PF_CHECK_STRING(self)
	
	
	//CFStringCreateFromExternalRepresentation (
	//										  CFAllocatorRef alloc,
	//										  CFDataRef data,
	//										  CFStringEncoding encoding
	//);

	PF_RETURN_STRING_INIT
}


- (BOOL)writeToURL:(NSURL *)url 
		atomically:(BOOL)useAuxiliaryFile 
		  encoding:(NSStringEncoding)enc 
			 error:(NSError **)error
{
	PF_TODO
	
	if( url == nil ) return NO;
	if( [url isFileURL] ) return [self writeToFile: [url path] atomically: useAuxiliaryFile encoding: enc error: error];
	
	
	
}

- (BOOL)writeToFile:(NSString *)path 
		 atomically:(BOOL)useAuxiliaryFile 
		   encoding:(NSStringEncoding)enc 
			  error:(NSError **)error
{
	PF_HELLO("")
	
	if( path == nil ) return NO;
	
	CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(enc);
	// set error is encoding isn't available...
	NSData *data = (NSData *)CFStringCreateExternalRepresentation( kCFAllocatorDefault, (CFStringRef)self, cf_enc, 0 );
	// set error if creating data failed...
	BOOL result = [data writeToFile: path atomically: useAuxiliaryFile];
	// set error if writing failed...
	[data release];
	return result;
}

- (id)propertyList 
{ 
	PF_HELLO("")
	
	// covert the string into a data object
	NSData *data = (NSData *)CFStringCreateExternalRepresentation( kCFAllocatorDefault, (CFStringRef)self, kCFStringEncodingUTF8, 0 );
	if( data == nil )
		[NSException raise: NSParseErrorException format: nil];
	
	id plist = [NSPropertyListSerialization propertyListFromData: data mutabilityOption: NSPropertyListImmutable format:NULL errorDescription: NULL];
	if( plist == nil )
		[NSException raise: NSParseErrorException format: nil];

	[data release];
	PF_RETURN_TEMP(plist)
}


- (NSDictionary *)propertyListFromStringsFileFormat { }



/*	PRIMATIVES -- NSString proper */
/*
 *	Return the length of the managed string, using the CFString primative
 */
- (NSUInteger)length
{
	return (NSUInteger)(CFStringGetLength((CFStringRef)self));
}

/*
 *	Return the unicode character at index, using the CFString primative
 */
- (unichar)characterAtIndex:(NSUInteger)index
{
	return CFStringGetCharacterAtIndex((CFStringRef)self, (CFIndex)index);
}

/*
 *	STRING MANIPULATION METHODS
 */

- (void)getCharacters:(unichar *)buffer
{
	PF_HELLO("")
	
	NSRange aRange = NSMakeRange( 0, [self length] );
	[self getCharacters: buffer range: aRange];
}

/*
 *	""
 */
- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange
{
	PF_HELLO("")
	
	// should check that aRange is valid and raise NSRangeException if it isn't
	NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
	if( length == 0 ) return;
	
	if( (aRange.location >= length) || ((aRange.location+aRange.length) > length) )
		[NSException raise: NSRangeException format: [NSString stringWithCString: "Substring out of range" encoding: NSUTF8StringEncoding]];
	
	CFRange range = CFRangeMake( aRange.location, aRange.length );
	CFStringGetCharacters( (CFStringRef)self, range, buffer );	
}

/*
 *	"Returns a new string containing the characters of the receiver from the one at a given 
 *	index to the end."
 */
- (NSString *)substringFromIndex:(NSUInteger)from
{
	PF_HELLO("")
	
	NSUInteger length = [self length];
	if( from >= length ) 
		[NSException raise: NSRangeException format: [NSString stringWithCString: "Index out of range" encoding: NSUTF8StringEncoding]];
	
	NSRange range = NSMakeRange( from, (length-from) );
	return [self substringWithRange: range];
}

/*
 *	"Returns a new string containing the characters of the receiver up to, but not including, the 
 *	one at a given index."
 */
- (NSString *)substringToIndex:(NSUInteger)to
{
	PF_HELLO("")
	
	if( to >= ([self length]-1) )
		[NSException raise: NSRangeException format: [NSString stringWithCString: "Index out of range" encoding: NSUTF8StringEncoding]];

	NSRange range = NSMakeRange( 0, to );
	return [self substringWithRange: range];
}

/*
 *	"Returns a string object containing the characters of the receiver that lie within a given range."
 */
- (NSString *)substringWithRange:(NSRange)range
{
	PF_HELLO("")
	
	NSUInteger length = [self length];
	if( (range.location >= length) || ((range.location + range.length) > length) ) 
		[NSException raise: NSRangeException format: [NSString stringWithCString: "Bad range" encoding: NSUTF8StringEncoding]];
	
	CFRange cf_range = CFRangeMake( range.location, range.length );
	
	CFStringRef new = CFStringCreateWithSubstring( kCFAllocatorDefault, (CFStringRef)self, cf_range );
	PF_RETURN_TEMP(new)
}

/** Comparison functions **/

/*
 *	"Returns the result of invoking compare:options:range: with no options and the receiver’s 
 *	full extent as the range."
 *
 *	It may be faster to call CFStringCompare() here, but since I'm not sure how and whether that
 *	obeys locales, we'll stick to the way documented by Apple.
 */
- (NSComparisonResult)compare:(NSString *)string
{
	PF_HELLO("")
	//NSRange range = NSMakeRange( 0, [self length] );
	//return [self compare: string options: 0 range: range];
	CFStringCompare( (CFStringRef)self, (CFStringRef)string, 0 );
}

/*
 *	"Returns the result of invoking compare:options:range: with a given mask as the options 
 *	and the receiver’s full extent as the range."
 */
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask
{
	PF_HELLO("")
	//NSRange range = NSMakeRange( 0, [self length] );
	//return [self compare: string options: mask range: range];
	CFStringCompare( (CFStringRef)self, (CFStringRef)string, mask );
}

/*
 *	"Returns the result of invoking compare:options:range:locale: with a nil locale."
 *
 *	Well, almost.
 */
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange
{
	PF_HELLO("")

	NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
	if( (compareRange.location >= length) || ((compareRange.location+compareRange.length) > length) )
		[NSException raise: NSRangeException format: nil];
	CFRange range = CFRangeMake( compareRange.location, compareRange.length );
	
	// check option flags, restricting to the 3 allowed methods (although I'm not 100% sue that CF
	//		supports the literal search option...
	mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSNumericSearch);
	
	return CFStringCompareWithOptions( (CFStringRef)self, (CFStringRef)string, range, mask );
}

/*
 *	"Returns an NSComparisonResult value that indicates the lexical ordering of a specified range 
 *	within the receiver and a given string."
 *
 *	"Returns an NSComparisonResult value that indicates the lexical ordering of a specified 
 *	range within the receiver and a given string." "locale arg used to be a dictionary pre-Leopard. 
 *	We now accepts NSLocale. Assumes the current locale if non-nil and non-NSLocale."
 *
 *	"We now accepts"???
 *
 *	This method is invoked by the various convinience methods above.
 */
- (NSComparisonResult)compare:(NSString *)string 
					  options:(NSStringCompareOptions)mask 
						range:(NSRange)compareRange 
					   locale:(id)locale
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
	if( (compareRange.location >= length) || ((compareRange.location+compareRange.length) > length) )
		[NSException raise: NSRangeException format: nil];
	CFRange range = CFRangeMake( compareRange.location, compareRange.length );
	
	// check option flags, restricting to the 3 allowed methods (although I'm not 100% sue that CF
	//		supports the literal search option...
	mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSNumericSearch);
	
	// check locale, but allow through a dictionary
	if(locale == nil) locale = (NSLocale *)CFLocaleCopyCurrent();
	
	return CFStringCompareWithOptionsAndLocale( (CFStringRef)self, (CFStringRef)string, range, mask, (CFLocaleRef)locale);
}

/*
 *	"Returns the result of invoking compare:options: with NSCaseInsensitiveSearch as the only option."
 */
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string
{
	PF_HELLO("")
	//return [self compare: string options: NSCaseInsensitiveSearch];
	return CFStringCompare( (CFStringRef)self, (CFStringRef)string, kCFCompareCaseInsensitive );
}

/*
 *	"Returns an NSComparisonResult value that indicates the lexical ordering of the receiver and 
 *	another given string using a localized comparison."
 *
 *	Umm... calls -compare:options:range:locale:, but I'm not sure what to pass as locale
 */
- (NSComparisonResult)localizedCompare:(NSString *)string
{
	PF_HELLO("")
	
	CFRange range = CFRangeMake( 0, CFStringGetLength((CFStringRef)self) );
	
	// yep, not sure what to put here
	//CFLocaleRef locale = CFLocaleCopyCurrent();
	
	//return [self compare: string options: 0 range: range locale: locale];
	return CFStringCompareWithOptionsAndLocale( (CFStringRef)self, (CFStringRef)string, range, 0, NULL );
}

/*
 *	"Returns an NSComparisonResult value that indicates the lexical ordering of the receiver and a 
 *	given string using a case-insensitive, localized, comparison."
 */
- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string
{
	PF_HELLO("")
	
	CFRange range = CFRangeMake( 0, CFStringGetLength((CFStringRef)self) );
	
	// yep, not sure what to put here
	//CFLocaleRef locale = CFLocaleCopyCurrent();
	
	//return [self compare: string options: NSCaseInsensitiveSearch range: range locale: locale];
	return CFStringCompareWithOptionsAndLocale( (CFStringRef)self, (CFStringRef)string, range, kCFCompareCaseInsensitive, NULL );
}

/*
 *	"Returns a Boolean value that indicates whether a given string is equal to the receiver using 
 *	an literal Unicode-based comparison."
 */
- (BOOL)isEqualToString:(NSString *)aString
{
	PF_HELLO("")
	
	if( self == aString ) return YES;
	if( aString == nil ) return NO;
	
	return ( kCFCompareEqualTo == CFStringCompare((CFStringRef)self, (CFStringRef)aString, 0 ) );
}

- (BOOL)hasPrefix:(NSString *)aString
{
	PF_HELLO("")
	return CFStringHasPrefix( (CFStringRef)self, (CFStringRef)aString );
}

- (BOOL)hasSuffix:(NSString *)aString
{
	PF_HELLO("")
	return CFStringHasSuffix( (CFStringRef)self, (CFStringRef)aString );
}



/* These methods return length==0 if the target string is not found. So, to check for containment: ([str rangeOfString:@"target"].length > 0).  Note that the length of the range returned by these methods might be different than the length of the target string, due composed characters and such.
 */
/*
 *	"Invokes rangeOfString:options: with no options."
 */
- (NSRange)rangeOfString:(NSString *)aString
{
	PF_HELLO("")
	
	if( aString == nil ) 
		[NSException raise: NSInvalidArgumentException format: nil];
	
	return [self rangeOfString: aString options: 0];
}

/*
 *	"Invokes rangeOfString:options:range: with the options specified by mask and the entire extent 
 *	of the receiver as the range."
 */
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask
{
	PF_HELLO("")
	
	if( aString == nil ) 
		[NSException raise: NSInvalidArgumentException format: nil];
	
	NSRange range = NSMakeRange( 0, [self length] );
	
	return [self rangeOfString: aString options: mask range: range];
}

/*
 *	"Finds and returns the range of the first occurrence of a given string, within the given range 
 *	of the receiver, subject to given options."
 *
 *	Previous methods call into this one. Not sure if it wouldn't be quicker for each to call the
 *	corresponding CFStringFind instead, but we'll do it like this for now.
 */
- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange
{
	PF_HELLO("")
	
	if( aString == nil ) 
		[NSException raise: NSInvalidArgumentException format: nil];
	
	// check that searchRange is valid
	NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
	if( length == 0 ) 
		return NSMakeRange( NSNotFound, 0 );
	
	if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) > length) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange range = CFRangeMake( searchRange.location, searchRange.length );
	
	// set the mask to only allow allowed options
	mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSBackwardsSearch | NSAnchoredSearch);
	
	CFRange result;
	
	if( TRUE == CFStringFindWithOptions( (CFStringRef)self, (CFStringRef)aString, range, mask, &result ) )
		return NSMakeRange( result.location, result.length );
	else
		return NSMakeRange( NSNotFound, 0 );
}

/*
 *	#if MAC_OS_X_VERSION_10_5 <= MAC_OS_X_VERSION_MAX_ALLOWED
 *
 *	"Finds and returns the range of the first occurrence of a given string within a given 
 *	range of the receiver, subject to given options, using the specified locale, if any."
 *
 *	This was added in 10.5. I'm not entirely sure how the non-locale version above handles the
 *	locale, but since CF provides a separate locale-using version we'll just call straight into
 *	that.
 */
- (NSRange)rangeOfString:(NSString *)aString 
				 options:(NSStringCompareOptions)mask 
				   range:(NSRange)searchRange 
				  locale:(NSLocale *)locale
{
	PF_HELLO("")

	if( aString == nil ) 
		[NSException raise: NSInvalidArgumentException format: nil];
	
	// check that searchRange is valid
	NSUInteger length =  CFStringGetLength((CFStringRef)self); //[self length];
	if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) >= length) )
		[NSException raise: NSRangeException format: nil];

	CFRange range = CFRangeMake( searchRange.location, searchRange.length );
	
	// set the mask to only allow allowed options
	mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSBackwardsSearch | NSAnchoredSearch);
	
	// check and set the locale
	if( locale == nil ) locale = (NSLocale *)CFLocaleCopyCurrent();

	CFRange result;
	
	if( TRUE == CFStringFindWithOptionsAndLocale( (CFStringRef)self, (CFStringRef)aString, range, mask, (CFLocaleRef) locale, &result ) )
		return NSMakeRange( result.location, result.length );
	else
		return NSMakeRange( NSNotFound, 0 );
}

/*	"These return the range of the first character from the set in the string, not the range 
	of a sequence of characters." */
/*
 *	"Finds and returns the range in the receiver of the first character from a given character set."
 */
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet
{
	PF_HELLO("")
	
	if( aSet == nil ) 
		[NSException raise: NSInvalidArgumentException format: nil];
	
	return [self rangeOfCharacterFromSet: aSet options: 0];
}

/*
 *	"Finds and returns the range in the receiver of the first character, using given options, from 
 *	a given character set."
 */
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask
{
	PF_HELLO("")
	
	if( aSet == nil ) 
		[NSException raise: NSInvalidArgumentException format: nil];
	
	NSRange range = NSMakeRange( 0, [self length] );
	
	return [self rangeOfCharacterFromSet: aSet options: 0 range: range];
}

/*
 *	"Finds and returns the range in the receiver of the first character from a given character 
 *	set found in a given range with given options."
 */
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet 
						   options:(NSStringCompareOptions)mask 
							 range:(NSRange)searchRange
{
	PF_HELLO("")
	
	if( aSet == nil ) 
		[NSException raise: NSInvalidArgumentException format: nil];

	// checks that searchRange is valid
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) >= length) )
		[NSException raise: NSRangeException format: nil];

	CFRange range = CFRangeMake( searchRange.location, searchRange.length );
	
	mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSBackwardsSearch);
	
	CFRange result;
	
	if( TRUE == CFStringFindCharacterFromSet( (CFStringRef)self, (CFCharacterSetRef)aSet, range, mask, &result ) )
		return NSMakeRange( result.location, result.length );
	else
		return NSMakeRange( NSNotFound, 0 );
}

/*
 *	"Returns the range in the receiver of the composed character sequence located at a given index."
 *
 *	Umm... what???
 */
- (NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index
{
	PF_HELLO("")
	
	if( index >= CFStringGetLength((CFStringRef)self) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange range = CFStringGetRangeOfComposedCharactersAtIndex( (CFStringRef)self, index );
	return NSMakeRange( range.location, range.length );
}

/*
 *	#if MAC_OS_X_VERSION_10_5 <= MAC_OS_X_VERSION_MAX_ALLOWED
 *
 *	"Returns the range in the receiver of the composed character sequence in a given range."
 *
 *	I'll admit that I'm making this up as I go along. Someone who understands composed characters
 *	should take a look at this.
 */
- (NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range
{
	PF_HELLO("Needs checking by some who understands composed characters")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) >= length) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange range1 = CFStringGetRangeOfComposedCharactersAtIndex( (CFStringRef)self, range.location );
	CFRange range2 = CFStringGetRangeOfComposedCharactersAtIndex( (CFStringRef)self, (range.location + range.length) );
	
	return NSMakeRange( range1.location, ((range2.location+range2.length)-range1.location) );
}

// string concatenation, etc.

/*
 *	This was influenced by the Cocotron way of doing things, but didn't actually use any of
 *	their source code.
 */
- (NSString *)stringByAppendingString:(NSString *)aString
{
	PF_HELLO("")
	PF_NIL_ARG(aString)
	
	NSUInteger length1 = CFStringGetLength((CFStringRef)self);
	NSUInteger length2 = [aString length];
	
	unichar buffer[length1+length2];
	
	CFStringGetCharacters( (CFStringRef)self, CFRangeMake(0, length1), buffer );
	[aString getCharacters: buffer+length1];

	CFStringRef new = CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, length1+length2 );

	PF_RETURN_TEMP(new)
}

/*
 *	This should be easy enough, too, except CF doesn't provide an explicit function for it. So...
 */
- (NSString *)stringByAppendingFormat:(NSString *)format, ...
{
	PF_HELLO("")
	PF_NIL_ARG(format)
	
	va_list arguments;
	va_start( arguments, format );
	
	CFStringRef aString = CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, arguments );

	va_end( arguments );
	
	NSUInteger length1 = CFStringGetLength((CFStringRef)self);
	NSUInteger length2 = CFStringGetLength((CFStringRef)aString);
	
	unichar buffer[length1+length2];
	
	CFStringGetCharacters( (CFStringRef)self, CFRangeMake(0, length1), buffer );
	CFStringGetCharacters( (CFStringRef)aString, CFRangeMake(0, length2), buffer+length1 );
	
	CFStringRef new = CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, length1+length2 );
	
	[(id)aString release];
	
	PF_RETURN_TEMP(new)
}


- (double)doubleValue
{
	PF_HELLO("")
	return CFStringGetDoubleValue((CFStringRef)self);
}

- (float)floatValue
{
	PF_HELLO("")
	return (float)CFStringGetDoubleValue((CFStringRef)self);
}

- (int)intValue
{
	PF_HELLO("")
	return CFStringGetIntValue((CFStringRef)self);
}

- (NSInteger)integerValue
{
	PF_HELLO("")
	return CFStringGetIntValue((CFStringRef)self);
}

- (long long)longLongValue
{
	PF_HELLO("")
	return CFStringGetIntValue((CFStringRef)self);	
}

/*
 *	Skips initial space characters (whitespaceSet), or optional -/+ sign followed by zeroes. 
 *	Returns YES on encountering one of "Y", "y", "T", "t", or a digit 1-9. It ignores any 
 *	trailing characters.
 *
 *	So... do something with an NSScanner
 */
- (BOOL)boolValue
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( length == 0 ) return NO;
	
	CFCharacterSetRef cset = CFCharacterSetGetPredefined( kCFCharacterSetWhitespace );
	
	CFStringInlineBuffer *buffer;
	CFRange range = CFRangeMake(0, length);
	CFStringInitInlineBuffer( (CFStringRef)self, buffer, range );
	NSUInteger index = 0;
	unichar c = CFStringGetCharacterFromInlineBuffer( buffer, index++ );
	
	while( CFCharacterSetIsCharacterMember( cset, c ) )
		c = CFStringGetCharacterFromInlineBuffer( buffer, index++ );

	//if( (c == '+') || (c == '-') )
		
	if( (c == 'Y') || (c == 'y') || (c == 'T') || (c == 't') || (c == '1') || (c == '2') || (c == '3') || (c == '4') || (c == '5') || (c == '6') || (c == '7') || (c == '8') || (c == '9') ) return YES;
	
	return NO;
}

/*
 *	Simply call the CFString equivalent
 */
- (NSArray *)componentsSeparatedByString:(NSString *)separator
{
	PF_HELLO("")
	
	CFArrayRef array = CFStringCreateArrayBySeparatingStrings( kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)separator );
	
	PF_RETURN_TEMP(array)
}

/*
 *	#if MAC_OS_X_VERSION_10_5 <= MAC_OS_X_VERSION_MAX_ALLOWED
 *
 */	
- (NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator
{
	PF_TODO
}

/*
 *	Returned prefix substring is taken from the reciever
 */
- (NSString *)commonPrefixWithString:(NSString *)aString options:(NSStringCompareOptions)mask
{
	PF_TODO
	
	// set mask up to contain only allowed options
	mask &= (NSCaseInsensitiveSearch | NSLiteralSearch);
	
	// if aString == nil, or [self length] == 0 or [aString length] == 0 return [NSString string];
	//
	//	lastPrefix = @""
	//	i = 1
	//	nextPrefix = substring( self, to i)
	//	if aString !have prefix nextPrefix return lastPrefix 
	//			eg. no match straigh off, return @""
	
}

/*
 *	"Returns an uppercased representation of the receiver."
 *
 *	For uppercaseString, lowercaseString and CapitalizedString, there must be a method
 *	which doesn't invlove creating a mutable copy. Prehaps running the internal CF function 
 *	over a character buffer
 */
- (NSString *)uppercaseString
{
	PF_HELLO("")
	
	// first create a copy of the reciever, then change it to uppercase
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringUppercase( new, NULL );
	PF_RETURN_TEMP(new)
}

/*
 *	"Returns lowercased representation of the receiver."
 */
- (NSString *)lowercaseString
{
	PF_HELLO("")
	
	// first create a copy of the reciever, then change it to lowercase
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringLowercase( new, NULL );
	PF_RETURN_TEMP(new)
}

/*
 *	"Returns a capitalized representation of the receiver."
 */
- (NSString *)capitalizedString
{
	PF_HELLO("")
	
	// first create a copy of the reciever, then change it to lowercase
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringCapitalize( new, NULL ); // no locale, is this a problem ???
	PF_RETURN_TEMP(new)
}

/*
 *	#if MAC_OS_X_VERSION_10_2 <= MAC_OS_X_VERSION_MAX_ALLOWED
 *
 *	"Returns a new string made by removing from both ends of the receiver characters contained in 
 *	a given character set."
 */
- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set
{
	PF_HELLO("")
	PF_NIL_ARG(set)
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( length == 0 ) return [NSString string];
	unichar sbuf[length];
	
	unichar *buffer = (unichar *)CFStringGetCharactersPtr((CFStringRef)self);
	if( buffer == NULL )
	{
		CFRange range = CFRangeMake(0, length);
		CFStringGetCharacters( (CFStringRef)self, range, sbuf );
		buffer = sbuf;
	}
	
	NSUInteger start, end;
	
	for( start = 0; start < length; start++ )
		if( !CFCharacterSetIsCharacterMember( (CFCharacterSetRef)set, buffer[start] ) )
			break;
	
	if( start == length ) return [NSString string];
	
	for( end = --length; length > 0; end-- )
		if( !CFCharacterSetIsCharacterMember( (CFCharacterSetRef)set, buffer[end] ) )
			break;
	
	if( end == 0 ) return [NSString string];
	
	PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, buffer+start, end-start+1) )
}

/*
 *	"Returns a new string formed from the receiver by either removing characters from the end, or 
 *	by appending as many occurrences as necessary of a given pad string."
 */
- (NSString *)stringByPaddingToLength:(NSUInteger)newLength 
						   withString:(NSString *)padString 
					  startingAtIndex:(NSUInteger)padIndex
{
	PF_HELLO("")
	PF_NIL_ARG(padString)

	// check that padIndex is valid
	if( padIndex >= [self length] )
		[NSException raise: NSRangeException format: nil];
	
	// create a mutable copy of self to work with
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	
	// carry-out the padding
	CFStringPad( new, (CFStringRef)padString, (CFIndex)newLength, (CFIndex)padIndex );
	
	PF_RETURN_NEW(new)
}

// line and paragraph extents

- (void)getLineStart:(NSUInteger *)startPtr 
				 end:(NSUInteger *)lineEndPtr 
		 contentsEnd:(NSUInteger *)contentsEndPtr 
			forRange:(NSRange)range
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) >= length) )
		[NSException raise: NSRangeException format: nil];

	CFRange r = CFRangeMake( range.location, range.length );
	CFStringGetLineBounds((CFStringRef)self, r, (CFIndex *)startPtr, (CFIndex *)lineEndPtr, (CFIndex *)contentsEndPtr);
}

- (NSRange)lineRangeForRange:(NSRange)range
{
	PF_HELLO("")

	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) >= length) )
		[NSException raise: NSRangeException format: nil];
	
	CFIndex start, end;
	CFRange r = CFRangeMake( range.location, range.length );
	CFStringGetLineBounds( (CFStringRef)self, r, &start, &end, NULL );
	return NSMakeRange( start, end-start+1 );
}

- (void)getParagraphStart:(NSUInteger *)startPtr 
					  end:(NSUInteger *)parEndPtr 
			  contentsEnd:(NSUInteger *)contentsEndPtr 
				 forRange:(NSRange)range
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) >= length) )
		[NSException raise: NSRangeException format: nil];

	CFRange r = CFRangeMake( range.location, range.length );
	CFStringGetParagraphBounds( (CFStringRef)self, r, (CFIndex *)startPtr, (CFIndex *)parEndPtr, (CFIndex *)contentsEndPtr );
}

- (NSRange)paragraphRangeForRange:(NSRange)range
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) >= length) )
		[NSException raise: NSRangeException format: nil];
	
	CFIndex start, end;
	CFRange r = CFRangeMake( range.location, range.length );
	CFStringGetParagraphBounds( (CFStringRef)self, r, &start, &end, NULL );
	return NSMakeRange( start, end-start+1 );	
}


/*** Encoding methods ***/

// Result in O(1) time; a rough estimate
- (NSStringEncoding)fastestEncoding
{
	PF_HELLO("")
	
	CFStringEncoding encoding = CFStringGetFastestEncoding( (CFStringRef)self );
	return CFStringConvertEncodingToNSStringEncoding(encoding);
}

// Result in O(n) time; the encoding in which the string is most compact
- (NSStringEncoding)smallestEncoding
{
	PF_HELLO("")
	
	CFStringEncoding encoding = CFStringGetSmallestEncoding( (CFStringRef)self );
	return CFStringConvertEncodingToNSStringEncoding(encoding);	
}

// External representation
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy
{
	PF_HELLO("")
	
	// check whether we can honour lossy
	//if( (lossy == NO) && ([self canBeConvertedToEncoding: encoding] == NO) ) return nil;
	
	// set the lossByte according to lossy, meaning it will return NULL if lossy encoding is attempted
	UInt8 lossByte = lossy ? '?' : 0; // need to find out what Founation uses here
	
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	
	CFDataRef new = CFStringCreateExternalRepresentation( kCFAllocatorDefault, (CFStringRef)self, enc, lossByte );
	PF_RETURN_TEMP(new)
}

// External representation
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding
{
	PF_HELLO("")
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	CFDataRef new = CFStringCreateExternalRepresentation( kCFAllocatorDefault, (CFStringRef)self, enc, 0 );
	PF_RETURN_TEMP(new)
}

- (BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding
{
	PF_TODO
	//CFStringEncoding cf_enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	return YES;	// random YES/NO perhaps?
}

/*
 *	"Returns a null-terminated UTF8 representation of the receiver." "The returned C string is 
 *	automatically freed just as a returned object would be released; you should copy the C string 
 *	if it needs to store it outside of the autorelease context in which the C string is created."
 */
- (const char *)UTF8String
{
	PF_HELLO("")
	
	NSUInteger size = CFStringGetMaximumSizeForEncoding( CFStringGetLength((CFStringRef)self), kCFStringEncodingUTF8 );
	char *buffer = malloc(size);
	
	if( CFStringGetCString( (CFStringRef)self, buffer, size, kCFStringEncodingUTF8 ) ) return buffer;
	
	free(buffer);
	return NULL;
}


/*	
 *	""Autoreleased"; NULL return if encoding conversion not possible; for performance reasons, 
 *	lifetime of this should not be considered longer than the lifetime of the receiving string 
 *	(if the receiver string is freed, this might go invalid then, before the end of the autorelease 
 *	scope)"
 *
 *	For the moment we're just going to leak the returned buffer.
 */
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding
{
	PF_HELLO("")
	
	// until we fix -lengthOfBytesUsingEncoding this will be the maximum
	NSUInteger size = [self lengthOfBytesUsingEncoding: encoding] + 1; // space for \n
	
	char *buffer = malloc( size );
	
	if( [self getCString: buffer maxLength: size encoding: encoding] ) return buffer;
	
	free(buffer);
	return NULL;
}

/* 
 *	"Converts the receiver’s content to a given encoding and stores them in a buffer." "NO return if 
 *	conversion not possible due to encoding errors or too small of a buffer. The buffer should include 
 *	room for maxBufferCount bytes; this number should accomodate the expected size of the return value 
 *	plus the NULL termination character, which this method adds. (So note that the maxLength passed to 
 *	this method is one more than the one you would have passed to the deprecated getCString:maxLength:.)"
 */
- (BOOL)getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(NSStringEncoding)encoding
{
	PF_HELLO("")
	
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	return CFStringGetCString( (CFStringRef)self, buffer, (CFIndex)maxBufferCount, enc );
}

/*
 *	"Use this to convert string section at a time into a fixed-size buffer, without any allocations.  
 *	Does not NULL-terminate. 
 *		buffer is the buffer to write to; if NULL, this method can be used to computed size of needed 
 *	buffer.
 *		maxBufferCount is the length of the buffer in bytes. It's a good idea to make sure this is at 
 *	least enough to hold one character's worth of conversion. 
 *		usedBufferCount is the length of the buffer used up by the current conversion. Can be NULL.
 *		encoding is the encoding to convert to.
 *		options specifies the options to apply.
 *		range is the range to convert.
 *		leftOver is the remaining range. Can be NULL.
 *	YES return indicates some characters were converted. Conversion might usually stop when the buffer 
 *	fills, but it might also stop when the conversion isn't possible due to the chosen encoding. 
 */
- (BOOL)getBytes:(void *)buffer 
	   maxLength:(NSUInteger)maxBufferCount 
	  usedLength:(NSUInteger *)usedBufferCount 
		encoding:(NSStringEncoding)encoding 
		 options:(NSStringEncodingConversionOptions)options 
		   range:(NSRange)range 
  remainingRange:(NSRangePointer)leftover
{
	PF_HELLO("")
	
	// check that range is valid
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) > length) )
		[NSException raise: NSRangeException format: nil];
	
	// convert NSRane range into a CFRange
	CFRange r = CFRangeMake( range.location, range.length );
	
	// convert the encoding
	CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
	
	// interpret the NSStringEncodingConversionOptions in options
	UInt8 lossByte = (options & NSStringEncodingConversionAllowLossy) ? '?' : 0;
	Boolean xRep = (options & NSStringEncodingConversionExternalRepresentation);
	
	CFIndex result = CFStringGetBytes( (CFStringRef)self, r, enc, lossByte, xRep, (UInt8 *)buffer, (CFIndex)maxBufferCount, (CFIndex *)usedBufferCount );
	return (result == 0) ? NO : YES;
}

/*
 *	"These return the maximum and exact number of bytes needed to store the receiver in the 
 *	specified encoding in non-external representation. The first one is O(1), while the second 
 *	one is O(n). These do not include space for a terminating null."
 */
- (NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)enc
{
	CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(enc);
	return (NSUInteger)CFStringGetMaximumSizeForEncoding( (CFIndex)CFStringGetLength((CFStringRef)self), encoding );
}

/*
 *	This version just does the same as maximum above
 */
- (NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)enc
{
	CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(enc);
	return (NSUInteger)CFStringGetMaximumSizeForEncoding( (CFIndex)CFStringGetLength((CFStringRef)self), encoding );
}

/*
 *	#if MAC_OS_X_VERSION_10_2 <= MAC_OS_X_VERSION_MAX_ALLOWED
 *
 *	I have no idea what these do, but there are CF functions to do them.
 */
- (NSString *)decomposedStringWithCanonicalMapping 
{
	PF_HELLO("")

	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringNormalize( (CFMutableStringRef)new, kCFStringNormalizationFormD );
	PF_RETURN_TEMP(new)
}

- (NSString *)precomposedStringWithCanonicalMapping 
{
	PF_HELLO("")
	
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringNormalize( (CFMutableStringRef)new, kCFStringNormalizationFormC );
	PF_RETURN_TEMP(new)
}

- (NSString *)decomposedStringWithCompatibilityMapping 
{
	PF_HELLO("")
	
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringNormalize( (CFMutableStringRef)new, kCFStringNormalizationFormKD );
	PF_RETURN_TEMP(new)
}

- (NSString *)precomposedStringWithCompatibilityMapping 
{
	PF_HELLO("")
	
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringNormalize( (CFMutableStringRef)new, kCFStringNormalizationFormKC );
	PF_RETURN_TEMP(new)
}

/*	
 *	#if MAC_OS_X_VERSION_10_5 <= MAC_OS_X_VERSION_MAX_ALLOWED
 *
 *	"Returns a string with the character folding options applied. theOptions is a mask of 
 *	compare flags with *InsensitiveSearch suffix."
 */
- (NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale *)locale
{
	PF_HELLO("")

	// do we need to convert option flags ???
	
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringFold( new, (CFOptionFlags)options, (CFLocaleRef)locale );
	
	PF_RETURN_TEMP(new)
}

/*
 *	"Replace all occurrences of the target string in the specified range with replacement. Specified 
 *	compare options are used for matching target."
 */
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target 
										withString:(NSString *)replacement 
										   options:(NSStringCompareOptions)options 
											 range:(NSRange)searchRange
{
	PF_HELLO("")
	
	// check that range is valid
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) > length) )
		[NSException raise: NSRangeException format: nil];
	CFRange range = CFRangeMake( searchRange.location, searchRange.length );
	
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringFindAndReplace( new, (CFStringRef)target, (CFStringRef)replacement, range, (CFOptionFlags)options );
	PF_RETURN_TEMP(new)
}

/* Replace all occurrences of the target string with replacement. Invokes the above method with 0 options and range of the whole string.
 */
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
{
	return [self stringByReplacingOccurrencesOfString: target 
										   withString: replacement 
											  options: 0
												range: NSMakeRange( 0, [self length] )];
}

/* Replace characters in range with the specified string, returning new string.
 */
- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement
{
	// check that range is valid
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) > length) )
		[NSException raise: NSRangeException format: nil];
	CFRange r = CFRangeMake( range.location, range.length );
	
	CFMutableStringRef new = CFStringCreateMutableCopy( kCFAllocatorDefault, 0, (CFStringRef)self );
	CFStringReplace( new, r, (CFStringRef)replacement );
	PF_RETURN_TEMP(new)
}


/*
 *	@interface NSMutableString (NSMutableStringExtensionMethods)
 *
 *	Instance methods added by NSMutableString.
 */

/*
 *	NSMutableString's sole defining feature. This is a no-op in NSMutableString, but is defined here to
 *	use the coresponding CFStringReplace function
 */
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString
{
	PF_HELLO("")
	PF_CHECK_STR_MUTABLE(self)
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) > length) )
		[NSException raise: NSRangeException format: nil];
	CFRange r = CFRangeMake( range.location, range.length );

	CFStringReplace( (CFMutableStringRef)self, r, (CFStringRef)aString);
}


/*
 *	"Inserts into the receiver the characters of a given string at a given location."
 */
- (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc
{
	PF_HELLO("")
	PF_NIL_ARG(aString)
	PF_CHECK_STR_MUTABLE(self)
	
	if( loc >= CFStringGetLength((CFStringRef)self) ) //raise NSRangeException
		[NSException raise: NSRangeException format: nil];
	
	CFStringInsert( (CFMutableStringRef)self, (CFIndex)loc, (CFStringRef)aString );
}


/*
 *	""
 */
- (void)deleteCharactersInRange:(NSRange)range
{
	PF_HELLO("")
	PF_CHECK_STR_MUTABLE(self)
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (range.location >= length) || ((range.location+range.length) > length) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( (CFIndex)range.location, (CFIndex)range.length );
	CFStringDelete( (CFMutableStringRef)self , r );
}


/*
 *	""
 */
- (void)appendString:(NSString *)aString
{
	PF_HELLO("")
	PF_NIL_ARG(aString)
	PF_CHECK_STR_MUTABLE(self)
	
	CFStringAppend( (CFMutableStringRef)self, (CFStringRef)aString );
}


/*
 *	""
 */
- (void)appendFormat:(NSString *)format, ...
{
	PF_HELLO("")
	PF_NIL_ARG(format)
	PF_CHECK_STR_MUTABLE(self)
	
	va_list arguments;
	va_start( arguments, format );
	
	CFStringAppendFormatAndArguments( (CFMutableStringRef)self, NULL, (CFStringRef)format, arguments );
	
	va_end( arguments );
}


/*
 *	""
 */
- (void)setString:(NSString *)aString
{
	PF_HELLO("")
	PF_NIL_ARG(aString)
	PF_CHECK_STR_MUTABLE(self)
	
	CFStringReplaceAll( (CFMutableStringRef)self, (CFStringRef)aString );
}


/*
 *	#if MAC_OS_X_VERSION_10_2 <= MAC_OS_X_VERSION_MAX_ALLOWED
 *
 *	This method replaces all occurrences of the target string with the replacement string, in the 
 *	specified range of the receiver string, and returns the number of replacements. NSBackwardsSearch 
 *	means the search is done from the end of the range (the results could be different); NSAnchoredSearch 
 *	means only anchored (but potentially multiple) instances will be replaced. NSLiteralSearch and
 *	NSCaseInsensitiveSearch also apply. NSNumericSearch is ignored. Use NSMakeRange(0, [receiver length]) 
 *	to process whole string. 
 */
- (NSUInteger)replaceOccurrencesOfString:(NSString *)target 
							  withString:(NSString *)replacement 
								 options:(NSStringCompareOptions)options 
								   range:(NSRange)searchRange
{
	//printf("replaceOccurencesOfString...\n");
	PF_CHECK_STR_MUTABLE(self)
	
	if( (target == nil) || (replacement == nil) ) 
		[NSException raise: NSInvalidArgumentException format: nil];
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( length == 0 ) return 0;
	
	if( (searchRange.location >= length) || ((searchRange.location+searchRange.length) > length) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange range = CFRangeMake( searchRange.location, searchRange.length );

	// I think these are the only allowable options
	options &= (NSBackwardsSearch | NSAnchoredSearch | NSLiteralSearch | NSCaseInsensitiveSearch);

	return CFStringFindAndReplace( (CFMutableStringRef)self, (CFStringRef)target, (CFStringRef)replacement, range, options );
}



/*
 *	NSString (NSStringPathExtensions) methods, defined in NSPathUtilities
 *
 *	Those methods which can be achieved using just declared NSString methods are implemented in the
 *	file NSPathUtilities.m. Where an implementation can be improved by calling CF they are re-done
 *	here.
 */
- (NSArray *)pathComponents 
{
	PF_HELLO("")
	CFArrayRef array = CFStringCreateArrayBySeparatingStrings( kCFAllocatorDefault, (CFStringRef)self, CFSTR("/") );
	PF_RETURN_TEMP(array);
}


- (BOOL)isAbsolutePath 
{
	PF_HELLO("")
	return CFStringHasPrefix( (CFStringRef)self, CFSTR("/") );
}


- (NSString *)stringByAbbreviatingWithTildeInPath 
{
	PF_HELLO("")
	
	NSString *home = NSHomeDirectory();

	if( !CFStringHasPrefix((CFStringRef)self, (CFStringRef)home) ) 
		PF_RETURN_TEMP( CFStringCreateCopy( kCFAllocatorDefault, (CFStringRef)self ) )
	
	return [@"~" stringByAppendingString: [self substringFromIndex: CFStringGetLength((CFStringRef)home)]];
}

- (NSString *)stringByExpandingTildeInPath 
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( (length == 0) || !CFStringHasPrefix((CFStringRef)self, CFSTR("~")) )
		PF_RETURN_TEMP( CFStringCreateCopy( kCFAllocatorDefault, (CFStringRef)self ) )

	unichar sbuf[length];
	unichar *buffer = (unichar *)CFStringGetCharactersPtr((CFStringRef)self);
	if( buffer == NULL )
	{
		CFRange range = CFRangeMake(0, length);
		CFStringGetCharacters((CFStringRef)self, range, sbuf);
		buffer = sbuf;
	}
	
	int i;
	for( i = 1; ((buffer[i] != '/') && (i < length)); i++ ) ;
	
	NSString *homeDir;
	if( i == 1 ) // "~/"
	{
		homeDir = NSHomeDirectory();
	}
	else // "~user"
	{
		CFStringRef userName = CFStringCreateWithCharacters( kCFAllocatorDefault, buffer+1, i-1 );
		homeDir = NSHomeDirectoryForUser( (NSString *)userName );
		[(id)userName release];
		if( (homeDir == nil) || (CFStringGetLength((CFStringRef)homeDir) == 0) )
		{
			if( buffer[length-1] == '/' ) length--; // strip trailing "/"
			PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, length ) )
		}
	}
	
	// the path should not contain a leading slash
	if( buffer[i] == '/' ) i++;
	
	// if there's no path component, we can just return the new homeDir string
	if( i == length ) return homeDir;
	
	/*	It may be quicker to allocate a buffer of [homeDir length] + length - i, copy into it from both
		string buffers, and then create a new string from it... maybe */
	CFStringRef path = CFStringCreateWithCharacters( kCFAllocatorDefault, buffer+i, length-i );
	NSString *new = [homeDir stringByAppendingString: (NSString *)path];
	[(id)path release];

	PF_RETURN_TEMP( new )
}


- (NSString *)stringByStandardizingPath 
{
	PF_TODO
}

- (NSString *)stringByResolvingSymlinksInPath 
{
	PF_TODO
}


- (NSArray *)stringsByAppendingPaths:(NSArray *)paths 
{
	PF_HELLO("")
	
	NSUInteger count = [paths count];
	id buffer[count];
	
	id *ptr = buffer;
	for( NSString *string in paths )
		*ptr++ = [self stringByAppendingPathComponent: string];
	
	PF_RETURN_TEMP( CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, (CFArrayCallBacks *)&_PFCollectionCallBacks ) )
}


- (NSUInteger)completePathIntoString:(NSString **)outputName 
					   caseSensitive:(BOOL)flag 
					matchesIntoArray:(NSArray **)outputArray 
						 filterTypes:(NSArray *)filterTypes 
{
	PF_TODO
}

- (const char *)fileSystemRepresentation 
{
	PF_HELLO("")

	NSUInteger size = CFStringGetMaximumSizeOfFileSystemRepresentation( (CFStringRef)self );
	const char *buffer = malloc(size);

	if( CFStringGetFileSystemRepresentation( (CFStringRef)self, (char *)buffer, size ) == true )
		return buffer;

	free((void *)buffer);
	[NSException raise: NSCharacterConversionException format: nil];
	return nil;
}

- (BOOL)getFileSystemRepresentation:(char *)cname maxLength:(NSUInteger)max 
{
	PF_HELLO("")
	return CFStringGetFileSystemRepresentation( (CFStringRef)self, cname, max );
}




/*
 *	The following are adapted from Cocotron. (I think the retention policies are wrong.)
 *
 *	The original copyright notice is reproduced here:
 */

	/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
 
	 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
	 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

- (NSString *)lastPathComponent 
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	if( length == 0 ) return @"";
	
	unichar  sbuf[length];
	
	unichar *buffer = (unichar *)CFStringGetCharactersPtr( (CFStringRef)self );
	if( buffer == 0 )
	{
		CFRange range = CFRangeMake(0, length);
		CFStringGetCharacters((CFStringRef)self, range, sbuf);
		buffer = sbuf;
	}

	if( buffer[length-1] == '/' ) length--;
	
	for( int i = length; --i >= 0; )
		if( (buffer[i] == '/') && (i < length - 1) )
			PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, buffer+i+1, length-i-1 ) )
	
	PF_RETURN_TEMP( CFStringCreateCopy( kCFAllocatorDefault, (CFStringRef)self ) )
}

- (NSString *)pathExtension 
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	unichar  buffer[length];
	int      i;
	
	CFRange range = CFRangeMake(0, length);
	CFStringGetCharacters((CFStringRef)self, range, buffer);
	
	if( (length > 0) && (buffer[length-1] == '/') ) //ISSLASH(buffer[length-1]))
		length--;
	
	for( i = length; --i>=0; )
	{
		if(buffer[i] == '/')
			return @"";
		if(buffer[i]=='.')
		{
			range.location = i + 1;
			range.length = length - i - 1;
			return (NSString *)CFStringCreateWithSubstring( kCFAllocatorDefault, (CFStringRef)self, range );
			//return [NSString stringWithCharacters:buffer+i+1 length:(length-i)-1];
		}
	}
	
	return @"";
}

/*
 *	There could be a '/' (i) at the end of self, or (ii) at the begining of str. Since it's
 *	a little easier to skip the trailing slash, we'll do that and then add the extra in if
 *	str doesn't provide it.
 */
- (NSString *)stringByAppendingPathComponent:(NSString *)str 
{
	PF_HELLO("")
	
	NSUInteger selfLength = CFStringGetLength((CFStringRef)self);
	if( selfLength == 0 ) return [[str copy] autorelease];
	
	NSUInteger otherLength = [str length];
	NSUInteger totalLength = selfLength + 1 + otherLength; // actaully max length
	unichar  buffer[totalLength];
	
	CFRange range = CFRangeMake(0, selfLength);
	CFStringGetCharacters( (CFStringRef)self, range, buffer );
	
	// check for a leading slash on the other string
	if( [str hasPrefix: @"/"] )
	{
		totalLength--;
		if( buffer[selfLength-1] == '/' ) 
		{
			selfLength--; // shorten self
			totalLength--; // shorter self, less extra char
		}
	}
	else
	{
		if( buffer[selfLength-1] != '/' )
		{
			buffer[selfLength] = '/';
			selfLength++; // extra char, so totalLength is correct
		}
		else
			totalLength--; // we don't need the extra char
	}
	
	[str getCharacters: buffer+selfLength];
	
	// finally, is the entire string has a trailing "/", it should be removed
	if( buffer[totalLength-1] == '/' ) totalLength--;
	
	PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, totalLength ) )
}



- (NSString *)stringByDeletingLastPathComponent 
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self);
	unichar  sbuf[length];
	
	unichar *buffer = (unichar *)CFStringGetCharactersPtr( (CFStringRef)self );
	if( buffer == 0 )
	{
		CFRange range = CFRangeMake(0, length);
		CFStringGetCharacters((CFStringRef)self, range, sbuf);
		buffer = sbuf;
	}

	for( int i = length; --i>=0; )
		if( buffer[i] == '/' )
		{
			if( i == 0 ) 
				return @"/";
			else 
				if( (i + 1) < length )
					PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, i ) )
		}
    
	return @"";
}



- (NSString *)stringByAppendingPathExtension:(NSString *)str 
{
	PF_HELLO("")
	
	NSUInteger selfLength = CFStringGetLength((CFStringRef)self);
	
	if(selfLength && CFStringHasSuffix((CFStringRef)self, CFSTR("/")))
		selfLength--;
	
	NSUInteger otherLength = [str length];
	NSUInteger totalLength = selfLength + 1 + otherLength;
	unichar characters[totalLength];

	CFRange range = CFRangeMake(0, selfLength);
	CFStringGetCharacters((CFStringRef)self, range, characters);

	characters[selfLength] = '.';
	[str getCharacters: characters + selfLength + 1];
	
	PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, (const UniChar *)characters, totalLength ) )
}

- (NSString *)stringByDeletingPathExtension 
{
	PF_HELLO("")
	
	NSUInteger length = CFStringGetLength((CFStringRef)self); //[self length];
	unichar  sbuf[length];

	unichar *buffer = (unichar *)CFStringGetCharactersPtr( (CFStringRef)self );
	if( buffer == 0 )
	{
		CFRange range = CFRangeMake(0, length);
		CFStringGetCharacters((CFStringRef)self, range, sbuf);
		buffer = sbuf;
	}
	
	if( (length > 1) && (buffer[length-1] == '/') ) length--;

	for( int i = length; --i>=0; )
	{
		if( (buffer[i] == '/') || (buffer[i-1] == '/') )
			break;
		if(buffer[i] == '.')
			PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, i) )
	}

	PF_RETURN_TEMP( CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, length ) )
}

/** END OF COCOTRON ADDITIONS **/

/** DEPRECATED METHODS (for reasons of compatability) **/

// for dscl DSoException
- (const char *)cString
{
	return [self cStringUsingEncoding: NSASCIIStringEncoding];
}

- (const char *)lossyCString { };
- (NSUInteger)cStringLength { };
- (void)getCString:(char *)bytes { };
- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength { };
- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength range:(NSRange)aRange remainingRange:(NSRangePointer)leftoverRange  { };

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile { };
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically { };

- (id)initWithContentsOfFile:(NSString *)path { };
- (id)initWithContentsOfURL:(NSURL *)url { };
+ (id)stringWithContentsOfFile:(NSString *)path { };
+ (id)stringWithContentsOfURL:(NSURL *)url { };


- (id)initWithCStringNoCopy:(char *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer  { };
- (id)initWithCString:(const char *)bytes length:(NSUInteger)length { };

// also for dscl: DSoNodeConfig
- (id)initWithCString:(const char *)bytes { return [self initWithCString: bytes encoding: NSASCIIStringEncoding]; }

+ (id)stringWithCString:(const char *)bytes length:(NSUInteger)length { };
+ (id)stringWithCString:(const char *)bytes {};




@end




/*
 *	This is the class mapped to compiler-produced constant strings. It's sole
 *	purpose is to break retain/release, so that constants behave consistent with
 *	those on Cocoa.
 *
 *	TODO: Fix NSDeallocateObject() to prevent manual deallocation of strings.
 */
@interface NSCFConstantString : NSCFString
@end

@implementation NSCFConstantString
- (id)retain { return self; }
- (void)release { }
- (id)autorelease { return self; }
- (NSUInteger)retainCount { return 2147483647; }
@end

