/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSData.m
 *
 *	NSData, NSMutableData, NSCFData
 *
 *	Created by Stuart Crook on 27/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSData.h>
#import "NSString.h"

#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

//#import "../CF-476.15.patched/CFData.h"

/** TODO:
 *		Implement an NSCFData subclass, NSCFMappedData, created (by forcing the isa) when a mapped
 *	file is used, created with ...NoCopy, and which unmaps the file on deallocation. Register it 
 *	with CF after NSCFData, so it's never assigned by CF but still checks as a bridged class.
 */


/*
 *	This version of the NSData family will vary in implementation from Apple's. They seem to bridge
 *	twice, with both the NSData subclass NSConcreteData as well as the NSMutableData subclass 
 *	NSConcreteMutableData. This causes problems for us, since at the moment the bridge works according
 *	to CF object type, and both CFData and CFMutableData share a type ID. So we will be bridging CFData
 *	to our own NSCFData class, and using the _PFDataIsMutable() function exposed by our patched CFLite
 *	to determine whether the CFData is mutable or not.
 */

/*
 *	Macro to perform mutability checks
 */
extern bool __PFDataIsMutable( CFDataRef data );

#define PF_DUMMY_DATA(data) BOOL isMutable; \
	if( data == (id)&_PFNSCFDataClass ) isMutable = NO; \
	else if( data == (id)&_PFNSCFMutableDataClass ) isMutable = YES; \
	else { isMutable = __PFDataIsMutable((CFDataRef)data); [data autorelease]; }

#define PF_RETURN_DATA_INIT if( isMutable == YES ) { [self autorelease]; self = (id)CFDataCreateMutableCopy( kCFAllocatorDefault, 0, (CFDataRef)self ); } \
	PF_RETURN_NEW(self)

#define PF_CHECK_DATA_MUTABLE(data) if( !__PFDataIsMutable((CFDataRef)data) ) \
	[NSException raise: NSInternalInconsistencyException format: [NSString stringWithCString: "Attempting mutable data op on a static NSData" encoding: NSUTF8StringEncoding]];


/*
 *	Declaration of the actual bridged class
 */
@interface NSCFData : NSMutableData
@end


/*
 *	A class variable to act as a dummy NSData or NSMutableData
 */
static Class _PFNSCFDataClass = nil;
static Class _PFNSCFMutableDataClass = nil;


/*
 *	The NSData factory class
 */
@implementation NSData

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSData class] )
		_PFNSCFDataClass = objc_getClass("NSCFData");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSData class] )
		return (id)&_PFNSCFDataClass;
	return [super alloc];
}

/*
 *	Instance methods to keep the compiler happy
 */
- (NSUInteger)length
{
	return 0;
}

- (const void *)bytes
{
	return NULL;
}

/**	NSCopying COMPLIANCE **/

/*
 *	Return nil, because NSString should never be instatitated
 */
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

/** NSMutableCopying COMPLIANCE **/

/*
 *	Create an NSCFMutableString
 */
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return nil;
}

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

@end





/*
 *	The class methods from the NSDataCreation category.
 *
 *	These use the dummy returned by [self alloc] and send it the appropriate -init message. This
 *	method makes the object collectable, etc., so there's no need for this method to do so.
 */
@implementation NSData (NSDataCreation)

/*
 *	A data containing nothing
 */
+ (id)data 
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease];
	CFDataRef data = CFDataCreate( kCFAllocatorDefault, NULL, 0 );
	PF_RETURN_TEMP(data)
}

+ (id)dataWithBytes:(const void *)bytes length:(NSUInteger)length 
{
	PF_HELLO("")
	return [[[self alloc] initWithBytes: bytes length: length] autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length 
{
	PF_HELLO("")
		// calling the ...freeWhenDone: version cuts one hop off of the call
	return [[[self alloc] initWithBytesNoCopy: bytes length: length freeWhenDone: YES] autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b 
{
	PF_HELLO("")
	return [[[self alloc] initWithBytesNoCopy: bytes length: length freeWhenDone: b] autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url 
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfURL: url] autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr 
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfURL: url options: readOptionsMask error: errorPtr] autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path 
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfFile: path] autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr 
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfFile: path options: readOptionsMask error: errorPtr] autorelease];
}


+ (id)dataWithContentsOfMappedFile:(NSString *)path 
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfMappedFile: path] autorelease];
}

