/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSStream.m
 *
 *	NSStream, NSInputStream, NSCFInputStream, NSOutputStream, NSCFOutputStream
 *
 *	Created by Stuart Crook on 29/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSStream.h"

/*
 *	This structure is based on _CFStream (defined in CFStreamPriv.h line 71) and is used to create
 *	padding so we can get at the _reserved1 ivar
 */
typedef struct _PFStream {
    UInt32 _cfBase;	// the bit of CFRuntimeBase _cfBase not used as an ISA
    CFOptionFlags flags;  
    CFErrorRef error;
    struct _CFStreamClient *client;
    void *info;
    const struct _CFStreamCallBacks *callBacks;
    //void *_reserved1; <- we'll try to store delegate here, since CF doesn't use it
} _PFStreamIVars;

/*
 *	Bridged classes
 */
@interface NSCFInputStream : NSInputStream
{
	@private
	_PFStreamIVars _reserved0;
	id _reserved1;
}
@end

@interface NSCFOutputStream : NSOutputStream
{
	@private
	_PFStreamIVars _reserved0;
	id _reserved1;
}
@end

/*
 *	Dummy class instances
 */
static Class _PFNSCFInputStreamClass = nil;
static Class _PFNSCFOutputStreamClass = nil;

#define PF_INPUT_CHECK(str) if( str != (id)&_PFNSCFInputStreamClass ) [str autorelease];
#define PF_OUTPUT_CHECK(str) if( str != (id)&_PFNSCFOutputStreamClass ) [str autorelease];

/*
 *	delegate callback function(s... need different profiles?)
 */
void _PFReadStreamCB( CFReadStreamRef stream, CFStreamEventType eventType, void *delegate )
{
	PF_HELLO("")
	if( [(NSObject *)delegate respondsToSelector:@selector(stream:handleEvent:)] )
		[(id)delegate stream: (NSStream *)stream handleEvent: eventType];
}	

void _PFWriteStreamCB( CFWriteStreamRef stream, CFStreamEventType eventType, void *delegate )
{
	PF_HELLO("")
	if( [(id)delegate respondsToSelector:@selector(stream:handleEvent:)] )
		[(id)delegate stream: (NSStream *)stream handleEvent: eventType];
}

#define PF_ALL_STREAM_EVENTS (kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered)

/*
 *	Constants
 */
NSString * const NSStreamSocketSecurityLevelKey	= @"kCFStreamPropertySocketSecurityLevel";
	// set to one of:
NSString * const NSStreamSocketSecurityLevelNone			= @"kCFStreamSocketSecurityLevelNone";
NSString * const NSStreamSocketSecurityLevelSSLv2			= @"kCFStreamSocketSecurityLevelSSLv2";
NSString * const NSStreamSocketSecurityLevelSSLv3			= @"kCFStreamSocketSecurityLevelSSLv3";
NSString * const NSStreamSocketSecurityLevelTLSv1			= @"kCFStreamSocketSecurityLevelTLSv1";
NSString * const NSStreamSocketSecurityLevelNegotiatedSSL	= @"kCFStreamSocketSecurityLevelNegotiatedSSL";

NSString * const NSStreamSOCKSProxyConfigurationKey	= @"kCFStreamPropertySOCKSProxy";
	// dictionary containing keys:
NSString * const NSStreamSOCKSProxyHostKey		= @"SOCKSProxy";
NSString * const NSStreamSOCKSProxyPortKey		= @"SOCKSPort";
NSString * const NSStreamSOCKSProxyVersionKey	= @"kCFStreamPropertySOCKSVersion";
NSString * const NSStreamSOCKSProxyUserKey		= @"kCFStreamPropertySOCKSUser";
NSString * const NSStreamSOCKSProxyPasswordKey	= @"kCFStreamPropertySOCKSPassword";

NSString * const NSStreamSOCKSProxyVersion4	= @"kCFStreamSocketSOCKSVersion4";
NSString * const NSStreamSOCKSProxyVersion5	= @"kCFStreamSocketSOCKSVersion5";

