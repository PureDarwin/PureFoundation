/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSTimer.m
 *
 *	NSTimer, NSCFTimer
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSTimer.h"

#define SELF ((CFRunLoopTimerRef)self)

@interface __NSCFTimer : NSTimer
@end


@implementation NSTimer

#pragma mark - factory methods

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)repeats {
	PF_TODO
    return nil;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)repeats {
	PF_TODO
    return nil;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats
{
    PF_TODO
    return nil;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats
{
	PF_TODO
    return nil;
}

#pragma mark - init

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)repeats
{
    PF_TODO
    free(self);
    return nil;
}

#pragma mark - instance methods

- (void)fire { }
- (NSDate *)fireDate { return nil; }
- (void)setFireDate:(NSDate *)date { }
- (NSTimeInterval)timeInterval { return 0; }
- (void)invalidate { }
- (BOOL)isValid { return NO; }
- (id)userInfo { return nil; }

@end


@implementation __NSCFTimer

-(CFTypeID)_cfTypeID {
	return CFRunLoopTimerGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (void)fire {
    PF_TODO
}

- (NSDate *)fireDate {
    CFAbsoluteTime time = CFRunLoopTimerGetNextFireDate(SELF);
    return [(id)CFDateCreate(kCFAllocatorDefault, time) autorelease];
}

- (void)setFireDate:(NSDate *)date {
	CFRunLoopTimerSetNextFireDate(SELF, CFDateGetAbsoluteTime((CFDateRef)date));
}

- (NSTimeInterval)timeInterval {
	return CFRunLoopTimerGetInterval(SELF);
}

- (void)invalidate {
	CFRunLoopTimerInvalidate(SELF);
}

- (BOOL)isValid {
	return CFRunLoopTimerIsValid(SELF);
}

- (id)userInfo {
    CFRunLoopTimerContext context = { 0, NULL, NULL, NULL, NULL };
	CFRunLoopTimerGetContext(SELF, &context);
    return context.info;
}

@end

#undef SELF