+ (id)dataWithData:(NSData *)data 
{
	PF_HELLO("")
	return [[[self alloc] initWithData: data] autorelease];
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length { return nil; }
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length { return nil; }
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b  { return nil; }
- (id)initWithContentsOfFile:(NSString *)path options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr { return nil; }
- (id)initWithContentsOfURL:(NSURL *)url options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr { return nil; }
- (id)initWithContentsOfFile:(NSString *)path { return nil; }
- (id)initWithContentsOfURL:(NSURL *)url { return nil; }
- (id)initWithContentsOfMappedFile:(NSString *)path { return nil; }
- (id)initWithData:(NSData *)data { return nil; }

@end



/*
 *	The NSMutableData factory class
 */
@implementation NSMutableData

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSMutableData class] )
		_PFNSCFMutableDataClass = objc_getClass("NSCFData");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSMutableData class] )
		return (id)&_PFNSCFMutableDataClass;
	return [super alloc];
}

/*
 *	NSData (NSDataCreation) class methods to replace
 */
+ (id)data 
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease];
	CFDataRef data = CFDataCreateMutable( kCFAllocatorDefault, 0 );
	PF_RETURN_TEMP(data)
}

// the rest of these should be fine inheriting from NSData
//+ (id)dataWithBytes:(const void *)bytes length:(NSUInteger)length 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithBytes: bytes length: length] autorelease];
//}

//+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithBytesNoCopy: bytes length: length] autorelease];
//}

//+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithBytesNoCopy: bytes length: length freeWhenDone: b] autorelease];
//}

//+ (id)dataWithContentsOfFile:(NSString *)path 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithContentsOfFile: path] autorelease];
//}

//+ (id)dataWithContentsOfFile:(NSString *)path options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithContentsOfFile: path options: readOptionsMask error: errorPtr] autorelease];
//}

//+ (id)dataWithContentsOfURL:(NSURL *)url 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithContentsOfURL: url] autorelease];
//}

//+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithContentsOfURL: url options: readOptionsMask error: errorPtr] autorelease];
//}

//+ (id)dataWithContentsOfMappedFile:(NSString *)path 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithContentsOfMappedFile: path] autorelease];
//}

//+ (id)dataWithData:(NSData *)data 
//{
//	PF_HELLO("")
//	//PF_NIL_ARG(data)
//	return [[[self alloc] initWithData: data] autorelease];
//}


/*
 *	NSMutableData instance methods
 */
- (void *)mutableBytes
{
	return NULL;
}

- (void)setLength:(NSUInteger)length {}

@end


/*
 *	NSMutableData specific creation class methods
 */
@implementation  NSMutableData (NSMutableDataCreation)

+ (id)dataWithCapacity:(NSUInteger)aNumItems
{
	PF_HELLO("")
	return [[[self alloc] initWithCapacity: aNumItems] autorelease];
}

+ (id)dataWithLength:(NSUInteger)length
{
	PF_HELLO("")
	return [[[self alloc] initWithLength: length] autorelease];
}

- (id)initWithCapacity:(NSUInteger)capacity { return nil; }
- (id)initWithLength:(NSUInteger)length { return nil; }

@end

/*
 *	NSMutableData (NSExtendedMutableData) -- if basic enough
 */
//@implementation NSMutableData (NSExtendedMutableData)
//@end



/*
 *	The NSCFData bridged class
 */
@implementation NSCFData

/*
 *	Object maintenance
 */

/*
 *	Called by NSString and NSMutableString +alloc methods. Returns the _PFNSCFStringClass dummy, so that
 *	the impending -init... methods can be correctly delivered. These then replace it with newly-allocated
 *	CFString objects
 */
+(id)alloc
{
	PF_HELLO("")
	return nil; // can't ever instantiate
}



/*
 *	Undocumented method used by CFLite to support bridging
 */
-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFDataGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

-(NSString *)description
{
	PF_HELLO("")
	return [NSString stringWithFormat: @"It's a data! (length = %u)", [self length]]; // to test
	//PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}

/**	NSCopying COMPLIANCE **/
- (id)copyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	CFDataRef new = CFDataCreateCopy( kCFAllocatorDefault ,(CFDataRef)self );
	PF_RETURN_NEW(new)
}

/** NSMutableCopying COMPLIANCE **/

/*
 *	Create an NSCFMutableString
 */
- (id)mutableCopyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	CFMutableDataRef new = CFDataCreateMutableCopy( kCFAllocatorDefault , 0, (CFDataRef)self );
	PF_RETURN_NEW(new)
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
 *	NSData (NSDataCreation) methods
 */
