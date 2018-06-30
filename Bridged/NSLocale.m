/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSLocale.m
 *
 *	NSLocale
 *
 *	Created by Stuart Crook on 02/02/2009.
 */

#import "NSLocale.h"

// NSLocale is implemented in CF. Only the auto-updating NSLocale is implemented in Foundation.

@implementation NSLocale (NSLocale)

// TODO
+ (id)autoupdatingCurrentLocale {
    return [(id)CFLocaleCopyCurrent() autorelease];
}

@end
