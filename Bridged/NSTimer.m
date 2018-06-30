/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSTimer.m
 *
 *	Created by Stuart Crook on 02/02/2009.
 */

#import "NSTimer.h"

// NSTimer is declared in CoreFoundation
// TODO: Implement the factory creation methods prototyped here

@implementation NSTimer (NSTimer)

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