- (id)init
{
	PF_HELLO("")
	PF_DUMMY_DATA(self)
	
	if( isMutable == NO )
		self = (id)CFDataCreate( kCFAllocatorDefault, NULL, 0 );
	else
		self = (id)CFDataCreateMutable( kCFAllocatorDefault, 0 );
	
	PF_RETURN_NEW(self)
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length 
{
	PF_HELLO("")
	PF_DUMMY_DATA(self)

	self = (id)CFDataCreate( kCFAllocatorDefault, (const UInt8 *)bytes, (CFIndex)length );
	PF_RETURN_DATA_INIT
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length 
{
	PF_HELLO("")
	
	return [self initWithBytesNoCopy: bytes length: length freeWhenDone: YES];
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b 
{
	PF_HELLO("")
	PF_DUMMY_DATA(self)
	
	// set up the deallocator based on the value of the freeWhenDone BOOL
	CFAllocatorRef d = b ? kCFAllocatorDefault : kCFAllocatorNull;
	
	self = (id)CFDataCreateWithBytesNoCopy( kCFAllocatorDefault, (const UInt8 *)bytes, (CFIndex)length, d );
	PF_RETURN_DATA_INIT
}

/*
 *	Reading from a file or URL
 */
- (id)initWithContentsOfFile:(NSString *)path 
{
	PF_HELLO("")
	NSError *error;
	return [self initWithContentsOfFile: path options: 0 error: &error];
}


- (id)initWithContentsOfMappedFile:(NSString *)path 
{
	PF_HELLO("")
	NSError *error;
	return [self initWithContentsOfFile: path options: NSMappedRead error: &error];
}



/*
 *	Not entirely sure whether readOptionsMask should be actually treated as a mask or
 *	whether it's two options (uncached and mapped) are mutually eclusive
 */
- (id)initWithContentsOfFile:(NSString *)path options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr 
{
	PF_HELLO("")
	if( path == nil ) { /* set *error */ return nil; }
	const char *filename = [path fileSystemRepresentation];

	//NSLog(@"filename = %s", filename);
	
	if( filename == NULL ) { /* set error */ return nil; }
	
	// open the file and get a file descriptor for it
	int fd = open(filename, O_RDONLY);
	if( fd == -1 ) 
		{ *errorPtr = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil]; return nil; }
	
	//NSLog(@"got fd %u", fd);
	
	// get the size of the file
	struct stat statbuf;
	if (fstat(fd, &statbuf) == -1) 
		{ *errorPtr = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil]; return nil; }
	
	NSUInteger length = statbuf.st_size;
	
	//NSLog(@"got length %u", length);
	
	// if uncached was specified, turn caching off
	if( readOptionsMask & NSUncachedRead )
	{
		//NSLog(@"going to set read to uncahced");
		if(fcntl(fd, F_NOCACHE, 1) == -1)
			{ *errorPtr = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil]; return nil; }
	}

	//NSLog(@"past fnctl, fd = %u", fd);
	
	void *bytes;
	
	// if we're mapping, map...
	if( readOptionsMask & NSMappedRead )
	{
		//NSLog(@"Going to mmap");
		if( (int)(bytes = mmap(0, length, PROT_READ, (MAP_FILE | MAP_PRIVATE | MAP_NOCACHE), fd, 0)) == -1 )
			{ *errorPtr = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil]; return nil; }
	}
	else // ...otherwise, simply read in the data
	{
		//NSLog(@"going to malloc and read");
		bytes = malloc(length);
		//NSLog(@"allocated memory at 0x%X", bytes);
		if( (length = read(fd, bytes, length)) == -1 )
			{ *errorPtr = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil]; return nil; }
	}

	//NSLog(@"bytes is 0x%X", bytes);
	
	PF_DUMMY_DATA(self)

	// create the data object (by copying bytes into it) 
	self = (id)CFDataCreate( kCFAllocatorDefault, (const UInt8 *)bytes, length );
	
	//NSLog(@"self = 0x%X", self);
	
	// clear up
	if( readOptionsMask & NSMappedRead )
		munmap(bytes, length);
	else
		free(bytes);

	close(fd);

	PF_RETURN_DATA_INIT
}


- (id)initWithContentsOfURL:(NSURL *)url 
{
	PF_TODO
	NSError *error;
	if( url == nil ) return nil;
	if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] options: 0 error: &error];
	return [self initWithContentsOfURL: url options: 0 error: &error];
}

