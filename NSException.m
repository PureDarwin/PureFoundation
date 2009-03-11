/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSException.m
 *
 *	NSException
 *
 *	Created by Stuart Crook on 27/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

/*
 *	NSException itself is fairly simple -- it just holds two strings and a dictionary -- the
 *	trick is raising it, calling the correct exception handler, and then leanving
 */

/*
 *	Some exceptions
 */
// moved into CFLite: ForFoundationOnly.h and CFRuntime.c
//NSString * const NSGenericException					= @"NSGenericException";
//NSString * const NSRangeException					= @"NSRangeException";			
//NSString * const NSInvalidArgumentException			= @"NSInvalidArgumentException";
//NSString * const NSInternalInconsistencyException	= @"NSInternalInconsistencyException";

//NSString * const NSMallocException		= @"NSMallocException";

NSString * const NSObjectInaccessibleException	= @"NSObjectInaccessibleException";
NSString * const NSObjectNotAvailableException	= @"NSObjectNotAvailableException";
NSString * const NSDestinationInvalidException	= @"NSDestinationInvalidException";

NSString * const NSPortTimeoutException			= @"NSPortTimeoutException";
NSString * const NSInvalidSendPortException		= @"NSInvalidSendPortException";
NSString * const NSInvalidReceivePortException	= @"NSInvalidReceivePortException";
NSString * const NSPortSendException			= @"NSPortSendException";
NSString * const NSPortReceiveException			= @"NSPortReceiveException";

NSString * const NSOldStyleException	= @"NSOldStyleException";


/*
 *	NSException
 *
 *	Really sloppy first attempt. Objects aren't retained, nil values are allowed, and -raise just
 *	prints the exception name and reason and then exit(1)s.
 *
 *		NSString		*name;
 *		NSString		*reason;
 *		NSDictionary	*userInfo;
 *		id				reserved;
 */
@implementation NSException

/*
 *	Convinience methods which we'll probably use a lot
 */
+ (void)raise:(NSString *)name format:(NSString *)format, ...
{
	va_list argList;
	va_start( argList, format );
	[self raise: name format: format arguments: argList];
	va_end( argList );
}

+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList
{
	NSString *reason = [[NSString alloc] initWithFormat: format arguments: argList];
	[[self exceptionWithName: name reason: reason userInfo: nil] raise];
}

+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo
{
	return [[NSException alloc] initWithName: name reason: reason userInfo: userInfo];
}

- (id)initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
	if( self = [super init] )
	{
		//NSLog(@"NSException initWithName: %@ reason: %@", aName, aReason);
		name = aName;
		reason = aReason;
		userInfo = aUserInfo;
	}
	return self;
}

- (NSString *)name
{
	return name;
}

- (NSString *)reason
{
	return reason;
}

- (NSDictionary *)userInfo
{
	return userInfo;
}

- (NSArray *)callStackReturnAddresses //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER
{
	return nil;
}

/*
 *	Yes, I'm very, very sorry, but this is a simply retarded implementation
 */
- (void)raise
{
	printf("Exception raise: is this getting through?\n");
	//NSLog(@"Exception: %@ (%@)", [self name], [self reason]);
	@throw self;
}

- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

@end


NSUncaughtExceptionHandler *NSGetUncaughtExceptionHandler(void)
{
	return nil;
}

void NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler *handler)
{
	
}



/*
 *	NSAssertionHandler
 */
@implementation NSAssertionHandler

+ (NSAssertionHandler *)currentHandler
{
	PF_HELLO("")
	
	NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
	NSAssertionHandler *handler = [dict objectForKey: @"NSAssertionHandler"];
	if( handler == nil )
	{
		NSLog(@"no assertion handler set in dict 0x%X", dict);
		handler = [[NSAssertionHandler alloc] init];
		[dict setObject: handler forKey: @"NSAssertionHandler"];
	}
	return handler;
}

- (void)handleFailureInMethod:(SEL)selector 
					   object:(id)object 
						 file:(NSString *)fileName 
				   lineNumber:(NSInteger)line 
				  description:(NSString *)format,...
{
	va_list args;
	va_start( args, format );
	
	CFStringRef desc = CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, args );
	
	NSLog( @"*** Assertion failure in [%s %s], %@:%u (%@)", object_getClassName(object), sel_getName(selector), fileName, line, format );
	[NSException raise: NSInternalInconsistencyException format: (NSString *)desc];
	
	[(id)desc release];
	va_end( args );
}

- (void)handleFailureInFunction:(NSString *)functionName 
						   file:(NSString *)fileName 
					 lineNumber:(NSInteger)line 
					description:(NSString *)format,...
{
	va_list args;
	va_start( args, format );
	
	CFStringRef desc = CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, args );
	
	NSLog( @"*** Assertion failure in %@(), %@:%u (%@)", functionName, fileName, line, format );
	[NSException raise: NSInternalInconsistencyException format: (NSString *)desc];
	
	[(id)desc release];
	va_end( args );
}

@end

