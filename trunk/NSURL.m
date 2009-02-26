/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSURL.m
 *
 *	NSURL, PFURL
 *
 *	Created by Stuart Crook on 29/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/*
 *	This is going to get messy.
 *
 *	While on OS X CFURL appears to bridge directly to NSURL, it doesn't seem possible to replicate
 *	this using CFLite on Darwin. For one thing, the NSURL object and the CFURL data structure are
 *	different sizes with annoyingly different layouts.
 *
 *	We will therefor bridge CFURL to a new class, PFURL. This will be a subclass on NSURL, mainly so
 *	it passes any -isKindOf: NSURL tests. Having this class means that CFURLs can be sent messages
 *	through the obj-c runtime.
 *
 *	NSURL will create and store a CFURL object (treated only as a CFURL object) in its _reserved
 *	ivar (which is marked as __strong for the benefit of the GC, so might have been designed for the
 *	task). Where it needs to invoke CFURL... functions it will do so by passing this CFURL in.
 *
 *	Inside CF, in CFURL.c, the CF_IS_OBJC macro will be defined to compare the passed object's ISA
 *	to that of NSURL (NOT the bridged PFURL), so that when an NSURL is passed in to CFURL... calls
 *	it will call out by sending messages to the NSURL object.
 *
 *	This may of may not work.
 */

/**	TODO:
 *		URL loading (to be implemented by the other NSURL... classes) will probably require CFNetwork.
 *	As of 26/2/09 I've got an old (10.4.11-ish) CFNetwork to compile in the darwinbuild chroot, but
 *	I've yet to start poking about and seeing what it's capable of.
 */

/*
 *	Declaration for our PFURL class
 */
@interface PFURL : NSURL
@end


/*
 *	Constant
 */
NSString *NSURLFileScheme = @"file";


/*
 *	NSURL
 *
 *	This class can be passed into CFURL... calls, but is not technically bridged with CFURL, since
 *	they have different storage structures.
 *
 *	Expect CFLite to send this class the following selectors: _cfurl, relativeString, baseURL,
 *		absoluteURL, scheme, host, port, user, password, parameterString, query, fragment
 */
@implementation NSURL

/*
 *	Class creation methods
 */

+ (id)URLWithString:(NSString *)URLString
{
	PF_HELLO("")
	return [[[self alloc] initWithString: URLString] autorelease];
}

+ (id)URLWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL
{
	PF_HELLO("")
	return [[[self alloc] initWithString: URLString relativeToURL: baseURL] autorelease];
}

// AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL) isDir 
{
	PF_HELLO("")
	return [[[self alloc] initFileURLWithPath: path isDirectory: isDir] autorelease];
}

// Better to use fileURLWithPath:isDirectory: if you know if the path is a file vs directory, as it saves an i/o.
+ (id)fileURLWithPath:(NSString *)path 
{
	PF_HELLO("")
	return [[[self alloc] initFileURLWithPath: path] autorelease];
}

/*
 *	Instance creation methods
 *
 *	Lots of duplicated code here. Sorry.
 *
 *	_urlString and _baseURL are stored mainly for the benefit of catagories on NSURL written by future 
 *	third parties following Apple's guidelines
 */

// These methods expect their string arguments to contain any percent escape codes that are necessary
-(id)initWithString:(NSString *)URLString
{
	PF_HELLO("")
	PF_NIL_ARG(URLString)
	
	if( self = [super init] )
	{
		_reserved = (void *)CFURLCreateWithString( kCFAllocatorDefault, (CFStringRef)URLString, NULL );
		if( _reserved == NULL ) return nil;
		_urlString = [URLString copyWithZone: nil];
	}
	return self;
}

// It is an error for URLString to be nil
-(id)initWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL
{
	PF_HELLO("")
	PF_NIL_ARG(URLString)
	
	if( self = [super init] )
	{
		_reserved = (void *)CFURLCreateWithString( kCFAllocatorDefault, (CFStringRef)URLString, (CFURLRef)baseURL );
		if( _reserved == NULL ) return nil;
		_urlString = [URLString copyWithZone: nil];
		_baseURL = [baseURL copyWithZone: nil];
	}
	return self;
}

/*
 *	These currently assume POSIX path styles
 *	
 *	AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
 */
-(id)initFileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir 
{
	PF_HELLO("")
	PF_NIL_ARG(path)
	
	if( self = [super init] )
	{
		_reserved = (void *)CFURLCreateWithFileSystemPath( kCFAllocatorDefault, (CFStringRef)path,kCFURLPOSIXPathStyle, isDir );
		if( _reserved == NULL ) return nil;
		// _urlString = ???
	}
	return self;
}
// Better to use initFileURLWithPath:isDirectory: if you know if the path is a file vs directory, 
//	as it saves an i/o.
-(id)initFileURLWithPath:(NSString *)path 
{
	PF_HELLO("TODO -- Checking if it is a directory")
	PF_NIL_ARG(path)
	
	if( self = [super init] )
	{
		_reserved = (void *)CFURLCreateWithFileSystemPath( kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, FALSE ); // assumes it isn't a directory
		if( _reserved == NULL ) return nil;
		// _urlString = ???
	}
	return self;
}

