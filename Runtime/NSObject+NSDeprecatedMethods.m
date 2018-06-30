//
//  PureFoundation -- http://www.puredarwin.org
//  NSObject+NSDeprecatedMethods.m
//
//  Created by Stuart Crook on 08/04/2018.
//  LGPL'd. See LICENCE.txt for copyright information.
//

#import "NSObject.h"

#include <objc/runtime.h>

@implementation NSObject (NSDeprecatedMethods)

+ (void)poseAsClass:(Class)aClass {
    class_poseAs(self, aClass);
}

@end