NSString * const NSStreamDataWrittenToMemoryStreamKey	= @"kCFStreamPropertyDataWritten";

NSString * const NSStreamFileCurrentOffsetKey	= @"kCFStreamPropertyFileCurrentOffset";

NSString * const NSStreamSocketSSLErrorDomain	= @"NSStreamSocketSSLErrorDomain";
NSString * const NSStreamSOCKSErrorDomain		= @"NSStreamSOCKSErrorDomain";



/*
 *	NSStream, an abstract class
 */
@implementation NSStream

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSStream class] )
	{
		_PFNSCFInputStreamClass = objc_getClass("NSCFInputStream");
		_PFNSCFOutputStreamClass = objc_getClass("NSCFOutputStream");
	
		//printf("Set _PFNSCFInputStreamClass to 0x%X and _PFNSCFOutputStreamClass to 0x%X\n", _PFNSCFInputStreamClass, _PFNSCFOutputStreamClass);
	}
}

+(id)alloc
{
	if( self == [NSStream class] )
		return nil;
	return [super alloc];
}

// NSSocketStreamCreationExtensions class method
+(void)getStreamsToHost:(NSHost *)host 
				   port:(NSInteger)port 
			inputStream:(NSInputStream **)inputStream 
		   outputStream:(NSOutputStream **)outputStream
{
	PF_HELLO("")
	
	CFStreamCreatePairWithSocketToHost( kCFAllocatorDefault, (CFStringRef)[host address], port, 
									(CFReadStreamRef *)inputStream, (CFWriteStreamRef *)outputStream );
}

// NSStream instance methods
- (void)open {}
- (void)close {}
- (id)delegate { return nil; }
- (void)setDelegate:(id)delegate { }
- (id)propertyForKey:(NSString *)key { return nil; }
- (BOOL)setProperty:(id)property forKey:(NSString *)key { return NO; }
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
- (NSStreamStatus)streamStatus { return NSStreamStatusNotOpen; }
- (NSError *)streamError { return nil; }

@end



/*
 *	NSInputStream
 */
@implementation NSInputStream

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSInputStream class] )
		return (id)&_PFNSCFInputStreamClass;
	return [super alloc];
}

// (NSInputStreamExtensions) class creation methods
+ (id)inputStreamWithData:(NSData *)data
{
	PF_HELLO("")
	return [[[self alloc] initWithData: data] autorelease];
}

+ (id)inputStreamWithFileAtPath:(NSString *)path
{
	PF_HELLO("")
	return [[[self alloc] initWithFileAtPath: path] autorelease];
}


// NSStream instance methods
//- (void)open {}
//- (void)close {}
//- (id)delegate { ret
//- (void)setDelegate:(id)delegate;
//- (id)propertyForKey:(NSString *)key;
//- (BOOL)setProperty:(id)property forKey:(NSString *)key;
//- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
//- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
//- (NSStreamStatus)streamStatus;
//- (NSError *)streamError;

// NSInputStream instance methods
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len { return 0; }
- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len { return NO; }
- (BOOL)hasBytesAvailable { return NO; }


@end


/*
 *	NSCFInputStream class bridged to CFReadStream
 */
@implementation NSCFInputStream

// terminal class
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
	return CFReadStreamGetTypeID();
}

-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}


// (NSInputStreamExtensions) instance creation methods
- (id)initWithData:(NSData *)data
{
	PF_HELLO("")
	PF_INPUT_CHECK(self)
	
	NSUInteger length = [data length];
	UInt8 *bytes = malloc(length);
	[data getBytes: bytes];
	self = (id)CFReadStreamCreateWithBytesNoCopy( kCFAllocatorDefault, bytes, (CFIndex)length, kCFAllocatorMalloc );
	PF_RETURN_NEW(self)
}

