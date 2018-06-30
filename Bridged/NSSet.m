/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSSet.m
 *
 *	NSSet, NSMutableSet, NSCFSet
 *
 *	Created by Stuart Crook on 26/01/2009.
 */

#import <Foundation/NSSet.h>

// Most of NSSet is implemented in CF, as a bridge to CFSetRef. Only coding is implemented in Foundation.

@implementation NSSet (NSSet)

+ (BOOL)supportsSecureCoding { return  YES; }
- (void)encodeWithCoder:(NSCoder *)aCoder {}
- (id)initWithCoder:(NSCoder *)aDecoder {
    return nil;
}

@end
