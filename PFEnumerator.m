/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFEnumerators.m
 *
 *	PFEnumerator, PFReverseEnumerator
 *
 *	Created by Stuart Crook on 04/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "PFEnumerator.h"
#import "PureFoundation.h"

/*
 *	A generic forward-moving object enumerator
 *
 *	Since the array, dictionary and set objects are responsible for vending their own
 *	enumerators, we can make these specific to the bridged CF objects, which with any
 *	luck will yield some speed gains.
 */
@implementation PFEnumerator

- (id)initWithCFArray: (NSArray *)array
{
	PF_HELLO("")
	if( self = [super init] )
	{
		_collection = [array retain];
		_count = [array count];
		if( _count != 0 )
		{
			_storage = NSZoneCalloc( nil, _count, sizeof(id) );
			CFRange range = CFRangeMake( 0, _count );
			CFArrayGetValues( (CFArrayRef)array, range, (const void **)_storage );
			_location = _storage;
		}
		_position = 0;
	}
	return self;
}

- (id)initWithCFDictionaryKeys: (NSDictionary *)dict
{
	if( self = [super init] )
	{
		_collection = [dict retain];
		_count = [dict count];
		if( _count != 0 )
		{
			_storage = NSZoneCalloc( nil, _count, sizeof(id) );
			CFDictionaryGetKeysAndValues( (CFDictionaryRef)dict, (const void**)_storage, NULL );
			_location = _storage;
		}
		_position = 0;		
	}
	return self;
}

- (id)initWithCFDictionaryValues: (NSDictionary *)dict
{
	if( self = [super init] )
	{
		_collection = [dict retain];
		_count = [dict count];
		if( _count != 0 )
		{
			_storage = NSZoneCalloc( nil, _count, sizeof(id) );
			CFDictionaryGetKeysAndValues( (CFDictionaryRef)dict, NULL, (const void**)_storage );
			_location = _storage;
		}
		_position = 0;				
	}
	return self;
}

- (id)initWithCFSet: (NSSet *)set
{
	if( self = [super init] )
	{
		_collection = [set retain];
		_count = [set count];
		if( _count != 0 )
		{
			_storage = NSZoneCalloc( nil, _count, sizeof(id) );
			CFSetGetValues( (CFSetRef)set, (const void**)_storage );
			_location = _storage;
		}
		_position = 0;						
	}
	return self;
}

- (void)dealloc
{
	NSZoneFree( nil, _storage );
	[_collection autorelease];
	[super dealloc];
}

- (id)nextObject
{
	if( _position == _count ) 
		return nil;
	_position++;
	return *_location++;
}

- (NSArray *)allObjects
{
	if( _position == _count )
		return [NSArray array];
	CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void**)_location, (_count - _position), (CFArrayCallBacks *)&_PFCollectionCallBacks );
	_position = _count;
	PF_RETURN_TEMP(array)
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{	
	/* Calculate the number of objects left to enumerate over. Unlike the other collection
		fast-enumerators, we use our own counter (_position) to track where we are and leave
		the state->state alone.
	 
		Hmm... I wonder what should happen if you interupted a fast-enumerated enumerator... */
	NSUInteger num = _count - _position;

	if( num != 0 )
	{
		num = (len < num) ? len : num; // number of items to copy
		
		id *buffer = stackbuf;
		int i = num;
		while( i-- )
			*buffer++ = *_location++;
		
		_position += num;
		
		// set the return values
		state->itemsPtr = stackbuf;
		state->mutationsPtr = (unsigned long *)self;
	}
	return num;
}

@end


/*
 *	A backwards-moving object enumerator, optomised for fat set-up and normal 
 *	-nextObject useage
 */
@implementation PFReverseEnumerator

- (id)initWithCFArray: (NSArray *)array
{
	PF_HELLO("")
	if( self = [super init] )
	{
		_collection = [array retain];
		_count = [array count];
		if( _count != 0 )
		{
			_storage = NSZoneCalloc( nil, _count, sizeof(id) );
			CFRange range = CFRangeMake( 0, _count );
			CFArrayGetValues( (CFArrayRef)array, range, (const void **)_storage );
			_location = _storage + _count; // + (_count * sizeof(id *)); 
			/*
			 *	Oh, you have got to be fucking kidding me. Since when did adding to a pointer
			 *	increase it by that * pointer size? Why isn't that written in big flashing letters
			 *	on the front of the compiler?
			 */
		}
		_position = 0;
	}
	return self;
}

- (id)nextObject
{
	//PF_HELLO("")
	if( _position == _count ) 
		return nil;
	_position++;
	return *--_location;
}

- (NSArray *)allObjects
{
	if( _position == _count )
		return [NSArray array];

	NSUInteger num = _count - _position; // number of objects left
	id *buffer = NSZoneCalloc( nil, num, sizeof(void *) );
	id *ptr = buffer;

	while( num-- )
		*ptr++ = *--_location;
	
	CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void**)buffer, (_count - _position), (CFArrayCallBacks *)&_PFCollectionCallBacks );
	
	_position = _count;
	NSZoneFree( nil, buffer );
	PF_RETURN_TEMP(array)
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
	NSUInteger num = _count - _position;
	
	if( num != 0 )
	{
		num = (len < num) ? len : num; // number of items to copy
		
		id *buffer = stackbuf;
		int i = num;
		while( i-- )
			*buffer++ = *--_location;
		
		_position += num;
		
		// set the return values
		state->itemsPtr = stackbuf;
		state->mutationsPtr = (unsigned long *)self;
	}
	return num;
}

@end
