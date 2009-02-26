/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSRunLoop.m
 *
 *	NSRunLoop
 *
 *	Created by Stuart Crook on 18/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSRunLoop.h"

/*
 *	Constants
 */
NSString * const NSDefaultRunLoopMode = @"";
NSString * const NSRunLoopCommonModes = @"";


NSRunLoop *_pfMainRunLoop = nil;

/*
 *	ivars:	id		_rl;
 *			id		_dperf;
 *			id		_perft;
 *			void	*_reserved[8];
 */
@implementation NSRunLoop

/*
 *	Life cycle
 */
- (id)init
{
	_rl = (id)CFRunLoopGetCurrent();
	_dperf = nil;
	_perft = nil;
	
	return self;
}

- (void)dealloc
{
	if( _pfMainRunLoop == self ) _pfMainRunLoop = nil;
	[[[NSThread currentThread] threadDictionary] removeObjectForKey: @"NSRunLoop"];
	
	_rl = nil; // got, so don't release
	// etc...
	
	[super dealloc];
}

/*
 *	Runloops will be stored in the current thread's dictionary under @"NSRunLoop"
 */
+ (NSRunLoop *)currentRunLoop 
{ 
	NSThread *thread = [NSThread currentThread];
	NSMutableDictionary *dict = [thread threadDictionary];
	NSRunLoop *rl = [dict objectForKey: @"NSRunLoop"];
	if( rl == nil )
	{
		rl = [[[NSRunLoop alloc] init] autorelease];
		[dict setObject: rl forKey: @"NSRunLoop"];
		if( thread == [NSThread mainThread] ) _pfMainRunLoop = rl;
	}
	return rl;
}

+ (NSRunLoop *)mainRunLoop 
{
	if( _pfMainRunLoop == nil )
	{
		NSRunLoop *rl = [[[NSRunLoop alloc] init] autorelease];
		[[[NSThread currentThread] threadDictionary] setObject: rl forKey: @"NSRunLoop"];
		_pfMainRunLoop = rl;
	}
	return _pfMainRunLoop;
}

/*
 *	Runloop instance methods
 */
- (NSString *)currentMode { }

- (CFRunLoopRef)getCFRunLoop { return (CFRunLoopRef)_rl; }

- (void)addTimer:(NSTimer *)timer forMode:(NSString *)mode {}

- (void)addPort:(NSPort *)aPort forMode:(NSString *)mode {}

- (void)removePort:(NSPort *)aPort forMode:(NSString *)mode {}

- (NSDate *)limitDateForMode:(NSString *)mode {}

- (void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limitDate {}

@end

@implementation NSRunLoop (NSRunLoopConveniences)

- (void)run { CFRunLoopRun(); }

- (void)runUntilDate:(NSDate *)limitDate {}
- (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate {}

// DEPRECATED_IN_MAC_OS_X_VERSION_10_5_AND_LATER;
- (void)configureAsServer {}

@end




/**************** 	Delayed perform	 ******************/

/*
@implementation NSObject (NSDelayedPerforming)

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes;
- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;
+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument;
+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget;

@end

@implementation NSRunLoop (NSOrderedPerform)

- (void)performSelector:(SEL)aSelector target:(id)target argument:(id)arg order:(NSUInteger)order modes:(NSArray *)modes;
- (void)cancelPerformSelector:(SEL)aSelector target:(id)target argument:(id)arg;
- (void)cancelPerformSelectorsWithTarget:(id)target;
 
@end
*/

