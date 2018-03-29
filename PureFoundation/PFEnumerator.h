/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFEnumerators.h
 *
 *	PFEnumerator, PFReverseEnumerator
 *
 *	Created by Stuart Crook on 04/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/Foundation.h>

@class NSArray, NSDictionary, NSSet;

/*
 *	A generic forward-moving object enumerator
 */
@interface PFEnumerator : NSEnumerator
{
	id _collection;			// whichever collection we're enumerating
	NSUInteger _count;		// number of items in the collection
	NSUInteger _position;	// number of items served-up so far
	id *_storage;			// pointer to the malloced block of memory
	id *_location;			// pointer to our current location in the _storage memory
}

- (id)initWithCFArray: (NSArray *)array;
- (id)initWithCFDictionaryKeys: (NSDictionary *)dict;
- (id)initWithCFDictionaryValues: (NSDictionary *)dict;
- (id)initWithCFSet: (NSSet *)set;

- (void)dealloc;

- (id)nextObject;
- (NSArray *)allObjects;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end


/*
 *	A backwards-moving object enumerator, optomised for fat set-up and normal 
 *	-nextObject useage
 */
@interface PFReverseEnumerator : PFEnumerator

- (id)initWithCFArray: (NSArray *)array;

- (id)nextObject;
- (NSArray *)allObjects;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end

