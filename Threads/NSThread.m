/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSThread.m
 *
 *	NSThread
 *
 *	Created by Stuart Crook on 16/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSThread.h"
#import "PureFoundation.h"

#include <pthread.h>
#include <sys/resource.h>
#include <time.h>

/*
 *	Constants
 */
NSString * const NSWillBecomeMultiThreadedNotification = @"NSWillBecomeMultiThreadedNotification";
NSString * const NSDidBecomeSingleThreadedNotification = @"NSDidBecomeSingleThreadedNotification";
NSString * const NSThreadWillExitNotification = @"NSThreadWillExitNotification";


/*
 *	ivars:	id _private;
 *			uint8_t _bytes[44];
 *
 *	So we use this to make access to NSThreads ivar storage a little easier.
 */
typedef struct _PFThread {
	Class isa;
	NSMutableDictionary	*_dict; // id _private	64-bit
	NSString *_name;			// _bytes[0]	 0
	NSUInteger _stackSize;		// _bytes[4]	 8
	pthread_t _tid;				// 8			 12
	id _target;					// 12			 20
	SEL _selector;				// 16			 28
	id _object;					// 20			 36
	BOOL _executing;			// 24		     44
	BOOL _finished;				// 25			 45 -- oh, damn... (although, ivars should be movable
	BOOL _cancelled;			// 26			 46				under the new runtime...)
} _pfT;


/*
 *	
 */
NSThread *_pfMainThread = nil;
pthread_t _pfMainThreadID = 0;
CFMutableDictionaryRef _pfThreadStore = nil;

// since we're using pthread_t values as keys in the store dictionary, we need a special comparison function
Boolean _pfThreadKeyEqual( const void *value1, const void *value2 ) 
{ 
	return pthread_equal((pthread_t)value1, (pthread_t)value2);
}

// the function called when a thread starts running. parameter is a pointer to a NSThread object
void *_pfThreadRun( void *parameter ) { return objc_msgSend((id)parameter, @selector(main)); }


/*
 *	
 */
@implementation NSThread

+ (void)initialize
{
	if( self == [NSThread class] )
	{
		// create the _pfThreadStore dictionary
		CFDictionaryKeyCallBacks cb = { 0, NULL, NULL, NULL, _pfThreadKeyEqual, NULL };
		_pfThreadStore = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &cb, NULL );

		// get the main thread ID
		pthread_t mainTID = pthread_self();
		_pfMainThreadID = mainTID;

		// create an NSThread object for the main thread
		_pfMainThread = [[NSThread alloc] init];
		((_pfT *)_pfMainThread)->_tid = mainTID;
		
		pthread_attr_t attr;
		size_t stackSize;
		pthread_attr_init(&attr);
		pthread_attr_getstacksize( &attr, &stackSize );
		((_pfT *)_pfMainThread)->_stackSize = stackSize;

		// add it to the _pfThreadStore
		CFDictionaryAddValue( _pfThreadStore, (const void *)mainTID, (const void *)_pfMainThread );
	}
}

/*
 *	Thread creation, deallocation
 */
+ (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(id)argument { }


- (id)init 
{
	if( self = [super init] )
	{
		// set up the thread dictionary with an assertion handler
		((_pfT*)self)->_dict = (NSMutableDictionary *)CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, (CFDictionaryValueCallBacks *)&_PFCollectionCallBacks );
		
		NSLog( @"created thread dict 0x%X", ((_pfT*)self)->_dict );
		
		// set up the rest of the thread structure
		((_pfT*)self)->_stackSize = 524288; // default 512k size
		((_pfT*)self)->_name = nil;
		((_pfT*)self)->_executing = NO;
		((_pfT*)self)->_finished = NO;
		((_pfT*)self)->_cancelled = NO;
	}
	return self;
}

- (id)initWithTarget:(id)target selector:(SEL)selector object:(id)argument 
{
	if( self = [self init] )
	{
		((_pfT*)self)->_target = target;
		((_pfT*)self)->_selector = selector;
		((_pfT*)self)->_object = argument;
	}
	return self;
}

- (void)dealloc
{
	[((_pfT*)self)->_dict release];
	[super dealloc];
}

/*
 *	
 */
+ (BOOL)isMultiThreaded { return _pf_IsMultiThreaded; }

+ (NSThread *)mainThread { return _pfMainThread; }

+ (NSThread *)currentThread
{
	pthread_t threadID = pthread_self();
	return (NSThread *)CFDictionaryGetValue( _pfThreadStore, (const void *)threadID ); 
}


/*
 *	Class methods used to manipulate the current thread
 */
+ (void)sleepUntilDate:(NSDate *)date
{
	NSTimeInterval ti = [date timeIntervalSinceReferenceDate] - CFAbsoluteTimeGetCurrent();
	if( ti > 0.0 ) [self sleepForTimeInterval: ti];
}

+ (void)sleepForTimeInterval:(NSTimeInterval)ti 
{
	if( ti < 0.0 ) return;
	
	struct timespec rqtp, rmtp;
	rqtp.tv_sec = (time_t)ti;
	rqtp.tv_nsec = (long)((ti - rqtp.tv_sec) * 1000000000);
	rmtp.tv_sec = 0;
	rmtp.tv_nsec = 0;
	
	while( nanosleep(&rqtp, &rmtp) != 0 )
	{
		rqtp.tv_sec = rmtp.tv_sec;
		rqtp.tv_nsec = rqtp.tv_nsec;
		rmtp.tv_sec = 0;
		rmtp.tv_nsec = 0;
	}
}


