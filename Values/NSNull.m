/*
 *  PureFoundation -- http://www.puredarwin.org
 *  NSNull.m
 *
 *  NSNull
 *  Bridged to CFNull
 *
 *  Created by Stuart Crook on 29/01/2009.
 *  LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSNull.h"

@implementation NSNull

+ (instancetype)alloc {
    return (id)kCFNull;
}

+ (NSNull *)null {
    return (id)kCFNull;
}

- (NSString *)description {
	return @"<null>";
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    PF_TODO
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	return self;
}

@end
