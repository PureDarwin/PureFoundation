/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSError.m
 *
 *	NSError
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSError.h>

// These constants have the same values as those defined in CoreFoundation but are distinct symbols
NSString *const NSCocoaErrorDomain      = @"NSCocoaErrorDomain";    // kCFErrorDomainCocoa
NSString *const NSPOSIXErrorDomain		= @"NSPOSIXErrorDomain";    // kCFErrorDomainPOSIX
NSString *const NSOSStatusErrorDomain	= @"NSOSStatusErrorDomain"; // kCFErrorDomainOSStatus
NSString *const NSMachErrorDomain		= @"NSMachErrorDomain";     // kCFErrorDomainMach

// NSError userInfo dictionary keys
NSString *const NSUnderlyingErrorKey					= @"NSUnderlyingError";
NSString *const NSLocalizedDescriptionKey				= @"NSLocalizedDescription";
NSString *const NSLocalizedFailureReasonErrorKey		= @"NSLocalizedFailureReason";
NSString *const NSLocalizedRecoverySuggestionErrorKey	= @"NSLocalizedRecoverySuggestion";
NSString *const NSLocalizedRecoveryOptionsErrorKey		= @"NSLocalizedRecoveryOptions";
NSString *const NSRecoveryAttempterErrorKey				= @"NSRecoveryAttempter";
NSString *const NSStringEncodingErrorKey				= @"NSStringEncoding";
NSString *const NSURLErrorKey							= @"NSURL";
NSString *const NSFilePathErrorKey						= @"NSFilePath";

NSString *const NSHelpAnchorErrorKey = @"NSHelpAnchor";

#define SELF ((CFErrorRef)self)

@interface __NSCFError : NSError
@end

@implementation NSError

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    return [(id)CFErrorCreate(kCFAllocatorDefault, (CFStringRef)domain, code, (CFDictionaryRef)dict) autorelease];
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    free(self);
    if (!domain) return nil;
    return [(id)CFErrorCreate(kCFAllocatorDefault, (CFStringRef)domain, code, (CFDictionaryRef)dict) autorelease];
}

// Placeholder implementations of NSError methods
// These will never be called because we always return a (__NS)CFError
- (NSString *)domain { return nil; }
- (NSInteger)code { return 0; }
- (NSDictionary *)userInfo { return nil; }
- (NSString *)localizedDescription { return nil; }
- (NSString *)localizedFailureReason { return nil; }
- (NSString *)localizedRecoverySuggestion { return nil; }
- (NSArray *)localizedRecoveryOptions { return nil; }
- (id)recoveryAttempter { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return self; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return self; }

@end


@implementation __NSCFError

- (CFTypeID)_cfTypeID {
	return CFErrorGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

- (NSString *)description {
	return [(id)CFErrorCopyDescription(SELF) autorelease];
}

- (NSString *)domain {
    return (id)CFErrorGetDomain(SELF);
}

- (NSInteger)code {
    return CFErrorGetCode(SELF);
}

- (NSDictionary *)userInfo {
    return [(id)CFErrorCopyUserInfo(SELF) autorelease];
}

- (NSString *)localizedDescription {
    return [(id)CFErrorCopyDescription(SELF) autorelease];
}

- (NSString *)localizedFailureReason {
    return [(id)CFErrorCopyFailureReason(SELF) autorelease];
}

id PFErrorUserInfoValue(CFErrorRef error, NSString *key) {
    CFDictionaryRef userInfo = CFErrorCopyUserInfo(error);
    if (!userInfo) return nil;
    const void *value = CFDictionaryGetValue(userInfo, key);
    CFRelease(userInfo);
    return [(id)value autorelease];
}

- (NSString *)localizedRecoverySuggestion {
    return PFErrorUserInfoValue(SELF, NSLocalizedRecoverySuggestionErrorKey);
}

- (NSArray *)localizedRecoveryOptions {
    return PFErrorUserInfoValue(SELF, NSLocalizedRecoveryOptionsErrorKey);
}

- (id)recoveryAttempter {
    return PFErrorUserInfoValue(SELF, NSRecoveryAttempterErrorKey);
}

- (NSString *)helpAnchor {
    return PFErrorUserInfoValue(SELF, NSHelpAnchorErrorKey);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CFStringRef domain = CFErrorGetDomain(SELF);
    CFIndex code = CFErrorGetCode(SELF);
    CFDictionaryRef userInfo = CFErrorCopyUserInfo(SELF);
	CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, domain, code, userInfo);
    CFRelease(userInfo);
    return [(id)error autorelease];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    PF_TODO
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
	return nil;
}

@end

#undef SELF
