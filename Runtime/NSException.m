/*
 *	PureFoundation -- http://puredarwin.org
 *	NSException.m
 *
 *	NSException
 *
 *	Created by Stuart Crook on 27/01/2009.
 */

#import "NSException.h"
#import "NSString.h"
#import "NSDebug.h"

// NSException is implemented in CF
// TODO: Audit and then update this implementation

static NSUncaughtExceptionHandler *uncaughtHandler = nil;

NSUncaughtExceptionHandler *NSGetUncaughtExceptionHandler(void) {
	return uncaughtHandler;
}

void NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler *handler) {
	uncaughtHandler = handler;
}

/*
 *	PureFoundation's default uncaught exception handler. Like Apple's, this gets
 *	invoked in addition to any application-specific handler. Unlike Apple's, it
 *	doesn't provide any useful information
 */
void __defaultUncaughtHandler( id value ) {
	NSLog( @"*** Uncaught Exception Handler: Good Bye." );
}


//000000000021a444 t +[NSException(NSUnpublishedEOF) aggregateExceptionWithExceptions:]
//000000000021a4c7 t +[NSException(NSUnpublishedEOF) validationExceptionWithFormat:]
//00000000001428dc t -[NSException(NSException) debugDescription]
//00000000001426fd t -[NSException(NSException) encodeWithCoder:]
//00000000001427fa t -[NSException(NSException) initWithCoder:]
//00000000002803d8 t -[NSException(NSExceptionPortCoding) replacementObjectForPortCoder:]
//000000000021a5c6 t -[NSException(NSUnpublishedEOF) exceptionAddingEntriesToUserInfo:]
//000000000021a6c1 t -[NSException(NSUnpublishedEOF) exceptionRememberingObject:key:]



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
		//if(NSHangOnUncaughtException) while(TRUE) {} // not sure if this is what they meant by "hang"
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

    for (Class cls = [exception class]; nil != cls; cls = class_getSuperclass(cls))
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
    // TODO: has this changed?
    /*
	objc_exception_functions_t handlers = { 0, default_throw, default_try_enter, default_try_exit, default_extract, default_match };
    objc_exception_set_functions(&handlers);
     */
}



/*
 *	NSException itself is fairly simple -- it just holds two strings and a dictionary -- the
 *	trick is raising it, calling the correct exception handler, and then leanving
 */

/*
 *	Some exceptions
 */

NSString * const NSObjectInaccessibleException	= @"NSObjectInaccessibleException";
NSString * const NSObjectNotAvailableException	= @"NSObjectNotAvailableException";
NSString * const NSDestinationInvalidException	= @"NSDestinationInvalidException";

NSString * const NSPortTimeoutException			= @"NSPortTimeoutException";
NSString * const NSInvalidSendPortException		= @"NSInvalidSendPortException";
NSString * const NSInvalidReceivePortException	= @"NSInvalidReceivePortException";
NSString * const NSPortSendException			= @"NSPortSendException";
NSString * const NSPortReceiveException			= @"NSPortReceiveException";

NSString * const NSOldStyleException	= @"NSOldStyleException";

// TODO: Ensure that these are declared somewhere
// S _NSCharacterConversionException
// S _NSDecimalNumberDivideByZeroException
// S _NSDecimalNumberExactnessException
// S _NSDecimalNumberOverflowException
// S _NSDecimalNumberUnderflowException
// S _NSExtensionInternalErrorException
// S _NSFailedAuthenticationException
// S _NSFileHandleOperationException
// S _NSHangOnUncaughtException
// S _NSInconsistentArchiveException
// S _NSInvalidArchiveOperationException
// s _NSInvalidLayoutConstraintException
// S _NSInvalidUnarchiveOperationException
// S _NSInvocationOperationCancelledException
// S _NSInvocationOperationVoidResultException
// S _NSParseErrorException
// S _NSUndefinedKeyException
