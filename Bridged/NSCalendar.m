/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSCalendar.m
 *
 *	NSCalendar, NSCFCalendar, NSDateComponents
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSCalendar.h"
#import "PFDateComponents.h"

/*
 *	Declare the bridged class
 */
@interface __NSCFCalendar : NSCalendar
@end


/*
 *	The dummy instance
 */
static Class _PFNSCFCalendarClass = nil;


/*
 *	Private CF functions for working with calendars and date components, which
 *	are exposed by default from unpatched CFLite and declared in CFCalendar.c
 */
extern Boolean _CFCalendarComposeAbsoluteTimeV(CFCalendarRef calendar, /* out */ CFAbsoluteTime *atp, const char *componentDesc, int *vector, int count);
extern Boolean _CFCalendarDecomposeAbsoluteTimeV(CFCalendarRef calendar, CFAbsoluteTime at, const char *componentDesc, int **vector, int count);
extern Boolean _CFCalendarAddComponentsV(CFCalendarRef calendar, /* inout */ CFAbsoluteTime *atp, CFOptionFlags options, const char *componentDesc, int *vector, int count);
extern Boolean _CFCalendarGetComponentDifferenceV(CFCalendarRef calendar, CFAbsoluteTime startingAT, CFAbsoluteTime resultAT, CFOptionFlags options, const char *componentDesc, int **vector, int count);

/*
 *	Produce a string representing the components in flags
 */
NSUInteger _PFGetDateComponents( char *comps, NSUInteger flags )
{
	NSUInteger count = 0;
	
	if(flags & NSYearCalendarUnit) { *comps++ = 'y'; count++; }
	if(flags & NSMonthCalendarUnit) { *comps++ = 'M'; count++; }
	if(flags & NSDayCalendarUnit) { *comps++ = 'd'; count++; }
	if(flags & NSHourCalendarUnit) { *comps++ = 'H'; count++; }
	if(flags & NSHourCalendarUnit) { *comps++ = 'm'; count++; }
	if(flags & NSSecondCalendarUnit) { *comps++ = 's'; count++; }
	if(flags & NSEraCalendarUnit) { *comps++ = 'G'; count++; }
	if(flags & NSWeekCalendarUnit) { *comps++ = 'w'; count++; }
	if(flags & NSWeekdayCalendarUnit) { *comps++ = 'E'; count++; }
	if(flags & NSWeekdayOrdinalCalendarUnit) { *comps++ = 'F'; count++; }
	
	*comps = '\0';
	return count;
}


/*
 *	NSCalendar
 */
@implementation NSCalendar

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSCalendar class] )
		_PFNSCFCalendarClass = objc_getClass("NSCFCalendar");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSCalendar class] )
		return (id)&_PFNSCFCalendarClass;
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
 *	Class creation methods
 */
+ (id)currentCalendar
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFCalendarCopyCurrent() )
}

/*
 *	Ah. Another one of these auto-updating wossnames. So...
 */
+ (id)autoupdatingCurrentCalendar
{
	PF_HELLO("")
	
}

// compiler-friendly init method
- (id)initWithCalendarIdentifier:(NSString *)ident { return nil; }

/*
 *	instance methods to please the compiler
 */
- (NSString *)calendarIdentifier { return nil; }
- (void)setLocale:(NSLocale *)locale {}
- (NSLocale *)locale { return nil; }
- (void)setTimeZone:(NSTimeZone *)tz {}
- (NSTimeZone *)timeZone  { return nil; }
- (void)setFirstWeekday:(NSUInteger)weekday {}
- (NSUInteger)firstWeekday { return 1; }
- (void)setMinimumDaysInFirstWeek:(NSUInteger)mdw {}
- (NSUInteger)minimumDaysInFirstWeek { return 1; }
- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit { return NSMakeRange(0,0); }
- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit { return NSMakeRange(0,0); }
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date { return NSMakeRange(0,0); }
- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date  { return 0; }

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date { return NO; }
- (NSDate *)dateFromComponents:(NSDateComponents *)comps { return nil; }
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date { return nil; }
- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSUInteger)opts  { return nil; }
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSUInteger)opts  { return nil; }

@end




/*
 *	The NSCFCalendar bridged class
 */
@implementation __NSCFCalendar

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFCalendarGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

// do we override isEqual: ???