// these have to map a float 0.0-1.0 to the get/setpriority() parameter of either
//	0 (foreground) or PRIO_DARWIN_BG (background)
+ (double)threadPriority 
{ 
	// 0 = not background, 1 = background
	return (getpriority(PRIO_DARWIN_THREAD, 0) == 0) ? 1.0 : 0.0;
}

+ (BOOL)setThreadPriority:(double)p
{
	int prio = (p > 0.8) ? 0 : PRIO_DARWIN_BG;
	return (setpriority(PRIO_DARWIN_THREAD, 0, prio) == 0) ? YES : NO;
}

+ (NSArray *)callStackReturnAddresses {  }

+ (void)exit 
{ 
	// get the NSThread for this thread
	NSThread *thread = [self currentThread];
	if( (thread == nil) || (((_pfT*)thread)->_executing == NO) ) return; // this thread wasn't launched through NSThread
	
	// set the threads status
	((_pfT*)thread)->_executing = NO;
	((_pfT*)thread)->_finished = YES;
	
	// post the NSThreadWillExit notification for this thread
	
	// and finally, exit
	pthread_exit(NULL); 
}


+ (BOOL)isMainThread 
{
	pthread_t threadID = pthread_self();
	return pthread_equal(threadID, _pfMainThreadID);
}

/*
 *	Instance methods
 */
- (BOOL)isMainThread { return (self == _pfMainThread); }

- (void)setName:(NSString *)n 
{ 
	[((_pfT*)self)->_name release];
	((_pfT*)self)->_name = [n copyWithZone: nil];
}

- (NSString *)name { return [[((_pfT*)self)->_name copyWithZone: nil] autorelease]; }

- (NSUInteger)stackSize { return ((_pfT*)self)->_stackSize; }

- (void)setStackSize:(NSUInteger)s { ((_pfT*)self)->_stackSize = s; } // check boundary before setting

- (NSMutableDictionary *)threadDictionary { return ((_pfT*)self)->_dict; }


- (BOOL)isExecuting { return ((_pfT*)self)->_executing; }

- (BOOL)isFinished { return ((_pfT*)self)->_finished; }

- (BOOL)isCancelled { return ((_pfT*)self)->_cancelled; }

- (void)cancel { ((_pfT*)self)->_cancelled = YES; }

/*
 *	Start the thread running, sending notifications if this is the first thread spawned.
 */
- (void)start 
{
	// check current status. these exceptions need more detail
	if( ((_pfT*)self)->_executing == YES )
		[NSException raise: NSInternalInconsistencyException format: nil];

	if( ((_pfT*)self)->_finished == YES )
		[NSException raise: NSInternalInconsistencyException format: nil];

	if( ((_pfT*)self)->_cancelled == YES )
		[NSException raise: NSInternalInconsistencyException format: nil];

	// check if this is the first thread spawned
	if( _pf_IsMultiThreaded == NO )
	{
		// send the notification SYNCHRONOUSLY

		_pf_IsMultiThreaded == YES;
	}

	int err;

	// set attributes, like stack size
	pthread_attr_t attr;
	pthread_attr_init(&attr);
	pthread_attr_setstacksize(&attr, ((_pfT*)self)->_stackSize);
	
	// create a thread with pthread_create. target function is _pfThreadRun, the extra parameter
	//	is self.... or do we get the IMP for [self main] ??? Might be neater...
	pthread_t threadID;
	if( (err = pthread_create( &threadID, &attr, _pfThreadRun, (void *)self )) != 0 )
	{
		NSLog(@"pthread_create failed with error code %u", err);
		return;
	}
	
	pthread_attr_destroy(&attr);
	
	// enter the NSThread into _pfThreadStore, now we have a key for it
	((_pfT*)self)->_tid = threadID;
	CFDictionaryAddValue( _pfThreadStore, (const void *)threadID, (const void *)self );
	
	
	// set the threads status
	((_pfT*)self)->_executing = YES;
}

/*
 *	In sub-classes, this is the main method to be replaced. So we assume that everything about the
 *	thread has been set-up before it is called.
 */
- (void)main 
{
	[((_pfT*)self)->_target retain];
	[((_pfT*)self)->_object retain];
	objc_msgSend( ((_pfT*)self)->_target, ((_pfT*)self)->_selector, ((_pfT*)self)->_object );
	[((_pfT*)self)->_object release];
	[((_pfT*)self)->_target release];	
}

@end


/*
 *	Additions to NSObject
 */
@implementation NSObject (NSThreadPerformAdditions)

- (void)performSelectorOnMainThread:(SEL)aSelector 
						 withObject:(id)arg 
					  waitUntilDone:(BOOL)wait 
							  modes:(NSArray *)array
{
}

- (void)performSelectorOnMainThread:(SEL)aSelector 
						 withObject:(id)arg 
					  waitUntilDone:(BOOL)wait
{
}

- (void)performSelector:(SEL)aSelector 
			   onThread:(NSThread *)thr 
			 withObject:(id)arg waitUntilDone:(BOOL)wait 
				  modes:(NSArray *)array
{
}

- (void)performSelector:(SEL)aSelector 
			   onThread:(NSThread *)thr 
			 withObject:(id)arg 
		  waitUntilDone:(BOOL)wait
{
}

// equivalent to the first method with kCFRunLoopCommonModes
- (void)performSelectorInBackground:(SEL)aSelector withObject:(id)arg { }

@end

