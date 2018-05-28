//
//  FileLoaders.m
//  Foundation
//
//  Created by Stuart Crook on 27/05/2018.
//

#import "FileLoaders.h"

// Attempts to load a plist from a file URL
static CFPropertyListRef PFPropertyListInitFromURL(CFURLRef url, Boolean mutable) {
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

static CFPropertyListRef PFPropertyListInitFromPath(CFStringRef path, Boolean mutable) {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    CFPropertyListRef list = PFPropertyListInitFromURL(url, mutable);
    CFRelease(url);
    return list;
}

// Attempts to save to a plist
static BOOL PFPropertyListSaveToURL(CFPropertyListRef item, CFURLRef url, BOOL atomically, CFErrorRef *error) {
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

static BOOL PFPropertyListSaveToPath(CFPropertyListRef list, CFStringRef path, BOOL atomically, CFErrorRef *error) {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    BOOL result = PFPropertyListSaveToURL(list, url, atomically, error);
    CFRelease(url);
    return result;
}

