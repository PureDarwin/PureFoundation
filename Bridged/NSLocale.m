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

@interface __NSCFLocale : NSLocale
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
@implementation __NSCFLocale

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

/*
 *	Standard bridged-class over-rides
 */
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

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
