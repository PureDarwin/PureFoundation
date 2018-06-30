/*
 *	PureFoundation -- http://puredarwin.org
 *	NSDictionary.m
 *
 *	NSDictionary, NSMutableDictionary, NSCFDictionary
 *
 *	Created by Stuart Crook on 26/01/2009.
 */

#import <Foundation/NSDictionary.h>
#import "PureFoundation.h"
#import "FileLoaders.h"

#define KEY_CALLBACKS (&kCFTypeDictionaryKeyCallBacks)
#define VALUE_CALLBACKS ((CFDictionaryValueCallBacks *)&_PFCollectionCallBacks)

#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)


@implementation NSDictionary (NSDictionary)

#pragma mark - immutable factory methods

+ (id)dictionaryWithContentsOfFile:(NSString *)path {
    return [(id)PFPropertyListInitFromPath((CFStringRef)path, false) autorelease];
}

+ (id)dictionaryWithContentsOfURL:(NSURL *)url {
    return [(id)PFPropertyListInitFromURL((CFURLRef)url, false) autorelease];
}

// TODO:
// t +[NSDictionary(NSDictionary) dictionaryWithContentsOfURL:error:]
// t +[NSDictionary(NSDictionary) newWithContentsOf:immutable:]

#pragma mark - immutable init methods

- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFPropertyListInitFromPath((CFStringRef)path, false);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFPropertyListInitFromURL((CFURLRef)url, false);
}

// TODO:
// t -[NSDictionary(NSDictionary) initWithContentsOfURL:error:]

@end


@implementation NSMutableDictionary (NSMutableDictionary)

#pragma mark - mutable factory methods

+ (id)dictionaryWithContentsOfFile:(NSString *)path {
    return [(id)PFPropertyListInitFromPath((CFStringRef)path, true) autorelease];
}

+ (id)dictionaryWithContentsOfURL:(NSURL *)url {
    return [(id)PFPropertyListInitFromURL((CFURLRef)url, true) autorelease];
}

// TODO:
// t +[NSDictionary(NSDictionary) dictionaryWithContentsOfURL:error:]
// t +[NSDictionary(NSDictionary) newWithContentsOf:immutable:]

#pragma mark - mutable initialisers


- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFPropertyListInitFromPath((CFStringRef)path, true);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFPropertyListInitFromURL((CFURLRef)url, true);
}

// TODO:
// t -[NSDictionary(NSDictionary) initWithContentsOfURL:error:]

@end

#undef KEY_CALLBACKS
#undef VALUE_CALLBACKS
#undef ARRAY_CALLBACKS
