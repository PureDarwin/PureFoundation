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
NSString * const NSDefaultRunLoopMode = @"kCFRunLoopDefaultMode";
NSString * const NSRunLoopCommonModes = @"kCFRunLoopCommonModes";


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
- (NSString *)currentMode { PF_RETURN_TEMP(CFRunLoopCopyCurrentMode((CFRunLoopRef)_rl)) }

- (CFRunLoopRef)getCFRunLoop { return (CFRunLoopRef)_rl; }

- (void)addTimer:(NSTimer *)timer forMode:(NSString *)mode 
{
	CFRetain((CFTypeRef)timer);
	CFRunLoopAddTimer((CFRunLoopRef)_rl, (CFRunLoopTimerRef)timer, (CFStringRef)mode);
}

- (void)addPort:(NSPort *)aPort forMode:(NSString *)mode 
{


}

- (void)removePort:(NSPort *)aPort forMode:(NSString *)mode {}

- (NSDate *)limitDateForMode:(NSString *)mode 
{
	CFAbsoluteTime next = CFRunLoopGetNextTimerFireDate((CFRunLoopRef)_rl, (CFStringRef)mode);
	PF_RETURN_TEMP(CFDateCreate( kCFAllocatorDefault, next ))
}

- (void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limitDate 
{
	CFTimeInterval length = CFDateGetAbsoluteTime((CFDateRef)limitDate) - CFAbsoluteTimeGetCurrent();
	CFRunLoopRunInMode((CFStringRef)mode, length, TRUE);
}

@end

@implementation NSRunLoop (NSRunLoopConveniences)

- (void)run 
{ 
	/*	This implementation is strictly correct, since the docs say it should repeatedly call
	 *	runMode:beforeDate:. However, as far as I can tell it achieves the same result 
	 */
	CFRunLoopRun(); 
}

- (void)runUntilDate:(NSDate *)limitDate 
{
	CFTimeInterval length = CFDateGetAbsoluteTime((CFDateRef)limitDate) - CFAbsoluteTimeGetCurrent();
	// docs don't say what mode it should be run in, so we'll assume the common modes
	CFRunLoopRunInMode(kCFRunLoopCommonModes, length, FALSE);
}

- (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate 
{
	CFTimeInterval length = CFDateGetAbsoluteTime((CFDateRef)limitDate) - CFAbsoluteTimeGetCurrent();
	SInt32 result = CFRunLoopRunInMode((CFStringRef)mode, length, TRUE);
	return (result == kCFRunLoopRunFinished) ? NO : YES;
}

// DEPRECATED_IN_MAC_OS_X_VERSION_10_5_AND_LATER;
// "Deprecated. Does nothing."
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

