/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSData.m
 *
 *	Created by Stuart Crook on 27/01/2009.
 */

#import <Foundation/NSData.h>
#import "NSString.h"
#import "FileLoaders.h"

// NSData and NSMutableData are declared in CoreFoundation but their methods are implemented in a category here.
// __NSCFData is declared and implemented in CoreFoundation and is the actual bridged class

@implementation NSData (NSData)

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
    return [(id)PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, NO, NULL) autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    return [(id)PFDataInitFromURL((CFURLRef)url, readOptionsMask, NO, (CFErrorRef *)errorPtr) autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path {
    return [(id)PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, NO, NULL) autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    return [(id)PFDataInitFromPath((CFStringRef)path, readOptionsMask, NO, (CFErrorRef *)errorPtr) autorelease];
}

+ (id)dataWithContentsOfMappedFile:(NSString *)path {
    return [(id)PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, NO, NULL) autorelease];
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

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length deallocator:(void (^)(void *, NSUInteger))deallocator {
    free(self);
    dispatch_data_t data = dispatch_data_create(bytes, length, dispatch_get_main_queue(), ^{
        deallocator(bytes, length);
    });
    return (id)data;
}

- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, readOptionsMask, NO, (CFErrorRef *)errorPtr);
}

- (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    return (id)PFDataInitFromURL((CFURLRef)url, readOptionsMask, NO, (CFErrorRef *)errorPtr);
}

- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, NO, NULL);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, NO, NULL);
}

- (id)initWithContentsOfMappedFile:(NSString *)path {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, NO, NULL);
}

- (id)initWithData:(NSData *)data {
    free(self);
    return (id)CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)data);
}

@end


@implementation NSMutableData (NSMutableData)

#pragma mark - mutable factory methods

+ (id)data {
    return [(id)CFDataCreateMutable(kCFAllocatorDefault, 0) autorelease];
}

+ (instancetype)dataWithCapacity:(NSUInteger)capacity {
    return [(id)CFDataCreateMutable(kCFAllocatorDefault, capacity) autorelease];
}

+ (instancetype)dataWithLength:(NSUInteger)length {
    CFMutableDataRef mData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(mData, length);
    return [(id)mData autorelease];
}

+ (instancetype)dataWithBytes:(const void *)bytes length:(NSUInteger)length {
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    return [(id)mData autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length {
    // As per the documentation, when creating NSMutableData, `NoCopy` is ignored and the data is copied immediately
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    if (bytes) {
        free(bytes);
    }
    return [(id)mData autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone {
    // As per the documentation, when creating NSMutableData, `NoCopy` is ignored and the data is copied immediately
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
    CFRelease(data);
    if (freeWhenDone && bytes) {
        free(bytes);
    }
    return [(id)mData autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url {
    return [(id)PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, YES, NULL) autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    return [(id)PFDataInitFromURL((CFURLRef)url, readOptionsMask, YES, (CFErrorRef *)errorPtr) autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path {
    return [(id)PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, YES, NULL) autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    return [(id)PFDataInitFromPath((CFStringRef)path, readOptionsMask, YES, (CFErrorRef *)errorPtr) autorelease];
}

+ (id)dataWithContentsOfMappedFile:(NSString *)path {
    return [(id)PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, YES, NULL) autorelease];
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
    CFMutableDataRef mData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(mData, length);
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
    // As per the documentation, when creating NSMutableData, `NoCopy` is ignored and the data is copied immediately
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, data);
    CFRelease(data);
    if (bytes) {
        free(bytes);
    }
    return (id)mData;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone  {
    free(self);
    // As per the documentation, when creating NSMutableData, `NoCopy` is ignored and the data is copied immediately
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, data);
    CFRelease(data);
    if (freeWhenDone && bytes) {
        free(bytes);
    }
    return (id)mData;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length deallocator:(void (^)(void *, NSUInteger))deallocator {
    free(self);
    // As per the documentation, when creating NSMutableData, `NoCopy` is ignored and the data is copied immediately
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)bytes, length);
    CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, data);
    CFRelease(data);
    deallocator(bytes, length);
    return (id)mData;
}

- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, readOptionsMask, YES, (CFErrorRef *)errorPtr);
}

- (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr {
    free(self);
    return (id)PFDataInitFromURL((CFURLRef)url, readOptionsMask, YES, (CFErrorRef *)errorPtr);
}

- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, NSDataReadingUncached, YES, NULL);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFDataInitFromURL((CFURLRef)url, NSDataReadingUncached, YES, NULL);
}

- (id)initWithContentsOfMappedFile:(NSString *)path {
    free(self);
    return (id)PFDataInitFromPath((CFStringRef)path, NSDataReadingMappedAlways, YES, NULL);
}

- (id)initWithData:(NSData *)data {
    free(self);
    return (id)CFDataCreateMutableCopy(kCFAllocatorDefault, 0, (CFDataRef)data);
}

#pragma mark - mutable instance method prototypes

- (void *)mutableBytes { return NULL; }
- (void)setLength:(NSUInteger)length {}

@end
