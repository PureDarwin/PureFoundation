/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSDateFormatter.m
 *
 *	NSDateFormatter
 *
 *  Created by Stuart Crook on 14/03/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/*
 *	Like NSNumberFormatter, locale, dateStyle and timeStyle can be set after the object
 *	is instantiated, but are fixed when the CFDF is created, so the question is when do
 *	we create the wrapped CF type?
 */

/*
 *	ivars:	NSMutableDictionary *_attributes;
 *			__strong CFDateFormatterRef _formatter;
 *			NSUInteger _counter;
 */
@implementation NSDateFormatter //: NSObject <NSCopying, NSCoding>

- (id)init
{
	if( self = [super init] )
	{
		_attributes = nil;
		_formatter = nil;
		_counter = 0;
	}
	return self;
}

- (NSString *)stringForObjectValue:(id)obj { return nil; }

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs { return nil; }

- (NSString *)editingStringForObjectValue:(id)obj { return nil; }

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error { return NO; }

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error { return NO; }
// Compatibility method.  If a subclass overrides this and does not override the new method below, this will be called as before (the new method just calls this one by default).  The selection range will always be set to the end of the text with this method if replacement occurs.

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error { return NO; }

- (id)copyWithZone:(NSZone *)zone { return self; }


// Report the used range of the string and an NSError, in addition to the usual stuff from NSFormatter

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string range:(inout NSRange *)rangep error:(NSError **)error { }

// Even though NSDateFormatter responds to the usual NSFormatter methods,
//   here are some convenience methods which are a little more obvious.

- (NSString *)stringFromDate:(NSDate *)date {}
- (NSDate *)dateFromString:(NSString *)string {}


// Attributes of an NSDateFormatter

- (NSString *)dateFormat {}

- (NSDateFormatterStyle)dateStyle {}
- (void)setDateStyle:(NSDateFormatterStyle)style {}

- (NSDateFormatterStyle)timeStyle {}
- (void)setTimeStyle:(NSDateFormatterStyle)style {}

- (NSLocale *)locale {}
- (void)setLocale:(NSLocale *)locale {}

- (BOOL)generatesCalendarDates {}
- (void)setGeneratesCalendarDates:(BOOL)b {}

- (NSDateFormatterBehavior)formatterBehavior {}
- (void)setFormatterBehavior:(NSDateFormatterBehavior)behavior {}

+ (NSDateFormatterBehavior)defaultFormatterBehavior {}
+ (void)setDefaultFormatterBehavior:(NSDateFormatterBehavior)behavior {}

- (void)setDateFormat:(NSString *)string {}

- (NSTimeZone *)timeZone {}
- (void)setTimeZone:(NSTimeZone *)tz {}

- (NSCalendar *)calendar {}
- (void)setCalendar:(NSCalendar *)calendar {}

- (BOOL)isLenient {}
- (void)setLenient:(BOOL)b {}

- (NSDate *)twoDigitStartDate {}
- (void)setTwoDigitStartDate:(NSDate *)date {}

- (NSDate *)defaultDate {}
- (void)setDefaultDate:(NSDate *)date {}

- (NSArray *)eraSymbols {}
- (void)setEraSymbols:(NSArray *)array {}

- (NSArray *)monthSymbols {}
- (void)setMonthSymbols:(NSArray *)array {}

- (NSArray *)shortMonthSymbols {}
- (void)setShortMonthSymbols:(NSArray *)array {}

- (NSArray *)weekdaySymbols {}
- (void)setWeekdaySymbols:(NSArray *)array {}

- (NSArray *)shortWeekdaySymbols {}
- (void)setShortWeekdaySymbols:(NSArray *)array {}

- (NSString *)AMSymbol {}
- (void)setAMSymbol:(NSString *)string {}

- (NSString *)PMSymbol {}
- (void)setPMSymbol:(NSString *)string {}

// AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
- (NSArray *)longEraSymbols {}
- (void)setLongEraSymbols:(NSArray *)array {}

- (NSArray *)veryShortMonthSymbols {}
- (void)setVeryShortMonthSymbols:(NSArray *)array {}

- (NSArray *)standaloneMonthSymbols {}
- (void)setStandaloneMonthSymbols:(NSArray *)array {}

- (NSArray *)shortStandaloneMonthSymbols {}
- (void)setShortStandaloneMonthSymbols:(NSArray *)array {}

- (NSArray *)veryShortStandaloneMonthSymbols {}
- (void)setVeryShortStandaloneMonthSymbols:(NSArray *)array {}

- (NSArray *)veryShortWeekdaySymbols {}
- (void)setVeryShortWeekdaySymbols:(NSArray *)array {}

- (NSArray *)standaloneWeekdaySymbols {}
- (void)setStandaloneWeekdaySymbols:(NSArray *)array {}

- (NSArray *)shortStandaloneWeekdaySymbols {}
- (void)setShortStandaloneWeekdaySymbols:(NSArray *)array {}

- (NSArray *)veryShortStandaloneWeekdaySymbols {}
- (void)setVeryShortStandaloneWeekdaySymbols:(NSArray *)array {}

- (NSArray *)quarterSymbols {}
- (void)setQuarterSymbols:(NSArray *)array {}

- (NSArray *)shortQuarterSymbols {}
- (void)setShortQuarterSymbols:(NSArray *)array {}

- (NSArray *)standaloneQuarterSymbols {}
- (void)setStandaloneQuarterSymbols:(NSArray *)array {}

- (NSArray *)shortStandaloneQuarterSymbols {}
- (void)setShortStandaloneQuarterSymbols:(NSArray *)array {}

- (NSDate *)gregorianStartDate {}
- (void)setGregorianStartDate:(NSDate *)date {}

@end

@implementation NSDateFormatter (NSDateFormatterCompatibility)

- (id)initWithDateFormat:(NSString *)format allowNaturalLanguage:(BOOL)flag {}
- (BOOL)allowsNaturalLanguage {}

@end

