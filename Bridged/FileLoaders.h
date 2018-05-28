//
//  FileLoaders.h
//  Foundation
//
//  Created by Stuart Crook on 27/05/2018.
//

#import <CoreFoundation/CoreFoundation.h>

static CFPropertyListRef PFPropertyListInitFromURL(CFURLRef url, Boolean mutable);
static CFPropertyListRef PFPropertyListInitFromPath(CFStringRef path, Boolean mutable);
static BOOL PFPropertyListSaveToURL(CFPropertyListRef item, CFURLRef url, BOOL atomically, CFErrorRef *error);
static BOOL PFPropertyListSaveToPath(CFPropertyListRef list, CFStringRef path, BOOL atomically, CFErrorRef *error);
