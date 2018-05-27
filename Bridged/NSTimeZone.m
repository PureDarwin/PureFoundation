/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSTimeZone.m
 *
 *	NSTimerZone, NSCFTimeZone
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSTimeZone.h"

#define SELF ((CFTimeZoneRef)self)

// On macOS, CFTimeZone is bridged with __NSTimeZone, and both NSTimeZone and __NSTimeZone are implemented in CoreFoundation

@interface __NSTimeZone : NSTimeZone
@end

@implementation NSTimeZone

#pragma mark - init methods

- (id)initWithName:(NSString *)tzName {
    free(self);
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)tzName, false);
}

- (id)initWithName:(NSString *)tzName data:(NSData *)data {
    free(self);
    return (id)CFTimeZoneCreate(kCFAllocatorDefault, (CFStringRef)tzName, (CFDataRef)data);
}

#pragma mark - factory methods

+ (instancetype)timeZoneWithName:(NSString *)tzName {
    return [(id)CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)tzName, true) autorelease];
}

+ (id)timeZoneWithName:(NSString *)tzName data:(NSData *)data {
    return [(id)CFTimeZoneCreate(kCFAllocatorDefault, (CFStringRef)tzName, (CFDataRef)data) autorelease];
}

+ (id)timeZoneForSecondsFromGMT:(NSInteger)seconds {
    return [(id)CFTimeZoneCreateWithTimeIntervalFromGMT(kCFAllocatorDefault, seconds) autorelease];
}

+ (id)timeZoneWithAbbreviation:(NSString *)abbreviation {
    return [(id) CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)abbreviation, true) autorelease];
}

+ (NSTimeZone *)systemTimeZone {
    return [(id)CFTimeZoneCopySystem() autorelease];
}

+ (void)resetSystemTimeZone {
	CFTimeZoneResetSystem();
}
 
+ (NSTimeZone *)defaultTimeZone {
    return [(id)CFTimeZoneCopyDefault() autorelease];
}

+ (void)setDefaultTimeZone:(NSTimeZone *)aTimeZone {
	CFTimeZoneSetDefault((CFTimeZoneRef)aTimeZone);
}

// "Returns an object that forwards all messages to the default time zone for the current application."
// TODO: implement some form of proxy timezone object
+ (NSTimeZone *)localTimeZone {
	PF_TODO
    return [(id)CFTimeZoneCopyDefault() autorelease];
}
 
+ (NSArray *)knownTimeZoneNames {
    return [(id)CFTimeZoneCopyKnownNames() autorelease];
}
 
+ (NSDictionary *)abbreviationDictionary {
    return [(id)CFTimeZoneCopyAbbreviationDictionary() autorelease];
}
 
// NSTimeZone instance methods
- (NSString *)name { return nil; }
- (NSData *)data { return nil; }
- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate { return 0; }
- (NSString *)abbreviationForDate:(NSDate *)aDate { return nil; }
- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate { return NO; }
- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate { return 0; }
- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate { return nil; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {}
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder { return nil; }

@end


@implementation __NSTimeZone

- (CFTypeID)_cfTypeID {
	return CFTimeZoneGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)name {
    return (id)CFTimeZoneGetName(SELF);
}

- (NSData *)data {
    return (id)CFTimeZoneGetData(SELF);
}

- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate {
	return CFTimeZoneGetSecondsFromGMT(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
}

- (NSString *)abbreviationForDate:(NSDate *)aDate {
    return [(id)CFTimeZoneCopyAbbreviation(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate)) autorelease];
}

- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate {
	return CFTimeZoneIsDaylightSavingTime(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate {
	return CFTimeZoneGetDaylightSavingTimeOffset(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
}

- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate {
	CFAbsoluteTime time = CFTimeZoneGetNextDaylightSavingTimeTransition(SELF, CFDateGetAbsoluteTime((CFDateRef)aDate));
    return [(id)CFDateCreate(kCFAllocatorDefault, time) autorelease];
}

- (NSInteger)secondsFromGMT {
	return CFTimeZoneGetSecondsFromGMT(SELF, CFAbsoluteTimeGetCurrent());
}

- (NSString *)abbreviation {
    return [(id)CFTimeZoneCopyAbbreviation(SELF, CFAbsoluteTimeGetCurrent()) autorelease];
}

- (BOOL)isDaylightSavingTime {
	return CFTimeZoneIsDaylightSavingTime(SELF, CFAbsoluteTimeGetCurrent());
}

- (NSTimeInterval)daylightSavingTimeOffset {
	return CFTimeZoneGetDaylightSavingTimeOffset(SELF, CFAbsoluteTimeGetCurrent());
}

- (NSDate *)nextDaylightSavingTimeTransition {
	CFAbsoluteTime time = CFTimeZoneGetNextDaylightSavingTimeTransition(SELF, CFAbsoluteTimeGetCurrent());
    return [(id)CFDateCreate(kCFAllocatorDefault, time) autorelease];
}

- (BOOL)isEqualToTimeZone:(NSTimeZone *)aTimeZone {
    if (!aTimeZone) return NO;
	return (self == aTimeZone) || CFEqual((CFTypeRef)self, (CFTypeRef)aTimeZone);
}

- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale {
    return [(id)CFTimeZoneCopyLocalizedName(SELF, style, (CFLocaleRef)locale) autorelease];
}

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, CFTimeZoneGetName(SELF), false);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    PF_TODO
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    PF_TODO
    return nil;
}

@end

#undef SELF
