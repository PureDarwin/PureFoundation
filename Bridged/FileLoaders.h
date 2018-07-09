//
//  FileLoaders.h
//  Foundation
//
//  Created by Stuart Crook on 27/05/2018.
//

#import <CoreFoundation/CoreFoundation.h>

CFPropertyListRef PFPropertyListInitFromURL(CFURLRef url, Boolean mutable);
CFPropertyListRef PFPropertyListInitFromPath(CFStringRef path, Boolean mutable);

BOOL PFPropertyListWriteToURL(CFPropertyListRef item, CFURLRef url, BOOL atomically, CFErrorRef *error);
BOOL PFPropertyListWriteToPath(CFPropertyListRef list, CFStringRef path, BOOL atomically, CFErrorRef *error);

// This version should be able to deal with data:// URLs and server URLs
CFDataRef PFDataInitFromURL(CFURLRef url, NSDataReadingOptions options, BOOL mutable, CFErrorRef *error);
CFDataRef PFDataInitFromPath(CFStringRef path, NSDataReadingOptions options, BOOL mutable, CFErrorRef *error);

BOOL PFDataWriteToURL(CFDataRef data, CFURLRef url, NSDataWritingOptions options, CFErrorRef *error);
BOOL PFDataWriteToPath(CFDataRef data, CFStringRef path, NSDataWritingOptions options, CFErrorRef *error);