- (id)initWithFileAtPath:(NSString *)path
{
	PF_HELLO("")
	PF_INPUT_CHECK(self)
							// this should do [path stringByExpandingTildeInPath]
	NSLog(@"path is %@ at 0x%X", path, path);
	CFURLRef fileURL = CFURLCreateWithFileSystemPath( kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, NO);
	NSLog(@"fileURL is %@ at 0x%X", fileURL, fileURL);
	self = (id)CFReadStreamCreateWithFile( kCFAllocatorDefault, fileURL );
	NSLog(@"self is 0x%X", self);
	[(NSURL *)fileURL release];
	PF_RETURN_NEW(self)
}

// NSStream instance methods
- (void)open
{
	PF_HELLO("")
	// return value is ignored
	CFReadStreamOpen( (CFReadStreamRef)self );
}

- (void)close
{
	PF_HELLO("")
	CFReadStreamClose( (CFReadStreamRef)self );
}

- (id)delegate 
{
	PF_HELLO("")
	return _reserved1;
}

- (void)setDelegate:(id)delegate 
{ 
	PF_HELLO("")
	if( delegate == _reserved1 ) return;
	_reserved1 = delegate;
	CFOptionFlags flags = (delegate == nil) ? kCFStreamEventNone : PF_ALL_STREAM_EVENTS;
	CFStreamClientContext context = { 0, (void *)delegate, NULL, NULL, NULL };
	CFReadStreamSetClient( (CFReadStreamRef)self, flags, (CFReadStreamClientCallBack)&_PFReadStreamCB, &context );
}

- (id)propertyForKey:(NSString *)key
{
	PF_HELLO("")
	
	id new = (id)CFReadStreamCopyProperty( (CFReadStreamRef)self, (CFStringRef)key );
	PF_RETURN_TEMP(new)
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
	PF_HELLO("")
	return CFReadStreamSetProperty( (CFReadStreamRef)self, (CFStringRef)key, (CFTypeRef)property );
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}

- (NSStreamStatus)streamStatus
{
	PF_HELLO("")
	return (NSStreamStatus)CFReadStreamGetStatus( (CFReadStreamRef)self );
}

- (NSError *)streamError
{
	PF_HELLO("")
	NSError *err = (NSError *)CFReadStreamCopyError( (CFReadStreamRef)self );
	PF_RETURN_TEMP(err)
}

// NSInputStream instance methods
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
	PF_HELLO("")
	return (NSUInteger)CFReadStreamRead( (CFReadStreamRef)self, (UInt8 *)buffer, (CFIndex)len );
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
	PF_HELLO("")
	
	*buffer = (uint8_t *)CFReadStreamGetBuffer( (CFReadStreamRef)self, 0, (CFIndex *)len );
	return (*len == -1) ? NO : YES; // was anything read?
}

- (BOOL)hasBytesAvailable
{
	PF_HELLO("")
	return CFReadStreamHasBytesAvailable( (CFReadStreamRef)self );
}

@end




/*
 *	NSOutputStream
 */
@implementation NSOutputStream

+(id)alloc
{
	if( self == [NSOutputStream class] )
		return (id)&_PFNSCFOutputStreamClass;
	return [super alloc];
}

// (NSOutputStreamExtensions) class creaion methods
+ (id)outputStreamToMemory
{
	PF_HELLO("")
	return [[[self alloc] initToMemory] autorelease];
}

+ (id)outputStreamToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity
{
	PF_HELLO("")
	return [[[self alloc] initToBuffer: buffer capacity: capacity] autorelease];
}

+ (id)outputStreamToFileAtPath:(NSString *)path append:(BOOL)shouldAppend
{
	PF_HELLO("")
	return [[[self alloc] initToFileAtPath: path append: shouldAppend] autorelease];
}

// NSStream instance methods
//- (void)open;
//- (void)close;
//- (id)delegate;
//- (void)setDelegate:(id)delegate;
//- (id)propertyForKey:(NSString *)key;
//- (BOOL)setProperty:(id)property forKey:(NSString *)key;
//- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
//- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
//- (NSStreamStatus)streamStatus;
//- (NSError *)streamError;

// NSOutputStream instance methods
- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len { return 0; }
- (BOOL)hasSpaceAvailable { return NO; }