- (id)initWithContentsOfURL:(NSURL *)url options:(NSUInteger)readOptionsMask error:(NSError **)errorPtr 
{
	PF_TODO
	if( url == nil ) return nil;
	if( [url isFileURL] ) return [self initWithContentsOfFile: [url path] options: readOptionsMask error: errorPtr];
	
	return nil;
}


- (id)initWithData:(NSData *)data 
{
	PF_HELLO("")
	PF_NIL_ARG(data)
	PF_DUMMY_DATA(self)

	self = (id)CFDataCreateCopy( kCFAllocatorDefault, (CFDataRef)data );
	PF_RETURN_DATA_INIT
}

/*
 *	NSMutableData creation methods
 */
- (id)initWithCapacity:(NSUInteger)capacity 
{
	PF_HELLO("")
	PF_DUMMY_DATA(self)
	if( isMutable == NO ) return nil; // throw exception?
	self = (id)CFDataCreateMutable( kCFAllocatorDefault, 0 );
	// apply capacity hint?
	PF_RETURN_NEW(self)
}

- (id)initWithLength:(NSUInteger)length 
{
	PF_HELLO("")
	PF_DUMMY_DATA(self)
	if( isMutable == NO ) return nil; // throw exception?
	self = (id)CFDataCreateMutable( kCFAllocatorDefault, 0 );
	CFDataIncreaseLength( (CFMutableDataRef)self, (CFIndex)length );
	PF_RETURN_NEW(self)
}


/*
 *	NSData instance methods
 */
- (NSUInteger)length
{
	return (NSUInteger)CFDataGetLength((CFDataRef)self);
}

- (const void *)bytes
{
	return (const void *)CFDataGetBytePtr((CFDataRef)self);
}

/*
 *	NSData (NSExtendedData) instance methods
 */

- (void)getBytes:(void *)buffer 
{
	PF_HELLO("")
	[self getBytes: buffer length: [self length]];
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length 
{
	PF_HELLO("")
	PF_NIL_ARG(buffer)

	CFRange range = CFRangeMake( 0, length );
	CFDataGetBytes( (CFDataRef)self, range, (UInt8 *)buffer );
}

- (void)getBytes:(void *)buffer range:(NSRange)range 
{
	PF_HELLO("")
	PF_NIL_ARG(buffer)

	NSUInteger length = [self length];
	if( (range.location >= length) || ((range.location+range.length) > length) )
		[NSException raise: NSRangeException format: nil];
	CFRange r = CFRangeMake( range.location, range.length );
	
	CFDataGetBytes( (CFDataRef)self, r, (UInt8 *)buffer );
}

- (BOOL)isEqualToData:(NSData *)other 
{
	PF_HELLO("")
	if( self == other ) return YES;
	if( other == nil ) return NO;
	
	return CFEqual( (CFTypeRef)self, (CFTypeRef)other );
}

- (NSData *)subdataWithRange:(NSRange)range 
{
	PF_HELLO("")

	NSUInteger length = [self length];
	if( (length == 0) || (range.location >= length) || ((range.location+range.length) > length) )
		[NSException raise: NSRangeException format: nil];
	CFRange r = CFRangeMake( range.location, range.length );
	
	// get the butes of the sub-range...
	UInt8 *buffer = NSZoneMalloc( nil, range.length );
	CFDataGetBytes( (CFDataRef)self, r, buffer );
	
	// ...and copy them into a new data
	CFDataRef new = CFDataCreate( kCFAllocatorDefault, (const UInt8 *)buffer, range.length );
	NSZoneFree( nil, buffer );
	PF_RETURN_NEW(new)
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile 
{
	PF_HELLO("")
	NSError *error;
	return [self writeToFile: path options: useAuxiliaryFile error: &error];
}

/*
 *	This is a quick-and-dirty implementation which goes via the NSFileManager. If it gets
 *	re-written one day it will use open() and write() directly and therefore return the 
 *	correct POSIX errors
 */
- (BOOL)writeToFile:(NSString *)path options:(NSUInteger)writeOptionsMask error:(NSError **)errorPtr 
{
	PF_HELLO("")
	
	// if we're writing directly to the file location...
	if( writeOptionsMask == 0 )
		return [[NSFileManager defaultManager] createFileAtPath: path contents: self attributes: nil];
		
	// ...otherwise
	// the temp name won't be unique if we try lots of these in quick sucession
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingFormat: @"PFTemp-%u", [[NSDate date] timeIntervalSinceReferenceDate]]; 
		
	//NSLog(@"Trying temp path %@", tempPath);
		
	// could maybe check to see if path exists before doing this
		
	if( YES == [[NSFileManager defaultManager] createFileAtPath: tempPath contents: self attributes: nil] )
	{
		//return [[NSFileManager defaultManager] moveItemAtPath: tempPath toPath: path error: NULL];
#warning Replace this with the version above, once NSFileManager supports it
		return [[NSFileManager defaultManager] movePath: tempPath toPath: path handler: nil];
	}
	return NO;
}

	
// the atomically flag is ignored if the url is not of a type the supports atomic writes
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically 
{
	PF_TODO
	NSError *error;
	if( url == nil ) return NO;
	if( [url isFileURL] ) return [self writeToFile: [url path] options: atomically error: &error];

	return NO;
}


- (BOOL)writeToURL:(NSURL *)url options:(NSUInteger)writeOptionsMask error:(NSError **)errorPtr 
{
	PF_TODO
	if( url == nil ) return NO;
	if( [url isFileURL] ) return [self writeToFile: [url path] options: writeOptionsMask error: errorPtr];
	
	return NO;
}

	
/*
 *	NSMutableData instance methods
 */
- (void *)mutableBytes
{
	PF_HELLO("")
	PF_CHECK_DATA_MUTABLE(self)

	PF_RETURN_NEW( CFDataGetMutableBytePtr( (CFMutableDataRef)self ) )
}

- (void)setLength:(NSUInteger)length 
{
	PF_HELLO("")
	PF_CHECK_DATA_MUTABLE(self)
	
	CFDataSetLength( (CFMutableDataRef)self, (CFIndex)length );
}

/*
 *	NSMutableData (NSExtendedMutableData) instance methods
 */
- (void)appendBytes:(const void *)bytes length:(NSUInteger)length 
{
	PF_HELLO("")
	PF_CHECK_DATA_MUTABLE(self)

	CFDataAppendBytes( (CFMutableDataRef)self, (const UInt8 *)bytes, (CFIndex)length );
}

- (void)appendData:(NSData *)other 
{
	PF_HELLO("")
	PF_CHECK_DATA_MUTABLE(self)

	[self appendBytes: [other bytes] length: [other length]];
}

- (void)increaseLengthBy:(NSUInteger)extraLength 
{
	PF_HELLO("")
	PF_CHECK_DATA_MUTABLE(self)

	CFDataIncreaseLength( (CFMutableDataRef)self, (CFIndex)extraLength );
}

/*
 *	I presume that we're assuming bytes are range.length long...
 */
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes 
{
	PF_TODO
	PF_CHECK_DATA_MUTABLE(self)

	NSUInteger length = [self length];
	if( range.location >= [self length] )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );
	if( (range.location + range.length) > length ) 
		r.length = length - range.location;

	CFDataReplaceBytes( (CFMutableDataRef)self, r, (const UInt8 *)bytes, range.length );
}

