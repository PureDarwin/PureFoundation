//
//  FileLoaders.m
//  Foundation
//
//  Created by Stuart Crook on 27/05/2018.
//

#import "FileLoaders.h"

#include <sys/stat.h>
#include <sys/mman.h>

// Attempts to load a plist from a file URL
CFPropertyListRef PFPropertyListInitFromURL(CFURLRef url, Boolean mutable) {
    CFReadStreamRef stream = CFReadStreamCreateWithFile(kCFAllocatorDefault, url);
    if (!stream) {
        // TODO: Logging
        return NULL;
    }
    CFErrorRef error = NULL;
    CFOptionFlags options = mutable ? kCFPropertyListMutableContainers : kCFPropertyListImmutable;
    CFPropertyListRef list = CFPropertyListCreateWithStream(kCFAllocatorDefault, stream, 0, options, NULL, &error);
    if (error) {
        // TODO: Logging
        CFRelease(error);
    }
    CFRelease(stream);
    return list;
}

CFPropertyListRef PFPropertyListInitFromPath(CFStringRef path, Boolean mutable) {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    CFPropertyListRef list = PFPropertyListInitFromURL(url, mutable);
    CFRelease(url);
    return list;
}

// TODO: Implement atomic saving for these methods

// Attempts to save to a plist
BOOL PFPropertyListWriteToURL(CFPropertyListRef item, CFURLRef url, BOOL atomically, CFErrorRef *error) {
    CFWriteStreamRef stream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, url);
    if (!stream) {
        // TODO: Logging
        // TODO: Create and return an error
        return NO;
    }
    CFPropertyListFormat format = kCFPropertyListXMLFormat_v1_0;
    CFIndex length = CFPropertyListWrite(item, stream, format, 0, error);
    CFRelease(stream);
    return length ? YES : NO;
}

BOOL PFPropertyListWriteToPath(CFPropertyListRef list, CFStringRef path, BOOL atomically, CFErrorRef *error) {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    BOOL result = PFPropertyListWriteToURL(list, url, atomically, error);
    CFRelease(url);
    return result;
}

// This version should be able to deal with data:// URLs and server URLs
CFDataRef PFDataInitFromURL(CFURLRef url, NSDataReadingOptions options, BOOL mutable, CFErrorRef *error) {
    CFDataRef data = NULL;
    CFStringRef scheme = CFURLCopyScheme(url);
    if (CFEqual((CFTypeRef)scheme, CFSTR("file"))) {
        data = PFDataInitFromPath(CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle), mutable, options, error);
    }
    // TODO: Implement data:// schemes
    // TODO: Implement sync URL loading of network files

    CFRelease(scheme);
    return data;
}

#define MaxPathSize 1024

CFDataRef PFDataInitFromPath(CFStringRef path, NSDataReadingOptions options, BOOL mutable, CFErrorRef *error) {

    char filepath[MaxPathSize];
    if (!CFStringGetCString(path, filepath, MaxPathSize, kCFStringEncodingUTF8)) return NULL;

    if (mutable) {
        // Mutable data objects are never created from mmapped files
        options &= NSDataReadingUncached;
    }
    
    int fd = open(filepath, O_RDONLY);
    if (fd == -1) {
        if (error) *error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, NULL);
        return NULL;
    }
    struct stat st;
    if(fstat(fd, &st)) {
        if (error) *error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, NULL);
        close(fd);
        return NULL;
    }
    size_t length = st.st_size;
    
    if (options & (NSDataReadingMapped|NSDataReadingMappedIfSafe)) {
        void *ptr = mmap(NULL, length, PROT_READ, MAP_FILE|MAP_SHARED, fd, 0);
        if (ptr == MAP_FAILED) {
            if (error) *error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, NULL);
            close(fd);
            return NULL;
        }
        // Wrap the mapped memory into a data object
        dispatch_data_t data = dispatch_data_create(ptr, length, dispatch_get_main_queue(), ^{
            if (munmap(ptr, length)) {
                fprintf(stderr, "munmap() mapped data failed, ptr: %p errno: %d", ptr, errno);
            }
        });
        close(fd);
        return (void *)data;
    }

    UInt8 *buffer = malloc(length);
    if (!buffer) {
        if (errno) *error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, NULL);
        close(fd);
        return NULL;
    }
    if (read(fd, buffer, length) == -1) {
        if (error) *error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, NULL);
        close(fd);
        return NULL;
    }
    close(fd);
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)buffer, length, kCFAllocatorDefault);
    if (mutable) {
        CFMutableDataRef mData = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, data);
        CFRelease(data);
        data = (CFDataRef)mData;
    }
    return data;
}

BOOL PFDataWriteToURL(CFDataRef data, CFURLRef url, NSDataWritingOptions options, CFErrorRef *error) {
    BOOL result = NO;
    CFStringRef scheme = CFURLCopyScheme(url);
    if (CFEqual((CFTypeRef)scheme, CFSTR("file"))) {
        result = PFDataWriteToPath(data, CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle), options, error);
    }
    CFRelease(scheme);
    return result;
}

BOOL PFDataWriteToPath(CFDataRef data, CFStringRef path, NSDataWritingOptions options, CFErrorRef *error) {
    
    CFIndex length = CFDataGetLength(data);
    if (!length) return NO;
    
    char filepath[MaxPathSize];
    if (!CFStringGetCString(path, filepath, MaxPathSize, kCFStringEncodingUTF8)) return NO;

    FILE *fh = fopen(filepath, "w");
    if (!fh) {
        if (error) *error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, NULL);
        return NO;
    }
    BOOL result = YES;
    if (fwrite(CFDataGetBytePtr(data), 1, length, fh) != length && ferror(fh)) {
        if (error) *error = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainPOSIX, ferror(fh), NULL);
        result = NO;
    }
    fclose(fh);
    return result;
}

#undef MaxPathSize
