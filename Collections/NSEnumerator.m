/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSEnumerator.m
 *
 *	NSEnumerator
 *
 *	Created by Stuart Crook on 05/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSEnumerator.h"

@implementation NSEnumerator
- (id)nextObject { return nil; }
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len { return 0; }
@end