- (void)replaceBytesInRange:(NSRange)range 
				  withBytes:(const void *)replacementBytes 
					 length:(NSUInteger)replacementLength 
{
	PF_TODO
	PF_CHECK_DATA_MUTABLE(self)
	
	NSUInteger length = [self length];
	if( range.location >= [self length] )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );
	if( (range.location + range.length) > length ) 
		r.length = length - range.location;
	
	CFDataReplaceBytes( (CFMutableDataRef)self, r, (const UInt8 *)replacementBytes, replacementLength );
}

- (void)resetBytesInRange:(NSRange)range 
{
	PF_TODO
	PF_CHECK_DATA_MUTABLE(self)

	NSUInteger length = [self length];
	if( range.location >= length )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );
	// check that r doesn't exceed the range of self
	if( (range.location + range.length) > length ) 
		r.length = length - range.location;
	
	// don't know if this will work
	UInt8 *newBytes = NSZoneMalloc( nil, range.length ); // hope they're zeroed
	CFDataReplaceBytes( (CFMutableDataRef)self, r, (const UInt8 *)newBytes, range.length );
	NSZoneFree( nil, newBytes );
}

- (void)setData:(NSData *)data 
{
	PF_HELLO("")
	PF_CHECK_DATA_MUTABLE(self)
	PF_NIL_ARG(data)
	
	CFRange range = CFRangeMake( 0, [self length] );
	
	//CFDataDeleteBytes( (CFMutableDataRef)self, range );
	//CFDataAppendBytes( (CFMutableDataRef)self, (const UInt8*)[data bytes], [data length] );
	
	CFDataReplaceBytes( (CFMutableDataRef)self, range, [data bytes], [data length] );
}

 
@end


