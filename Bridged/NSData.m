/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSData.m
 *
 *	NSData, NSMutableData, NSCFData
 *
 *	Created by Stuart Crook on 27/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSData.h>
#import "NSString.h"
#import "FileLoaders.h"

#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

#define SELF ((CFDataRef)self)
#define MSELF ((CFMutableDataRef)self)

extern bool __PFDataIsMutable( CFDataRef data );


@interface __NSCFData : NSMutableData
@end

@implementation NSData

#pragma mark - primatives

- (NSUInteger)length { return 0; }
- (const void *)bytes { return NULL; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return nil;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
	return nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
    free(self);
	return nil;
}

#pragma mark - immutable factory methods

+ (instancetype)data {
    return [(id)CFDataCreate(kCFAllocatorDefault, NULL, 0) autorelease];
}

+ (instancetype)dataWithBytes:(const void *)bytes length:(NSUInteger)length {
    return [(id)CFDataCreate(kCFAllocatorDefault, bytes, length) autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length {
    return [(id)CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, bytes, length, kCFAllocatorDefault) autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)free {
    CFAllocatorRef deallocator = free ? kCFAllocatorDefault : kCFAllocatorNull;
    return [(id)CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, bytes, length, deallocator) autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url {
    return [(id)PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, NULL) autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    return [(id)PFDataInitFromURL((CFURLRef)url, readOptionsMask, (CFErrorRef *)errorPtr) autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path {
    return [(id)PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, NULL) autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    return [(id)PFDataInitFromPath((CFStringRef)path, readOptionsMask, (CFErrorRef *)errorPtr) autorelease];
}

+ (id)dataWithContentsOfMappedFile:(NSString *)path {
    return [(id)PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, NULL) autorelease];
}

+ (id)dataWithData:(NSData *)data {
    return [(id)CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)data) autorelease];
}

#pragma mark - immutable init methods

- (id)init {
    free(self);
    return (id)CFDataCreate(kCFAllocatorDefault, NULL, 0);
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length {
    free(self);
    return (id)CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length {
    free(self);
    return (id)CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, kCFAllocatorDefault);
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone {
    free(self);
    CFAllocatorRef deallocator = freeWhenDone ? kCFAllocatorDefault : kCFAllocatorNull;
    return (id)CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, deallocator);
}

- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, readOptionsMask, (CFErrorRef *)errorPtr);
}

- (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    return (id)PFDataInitFromURL((CFURLRef)url, readOptionsMask, (CFErrorRef *)errorPtr);
}

- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, NULL);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, NULL);
}

- (id)initWithContentsOfMappedFile:(NSString *)path {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, NULL);
}

- (id)initWithData:(NSData *)data {
    free(self);
    return (id)CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)data);
}

@end


@implementation NSMutableData

#pragma mark - mutable factory methods

+ (id)data {
    return [(id)CFDataCreateMutable(kCFAllocatorDefault, 0) autorelease];
}

+ (instancetype)dataWithCapacity:(NSUInteger)capacity {
    return [(id)CFDataCreateMutable(kCFAllocatorDefault, capacity) autorelease];
}

+ (instancetype)dataWithLength:(NSUInteger)length {
    // TODO: Check that ownership of these bytes is correctly passed on to the mutable data
    UInt8 *bytes = calloc(length, 1);
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, kCFAllocatorNull);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    free(bytes);
    return [(id)mData autorelease];
}

+ (instancetype)dataWithBytes:(const void *)bytes length:(NSUInteger)length {
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length {
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, kCFAllocatorDefault);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)free {
    CFAllocatorRef deallocator = free ? kCFAllocatorDefault : kCFAllocatorNull;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, deallocator);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url {
    CFDataRef data = PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, NULL);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    CFDataRef data = PFDataInitFromURL((CFURLRef)url, readOptionsMask, (CFErrorRef *)errorPtr);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path {
    CFDataRef data = PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, NULL);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    CFDataRef data = PFDataInitFromPath((CFStringRef)path, readOptionsMask, (CFErrorRef *)errorPtr);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithContentsOfMappedFile:(NSString *)path {
    CFDataRef data = PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, NULL);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithData:(NSData *)data {
    return [(id)CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data) autorelease];
}

#pragma mark - immutable init methods

- (id)init {
    free(self);
    return (id)CFDataCreateMutable(kCFAllocatorDefault, 0);
}

- (id)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFDataCreateMutable(kCFAllocatorDefault, capacity);
}

- (id)initWithLength:(NSUInteger)length {
    free(self);
    // TODO: Check that ownership of these bytes is correctly passed on to the mutable data
    // Or could use CFDataSetLength()
    UInt8 *bytes = calloc(length, 1);
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, kCFAllocatorNull);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    free(bytes);
    return (id)mData;
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length {
    free(self);
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return (id)mData;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length {
    free(self);
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, kCFAllocatorDefault);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return (id)mData;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone  {
    free(self);
    CFAllocatorRef deallocator = free ? kCFAllocatorDefault : kCFAllocatorNull;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)bytes, length, deallocator);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return (id)mData;
}

- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    CFDataRef data = PFDataInitFromPath((CFStringRef)path, readOptionsMask, (CFErrorRef *)errorPtr);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return (id)mData;
}

- (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    CFDataRef data = PFDataInitFromURL((CFURLRef)url, readOptionsMask, (CFErrorRef *)errorPtr);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return (id)mData;
}

- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    CFDataRef data = PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, NULL);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    CFDataRef data = PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, NULL);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return (id)mData;
}

- (id)initWithContentsOfMappedFile:(NSString *)path {
    free(self);
    CFDataRef data = PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, NULL);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

- (id)initWithData:(NSData *)data {
    free(self);
    return (id)CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
}

#pragma mark - mutable instance method prototypes

- (void *)mutableBytes { return NULL; }
- (void)setLength:(NSUInteger)length {}

@end


@implementation __NSCFData

- (CFTypeID)_cfTypeID {
	return CFDataGetTypeID();
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

- (id)copyWithZone:(NSZone *)zone {
	return (id)CFDataCreateCopy(kCFAllocatorDefault, SELF);
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	return (id)CFDataCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    PF_TODO
}

- (NSUInteger)length {
	return CFDataGetLength(SELF);
}

- (const void *)bytes {
	return (const void *)CFDataGetBytePtr(SELF);
}

- (void)getBytes:(void *)buffer {
    CFDataGetBytes(SELF, CFRangeMake(0, CFDataGetLength(SELF)), (UInt8 *)buffer);
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length {
    CFDataGetBytes(SELF, CFRangeMake(0, length), (UInt8 *)buffer);
}

- (void)getBytes:(void *)buffer range:(NSRange)range {
	CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length || range.location + range.length > length) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFDataGetBytes(SELF, CFRangeMake(range.location, range.length), (UInt8 *)buffer);
}

- (BOOL)isEqualToData:(NSData *)other {
	if (!other) return NO;
	return (self == other) || CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

- (NSData *)subdataWithRange:(NSRange)range {
    CFIndex length = CFDataGetLength(SELF);
	if (!length || range.location >= length || range.location + range.length > length) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
    UInt8 *buffer = malloc(range.length);
	CFDataGetBytes(SELF, CFRangeMake(range.location, range.length), buffer);
	CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)buffer, range.length);
    free(buffer);
    return [(id)data autorelease];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically {
    NSDataWritingOptions options = atomically ? NSDataWritingAtomic : 0;
    return PFDataWriteToPath(SELF, (CFStringRef)path, options, NULL);
}

- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr {
    return PFDataWriteToPath(SELF, (CFStringRef)path, writeOptionsMask, (CFErrorRef *)errorPtr);
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
    NSDataWritingOptions options = atomically ? NSDataWritingAtomic : 0;
    return PFDataWriteToURL(SELF, (CFURLRef)url, options, NULL);
}

- (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr {
    return PFDataWriteToURL(SELF, (CFURLRef)url, writeOptionsMask, (CFErrorRef *)errorPtr);
}

#pragma mark - mutable instance methods

- (void *)mutableBytes {
    return CFDataGetMutableBytePtr(MSELF);
}

- (void)setLength:(NSUInteger)length {
	CFDataSetLength(MSELF, length);
}

- (void)appendBytes:(const void *)bytes length:(NSUInteger)length {
    if (!length) return;
	CFDataAppendBytes(MSELF, (const UInt8 *)bytes, length);
}

- (void)appendData:(NSData *)other {
    CFIndex length = CFDataGetLength((CFDataRef)other);
    if (!length) return;
    const UInt8 *bytes = CFDataGetBytePtr((CFDataRef)other);
    CFDataAppendBytes(MSELF, bytes, length);
}

- (void)increaseLengthBy:(NSUInteger)extraLength {
	CFDataIncreaseLength(MSELF, extraLength);
}

- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes {
    CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFDataReplaceBytes(MSELF, CFRangeMake(range.location, range.length), (const UInt8 *)bytes, range.length);
}

- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)replacementBytes length:(NSUInteger)replacementLength {
    CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFDataReplaceBytes(MSELF, CFRangeMake(range.location, range.length), (const UInt8 *)replacementBytes, replacementLength);
}

- (void)resetBytesInRange:(NSRange)range {
    CFIndex length = CFDataGetLength(SELF);
    if (range.location >= length) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
    UInt8 *bytes = calloc(range.length, 1);
    CFDataReplaceBytes(MSELF, CFRangeMake(range.location, range.length), (const UInt8 *)bytes, range.length);
    free(bytes);
}

- (void)setData:(NSData *)data {
    CFIndex length = CFDataGetLength((CFDataRef)data);
    if (!length) return;
    const UInt8 *bytes = CFDataGetBytePtr((CFDataRef)data);
    CFRange range = CFRangeMake(0, CFDataGetLength(SELF));
	CFDataReplaceBytes(MSELF, range, bytes, length);
}
 
@end

#undef SELF
#undef MSELF
