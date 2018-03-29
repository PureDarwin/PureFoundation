/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSNull.m
 *
 *	NSNull
 *
 *	Created by Stuart Crook on 29/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSNull.h"


/*
 *	We implement NSNull's singelton in the same way as our bridged class dummies
 */
static Class _PFNull = nil;

@implementation NSNull

+(void)initialize
{
	if( self == [NSNull class] )
		_PFNull = [NSNull class];
}

+(id)alloc
{
	return (id)&_PFNull;
}

+(NSNull *)null
{
	return (id)&_PFNull;
}

-(NSString *)description
{
	return @"<null>";
}

-(id)copyWithZone:(NSZone *)zone
{
	return self;
}

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

@end
