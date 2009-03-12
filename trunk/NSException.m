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
 *	Application-specific uncaught exception handler
 */
static NSUncaughtExceptionHandler *uncaughtHandler = nil;

NSUncaughtExceptionHandler *NSGetUncaughtExceptionHandler(void) 
{ 
	//printf("NSGetUncaughtExceptionHandler()\n");
	return uncaughtHandler; 
}

void NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler *handler) 
{ 
	//printf("NSSetUncaughtExceptionHandler()\n");
	uncaughtHandler = handler; 
}


/*
 *	PureFoundation's default uncaught exception handler. Like Apple's, this gets
 *	invoked in addition to any application-specific handler. Unlike Apple's, it
 *	doesn't provide any useful information
 */
void __defaultUncaughtHandler( id value )
{
	NSLog( @"*** Uncaught Exception Handler: Good Bye." );
}


/*
 *	Exception handlers
 */
#import <objc/runtime.h>
#import <objc/objc-exception.h>

#import <pthread.h>
#import <setjmp.h>

/* This structure is created and passed-in by the compiler and runtime and 
 *	is defined in objc-exception.c. It's copied here so we know what we're
 *	dealing with */
typedef struct { jmp_buf buf; void *pointers[4]; } LocalData_t;

// the key under which we'll store the head of the exception chain
static pthread_key_t exceptionKey;

/*
 *	The functions below began life by being copy & pasted from objc/objc-exceptions.c.
 *	Since then they have been changed beyond recognition, so I think we're safe in
 *	not invoking the Apple licence here.
 */
static void default_try_enter(void *localExceptionData) {
	//printf("default_try_enter\n");

    ((LocalData_t *)localExceptionData)->pointers[1] = pthread_getspecific(exceptionKey);
	pthread_setspecific(exceptionKey, localExceptionData);
}

static void default_throw(id value) {
	//printf("default_throw\n");

    if (value == nil) {
		// Hmmm... maybe we should throw our own NSInvalidArgumentException ;)
        printf("EXCEPTIONS: objc_exception_throw with nil value\n");
        return;
    }
	
	LocalData_t *firstHandler = pthread_getspecific(exceptionKey);

	if (firstHandler == NULL) {
        //printf("EXCEPTIONS: No handler in place!\n");
		if( uncaughtHandler != NULL ) uncaughtHandler(value);
		__defaultUncaughtHandler(value);
		exit(0);
    }
	
	pthread_setspecific(exceptionKey, firstHandler->pointers[1]);
	firstHandler->pointers[0] = value;
    _longjmp(firstHandler->buf, 1);
}

static void default_try_exit(void *led) {
	//printf("default_try_exit\n");

	LocalData_t *firstHandler = pthread_getspecific(exceptionKey);
	if( firstHandler != NULL )
		pthread_setspecific(exceptionKey, firstHandler->pointers[1]);
}

static id default_extract(void *localExceptionData) {
	//printf("default_extract\n");

	return (id)((LocalData_t *)localExceptionData)->pointers[0];
}

static int default_match(Class exceptionClass, id exception) {
	//printf("default_match: class = %p, exception = %p\n", exceptionClass, exception);

    for (Class cls = exception->isa; nil != cls; cls = class_getSuperclass(cls)) 
		if (cls == exceptionClass) 
			return 1; //printf("default_match: returning 1\n");
	//printf("default_match: returning 0\n");
	return 0;
}

extern void _pfInitExceptions( void )
{
	// create the key used to access each thread's list of exception handlers
	pthread_key_create(&exceptionKey, NULL);
	
	// install our exception handling functions
	objc_exception_functions_t handlers = { 0, default_throw, default_try_enter, default_try_exit, default_extract, default_match };
    objc_exception_set_functions(&handlers);
}



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
	//printf("raise:format:\n");
	va_list argList;
	va_start( argList, format );
	[self raise: name format: format arguments: argList];
	va_end( argList );
}

+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList
{
	//printf("raise:format:arguments:\n");
	//NSString *reason = [[NSString alloc] initWithFormat: format arguments: argList];
	CFStringRef reason;
	if( format == nil )
		reason = nil;
	else
		reason = CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, argList );
	//printf("reason = %p\n", reason);
	[[self exceptionWithName: name reason: (NSString *)reason userInfo: nil] raise];
}

+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo
{
	//printf("exceptionWithName:reason:userInfo:\n");
	return [[self alloc] initWithName: name reason: reason userInfo: userInfo];
}

- (id)initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
	if( self = [super init] )
	{
		//NSLog(@"NSException initWithName: %@ reason: %@", aName, aReason);
		name = [aName retain];
		reason = [aReason retain];
		userInfo = [aUserInfo retain];
	}
	return self;
}

- (NSString *)name
{
	return name;
}

- (NSString *)reason
{
	//NSLog( reason );
	//printf("NSException -reason\n");
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
	//printf("Exception raise: is this getting through?\n");
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

