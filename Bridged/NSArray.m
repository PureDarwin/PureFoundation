/*
 *	PureFoundation -- http://www.puredarwin.org
 *	NSArray.m
 *
 *	NSArray, NSMutableArray, __NSCFArray
 *
 *	Created by Stuart Crook on 26/01/2009.
 */

#import "Foundation/NSArray.h"
#import "PureFoundation.h"
#import "FileLoaders.h"

// Most of NSArray and NSMutableArray are implemented in CoreFoundation

@implementation NSArray (NSArray)

+ (id)arrayWithContentsOfFile:(NSString *)path {
    return [(id)PFPropertyListInitFromPath((CFStringRef)path, false) autorelease];
}

+ (id)arrayWithContentsOfURL:(NSURL *)url {
    return [(id)PFPropertyListInitFromURL((CFURLRef)url, false) autorelease];
}

// TODO:
// t +[NSArray(NSArray) arrayWithContentsOfURL:error:]
// t +[NSArray(NSArray) newWithContentsOf:immutable:]

- (instancetype)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFPropertyListInitFromPath((CFStringRef)path, false);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFPropertyListInitFromURL((CFURLRef)url, true);
}

// TODO:
// t -[NSArray(NSArray) initWithContentsOfURL:error:]

@end

@implementation NSMutableArray (NSMutableArray)

+ (instancetype)arrayWithContentsOfFile:(NSString *)path {
    return [(id)PFPropertyListInitFromPath((CFStringRef)path, true) autorelease];
}

+ (instancetype)arrayWithContentsOfURL:(NSURL *)url {
    return [(id)PFPropertyListInitFromURL((CFURLRef)url, true) autorelease];
}

// TODO:
// t +[NSMutableArray(NSSMutableArray) arrayWithContentsOfURL:error:]
// t +[NSSMutableArray(NSSMutableArray) newWithContentsOf:immutable:]

- (instancetype)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFPropertyListInitFromPath((CFStringRef)path, true);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFPropertyListInitFromURL((CFURLRef)url, true);
}

// TODO:
// t -[NSSMutableArray(NSSMutableArray) initWithContentsOfURL:error:]

@end




