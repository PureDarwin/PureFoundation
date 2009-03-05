/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSDate.m
 *
 *	NSDate, NSCFDate
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSDate.h"

/*
 *	Declare the bridged class
 */
@interface NSCFDate : NSDate
@end

/*
 *	The dummy instance for alloc-init creation
 */
static Class _PFNSCFDateClass = nil;
static CFDateRef _PFReferenceDate = nil;

//#define PFTimeIntervalTo1970 -NSTimeIntervalSince1970


/*
 *	The NSDate class cluster frontend
 */
@implementation NSDate

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSDate class] )
	{
		_PFNSCFDateClass = objc_getClass("NSCFDate");
		_PFReferenceDate = CFDateCreate( kCFAllocatorDefault, 0 );
	}
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSDate class] )
		return (id)&_PFNSCFDateClass;
	return [super alloc];
}

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

/*
 *	NSDateCreation class methods.
 */
+ (id)date
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease];
	PF_RETURN_NEW( CFDateCreate( kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() ) )
}

+ (id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secs
{
	PF_HELLO("")
	//return [[[self alloc] initWithTimeIntervalSinceReferenceDate: secs] autorelease];
	PF_RETURN_NEW( CFDateCreate( kCFAllocatorDefault, secs ) )

}


+ (id)dateWithTimeIntervalSinceNow:(NSTimeInterval)secs
{
	PF_HELLO("")
	//return [[[self alloc] initWithTimeIntervalSinceNow: secs] autorelease];
	PF_RETURN_NEW( CFDateCreate( kCFAllocatorDefault, secs + CFAbsoluteTimeGetCurrent() ) )
}

+ (id)dateWithTimeIntervalSince1970:(NSTimeInterval)secs
{
	PF_HELLO("")
	//return [[[self alloc] initWithTimeIntervalSinceReferenceDate: (secs - NSTimeIntervalSince1970)] autorelease];
	PF_RETURN_NEW( CFDateCreate( kCFAllocatorDefault, (secs - NSTimeIntervalSince1970) ) )	
}

/*
 *	These values were deduced from proper Foundation
 */
+ (id)distantFuture
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFDateCreate( kCFAllocatorDefault, 63113904000.000000 ) )
}

+ (id)distantPast
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFDateCreate( kCFAllocatorDefault, -63114076800.000000 ) )
}



/*
 *	NSDateExtended class method
 */
+ (NSTimeInterval)timeIntervalSinceReferenceDate
{
	PF_HELLO("")										// are these the right way around?
	//return (NSTimeInterval)CFDateGetTimeIntervalSinceDate( (CFDateRef)[self date], _PFReferenceDate );
	return CFAbsoluteTimeGetCurrent();
}



/*
 *	NSDate instance method
 */
- (NSTimeInterval)timeIntervalSinceReferenceDate
{
	return 0.0;
}

@end


/*
 *	These additions were defined in NSCalendarDate.h but should be implemented here.
 */
@implementation NSDate (NSCalendarDateExtras)

+ (id)dateWithString:(NSString *)aString { return nil; }

- (id)initWithString:(NSString *)description { return nil; }

- (NSCalendarDate *)dateWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone { return nil; }

- (NSString *)descriptionWithLocale:(id)locale { return nil; }

- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale { return nil; }

@end

@implementation NSDate (NSNaturalLangage)

+ dateWithNaturalLanguageString:(NSString *)string
{
	PF_TODO
}

+ dateWithNaturalLanguageString:(NSString *)string locale:(id)locale
{
	PF_TODO
}

@end



/*
 *	NSCFDate, the bridged class
 */
@implementation NSCFDate

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFDateGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

/*
 *	"A string representation of the receiver in the international format 
 *	YYYY-MM-DD HH:MM:SS ±HHMM, where ±HHMM represents the time zone offset 
 *	in hours and minutes from GMT (for example, “2001-03-24 10:45:32 +0600”)."
 *
 *	This will probably have to wait until NSDateFormatter is made.
 */
