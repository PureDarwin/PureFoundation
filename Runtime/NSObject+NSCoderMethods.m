/*
 *  PureFoundation -- http://www.puredarwin.org
 *  NSObject+NSCoderMethods.m
 *
 *  Created by Stuart Crook on 08/01/2009.
 *  LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSObject.h"


@implementation NSObject (NSCoderMethods)

+ (NSInteger)version {
	return (NSInteger)class_getVersion((Class)self);
}

+ (void)setVersion:(NSInteger)aVersion {
	class_setVersion((Class)self, aVersion);
}

- (Class)classForCoder {
    return [self class];
}

- (id)replacementObjectForCoder:(NSCoder *)aCoder {
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return self;
}

@end
