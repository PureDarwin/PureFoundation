/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSCondition.m
 *
 *	NSCondition
 *
 *	Created by Stuart Crook on 16/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSLock.h"

/*
 *	ivar:    void *_priv;
 */
@implementation NSCondition

- (void)lock {}
- (void)unlock {}

- (void)wait {}
- (BOOL)waitUntilDate:(NSDate *)limit {}
- (void)signal {}
- (void)broadcast {}

- (void)setName:(NSString *)n {}
- (NSString *)name {}

@end
