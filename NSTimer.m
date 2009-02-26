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

/*
 *	Declare the bridged class
 */
@interface NSCFTimer : NSTimer
@end

/*
 *	The dummy instance for init calls
 */
static Class _PFNSCFTimerClass = nil;


/*
 *	The NSTimer front-end class
 */
@implementation NSTimer

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSTimer class] )
		_PFNSCFTimerClass = objc_getClass("NSCFTimer");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSTimer class] )
		return (id)&_PFNSCFTimerClass;
	return [super alloc];
}

/*
 *	Class creation methods
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti 
						invocation:(NSInvocation *)invocation 
						   repeats:(BOOL)yesOrNo
{
	
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti 
								 invocation:(NSInvocation *)invocation 
									repeats:(BOOL)yesOrNo
{
	
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti 
							target:(id)aTarget 
						  selector:(SEL)aSelector 
						  userInfo:(id)userInfo 
						   repeats:(BOOL)yesOrNo
{
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti 
									 target:(id)aTarget 
								   selector:(SEL)aSelector 
								   userInfo:(id)userInfo 
									repeats:(BOOL)yesOrNo
{
	
}

/*
 *	instance methods to keep the compiler happy
 */
- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep { return nil; }
- (void)fire { }
- (NSDate *)fireDate { return nil; }
- (void)setFireDate:(NSDate *)date { }
- (NSTimeInterval)timeInterval { return 0; }
- (void)invalidate { }
- (BOOL)isValid { return NO; }
- (id)userInfo { return nil; }

@end



/*
 *	NSCFTimer bridged class
 */
@implementation NSCFTimer

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFRunLoopTimerGetTypeID();
}

-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}

- (id)initWithFireDate:(NSDate *)date 
			  interval:(NSTimeInterval)ti 
				target:(id)t 
			  selector:(SEL)s 
			  userInfo:(id)ui 
			   repeats:(BOOL)rep
{
	
}

- (void)fire
{
}

- (NSDate *)fireDate
{
}

- (void)setFireDate:(NSDate *)date
{
	PF_HELLO("")
	CFRunLoopTimerSetNextFireDate( (CFRunLoopTimerRef)self, CFDateGetAbsoluteTime((CFDateRef)date) );
}

- (NSTimeInterval)timeInterval
{
	PF_HELLO("")
	return CFRunLoopTimerGetInterval( (CFRunLoopTimerRef)self );
}

- (void)invalidate
{
	PF_HELLO("")
	CFRunLoopTimerInvalidate( (CFRunLoopTimerRef)self );
}

- (BOOL)isValid
{
	PF_HELLO("")
	return CFRunLoopTimerIsValid( (CFRunLoopTimerRef)self );
}

- (id)userInfo
{
	PF_HELLO("")
	CFRunLoopTimerContext context;
	context.version = 0; // aparently we should do this
	CFRunLoopTimerGetContext( (CFRunLoopTimerRef)self, &context );
	PF_RETURN_TEMP( context.info )
}

@end
