/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFDateComponents.m
 *
 *	PFDateComponent
 *
 *	Created by Stuart Crook on 10/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "PFDateComponents.h"

/*
 *	I hope everyone appreciates the thousands of hours of work which has gone into
 *	Objective-C and the ultimate creation of this class
 */
@implementation PFDateComponents

- (id)init
{
	if( self = [super init])
	{	// take a deep breath
		_era = NSUndefinedDateComponent;
		_year = NSUndefinedDateComponent;
		_month = NSUndefinedDateComponent;
		_day = NSUndefinedDateComponent;
		_hour = NSUndefinedDateComponent;
		_minute = NSUndefinedDateComponent;
		_second = NSUndefinedDateComponent;
		_week = NSUndefinedDateComponent;
		_weekday = NSUndefinedDateComponent;
		_weekdayOrdinal = NSUndefinedDateComponent;
			
		_calendar = nil;
	}
	PF_RETURN_NEW(self)
}

// these are our own additions to make working with CFCalendar functions easier

// these are undocumented, but may be expected
- (id)calendar { return _calendar; }
- (void)setCalendar: (NSCalendar *)calendar;
{
	if( _calendar != nil ) 
		[_calendar autorelease];
	_calendar = [calendar retain];
}

- (NSInteger)era { return _era; }
- (NSInteger)year { return _year; }
- (NSInteger)month { return _month; }
- (NSInteger)day { return _day; }
- (NSInteger)hour { return _hour; }
- (NSInteger)minute { return _minute; }
- (NSInteger)second { return _second; }
- (NSInteger)week { return _week; }
- (NSInteger)weekday { return _weekday; }
- (NSInteger)weekdayOrdinal { return _weekdayOrdinal; }

- (void)setEra:(NSInteger)v { _era = v; }
- (void)setYear:(NSInteger)v { _year = v; }
- (void)setMonth:(NSInteger)v { _month = v; }
- (void)setDay:(NSInteger)v { _day = v; }
- (void)setHour:(NSInteger)v { _hour = v; }
- (void)setMinute:(NSInteger)v { _minute = v; }
- (void)setSecond:(NSInteger)v { _second = v; }
- (void)setWeek:(NSInteger)v { _week = v; }
- (void)setWeekday:(NSInteger)v { _weekday = v; }
- (void)setWeekdayOrdinal:(NSInteger)v { _weekdayOrdinal = v; }

@end


@implementation PFDateComponents (PFDateComponentsPrivate)

/*
 *	Create a PFDateComponents object with the vaues returned from one of the
 *	CFCalendar... functions, according to which flags have been set
 */
- (id)_initWithForFlags:(NSUInteger)flags 
		 withComponents:(const char *)comps 
				 values:(NSUInteger *)vals 
				  count:(NSUInteger)count
{
	if( (self = [self init]) && (count != 0) ) // set everything to default empty values
	{
		for( int i = 0; i < count; i++ )
		{
			switch (comps[i]) 
			{
				case 'y': // NSYearCalendarUnit
					if(flags & NSYearCalendarUnit) _year = vals[i];
					break;
				case 'M': // NSMonthCalendarUnit
					if(flags & NSMonthCalendarUnit) _month = vals[i];
					break;
				case 'd': // NSDayCalendarUnit
					if(flags & NSDayCalendarUnit) _day = vals[i];
					break;
				case 'H': // NSHourCalendarUnit
					if(flags & NSHourCalendarUnit) _hour = vals[i];
					break;
				case 'm': // NSMinuteCalendarUnit
					if(flags & NSHourCalendarUnit) _minute = vals[i];
					break;
				case 's': // NSSecondCalendarUnit
					if(flags & NSSecondCalendarUnit) _second = vals[i];
					break;
				/*
				 *	these don't appear to be mentioned in the CF docs
				 */
				case 'G': // NSEraCalendarUnit
					if(flags & NSEraCalendarUnit) _era = vals[i];
					break;
				case 'w': // NSWeekCalendarUnit
					if(flags & NSWeekCalendarUnit) _week = vals[i];
					break;
				case 'E': // NSWeekdayCalendarUnit
					if(flags & NSWeekdayCalendarUnit) _weekday = vals[i];
					break;
				case 'F': // NSWeekdayOrdinalCalendarUnit
					if(flags & NSWeekdayOrdinalCalendarUnit) _weekdayOrdinal = vals[i];
					break;
				default:
					break;
			}
		}
	}
	PF_RETURN_NEW(self)
}

/*
 *	Produce the two data structures (and count) needed by the CFCalendar functions, passing
 *	in all of the set calendar components
 */
- (NSUInteger)_getComponents:(char *)comps values:(NSUInteger *)vals
{
	NSUInteger count = 0;
	
	if( _year != NSUndefinedDateComponent )
		{ *comps++ = 'y'; *vals++ = _year; count++; }
	if( _month != NSUndefinedDateComponent )
		{ *comps++ = 'M'; *vals++ = _month; count++; }
	if( _day != NSUndefinedDateComponent )
		{ *comps++ = 'd'; *vals++ = _day; count++; }
	if( _hour != NSUndefinedDateComponent )
		{ *comps++ = 'H'; *vals++ = _hour; count++; }
	if( _minute != NSUndefinedDateComponent )
		{ *comps++ = 'm'; *vals++ = _minute; count++; }
	if( _second != NSUndefinedDateComponent )
		{ *comps++ = 's'; *vals++ = _second; count++; }
	if( _era != NSUndefinedDateComponent )
		{ *comps++ = 'G'; *vals++ = _era; count++; }
	if( _week != NSUndefinedDateComponent )
		{ *comps++ = 'w'; *vals++ = _week; count++; }
	if( _weekday != NSUndefinedDateComponent )
		{ *comps++ = 'E'; *vals++ = _weekday; count++; }
	if( _weekdayOrdinal != NSUndefinedDateComponent )
		{ *comps++ = 'F'; *vals++ = _weekdayOrdinal; count++; }
	   
	*comps = '\0';
	return count;
}

@end