-(id)initWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path 
{
	PF_HELLO("untested")
	
	if( self = [super init] )
	{
		NSUInteger schemeLength = [scheme length];
		NSUInteger hostLength = [host length];
		NSUInteger pathLength = [path length];

		NSUInteger totalLength = schemeLength + hostLength + pathLength;
		unichar buffer[totalLength];
		
		// do these need '/'s to join them?
		[scheme getCharacters: buffer];
		[host getCharacters: buffer+schemeLength];
		[path getCharacters: buffer+schemeLength+hostLength];
		
		_urlString = (NSString *)CFStringCreateWithCharacters( kCFAllocatorDefault, buffer, totalLength );
		_reserved = (void *)CFURLCreateWithString( kCFAllocatorDefault, (CFStringRef)_urlString, NULL );
		_baseURL = nil;
	}
	return self;
}

/*
 *	CFLite magic
 */
-(CFURLRef)_cfurl
{
	PF_HELLO("")
	return _reserved;
}

/*
 *	Whether this works depends on whether the hash is compared before or after the address
 */
-(NSUInteger)hash
{
	PF_HELLO("")
	return CFHash((CFTypeRef)_reserved);
}

-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)_reserved) )
}

/*
 *	Accessor instance methods
 *
 *	In their current implementation these are all deeply inefficient, especially if the NSURL object is
 *	passed to one of the coresponding CFURL... accessor functions: then the function invokes one of these
 *	methods which then invoke the exact same function on the _reserved CFURL
 */
- (NSString *)absoluteString
{
	PF_TODO
	return nil;
}

// The relative portion of a URL.  If baseURL is nil, or if the receiver is itself absolute, this is the same as absoluteString
- (NSString *)relativeString
{
	PF_TODO	
	return _urlString;
}

