/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSDate.m
 *
 *	NSDate, NSCFDate
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSDate.h"

#define SELF ((CFDateRef)self)

@interface __NSDate : NSDate
@end

@implementation NSDate

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

#pragma mark - factory methods

+ (id)date {
    return [(id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent()) autorelease];
}

+ (id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, seconds) autorelease];
}

+ (id)dateWithTimeIntervalSinceNow:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + seconds) autorelease];
}

+ (id)dateWithTimeIntervalSince1970:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, (seconds - NSTimeIntervalSince1970)) autorelease];
}

// These values were deduced from proper Foundation
+ (id)distantFuture {
    return [(id)CFDateCreate(kCFAllocatorDefault, 63113904000.000000) autorelease];
}

+ (id)distantPast {
    return [(id)CFDateCreate(kCFAllocatorDefault, -63114076800.000000) autorelease];
}

+ (NSTimeInterval)timeIntervalSinceReferenceDate {
	return CFAbsoluteTimeGetCurrent();
}

+ (id)dateWithString:(NSString *)aString {
    PF_TODO
    return nil;
}

#pragma mark - NSNaturalLangage

+ dateWithNaturalLanguageString:(NSString *)string {
    PF_TODO
    return nil;
}

+ dateWithNaturalLanguageString:(NSString *)string locale:(id)locale {
    PF_TODO
    return nil;
}

#pragma mark - init methods

- (id)init {
    return (id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent());
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secondsToBeAdded {
    return (id)CFDateCreate(kCFAllocatorDefault, secondsToBeAdded);
}

- (id)initWithTimeIntervalSinceNow:(NSTimeInterval)secondsToBeAddedToNow {
    return (id)CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + secondsToBeAddedToNow);
}

- (id)initWithTimeInterval:(NSTimeInterval)secondsToBeAdded sinceDate:(NSDate *)anotherDate {
    return (id)CFDateCreate(kCFAllocatorDefault, CFDateGetAbsoluteTime((CFDateRef)anotherDate) + secondsToBeAdded);
}

#pragma mark - NSCalendarDateExtras

// TODO: Implement this using CFDateFormatter
- (id)initWithString:(NSString *)description {
    PF_TODO
    return nil;
}

#pragma mark - instance method prototypes

- (NSTimeInterval)timeIntervalSinceReferenceDate { return 0.0; }

- (NSCalendarDate *)dateWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone { return nil; }
- (NSString *)descriptionWithLocale:(id)locale { return nil; }
- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale { return nil; }

@end

@implementation __NSDate

- (CFTypeID)_cfTypeID {
	return CFDateGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

/*
 *	"A string representation of the receiver in the international format 
 *	YYYY-MM-DD HH:MM:SS ±HHMM, where ±HHMM represents the time zone offset 
 *	in hours and minutes from GMT (for example, “2001-03-24 10:45:32 +0600”)."
 *
 *	This will probably have to wait until NSDateFormatter is made.
 */
-(NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale {
	PF_TODO
    return [self description];
}

- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale {
	PF_TODO
    return [self description];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFDateCreate(kCFAllocatorDefault, CFDateGetAbsoluteTime(SELF));
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
	return nil;
}

#pragma mark - instance methods

- (NSTimeInterval)timeIntervalSinceReferenceDate {
	return CFDateGetAbsoluteTime(SELF);
}

- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)anotherDate {
	return CFDateGetTimeIntervalSinceDate(SELF, (CFDateRef)anotherDate);
}

- (NSTimeInterval)timeIntervalSinceNow {
	return CFDateGetAbsoluteTime(SELF) - CFAbsoluteTimeGetCurrent();
}

- (NSTimeInterval)timeIntervalSince1970 {
	return CFDateGetAbsoluteTime(SELF) + NSTimeIntervalSince1970;
}

- (id)addTimeInterval:(NSTimeInterval)seconds {
    return [(id)CFDateCreate(kCFAllocatorDefault, (CFDateGetAbsoluteTime(SELF) + seconds)) autorelease];
}

- (NSDate *)earlierDate:(NSDate *)anotherDate {
    return CFDateCompare(SELF, (CFDateRef)anotherDate, NULL) == kCFCompareGreaterThan ? anotherDate : self;
}

- (NSDate *)laterDate:(NSDate *)anotherDate {
    return CFDateCompare(SELF, (CFDateRef)anotherDate, NULL) == kCFCompareLessThan ? anotherDate : self;
}

- (NSComparisonResult)compare:(NSDate *)other {
	return (NSComparisonResult)CFDateCompare(SELF, (CFDateRef)other, NULL);
}

- (BOOL)isEqualToDate:(NSDate *)otherDate {
    if (!otherDate) return NO;
	return (self == otherDate) || CFEqual((CFTypeRef)self, (CFTypeRef)otherDate);
}

#pragma mark - NSCalendarDate

- (NSCalendarDate *)dateWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone {
	PF_TODO
	return nil; 
}

@end

#undef SELF
