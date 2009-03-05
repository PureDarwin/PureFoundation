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

/*
 *	Declare the bridged class
 */
@interface NSCFTimeZone : NSTimeZone
@end

/*
 *	Dummy object for inits
 */
static Class _PFNSCFTimeZoneClass = nil;

// contant
NSString * const NSSystemTimeZoneDidChangeNotification = @"kCFTimeZoneSystemTimeZoneDidChangeNotification";


@implementation NSTimeZone

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSTimeZone class] )
		_PFNSCFTimeZoneClass = objc_getClass("NSCFTimeZone");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSTimeZone class] )
		return (id)&_PFNSCFTimeZoneClass;
	return [super alloc];
}

// NSCopying
- (id)copyWithZone:(NSZone *)zone { return nil; }

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }


/*
 *	NSTimeZoneCreation class creation methods
 */
+ (id)timeZoneWithName:(NSString *)tzName
{
	PF_HELLO("")
	return [[[self alloc] initWithName: tzName] autorelease];
}

+ (id)timeZoneWithName:(NSString *)tzName data:(NSData *)aData
{
	PF_HELLO("")
	return [[[self alloc] initWithName: tzName data: aData] autorelease];
}

// Time zones created with this never have daylight savings and the
// offset is constant no matter the date; the name and abbreviation
// do NOT follow the POSIX convention (of minutes-west).
+ (id)timeZoneForSecondsFromGMT:(NSInteger)seconds
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCreateWithTimeIntervalFromGMT( kCFAllocatorDefault, seconds ) )
}

+ (id)timeZoneWithAbbreviation:(NSString *)abbreviation
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCreateWithName( kCFAllocatorDefault, (CFStringRef)abbreviation, TRUE ) )
}


/*
 *	NSExtendedTimeZone class methods
 */
+ (NSTimeZone *)systemTimeZone
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopySystem() )
}

+ (void)resetSystemTimeZone
{
	PF_HELLO("")
	CFTimeZoneResetSystem();
}
 
+ (NSTimeZone *)defaultTimeZone
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyDefault() )
}

+ (void)setDefaultTimeZone:(NSTimeZone *)aTimeZone
{
	PF_HELLO("")
	CFTimeZoneSetDefault( (CFTimeZoneRef)aTimeZone );
}
 
/*
 *	"Returns an object that forwards all messages to the default time zone for the current application."
 */
+ (NSTimeZone *)localTimeZone
{
	PF_TODO
	//PF_RETURN_TEMP( 
}
 
+ (NSArray *)knownTimeZoneNames
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyKnownNames() )
}
 
+ (NSDictionary *)abbreviationDictionary
{
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

@end






@implementation NSCFTimeZone

+(id)alloc
{
	PF_HELLO("")
	return nil;
}

-(CFTypeID)_cfTypeID
{
	return CFTimeZoneGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}


// NSCopying
- (id)copyWithZone:(NSZone *)zone 
{
	PF_HELLO("I think this is correct")
	return (id)CFTimeZoneCreateWithName( kCFAllocatorDefault, CFTimeZoneGetName((CFTimeZoneRef)self), FALSE );
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

/*
 *	instance creation
 */
- (id)initWithName:(NSString *)tzName
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFTimeZoneClass ) [self autorelease];

	self = (id)CFTimeZoneCreateWithName( kCFAllocatorDefault, (CFStringRef)tzName, FALSE );
	PF_RETURN_NEW(self)
}

- (id)initWithName:(NSString *)tzName data:(NSData *)aData
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFTimeZoneClass ) [self autorelease];

	self = (id)CFTimeZoneCreate( kCFAllocatorDefault, (CFStringRef)tzName, (CFDataRef)aData );
	PF_RETURN_NEW(self)
}


/*
 *	instance methods
 */
- (NSString *)name
{
	PF_HELLO("")
	PF_RETURN_NEW( CFTimeZoneGetName( (CFTimeZoneRef)self ) )
}

- (NSData *)data
{
	PF_HELLO("")
	PF_RETURN_NEW( CFTimeZoneGetData( (CFTimeZoneRef)self ) )
}

- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate
{
	PF_HELLO("")
	return CFTimeZoneGetSecondsFromGMT( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
}

- (NSString *)abbreviationForDate:(NSDate *)aDate
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyAbbreviation( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) ) )
}

- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate
{
	PF_HELLO("")
	return CFTimeZoneIsDaylightSavingTime( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate
{
	PF_HELLO("")
	return CFTimeZoneGetDaylightSavingTimeOffset( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
}

- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate
{
	PF_HELLO("")
	CFAbsoluteTime time = CFTimeZoneGetNextDaylightSavingTimeTransition( (CFTimeZoneRef)self, CFDateGetAbsoluteTime((CFDateRef)aDate) );
	PF_RETURN_TEMP( CFDateCreate( kCFAllocatorDefault, time ) )
}

- (NSInteger)secondsFromGMT
{
	PF_HELLO("")
	return CFTimeZoneGetSecondsFromGMT( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() );
}

- (NSString *)abbreviation
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyAbbreviation( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() ) )
}

- (BOOL)isDaylightSavingTime
{
	PF_HELLO("")
	return CFTimeZoneIsDaylightSavingTime( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() );
}

- (NSTimeInterval)daylightSavingTimeOffset
{
	PF_HELLO("")
	return CFTimeZoneGetDaylightSavingTimeOffset( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent() );
}

- (NSDate *)nextDaylightSavingTimeTransition
{
	PF_HELLO("")
	CFAbsoluteTime t = CFTimeZoneGetNextDaylightSavingTimeTransition( (CFTimeZoneRef)self, CFAbsoluteTimeGetCurrent());
	PF_RETURN_TEMP( CFDateCreate( kCFAllocatorDefault, t ) )
}

- (BOOL)isEqualToTimeZone:(NSTimeZone *)aTimeZone
{
	PF_HELLO("")
	if( self == aTimeZone ) return YES;
	if( aTimeZone == nil ) return NO;
	return CFEqual( (CFTypeRef)self, (CFTypeRef)aTimeZone );
}

- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale
{
	PF_HELLO("")
	PF_RETURN_TEMP( CFTimeZoneCopyLocalizedName( (CFTypeRef)self, style, (CFLocaleRef)locale ) )
}


@end

