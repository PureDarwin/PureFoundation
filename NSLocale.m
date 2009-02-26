/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSLocale.m
 *
 *	NSLocale, NSCFLocale
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSLocale.h"

/*
 *	Constants
 */
NSString * const NSCurrentLocaleDidChangeNotification = @"kCFLocaleCurrentLocaleDidChangeNotification";

// these have now been moved into CF
//NSString * const NSLocaleIdentifier = @"locale:id";
//NSString * const NSLocaleLanguageCode = @"locale:language code";
//NSString * const NSLocaleCountryCode = @"locale:country code";
//NSString * const NSLocaleScriptCode = @"locale:script code";
//NSString * const NSLocaleVariantCode = @"locale:variant code";
//NSString * const NSLocaleExemplarCharacterSet = @"locale:exemplar characters";
//NSString * const NSLocaleCalendar = @"locale:calendarref";
//NSString * const NSLocaleCollationIdentifier = @"collation";
//NSString * const NSLocaleUsesMetricSystem = @"locale:uses metric";
//NSString * const NSLocaleMeasurementSystem = @"locale:measurement system";
//NSString * const NSLocaleDecimalSeparator = @"locale:decimal separator";
//NSString * const NSLocaleGroupingSeparator = @"locale:grouping separator";
//NSString * const NSLocaleCurrencySymbol = @"locale:currency symbol";
//NSString * const NSLocaleCurrencyCode = @"currency";

// Values for NSCalendar identifiers (not the NSLocaleCalendar property key)
// these are now exported by CF
//NSString * const NSGregorianCalendar = @"gregorian";
//NSString * const NSBuddhistCalendar = @"buddhist";
//NSString * const NSChineseCalendar = @"chinese";
//NSString * const NSHebrewCalendar = @"hebrew";
//NSString * const NSIslamicCalendar = @"islamic";
//NSString * const NSIslamicCivilCalendar = @"islamic-civil";
//NSString * const NSJapaneseCalendar = @"japanese";


/*
 *	Declaration for our bridged class
 */
@interface NSCFLocale : NSLocale
@end


/*
 *	Dummy instance
 */
static Class _PFNSCFLocaleClass = nil;


/*
 *	The bridged NSCFLocale class
 */
@implementation NSLocale

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSLocale class] )
		_PFNSCFLocaleClass = objc_getClass("NSCFClass");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSLocale class] )
		return (id)&_PFNSCFLocaleClass;
	return [super alloc];
}

/*
 *	NSLocaleCreation class methods
 */
+ (id)systemLocale
{
	PF_HELLO("")
	return (id)CFLocaleGetSystem();
}

+ (id)currentLocale
{
	PF_HELLO("")
	return [(id)CFLocaleCopyCurrent() autorelease];
}

/*
 *	Now, how are we going to do this? Are we going to do this?
 */
+ (id)autoupdatingCurrentLocale
{
	PF_TODO
	return nil;
}


/*
 *	NSLocaleGeneralInfo class methods
 */
+ (NSArray *)availableLocaleIdentifiers
{
	PF_HELLO("")
	return [(id)CFLocaleCopyAvailableLocaleIdentifiers() autorelease];
}

+ (NSArray *)ISOLanguageCodes
{
	PF_HELLO("")
	return [(id)CFLocaleCopyISOLanguageCodes() autorelease];
}

+ (NSArray *)ISOCountryCodes
{
	PF_HELLO("")
	return [(id)CFLocaleCopyISOCountryCodes() autorelease];
}

+ (NSArray *)ISOCurrencyCodes
{
	PF_HELLO("")
	return [(id)CFLocaleCopyISOCurrencyCodes() autorelease];
}

+ (NSArray *)commonISOCurrencyCodes
{
	PF_HELLO("")
	return [(id)CFLocaleCopyCommonISOCurrencyCodes() autorelease];
}

+ (NSArray *)preferredLanguages 
{
	PF_HELLO("")
	return [(id)CFLocaleCopyPreferredLanguages() autorelease];
}


+ (NSDictionary *)componentsFromLocaleIdentifier:(NSString *)string
{
	PF_HELLO("")
	return [(id)CFLocaleCreateComponentsFromLocaleIdentifier( kCFAllocatorDefault, (CFStringRef)string ) autorelease];
}

+ (NSString *)localeIdentifierFromComponents:(NSDictionary *)dict
{
	PF_HELLO("")
	return [(id)CFLocaleCreateLocaleIdentifierFromComponents( kCFAllocatorDefault, (CFDictionaryRef)dict ) autorelease];
}


+ (NSString *)canonicalLocaleIdentifierFromString:(NSString *)string
{
	PF_HELLO("")
	return [(id)CFLocaleCreateCanonicalLocaleIdentifierFromString( kCFAllocatorDefault, (CFStringRef)string ) autorelease];
}

/*
 *	NSLocale instance methods
 */
- (id)objectForKey:(id)key { return nil; }
- (NSString *)displayNameForKey:(id)key value:(id)value { return nil; }

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

@end



/*
 *	NSCFLocale, the bridged class
 */
@implementation NSCFLocale

+(id)alloc
{
	return nil;
}

- (id)init
{
	PF_HELLO("")
	return nil; // this is what proper Foundation does
}

-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFLocaleGetTypeID();
}

// appears to return NSObjects <class address> description
//-(NSString *)description
//{
//	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
//}

// NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	PF_RETURN_NEW( CFLocaleCreateCopy( kCFAllocatorDefault, (CFLocaleRef)self ) )
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}


// NSLocaleCreation
- (id)initWithLocaleIdentifier:(NSString *)string
{
	PF_HELLO("")
	if( self != (id)&_PFNSCFLocaleClass ) [self autorelease];
	
	self = (id)CFLocaleCreate( kCFAllocatorDefault, (CFStringRef)string );
	PF_RETURN_NEW(self)
}


// NSLocale
- (id)objectForKey:(id)key
{
	PF_HELLO("")
	return (id)CFLocaleGetValue( (CFLocaleRef)self, (CFStringRef)key );
}

- (NSString *)displayNameForKey:(id)key value:(id)value
{
	PF_HELLO("")
	CFStringRef name = CFLocaleCopyDisplayNameForPropertyValue( (CFLocaleRef)self, (CFStringRef)key, (CFStringRef)value );
	PF_RETURN_TEMP(name)
}


// NSExtendedLocale -- "same as NSLocaleIdentifier"
- (NSString *)localeIdentifier
{
	PF_HELLO("")
	return (NSString *)CFLocaleGetIdentifier( (CFLocaleRef)self );
}



@end
