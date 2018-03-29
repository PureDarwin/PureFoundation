/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFDateComponents.h
 *
 *	PFDateComponent
 *
 *	Created by Stuart Crook on 10/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSCalendar.h"

/*
 *	This class is really a glorified structure. It was created so we don't have
 *	to alter the declaration of NSDateComponents.
 *
 *	It may be possible to achieve the same results -- although a little slower 
 *	over-all -- using some kind of class-wide storage in the NSDateComponent class
 */
@interface PFDateComponents : NSDateComponents 
{
	NSInteger	_era;
	NSInteger	_year;
	NSInteger	_month;
	NSInteger	_day;
	NSInteger	_hour;
	NSInteger	_minute;
	NSInteger	_second;
	NSInteger	_week;
	NSInteger	_weekday;
	NSInteger	_weekdayOrdinal;

	// for our extra wossname
	id	_calendar;
}

// found this with "nm Foundation.framework/Foundation"
- (id)calendar;
- (void)setCalendar:(NSCalendar *)calendar;

@end

/*
 *	Shhh... Don't tell anyone about these, because if they expect to find them 
 *	in Cocoa they're going to be disappointed
 */
@interface PFDateComponents (PFDateComponentsPrivate)
- (id)_initWithForFlags:(NSUInteger)flags withComponents:(char *)comps values:(NSUInteger *)vals count:(NSUInteger)count;
- (NSUInteger)_getComponents:(const char *)comps values:(NSUInteger *)vals;
@end
