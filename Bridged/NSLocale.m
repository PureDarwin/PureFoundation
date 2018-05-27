/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSLocale.m
 *
 *	NSLocale, __NSCFLocale
 *
 *	Created by Stuart Crook on 02/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSLocale.h"

#define SELF ((CFLocaleRef)self)

@interface __NSCFLocale : NSLocale
@end

@implementation NSLocale

#pragma mark - init methods

- (instancetype)init {
    free(self);
    return nil; // This is what Foundation does
}

- (id)initWithLocaleIdentifier:(NSString *)string {
    free(self);
    return (id)CFLocaleCreate(kCFAllocatorDefault, (CFStringRef)string);
}

#pragma mark - factory methods

+ (id)systemLocale {
	return (id)CFLocaleGetSystem();
}

+ (id)currentLocale {
	return [(id)CFLocaleCopyCurrent() autorelease];
}

// TODO: Somehow
+ (id)autoupdatingCurrentLocale {
    return [(id)CFLocaleCopyCurrent() autorelease];
}

+ (NSArray *)availableLocaleIdentifiers {
	return [(id)CFLocaleCopyAvailableLocaleIdentifiers() autorelease];
}

+ (NSArray *)ISOLanguageCodes {
	return [(id)CFLocaleCopyISOLanguageCodes() autorelease];
}

+ (NSArray *)ISOCountryCodes {
	return [(id)CFLocaleCopyISOCountryCodes() autorelease];
}

+ (NSArray *)ISOCurrencyCodes {
	return [(id)CFLocaleCopyISOCurrencyCodes() autorelease];
}

+ (NSArray *)commonISOCurrencyCodes {
	return [(id)CFLocaleCopyCommonISOCurrencyCodes() autorelease];
}

+ (NSArray *)preferredLanguages {
	return [(id)CFLocaleCopyPreferredLanguages() autorelease];
}

+ (NSDictionary *)componentsFromLocaleIdentifier:(NSString *)string {
	return [(id)CFLocaleCreateComponentsFromLocaleIdentifier(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

+ (NSString *)localeIdentifierFromComponents:(NSDictionary *)dict {
	return [(id)CFLocaleCreateLocaleIdentifierFromComponents(kCFAllocatorDefault, (CFDictionaryRef)dict) autorelease];
}

+ (NSString *)canonicalLocaleIdentifierFromString:(NSString *)string {
	return [(id)CFLocaleCreateCanonicalLocaleIdentifierFromString(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

#pragma mark - instance method prototypes

- (id)objectForKey:(id)key { return nil; }
- (NSString *)displayNameForKey:(id)key value:(id)value { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }

@end


@implementation __NSCFLocale

-(CFTypeID)_cfTypeID {
	return CFLocaleGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFLocaleCreateCopy(kCFAllocatorDefault, SELF);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

#pragma mark - instance methods

- (id)objectForKey:(id)key {
	return (id)CFLocaleGetValue(SELF, (CFStringRef)key);
}

- (NSString *)displayNameForKey:(id)key value:(id)value {
	return [(id)CFLocaleCopyDisplayNameForPropertyValue(SELF, (CFStringRef)key, (CFStringRef)value) autorelease];
}

- (NSString *)localeIdentifier {
	return (id)CFLocaleGetIdentifier(SELF);
}

@end

#undef SELF