@end



/*
 *	NSCFOutputStream class bridged to CFWriteStream
 */
@implementation NSCFOutputStream

+(id)alloc
{
//	PF_HELLO("")
	return nil; //(id)&_PFNSCFOutputStreamClass;
}


/*
 *	Undocumented method used by Apple to support bridging
 */
-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFWriteStreamGetTypeID();
}

-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}

// (NSOutputStreamExtensions) instance creation methods
- (id)initToMemory
{
	PF_HELLO("")
	PF_OUTPUT_CHECK(self)
	
	self = (id)CFWriteStreamCreateWithAllocatedBuffers( kCFAllocatorDefault, kCFAllocatorDefault );
	PF_RETURN_NEW(self)
}

- (id)initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity
{
	PF_HELLO("")
	PF_OUTPUT_CHECK(self)
	
	self = (id)CFWriteStreamCreateWithBuffer( kCFAllocatorDefault, (UInt8 *)buffer, (CFIndex)capacity );
	PF_RETURN_NEW(self)
}

- (id)initToFileAtPath:(NSString *)path append:(BOOL)shouldAppend
{
	PF_HELLO("")
	PF_OUTPUT_CHECK(self)
	
	// this should do [path stringByExpandingTildeInPath]
	CFURLRef fileURL = CFURLCreateWithFileSystemPath( kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, NO);
	self = (id)CFWriteStreamCreateWithFile( kCFAllocatorDefault, fileURL );
	if( shouldAppend ) 
		CFWriteStreamSetProperty( (CFWriteStreamRef)self, kCFStreamPropertyAppendToFile, kCFBooleanTrue); 
	[(NSURL *)fileURL release];
	PF_RETURN_NEW(self)
}

// NSStream instance methods
- (void)open
{
	PF_HELLO("")
	CFWriteStreamOpen( (CFWriteStreamRef)self );
}

- (void)close
{
	PF_HELLO("")
	CFWriteStreamClose( (CFWriteStreamRef)self );
}

/*
 *	Delegates: currently set as part of the context passed to the callback. Is there some way we can
 *	then read it back? Or is there spance in the CF...Stream structure to store it?
 */
- (id)delegate 
{ 
	PF_HELLO("")
	return _reserved1; 
}

- (void)setDelegate:(id)delegate 
{
	PF_HELLO("")
	if( delegate == _reserved1 ) return;
	_reserved1 = delegate;
	CFOptionFlags flags = (delegate == nil) ? kCFStreamEventNone : PF_ALL_STREAM_EVENTS;
	CFStreamClientContext context = { 0, (void *)delegate, NULL, NULL, NULL };
	CFWriteStreamSetClient( (CFWriteStreamRef)self, flags, (CFWriteStreamClientCallBack)&_PFWriteStreamCB, &context );
}

- (id)propertyForKey:(NSString *)key
{
	PF_HELLO("")
	id new = (id)CFWriteStreamCopyProperty( (CFWriteStreamRef)self, (CFStringRef)key );
	PF_RETURN_TEMP(new)
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
	PF_HELLO("")
	return CFWriteStreamSetProperty( (CFWriteStreamRef)self, (CFStringRef)key, (CFTypeRef)property );
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}

- (NSStreamStatus)streamStatus
{
	PF_HELLO("")
	return (NSStreamStatus)CFWriteStreamGetStatus( (CFWriteStreamRef)self );
}

- (NSError *)streamError
{
	PF_HELLO("")
	NSError *err = (NSError *)CFWriteStreamCopyError( (CFWriteStreamRef)self );
	PF_RETURN_TEMP(err)
}

// NSOutputStream instance methods
- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
	PF_HELLO("")
	return (NSUInteger)CFWriteStreamWrite( (CFWriteStreamRef)self, (const UInt8 *)buffer, (CFIndex)len );	
}

- (BOOL)hasSpaceAvailable
{
	PF_HELLO("")
	return CFWriteStreamCanAcceptBytes( (CFWriteStreamRef)self );
}

@end