- (NSURL *)baseURL
{
	PF_HELLO("")
	CFURLRef new = CFURLGetBaseURL( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

// if the receiver is itself absolute, this will return self.
- (NSURL *)absoluteURL
{
	PF_HELLO("")
	CFURLRef new = CFURLCopyAbsoluteURL( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

// Any URL is composed of these two basic pieces.  The full URL would be the concatenation of [myURL scheme], ':', [myURL resourceSpecifier]
- (NSString *)scheme
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyScheme( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

- (NSString *)resourceSpecifier
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyResourceSpecifier( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

/* If the URL conforms to rfc 1808 (the most common form of URL), the following accessors will return the various components; otherwise they return nil.  The litmus test for conformance is as recommended in RFC 1808 - whether the first two characters of resourceSpecifier is @"//".  In all cases, they return the component's value after resolving the receiver against its base URL. */
- (NSString *)host 
{ 
	PF_HELLO("")
	CFStringRef new = CFURLCopyHostName( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

- (NSNumber *)port 
{
	PF_HELLO("")
	SInt32 new = CFURLGetPortNumber( (CFURLRef)_reserved );
	PF_RETURN_TEMP([NSNumber numberWithInt: new])
}

- (NSString *)user 
{ 
	PF_HELLO("")
	CFStringRef new = CFURLCopyUserName( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

- (NSString *)password 
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyPassword( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

- (NSString *)path 
{ 
	PF_HELLO("")
	CFStringRef new = CFURLCopyPath( (CFURLRef)_reserved );
	PF_RETURN_TEMP(new)
}

- (NSString *)fragment 
{
	PF_HELLO("Check OS X default behaviour") // (CFStringRef)@"" means escape all %s
	CFStringRef new = CFURLCopyFragment( (CFURLRef)_reserved, NULL );
	PF_RETURN_TEMP(new)
}

- (NSString *)parameterString 
{
	PF_HELLO("Check default OS X behaviour")
	CFStringRef new = CFURLCopyParameterString( (CFURLRef)_reserved, NULL );
	PF_RETURN_TEMP(new)
}

- (NSString *)query 
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyQueryString( (CFURLRef)_reserved, NULL );
	PF_RETURN_TEMP(new)
}

// The same as path if baseURL is nil
- (NSString *)relativePath 
{
	PF_TODO
	return nil;
} 

// Whether the scheme is file:; if [myURL isFileURL] is YES, then [myURL path] is suitable for 
// input into NSFileManager or NSPathUtilities.
- (BOOL)isFileURL
{
	PF_TODO
	return [[self scheme] isEqualToString: NSURLFileScheme];
}

- (NSURL *)standardizedURL
{
	PF_TODO
	return nil;
}

/*
 *	@interface NSString (NSURLUtilities)
 *	#if MAC_OS_X_VERSION_10_3 <= MAC_OS_X_VERSION_MAX_ALLOWED
 */
/* Adds all percent escapes necessary to convert the receiver in to a legal URL string.  Uses the given encoding to determine the correct percent escapes (returning nil if the given encoding cannot encode a particular character).  See CFURLCreateStringByAddingPercentEscapes in CFURL.h for more complex transformations */
//- (NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc;

/* Replaces all percent escapes with the matching characters as determined by the given encoding.  Returns nil if the transformation is not possible (i.e. the percent escapes give a byte sequence not legal in the given encoding).  See CFURLCreateStringByReplacingPercentEscapes in CFURL.h for more complex transformations */
//- (NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc;

//@end
//#endif
/*
/*
 *	@interface NSObject(NSURLClient)
 *	Client informal protocol for use with the deprecated loadResourceDataNotifyingClient: below.  
 *
 *	all 4 DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;
 */
//- (void)URL:(NSURL *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes { }
//- (void)URLResourceDidFinishLoading:(NSURL *)sender { }
//- (void)URLResourceDidCancelLoading:(NSURL *)sender { }
//- (void)URL:(NSURL *)sender resourceDidFailLoadingWithReason:(NSString *)reason { }

/*
 *	NSURL (NSURLLoading)
 *	This entire protocol is deprecated; use NSURLConnection instead.
 */
//- (NSData *)resourceDataUsingCache:(BOOL)shouldUseCache DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER; // Blocks to load the data if necessary.  If shouldUseCache is YES, then if an equivalent URL has already been loaded and cached, its resource data will be returned immediately.  If shouldUseCache is NO, a new load will be started
//- (void)loadResourceDataNotifyingClient:(id)client usingCache:(BOOL)shouldUseCache DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER; // Starts an asynchronous load of the data, registering delegate to receive notification.  Only one such background load can proceed at a time.
//- (id)propertyForKey:(NSString *)propertyKey DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;

// These attempt to write the given arguments for the resource specified by the URL; they return success or failure
//- (BOOL)setResourceData:(NSData *)data DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;
//- (BOOL)setProperty:(id)property forKey:(NSString *)propertyKey DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;

//- (NSURLHandle *)URLHandleUsingCache:(BOOL)shouldUseCache DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER; // Sophisticated clients will want to ask for this, then message the handle directly.  If shouldUseCache is NO, a newly instantiated handle is returned, even if an equivalent URL has been loaded

@end


/*
 *	PFURL, bridged with CFURL
 *
 *	Ignore previously declared and inherited ivars: all instances of this class will be CFURL objects
 *	created by CFLite.
 */
@implementation PFURL

+(id)alloc
{
	PF_HELLO("")
	return nil;	// no instances, and no subclasses, please
}

/*
 *	No creation methods, as these can only be created by CFURLCreate... methods
 */
-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFURLGetTypeID();
}

-(NSUInteger)hash
{
	PF_HELLO("")
	return CFHash((CFTypeRef)self);
}

-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}

/*
 *	Accessor instance methods, which are basically NSURL's with "self" in place of "_reserved"
 */
- (NSString *)absoluteString
{
	PF_TODO
	return nil;
}

// The relative portion of a URL.  If baseURL is nil, or if the receiver is itself absolute, this is the same as absoluteString
- (NSString *)relativeString
{
	PF_TODO	
	return nil;
}

- (NSURL *)baseURL
{
	PF_HELLO("")
	CFURLRef new = CFURLGetBaseURL( (CFURLRef)self );
	PF_RETURN_NEW(new)
}

// if the receiver is itself absolute, this will return self.
- (NSURL *)absoluteURL
{
	PF_HELLO("")
	CFURLRef new = CFURLCopyAbsoluteURL( (CFURLRef)self );
	PF_RETURN_TEMP(new)
}

// Any URL is composed of these two basic pieces.  The full URL would be the concatenation of [myURL scheme], ':', [myURL resourceSpecifier]
- (NSString *)scheme
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyScheme( (CFURLRef)self );
	PF_RETURN_TEMP(new)
}

- (NSString *)resourceSpecifier
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyResourceSpecifier( (CFURLRef)self );
	PF_RETURN_TEMP(new)
}

/* If the URL conforms to rfc 1808 (the most common form of URL), the following accessors will return the various components; otherwise they return nil.  The litmus test for conformance is as recommended in RFC 1808 - whether the first two characters of resourceSpecifier is @"//".  In all cases, they return the component's value after resolving the receiver against its base URL. */
- (NSString *)host 
{ 
	PF_HELLO("")
	CFStringRef new = CFURLCopyHostName( (CFURLRef)self );
	PF_RETURN_TEMP(new)
}

- (NSNumber *)port 
{
	PF_HELLO("")
	SInt32 new = CFURLGetPortNumber( (CFURLRef)self );
	PF_RETURN_TEMP([NSNumber numberWithInt: new])
}

- (NSString *)user 
{ 
	PF_HELLO("")
	CFStringRef new = CFURLCopyUserName( (CFURLRef)self );
	PF_RETURN_TEMP(new)
}

- (NSString *)password 
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyPassword( (CFURLRef)self );
	PF_RETURN_TEMP(new)
}

- (NSString *)path 
{ 
	PF_HELLO("")
	CFStringRef new = CFURLCopyPath( (CFURLRef)self );
	PF_RETURN_TEMP(new)
}

- (NSString *)fragment 
{
	PF_HELLO("Check OS X default behaviour") // (CFStringRef)@"" means escape all %s
	CFStringRef new = CFURLCopyFragment( (CFURLRef)self, NULL );
	PF_RETURN_TEMP(new)
}

- (NSString *)parameterString 
{
	PF_HELLO("Check default OS X behaviour")
	CFStringRef new = CFURLCopyParameterString( (CFURLRef)self, NULL );
	PF_RETURN_TEMP(new)
}

- (NSString *)query 
{
	PF_HELLO("")
	CFStringRef new = CFURLCopyQueryString( (CFURLRef)self, NULL );
	PF_RETURN_TEMP(new)
}

// The same as path if baseURL is nil
- (NSString *)relativePath 
{
	PF_TODO
	return nil;
} 

// Whether the scheme is file:; if [myURL isFileURL] is YES, then [myURL path] is suitable for 
// input into NSFileManager or NSPathUtilities.
- (BOOL)isFileURL
{
	PF_HELLO("")
	return [[self scheme] isEqualToString: NSURLFileScheme];
}

- (NSURL *)standardizedURL
{
	PF_TODO
	return nil;
}

/*
 *	@interface NSString (NSURLUtilities)
 *	#if MAC_OS_X_VERSION_10_3 <= MAC_OS_X_VERSION_MAX_ALLOWED
 */
/* Adds all percent escapes necessary to convert the receiver in to a legal URL string.  Uses the given encoding to determine the correct percent escapes (returning nil if the given encoding cannot encode a particular character).  See CFURLCreateStringByAddingPercentEscapes in CFURL.h for more complex transformations */
//- (NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc;

/* Replaces all percent escapes with the matching characters as determined by the given encoding.  Returns nil if the transformation is not possible (i.e. the percent escapes give a byte sequence not legal in the given encoding).  See CFURLCreateStringByReplacingPercentEscapes in CFURL.h for more complex transformations */
//- (NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc;

//@end
//#endif
/*
 /*
 *	@interface NSObject(NSURLClient)
 *	Client informal protocol for use with the deprecated loadResourceDataNotifyingClient: below.  
 *
 *	all 4 DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;
 */
//- (void)URL:(NSURL *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes { }
//- (void)URLResourceDidFinishLoading:(NSURL *)sender { }
//- (void)URLResourceDidCancelLoading:(NSURL *)sender { }
//- (void)URL:(NSURL *)sender resourceDidFailLoadingWithReason:(NSString *)reason { }

/*
 *	NSURL (NSURLLoading)
 *	This entire protocol is deprecated; use NSURLConnection instead.
 */
//- (NSData *)resourceDataUsingCache:(BOOL)shouldUseCache DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER; // Blocks to load the data if necessary.  If shouldUseCache is YES, then if an equivalent URL has already been loaded and cached, its resource data will be returned immediately.  If shouldUseCache is NO, a new load will be started
//- (void)loadResourceDataNotifyingClient:(id)client usingCache:(BOOL)shouldUseCache DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER; // Starts an asynchronous load of the data, registering delegate to receive notification.  Only one such background load can proceed at a time.
//- (id)propertyForKey:(NSString *)propertyKey DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;

// These attempt to write the given arguments for the resource specified by the URL; they return success or failure
//- (BOOL)setResourceData:(NSData *)data DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;
//- (BOOL)setProperty:(id)property forKey:(NSString *)propertyKey DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;

//- (NSURLHandle *)URLHandleUsingCache:(BOOL)shouldUseCache DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER; // Sophisticated clients will want to ask for this, then message the handle directly.  If shouldUseCache is NO, a newly instantiated handle is returned, even if an equivalent URL has been loaded


@end

