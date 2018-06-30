/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSTimeZone.m
 *
 *	NSTimerZone, NSCFTimeZone
 *
 *	Created by Stuart Crook on 02/02/2009.
 */

#import "NSTimeZone.h"

@implementation NSTimeZone (NSTimeZone)

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    PF_TODO
    free(self);
    return nil;
}

// TODO:
//  + classForCoder:

@end
