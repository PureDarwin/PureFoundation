/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSConditionLock.m
 *
 *	NSConditionLock
 *
 *	Created by Stuart Crook on 16/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSLock.h"

/*
 *	ivar:    void *_priv;
 */
@implementation NSConditionLock

- (id)initWithCondition:(NSInteger)condition {}

- (void)lock {}
- (void)unlock {}

- (NSInteger)condition {}
- (void)lockWhenCondition:(NSInteger)condition {}
- (BOOL)tryLock {}
- (BOOL)tryLockWhenCondition:(NSInteger)condition {}
- (void)unlockWithCondition:(NSInteger)condition {}
- (BOOL)lockBeforeDate:(NSDate *)limit {}
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit {}

- (void)setName:(NSString *)n {}
- (NSString *)name {}

@end