// removed because a calendar describes itself as <class: address>
//-(NSString *)description
//{
//	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
//}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	PF_HELLO("")
	CFStringRef identifier = CFCalendarGetIdentifier((CFCalendarRef)self);
	CFCalendarRef new = CFCalendarCreateWithIdentifier( kCFAllocatorDefault, identifier );
	PF_RETURN_NEW(new)
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
	return nil;
}

/*
 *	creation method
 */
// TODO: move this into NSCalendar
- (id)initWithCalendarIdentifier:(NSString *)ident 
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFCalendarClass ) [self autorelease];
	
	self = (id)CFCalendarCreateWithIdentifier( kCFAllocatorDefault, (CFStringRef)ident );
	PF_RETURN_NEW(self)
}

-(id)init
{
	PF_HELLO("is this correct?")
	return nil;
}

- (NSString *)calendarIdentifier 
{ 
	PF_HELLO("")
	PF_RETURN_NEW( CFCalendarGetIdentifier( (CFCalendarRef)self ) )
}

- (void)setLocale:(NSLocale *)locale 
{
	PF_HELLO("")
	CFCalendarSetLocale( (CFCalendarRef)self, (CFLocaleRef)locale );
}

- (NSLocale *)locale 
{ 
	PF_HELLO("")
	PF_RETURN_TEMP( CFCalendarCopyLocale( (CFCalendarRef)self ) )
}

- (void)setTimeZone:(NSTimeZone *)tz 
{
	PF_HELLO("")
	CFCalendarSetTimeZone( (CFCalendarRef)self, (CFTimeZoneRef)tz );
}

- (NSTimeZone *)timeZone  
{ 
	PF_HELLO("")
	PF_RETURN_TEMP( CFCalendarCopyTimeZone( (CFCalendarRef)self ) )
}

- (void)setFirstWeekday:(NSUInteger)weekday 
{
	PF_HELLO("")
	CFCalendarSetFirstWeekday( (CFCalendarRef)self, weekday );
}

- (NSUInteger)firstWeekday 
{
	PF_HELLO("")
	return CFCalendarGetFirstWeekday( (CFCalendarRef)self );
}

- (void)setMinimumDaysInFirstWeek:(NSUInteger)mdw 
{
	PF_HELLO("")
	CFCalendarSetMinimumDaysInFirstWeek( (CFCalendarRef)self, mdw );
}

- (NSUInteger)minimumDaysInFirstWeek 
{
	PF_HELLO("")
	return CFCalendarGetMinimumDaysInFirstWeek( (CFCalendarRef)self ); 
}

- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit 
{
	PF_HELLO("")
	CFRange range = CFCalendarGetMinimumRangeOfUnit( (CFCalendarRef)self, unit );
	return NSMakeRange( range.location, range.length );
}

- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit 
{
	PF_HELLO("")
	CFRange range = CFCalendarGetMaximumRangeOfUnit( (CFCalendarRef)self, unit );
	return NSMakeRange( range.location, range.length );
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date 
{ 
	PF_HELLO("")
	CFRange range = CFCalendarGetRangeOfUnit( (CFCalendarRef)self, smaller, larger, CFDateGetAbsoluteTime((CFDateRef)date) );
	return NSMakeRange( range.location, range.length );
}

- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date  
{
	PF_HELLO("")
	return CFCalendarGetOrdinalityOfUnit( (CFCalendarRef)self, smaller, larger, CFDateGetAbsoluteTime((CFDateRef)date) ); 
}

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit 
		  startDate:(NSDate **)datep 
		   interval:(NSTimeInterval *)tip 
			forDate:(NSDate *)date 
{ 
	PF_HELLO("")
	
	CFAbsoluteTime time;
	BOOL result;
	if( YES == (result = CFCalendarGetTimeRangeOfUnit( (CFCalendarRef)self, unit, [date timeIntervalSinceReferenceDate], &time, tip )) ) 
		{ *datep = (NSDate *)CFDateCreate( kCFAllocatorDefault, time ); }
	return result;
}

/*
 *	These call into un-advertised CFCalendar function exposed in an _unpatched_ CFLite
 */
- (NSDate *)dateFromComponents:(NSDateComponents *)comps 
{ 
	CFAbsoluteTime time;
	char components[11];
	NSUInteger values[10];
	NSUInteger count = [(PFDateComponents *)comps _getComponents: components values: values];
	
	if( count != 0 )
		if( YES == _CFCalendarComposeAbsoluteTimeV((CFCalendarRef)self, &time, components, (int *)values, count))
			PF_RETURN_TEMP(CFDateCreate( kCFAllocatorDefault, time ))

	return nil; 
}

- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps 
							toDate:(NSDate *)date 
						   options:(NSUInteger)opts  
{ 
	CFAbsoluteTime time = [date timeIntervalSinceReferenceDate];
	char components[11];
	NSUInteger values[10];
	NSUInteger count = [(PFDateComponents *)comps _getComponents: components values: values];
	
	if( count != 0 )
		if( YES == _CFCalendarAddComponentsV( (CFCalendarRef)self, &time, opts, components, (int *)values, count))
			PF_RETURN_TEMP(CFDateCreate( kCFAllocatorDefault, time ))
			
	return nil;
}

- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date 
{
	CFAbsoluteTime time = [date timeIntervalSinceReferenceDate];

	char components[11];
	NSUInteger values[10];
	// could I just point out that, as data structures go, this is really rather retarded
	NSUInteger *vector[10] = { &values[0], &values[1], &values[2], &values[3], &values[4], &values[5], &values[6], &values[7], &values[8], &values[9] };

	NSUInteger count = _PFGetDateComponents( components, unitFlags );
	
	if( count != 0 )
		if( NO == _CFCalendarDecomposeAbsoluteTimeV( (CFCalendarRef)self, time, components, (int **)vector, count) )
			return nil;
	
	return [[[PFDateComponents alloc] _initWithForFlags: unitFlags withComponents: components values: values count: count] autorelease];
}


- (NSDateComponents *)components:(NSUInteger)unitFlags 
						fromDate:(NSDate *)startingDate 
						  toDate:(NSDate *)resultDate 
						 options:(NSUInteger)opts  
{
	CFAbsoluteTime start = [startingDate timeIntervalSinceReferenceDate];
	CFAbsoluteTime end = [resultDate timeIntervalSinceReferenceDate];
	
	char components[11];
	NSUInteger values[10];
	// it's been about an hour since my comment above and this is still retarded
	NSUInteger *vector[10] = { &values[0], &values[1], &values[2], &values[3], &values[4], &values[5], &values[6], &values[7], &values[8], &values[9] };

	NSUInteger count = _PFGetDateComponents( components, unitFlags );
	
	if( count != 0 )
		if( NO == _CFCalendarGetComponentDifferenceV( (CFCalendarRef)self, start, end, opts, components, (int **)vector, count) ) 
			return nil;
	
	return [[[PFDateComponents alloc] _initWithForFlags: unitFlags withComponents: components values: values count: count] autorelease];
}

@end



/*
 *	NSDateComponents
 */
@implementation NSDateComponents

/*
 *	This class should never be instantiated
 */
+ (id)alloc
{
	if( self == [NSDateComponents class] )
		return [PFDateComponents alloc];
	return [super alloc];
}

- (NSInteger)era { return NSUndefinedDateComponent; }
- (NSInteger)year { return NSUndefinedDateComponent; }
- (NSInteger)month { return NSUndefinedDateComponent; }
- (NSInteger)day { return NSUndefinedDateComponent; }
- (NSInteger)hour { return NSUndefinedDateComponent; }
- (NSInteger)minute { return NSUndefinedDateComponent; }
- (NSInteger)second { return NSUndefinedDateComponent; }
- (NSInteger)week { return NSUndefinedDateComponent; }
- (NSInteger)weekday { return NSUndefinedDateComponent; }
- (NSInteger)weekdayOrdinal { return NSUndefinedDateComponent; }

- (void)setEra:(NSInteger)v {}
- (void)setYear:(NSInteger)v {}
- (void)setMonth:(NSInteger)v {}
- (void)setDay:(NSInteger)v {}
- (void)setHour:(NSInteger)v {}
- (void)setMinute:(NSInteger)v {}
- (void)setSecond:(NSInteger)v {}
- (void)setWeek:(NSInteger)v {}
- (void)setWeekday:(NSInteger)v {}
- (void)setWeekdayOrdinal:(NSInteger)v {}

// NSCopying
- (id)copyWithZone:(NSZone *)zone { return nil; }

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end