-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}

/*
 *	These next two methods come to us via NSCalendarDate
 */
- (NSString *)descriptionWithLocale:(id)locale 
{ 
	PF_TODO
	return nil; 
}

- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale 
{
	PF_TODO
	return nil; 
}


// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	PF_RETURN_NEW( CFDateCreate( kCFAllocatorDefault, CFDateGetAbsoluteTime((CFDateRef)self) ) )
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

/*
 *	NSDateCreation creation methods
 */
- (id)init
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFDateClass ) [self autorelease];
	
	self = (id)CFDateCreate( kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() );
	PF_RETURN_NEW(self)
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secsToBeAdded
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFDateClass ) [self autorelease];

	self = (id)CFDateCreate( kCFAllocatorDefault, secsToBeAdded );
	PF_RETURN_NEW(self)

}

- (id)initWithTimeIntervalSinceNow:(NSTimeInterval)secsToBeAddedToNow
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFDateClass ) [self autorelease];

	self = (id)CFDateCreate( kCFAllocatorDefault, secsToBeAddedToNow + CFAbsoluteTimeGetCurrent() );
	PF_RETURN_NEW(self)
}

- (id)initWithTimeInterval:(NSTimeInterval)secsToBeAdded sinceDate:(NSDate *)anotherDate
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFDateClass ) [self autorelease];
	
	self = (id)CFDateCreate( kCFAllocatorDefault, CFDateGetAbsoluteTime((CFDateRef)anotherDate) + secsToBeAdded );
	PF_RETURN_NEW(self)
}



/*
 *	NSDate instance method
 */
- (NSTimeInterval)timeIntervalSinceReferenceDate
{
	PF_HELLO("")						// the right wat around?
	//return CFDateGetTimeIntervalSinceDate( (CFDateRef)self, _PFReferenceDate );
	return CFDateGetAbsoluteTime((CFDateRef)self);
}


/*
 *	NSExtendedDate instance methods
 */
- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)anotherDate
{
	PF_HELLO("")
	return CFDateGetTimeIntervalSinceDate( (CFDateRef)self, (CFDateRef)anotherDate );
}

- (NSTimeInterval)timeIntervalSinceNow
{
	PF_HELLO("")
	return ( CFDateGetAbsoluteTime((CFDateRef)self) - CFAbsoluteTimeGetCurrent() );
}

- (NSTimeInterval)timeIntervalSince1970
{
	PF_HELLO("")
	return ( CFDateGetAbsoluteTime((CFDateRef)self) + NSTimeIntervalSince1970 );
}


- (id)addTimeInterval:(NSTimeInterval)seconds
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFDateCreate( kCFAllocatorDefault, (CFDateGetAbsoluteTime((CFDateRef)self) + seconds) ) )
}


- (NSDate *)earlierDate:(NSDate *)anotherDate
{
	PF_HELLO("")
	if( CFDateCompare( (CFDateRef)self, (CFDateRef)anotherDate, NULL ) == kCFCompareGreaterThan )
		return anotherDate;
	else
		return self;
}

- (NSDate *)laterDate:(NSDate *)anotherDate
{
	PF_HELLO("")
	if( CFDateCompare( (CFDateRef)self, (CFDateRef)anotherDate, NULL ) == kCFCompareLessThan )
		return anotherDate;
	else 
		return self;
}

- (NSComparisonResult)compare:(NSDate *)other
{
	PF_HELLO("")
	return (NSComparisonResult)CFDateCompare( (CFDateRef)self, (CFDateRef)other, NULL );
}



- (BOOL)isEqualToDate:(NSDate *)otherDate
{
	PF_HELLO("")
	if( self == otherDate ) return YES;
	if( otherDate == nil ) return NO;
	return CFEqual( (CFTypeRef)self, (CFTypeRef)otherDate );
}

/*
 *	This is also an NSCalendarDate addition
 */
- (NSCalendarDate *)dateWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone 
{
	PF_TODO
	return nil; 
}

@end


