/*
 *	PureFoundation -- http://puredarwin.org
 *	NSError.m
 *
 *	NSError
 *
 *	Created by Stuart Crook on 26/01/2009.
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


@implementation NSError

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    return [(id)CFErrorCreate(kCFAllocatorDefault, (CFStringRef)domain, code, (CFDictionaryRef)dict) autorelease];
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    free(self);
    if (!domain) return nil;
    return (id)CFErrorCreate(kCFAllocatorDefault, (CFStringRef)domain, code, (CFDictionaryRef)dict);
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

// NSCFError is defined in Foundation while __NSCFError is implemented in CoreFoundation
@interface NSCFError : NSError
@end

@implementation NSCFError

// TODO:
// t +[NSCFError automaticallyNotifiesObserversForKey:]
// t -[NSCFError allowsWeakReference]
// t -[NSCFError classForCoder]
// t -[NSCFError code]
// t -[NSCFError domain]
// t -[NSCFError hash]
// t -[NSCFError isEqual:]
// t -[NSCFError release]
// t -[NSCFError retainCount]
// t -[NSCFError retainWeakReference]
// t -[NSCFError retain]
// t -[NSCFError userInfo]

@end
