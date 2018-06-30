/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSDate.m
 *
 *	NSDate, NSCFDate
 *
 *	Created by Stuart Crook on 02/02/2009.
 */

#import "NSDate.h"

@implementation NSDate (NSDate)

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder *)aCoder {}

- (id)initWithCoder:(NSCoder *)aDecoder {
    free(self);
    return nil;
}

@end

@implementation NSDate (NSNaturalLanguageDate)

+ (id)dateWithNaturalLanguageString:(NSString *)string {
    PF_TODO
    return nil;
}

+ (id)dateWithNaturalLanguageString:(NSString *)string locale:(id)locale {
    PF_TODO
    return nil;
}

@end
