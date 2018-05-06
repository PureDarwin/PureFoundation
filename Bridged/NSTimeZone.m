/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSTimeZone.m
 *
 *	NSTimerZone, NSCFTimeZone
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSTimeZone.h"

// On macOS, CFTimeZone is bridged with __NSTimeZone, and both NSTimeZone and __NSTimeZone are implemented in CoreFoundation

@interface __NSTimeZone : NSTimeZone
@end

@implementation NSTimeZone

// Init-ing a NSTimeZone will return a CFTimeZone, which is bridged to __NSTimeZone
- (id)initWithName:(NSString *)tzName {
    PF_HELLO("")
    free(self);
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)tzName, false);
}

- (id)initWithName:(NSString *)tzName data:(NSData *)data {
    PF_HELLO("")
    free(self);
    return (id)CFTimeZoneCreate(kCFAllocatorDefault, (CFStringRef)tzName, (CFDataRef)data);
}

// Class creation methods, returning CFTimeZone instances
+ (instancetype)timeZoneWithName:(NSString *)tzName {
	PF_HELLO("")
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)tzName, true);
}

+ (id)timeZoneWithName:(NSString *)tzName data:(NSData *)data {
	PF_HELLO("")
    return (id)CFTimeZoneCreate(kCFAllocatorDefault, (CFStringRef)tzName, (CFDataRef)data);
}

// Time zones created with this never have daylight savings and the
// offset is constant no matter the date; the name and abbreviation
// do NOT follow the POSIX convention (of minutes-west).
+ (id)timeZoneForSecondsFromGMT:(NSInteger)seconds {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCreateWithTimeIntervalFromGMT(kCFAllocatorDefault, seconds) )
}

+ (id)timeZoneWithAbbreviation:(NSString *)abbreviation {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)abbreviation, true) )
}


/*
 *	NSExtendedTimeZone class methods
 */
+ (NSTimeZone *)systemTimeZone {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopySystem() )
}

+ (void)resetSystemTimeZone {
	PF_HELLO("")
	CFTimeZoneResetSystem();
}
 
+ (NSTimeZone *)defaultTimeZone {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyDefault() )
}

+ (void)setDefaultTimeZone:(NSTimeZone *)aTimeZone {
	PF_HELLO("")
	CFTimeZoneSetDefault((CFTimeZoneRef)aTimeZone);
}

// "Returns an object that forwards all messages to the default time zone for the current application."
// TODO: implement some form of proxy timezone object
+ (NSTimeZone *)localTimeZone {
	PF_TODO
}
 
+ (NSArray *)knownTimeZoneNames {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyKnownNames() )
}
 
+ (NSDictionary *)abbreviationDictionary {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyAbbreviationDictionary() )
}
 

/*
 *	NSTimeZone instance methods
 */
- (NSString *)name { return nil; }
- (NSData *)data { return nil; }
- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate { return 0; }
- (NSString *)abbreviationForDate:(NSDate *)aDate { return nil; }
- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate { return NO; }
- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate { return 0; }
- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate { return nil; }

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    PF_TODO
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    PF_TODO
}

@end


// Class which bridges to CFTimeZoneRef
@implementation __NSTimeZone

- (CFTypeID)_cfTypeID {
	return CFTimeZoneGetTypeID();
}

// TODO: classForCoder

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)description {
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}

- (NSString *)name {
	PF_HELLO("")
	PF_RETURN_NEW( CFTimeZoneGetName( (CFTimeZoneRef)self ) )
}

- (NSData *)data {
	PF_HELLO("")
	PF_RETURN_NEW( CFTimeZoneGetData( (CFTimeZoneRef)self ) )
}

- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate {
	PF_HELLO("")
	return CFTimeZoneGetSecondsFromGMT( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
}

- (NSString *)abbreviationForDate:(NSDate *)aDate {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyAbbreviation( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) ) )
}

- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate {
	PF_HELLO("")
	return CFTimeZoneIsDaylightSavingTime( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate {
	PF_HELLO("")
	return CFTimeZoneGetDaylightSavingTimeOffset( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
}

- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate {
	PF_HELLO("")
	CFAbsoluteTime time = CFTimeZoneGetNextDaylightSavingTimeTransition( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
	PF_RETURN_TEMP( CFDateCreate( kCFAllocatorDefault, time ) )
}

- (NSInteger)secondsFromGMT {
	PF_HELLO("")
	return CFTimeZoneGetSecondsFromGMT( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() );
}

- (NSString *)abbreviation {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyAbbreviation( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() ) )
}

- (BOOL)isDaylightSavingTime {
	PF_HELLO("")
	return CFTimeZoneIsDaylightSavingTime( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() );
}

- (NSTimeInterval)daylightSavingTimeOffset {
	PF_HELLO("")
	return CFTimeZoneGetDaylightSavingTimeOffset( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() );
}

- (NSDate *)nextDaylightSavingTimeTransition {
	PF_HELLO("")
	CFAbsoluteTime t = CFTimeZoneGetNextDaylightSavingTimeTransition( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent());
	PF_RETURN_TEMP( CFDateCreate( kCFAllocatorDefault, t ) )
}

- (BOOL)isEqualToTimeZone:(NSTimeZone *)aTimeZone {
	PF_HELLO("")
    if (!aTimeZone) return NO;
	if (self == aTimeZone) return YES;
	return CFEqual( (CFTypeRef)self, (CFTypeRef)aTimeZone );
}

- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale {
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyLocalizedName( (CFTypeRef)self, style, (CFLocaleRef)locale ) )
}

#pragma mark - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, CFTimeZoneGetName((CFTimeZoneRef)self), false);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    PF_TODO
    // TODO: serialise Name and Data
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    PF_TODO
    // TODO: create a CFTimeZone instance from the de-serialised Name and Data
    // TODO: also free(self) to get rid of the alloc's memory
    // TODO: this should probably be implemented in NSTimeZone because that is the class which will be in the coder
}

@end
