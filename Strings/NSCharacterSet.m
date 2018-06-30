/*
 *	PureFoundation -- https://puredarwin.org
 *	NSCharacterSet.m
 *
 *	NSCharacterSet, NSMutableCharacterSet
 *
 *	Created by Stuart Crook on 02/02/2009.
 */

#import "NSCharacterSet.h"

// NSCharacterSet and NSMutableCharacterSet are implemented here. The NSCF bridged versions which do the work are in CF.

@implementation NSCharacterSet

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return nil;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
	return nil;
}

# pragma mark - NSCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // TODO
    free(self);
	return nil;
}

#pragma mark - immutable factory methods

+ (id)characterSetWithRange:(NSRange)aRange {
	CFRange range = CFRangeMake(aRange.location, aRange.length);
	return [(id)CFCharacterSetCreateWithCharactersInRange(kCFAllocatorDefault, range) autorelease];
}

+ (id)characterSetWithCharactersInString:(NSString *)aString {
	return [(id)CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, (CFStringRef)aString) autorelease];
}

+ (id)characterSetWithBitmapRepresentation:(NSData *)data {
	return [(id)CFCharacterSetCreateWithBitmapRepresentation(kCFAllocatorDefault, (CFDataRef)data) autorelease];
}

+ (id)characterSetWithContentsOfFile:(NSString *)fName {
	NSData *data = [NSData dataWithContentsOfFile:fName];
	if (!data) return nil;
	return [(id)CFCharacterSetCreateWithBitmapRepresentation(kCFAllocatorDefault, (CFDataRef)data) autorelease];
}

#pragma mark -

+ (id)controlCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetControl);
}

+ (id)whitespaceCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetWhitespace);
}

+ (id)whitespaceAndNewlineCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetWhitespaceAndNewline);
}

+ (id)decimalDigitCharacterSet {
	return (id)CFCharacterSetGetPredefined( kCFCharacterSetDecimalDigit );
}

+ (id)letterCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetLetter);
}

+ (id)lowercaseLetterCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetLowercaseLetter);
}

+ (id)uppercaseLetterCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter);
}

+ (id)nonBaseCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetNonBase);
}

+ (id)alphanumericCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric);
}

+ (id)decomposableCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetDecomposable);
}

+ (id)illegalCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetIllegal);
}

+ (id)punctuationCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetPunctuation);
}

+ (id)capitalizedLetterCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetCapitalizedLetter);
}

+ (id)symbolCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetSymbol);
}

+ (id)newlineCharacterSet {
	return (id)CFCharacterSetGetPredefined(kCFCharacterSetNewline);
}

#pragma mark - immutable instance method prototypes

- (BOOL)characterIsMember:(unichar)aCharacter { return NO; }
- (NSData *)bitmapRepresentation { return nil; }
- (NSCharacterSet *)invertedSet { return nil; }
- (BOOL)longCharacterIsMember:(UTF32Char)theLongChar { return NO; }
- (BOOL)isSupersetOfSet:(NSCharacterSet *)theOtherSet { return NO; }
- (BOOL)hasMemberInPlane:(uint8_t)thePlane { return NO; }

@end

@implementation NSMutableCharacterSet

#pragma mark - mutable factory methods

+ (id)characterSetWithRange:(NSRange)aRange {
	CFRange range = CFRangeMake(aRange.location, aRange.length);
	CFCharacterSetRef set = CFCharacterSetCreateWithCharactersInRange(kCFAllocatorDefault, range);
	CFMutableCharacterSetRef mSet = CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

+ (id)characterSetWithCharactersInString:(NSString *)aString {
	CFCharacterSetRef set = CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, (CFStringRef)aString);
	CFMutableCharacterSetRef mSet = CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

+ (id)characterSetWithBitmapRepresentation:(NSData *)data {
	CFCharacterSetRef set = CFCharacterSetCreateWithBitmapRepresentation(kCFAllocatorDefault, (CFDataRef)data);
	CFMutableCharacterSetRef mSet = CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

+ (id)characterSetWithContentsOfFile:(NSString *)fName {
	NSData *data = [NSData dataWithContentsOfFile: fName];
	if (!data) return nil;
	CFCharacterSetRef set = CFCharacterSetCreateWithBitmapRepresentation(kCFAllocatorDefault, (CFDataRef)data);
	CFMutableCharacterSetRef mSet = CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

#pragma mark -

+ (id)controlCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetControl);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)whitespaceCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetWhitespace);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)whitespaceAndNewlineCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetWhitespaceAndNewline);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)decimalDigitCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetDecimalDigit);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)letterCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetLetter);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)lowercaseLetterCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetLowercaseLetter);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)uppercaseLetterCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)nonBaseCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetNonBase);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)alphanumericCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)decomposableCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetDecomposable);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)illegalCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetIllegal);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)punctuationCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetPunctuation);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)capitalizedLetterCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetCapitalizedLetter);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)symbolCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetSymbol);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

+ (id)newlineCharacterSet {
	CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetNewline);
    return [(id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, set) autorelease];
}

#pragma mark - mutable instance method prototypes

- (void)addCharactersInRange:(NSRange)aRange {}
- (void)removeCharactersInRange:(NSRange)aRange {}
- (void)addCharactersInString:(NSString *)aString {}
- (void)removeCharactersInString:(NSString *)aString {}
- (void)formUnionWithCharacterSet:(NSCharacterSet *)otherSet {}
- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)otherSet {}
- (void)invert {}

#pragma mark -  NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return nil;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
	return nil;
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding { return YES; }
- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
    // TODO
    free(self);
	return nil;
}

@end
