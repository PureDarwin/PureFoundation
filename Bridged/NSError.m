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

/*
 *	NSError domain constants, found by printing them out on OS X (10.5.6)
 */
NSString *const NSCocoaErrorDomain		= @"NSCocoaErrorDomain";
NSString *const NSPOSIXErrorDomain		= @"NSPOSIXErrorDomain";
NSString *const NSOSStatusErrorDomain	= @"NSOSStatusErrorDomain";
NSString *const NSMachErrorDomain		= @"NSMachErrorDomain";

// ??? CONST_STRING_DECL(kCFErrorDebugDescriptionKey,              "NSDebugDescription");

/*
 *	Keys for NSError userInfo dictionary
 */
NSString *const NSUnderlyingErrorKey					= @"NSUnderlyingError";
NSString *const NSLocalizedDescriptionKey				= @"NSLocalizedDescription";
NSString *const NSLocalizedFailureReasonErrorKey		= @"NSLocalizedFailureReason";
NSString *const NSLocalizedRecoverySuggestionErrorKey	= @"NSLocalizedRecoverySuggestion";
NSString *const NSLocalizedRecoveryOptionsErrorKey		= @"NSLocalizedRecoveryOptions";
NSString *const NSRecoveryAttempterErrorKey				= @"NSRecoveryAttempter";
NSString *const NSStringEncodingErrorKey				= @"NSStringEncoding";
NSString *const NSURLErrorKey							= @"NSURL";
NSString *const NSFilePathErrorKey						= @"NSFilePath";

@interface __NSCFError : NSError
@end

/*
 *	Dummy error object, but slightly different because NSError is the bridged class,
 *	not an abstract superclass
 */
//static Class _PFNSErrorClass = nil;

/*
 *	NSError is identical to CFError. The structure is simple, so we will keep this as an obj-c
 *	object.
 */
@implementation NSError

//+(void)initialize
//{
//    if( self == [NSError class] )
//        _PFNSErrorClass = self;
//}

//+(id)alloc
//{
//    if( self == [NSError class] )
//        return (id)&_PFNSErrorClass;
//    return [super alloc];
//}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    PF_HELLO("")
    CFErrorRef error = CFErrorCreate( kCFAllocatorDefault, (CFStringRef)domain, code, (CFDictionaryRef)dict );
    PF_RETURN_TEMP(error)
    //return [[[self alloc] initWithDomain: domain code: code userInfo: dict] autorelease];
}

// Designated initializer. Domain cannot be nil; dict may be nil if no userInfo desired
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    PF_HELLO("")
    
    free(self);
    
    if (!domain) return nil;
    
    return (id)CFErrorCreate(kCFAllocatorDefault, (CFStringRef)domain, code, (CFDictionaryRef)dict);
}

// Placeholder implementations of NSError methods

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
	PF_HELLO("")
	CFStringRef desc = CFErrorCopyDescription((CFErrorRef)self);
	PF_RETURN_TEMP(desc)
	//return [NSString stringWithFormat: @"Error Domain=%@ Code=%u\n\t\"%@\"", _domain, _code, @"TODO"];
}

/* These define the error. Domains are described by names that are arbitrary strings used to differentiate groups of codes; for custom domain using reverse-DNS naming will help avoid conflicts. Codes are domain-specific.
 */
- (NSString *)domain {
    return (id)CFErrorGetDomain((CFErrorRef)self);
}

- (NSInteger)code {
    return CFErrorGetCode((CFErrorRef)self);
}

/* Additional info which may be used to describe the error further. Examples of keys that might be included in here are "Line Number", "Failed URL", etc. Embedding other errors in here can also be used as a way to communicate underlying reasons for failures; for instance "File System Error" embedded in the userInfo of an NSError returned from a higher level document object. If the embedded error information is itself NSError, the standard key NSUnderlyingErrorKey can be used.
 */
- (NSDictionary *)userInfo {
    return (id)CFErrorCopyUserInfo((CFErrorRef)self);
}

/* The primary user-presentable message for the error. This method can be overridden by subclassers wishing to present better error strings.  By default this looks for NSLocalizedDescriptionKey in the user info. If not present, it manufactures a string from the domain and code. Also, for some of the built-in domains it knows about, it might try to fetch an error string by calling a domain-specific function. In the absence of a custom error string, the manufactured one might not be suitable for presentation to the user, but can be used in logs or debugging. 
 */
- (NSString *)localizedDescription {
	return self.userInfo[NSLocalizedDescriptionKey];
}

//#if MAC_OS_X_VERSION_10_4 <= MAC_OS_X_VERSION_MAX_ALLOWED

/* Return a complete sentence which describes why the operation failed. In many cases this will be just the "because" part of the error message (but as a complete sentence, which makes localization easier). This will return nil if string is not available. Default implementation of this will pick up the value of the NSLocalizedFailureReasonErrorKey from the userInfo dictionary.
 */
- (NSString *)localizedFailureReason {
    return (id)CFErrorCopyFailureReason((CFErrorRef)self);
}

/* Return the string that can be displayed as the "informative" (aka "secondary") message on an alert panel. Returns nil if no such string is available. Default implementation of this will pick up the value of the NSLocalizedRecoverySuggestionErrorKey from the userInfo dictionary.
 */
- (NSString *)localizedRecoverySuggestion {
	return self.userInfo[NSLocalizedRecoverySuggestionErrorKey];
}

/* Return titles of buttons that are appropriate for displaying in an alert. These should match the string provided as a part of localizedRecoverySuggestion.  The first string would be the title of the right-most and default button, the second one next to it, and so on. If used in an alert the corresponding default return values are NSAlertFirstButtonReturn + n. Default implementation of this will pick up the value of the NSLocalizedRecoveryOptionsErrorKey from the userInfo dictionary.  nil return usually implies no special suggestion, which would imply a single "OK" button.
 */
- (NSArray *)localizedRecoveryOptions {
    PF_TODO
    return nil;
}

/* Return an object that conforms to the NSErrorRecoveryAttempting informal protocol. The recovery attempter must be an object that can correctly interpret an index into the array returned by -localizedRecoveryOptions. The default implementation of this method merely returns [[self userInfo] objectForKey:NSRecoveryAttempterErrorKey].
 */
- (id)recoveryAttempter {
    PF_TODO
    return nil;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CFStringRef domain = CFErrorGetDomain((CFErrorRef)self);
    CFIndex code = CFErrorGetCode((CFErrorRef)self);
    CFDictionaryRef userInfo = CFErrorCopyUserInfo((CFErrorRef)self);
	CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, domain, code, userInfo);
    CFRelease(userInfo);
	PF_RETURN_NEW(error)
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
