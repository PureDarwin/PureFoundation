/*
 *	PureFoundation -- http://puredarwin.org
 *	NSRunLoop.m
 *
 *	NSRunLoop
 *
 *	Created by Stuart Crook on 18/02/2009.
 */

#import "NSRunLoop.h"

// NSRunLoop is defined in CF but implemented here in Foundation

#define RUNLOOP ((CFRunLoopRef)_rl)

static NSRunLoop *_pfMainRunLoop = nil;

/*
 *	ivars:	id		_rl;
 *			id		_dperf;
 *			id		_perft;
 *			void	*_reserved[8];
 */
@implementation NSRunLoop (NSRunLoop)

// TODO:
//00000000001cc2c0 t -[NSRunLoop(NSRunLoop) allModes]
//00000000000904df t -[NSRunLoop(NSRunLoop) containsPort:forMode:]
//00000000001cc1c9 t -[NSRunLoop(NSRunLoop) containsTimer:forMode:]
//00000000001cc016 t -[NSRunLoop(NSRunLoop) copyWithZone:]
//00000000001cc03d t -[NSRunLoop(NSRunLoop) description]
//00000000001cc099 t -[NSRunLoop(NSRunLoop) portsForMode:]
//00000000001cc0b2 t -[NSRunLoop(NSRunLoop) removeTimer:forMode:]
//00000000001cc66f t -[NSRunLoop(NSRunLoop) runBeforeDate:]
//00000000001cc568 t -[NSRunLoop(NSRunLoop) runMode:untilDate:]
//00000000001cc1b0 t -[NSRunLoop(NSRunLoop) timersForMode:]

- (id)init {
    if (self = [super init]) {
        _rl = (id)CFRunLoopGetCurrent();
        _dperf = nil;
        _perft = nil;
    }
    return self;
}

- (id)initWithCFRunLoop:(CFRunLoopRef)cfRunLoop {
    if (self = [super init]) {
        _rl = (id)cfRunLoop;
        _dperf = nil;
        _perft = nil;
    }
    return self;
}

- (void)dealloc {
    PF_TODO
    [super dealloc];
}

+ (NSRunLoop *)currentRunLoop {
	NSThread *thread = [NSThread currentThread];
	NSMutableDictionary *dict = [thread threadDictionary];
	NSRunLoop *rl = [dict objectForKey: @"NSRunLoop"];
	if (!rl) {
		rl = [[[NSRunLoop alloc] init] autorelease];
		[dict setObject: rl forKey: @"NSRunLoop"];
		if( thread == [NSThread mainThread] ) _pfMainRunLoop = rl;
	}
	return rl;
}

+ (NSRunLoop *)mainRunLoop {
	if (!_pfMainRunLoop) {
		_pfMainRunLoop = [[[NSRunLoop alloc] initWithCFRunLoop:CFRunLoopGetMain()] autorelease];
		[[[NSThread currentThread] threadDictionary] setObject:_pfMainRunLoop forKey:@"NSRunLoop"];
	}
	return _pfMainRunLoop;
}

- (NSString *)currentMode {
    return [(id)CFRunLoopCopyCurrentMode(RUNLOOP) autorelease];
}

- (CFRunLoopRef)getCFRunLoop {
    return RUNLOOP;
}

- (void)addTimer:(NSTimer *)timer forMode:(NSString *)mode {
	CFRetain((CFTypeRef)timer);
	CFRunLoopAddTimer(RUNLOOP, (CFRunLoopTimerRef)timer, (CFStringRef)mode);
}

- (void)addPort:(NSPort *)aPort forMode:(NSString *)mode {
    PF_TODO
}

- (void)removePort:(NSPort *)aPort forMode:(NSString *)mode {
    PF_TODO
}

- (NSDate *)limitDateForMode:(NSString *)mode {
	CFAbsoluteTime next = CFRunLoopGetNextTimerFireDate(RUNLOOP, (CFStringRef)mode);
    return [(id)CFDateCreate(kCFAllocatorDefault, next) autorelease];
}

- (void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limitDate {
	CFTimeInterval length = CFDateGetAbsoluteTime((CFDateRef)limitDate) - CFAbsoluteTimeGetCurrent();
	CFRunLoopRunInMode((CFStringRef)mode, length, TRUE);
}

@end

@implementation NSRunLoop (NSRunLoopConveniences)

// TODO:
// t -[NSRunLoop(NSRunLoop) performBlock:]
// t -[NSRunLoop(NSRunLoop) performInModes:block:]

- (void)run {
	CFRunLoopRun();
}

- (void)runUntilDate:(NSDate *)limitDate {
	CFTimeInterval length = CFDateGetAbsoluteTime((CFDateRef)limitDate) - CFAbsoluteTimeGetCurrent();
	CFRunLoopRunInMode(kCFRunLoopCommonModes, length, FALSE);
}

- (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate {
	CFTimeInterval length = CFDateGetAbsoluteTime((CFDateRef)limitDate) - CFAbsoluteTimeGetCurrent();
	SInt32 result = CFRunLoopRunInMode((CFStringRef)mode, length, TRUE);
	return (result == kCFRunLoopRunFinished) ? NO : YES;
}

- (void)configureAsServer {}

@end

@implementation NSObject (NSDelayedPerforming)

// TODO:
//- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes;
//- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;
//+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument;
//+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget;

@end

@implementation NSRunLoop (NSOrderedPerform)

// TODO:
//- (void)performSelector:(SEL)aSelector target:(id)target argument:(id)arg order:(NSUInteger)order modes:(NSArray *)modes;
//- (void)cancelPerformSelector:(SEL)aSelector target:(id)target argument:(id)arg;
//- (void)cancelPerformSelectorsWithTarget:(id)target;

@end

#undef RUNLOOP
