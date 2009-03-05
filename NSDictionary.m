/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSDictionary.m
 *
 *	NSDictionary, NSMutableDictionary, NSCFDictionary
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSDictionary.h>
#import "PFEnumerator.h"
#import "PureFoundation.h"

//#import "../CF-476.15.patched/CFDictionary.h"

/*
 *	Declare the interface for the bridged NSCFDisctionary class
 */
@interface NSCFDictionary : NSMutableDictionary
@end

/*
 *	Macro to check for our dummy NSCFData object
 */
extern bool _CFDictionaryIsMutable( CFDictionaryRef dict );

#define PF_CHECK_DICT(dict) BOOL isMutable; \
	if( dict == (id)&_PFNSCFDictionaryClass ) isMutable = NO; \
	else if( dict == (id)&_PFNSCFMutableDictionaryClass ) isMutable = YES; \
	else { isMutable = _CFDictionaryIsMutable((CFDictionaryRef)dict); [dict autorelease]; }

#define PF_RETURN_DICT_INIT if( isMutable == YES ) { [self autorelease]; self = (id)CFDictionaryCreateMutableCopy( kCFAllocatorDefault, 0, (CFDictionaryRef)self ); } \
	PF_RETURN_NEW(self)

#define PF_CHECK_DICT_MUTABLE(dict) if( !_CFDictionaryIsMutable((CFDictionaryRef)dict) ) \
	[NSException raise: NSInvalidArgumentException format: @"Attempting mutable dictionary op on a static NSDictionary"];


/*
 *	Dummy NSCFDictionary object
 */
static Class _PFNSCFDictionaryClass = nil;
static Class _PFNSCFMutableDictionaryClass = nil;


/*
 *	Various applied functions
 */
// find objects where isEqual: context[1] and put them into context[2]
void _PFKeysForObject( const void *key, const void *value, void *context );
void _PFKeysForObject( const void *key, const void *value, void *context )
{
	if( [(id)value isEqual: ((id *)context)[0]] )
		CFArrayAppendValue((CFMutableArrayRef)((CFMutableArrayRef *)context)[1], key);
}





/*
 *	The immutable dictionary class
 */
@implementation NSDictionary

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSDictionary class] )
		_PFNSCFDictionaryClass = objc_getClass("NSCFDictionary");
}

/*
 *	New bridged class +alloc design which I should really copy across into other bridged classes.
 *	It checks that the recepient is of one of the stated classes, and if not just makes the same
 *	call as NSObject+alloc
 */
+(id)alloc
{
	PF_HELLO("")
	if( self == [NSDictionary class] )
		return (id)&_PFNSCFDictionaryClass;
	return [super alloc];
}

/*
 *	NSDictionary creation methods
 */
+ (id)dictionary 
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease];
	// these NULL callback values don't matter because it won't be holding anything
	CFDictionaryRef dict = CFDictionaryCreate( kCFAllocatorDefault, NULL, NULL, 0, NULL, NULL );
	PF_RETURN_TEMP(dict)
}

+ (id)dictionaryWithObject:(id)object forKey:(id)key 
{
	PF_HELLO("")
	return [[[self alloc] initWithObjects: &object forKeys: &key count: 1] autorelease];
}

+ (id)dictionaryWithObjects:(id *)objects forKeys:(id *)keys count:(NSUInteger)cnt 
{
	PF_HELLO("")
	return [[[self alloc] initWithObjects: objects forKeys: keys count: cnt] autorelease];
}

/*
 *	Ah. Now this is a pain, isn't it?
 */
+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... 
{
	PF_HELLO("")
	
	if( firstObject == nil ) return nil; // throw an invalid argument exception?
	
	id *ptr1;
	id *ptr2;
	id *t_ptr1;
	id *t_ptr2;
	id temp;
	
	va_list args;
	va_start( args, firstObject );
	
	NSUInteger count = 1; // firstObject
	while( (temp = va_arg( args, id )) != nil ) count++;
	
	// if we got an odd number of arguments, throw an exception
	if( (count & 1) == 1 )
		[NSException raise: NSInvalidArgumentException format: nil];
	
	ptr1 = calloc( count, sizeof(id) );
	count /= 2;
	ptr2 = ptr1 + count;
	t_ptr1 = ptr1;
	t_ptr2 = ptr2;
	
	va_start( args, firstObject );
	
	// copy the args into the two buffers
	*t_ptr1++ = firstObject;
	*t_ptr2++ = va_arg( args, id );
	while( (temp = va_arg( args, id )) != nil )
	{
		*t_ptr1++ = temp;
		*t_ptr2++ = va_arg( args, id );
	}
	
	CFDictionaryRef new = CFDictionaryCreate( kCFAllocatorDefault, (const void **)ptr2, (const void **)ptr1, count, &kCFTypeDictionaryKeyCallBacks, (CFDictionaryValueCallBacks *)&_PFCollectionCallBacks );

	va_end( args );
	free( ptr1 );
	PF_RETURN_TEMP(new)
}

+ (id)dictionaryWithDictionary:(NSDictionary *)dict 
{
	PF_HELLO("")
	return [[[self alloc] initWithDictionary: dict] autorelease];
}

+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys 
{
	PF_HELLO("")
	return [[[self alloc] initWithObjects: objects forKeys: keys] autorelease];
}

+ (id)dictionaryWithContentsOfFile:(NSString *)path 
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfFile: path] autorelease];
}

+ (id)dictionaryWithContentsOfURL:(NSURL *)url 
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfURL: url] autorelease];
}


/*
 *	NSDictionary instance methods for the compiler
 */
- (NSUInteger)count
{
	PF_HELLO("")
	return 0;
}
- (id)objectForKey:(id)aKey
{
	PF_HELLO("")
	return nil;
}
- (NSEnumerator *)keyEnumerator
{
	PF_HELLO("")
	return nil;
}



/**	NSCopying COMPLIANCE **/

/*
 *	Return nil, because NSString should never be instatitated
 */
- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}

/** NSMutableCopying COMPLIANCE **/

/*
 *	Create an NSCFMutableString
 */
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return nil;
}

/**	NSCoding COMPLIANCE **/
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return nil;
}

/** NSFastEnumeration compliance **/
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
	return 0;
}

@end





/*
 *	NSMutableDictionary implementation
 */
@implementation NSMutableDictionary

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSMutableDictionary class] )
		_PFNSCFMutableDictionaryClass = objc_getClass("NSCFDictionary");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSMutableDictionary class] )
		return (id)&_PFNSCFMutableDictionaryClass;
	return [super alloc];
}

/*
 *	NSMutableDictionary creation methods
 *
 *	Capacity is ignored, unless we can find a hinting function
 */
+ (id)dictionaryWithCapacity:(NSUInteger)numItems 
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease];
	CFMutableDictionaryRef new = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	// dictionary capacity hint ???
	PF_RETURN_TEMP(new)
}

/*
 *	NSDictionary creation methods
 *
 *	Hmm... with the mutable/immutable logic moved into the init functions, these seem to just
 *	repeate the NSDictionary class methods above. Could be removed?
 */
+ (id)dictionary 
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease];
	CFMutableDictionaryRef new = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	PF_RETURN_TEMP(new)
}

//+ (id)dictionaryWithObject:(id)object forKey:(id)key 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithObjects: &object forKeys: &key count: 1] autorelease];
//}

//+ (id)dictionaryWithObjects:(id *)objects forKeys:(id *)keys count:(NSUInteger)cnt 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithObjects: objects forKeys: keys count: cnt] autorelease];
//}

/*
 *	This is a cut-and-paste redo because varadic params are a pain
 */
+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... 
{
	PF_HELLO("")
	
	if( firstObject == nil ) return nil; // throw an invalid argument exception?
	
	id *ptr1;
	id *ptr2;
	id *t_ptr1;
	id *t_ptr2;
	id temp;
	
	va_list args;
	va_start( args, firstObject );
	
	NSUInteger count = 1; // firstObject
	while( (temp = va_arg( args, id )) != nil ) count++;
	
	// if we got an odd number of arguments, throw an exception
	if( (count & 1) == 1 )
		[NSException raise: NSInvalidArgumentException format: nil];
	
	ptr1 = calloc( count, sizeof(id) );
	count /= 2;
	ptr2 = ptr1 + count;
	t_ptr1 = ptr1;
	t_ptr2 = ptr2;
	
	va_start( args, firstObject );
	
	// copy the args into the two buffers
	*t_ptr1++ = firstObject;
	*t_ptr2++ = va_arg( args, id );
	while( (temp = va_arg( args, id )) != nil )
	{
		*t_ptr1++ = temp;
		*t_ptr2++ = va_arg( args, id );
	}
	
	CFDictionaryRef new = CFDictionaryCreate( kCFAllocatorDefault, (const void **)ptr2, (const void **)ptr1, count, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	CFDictionaryRef mew = CFDictionaryCreateMutableCopy( kCFAllocatorDefault, 0, new );
	[(id)new release];
	
	va_end( args );
	free( ptr1 );
	PF_RETURN_TEMP(mew)
}

//+ (id)dictionaryWithDictionary:(NSDictionary *)dict 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithDictionary: dict] autorelease];
//}

//+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithObjects: objects forKeys: keys] autorelease];
//}

//+ (id)dictionaryWithContentsOfFile:(NSString *)path 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithContentsOfFile: path] autorelease];
//}

//+ (id)dictionaryWithContentsOfURL:(NSURL *)url 
//{
//	PF_HELLO("")
//	return [[[self alloc] initWithContentsOfURL: url] autorelease];
//}

/*
 *	NSMutableDictionary instance methods
 */
- (void)removeObjectForKey:(id)aKey {}
- (void)setObject:(id)anObject forKey:(id)aKey {}


@end




/*
 *	NSCFDictionary bridged class implementation
 */
@implementation NSCFDictionary

/*
 *	Object maintenance
 */
//+(void)initialize
//{
//	PF_HELLO("")
//	
//	// check that only NSCFSet will do this
//	if( self != [NSCFDictionary class] ) return;
//
//	PF_DEBUG("Setting _PFNSCFDictionaryClass\n");
//	_PFNSCFDictionaryClass = self;
//	PF_DEBUG_F("_PFNSCFDictionaryClass = %d\n", _PFNSCFDictionaryClass);
//}


/*
 *	Called by NSString and NSMutableString +alloc methods. Returns the _PFNSCFStringClass dummy, so that
 *	the impending -init... methods can be correctly delivered. These then replace it with newly-allocated
 *	CFString objects
 */
+(id)alloc
{
	PF_HELLO("")
	//printf("_PFNSCFDictionaryClass = %d\n", _PFNSCFDictionaryClass);
	//return (id)(&_PFNSCFDictionaryClass);
	return nil;
}

/*
 *	Undocumented method used by Apple to support bridging
 */
-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFDictionaryGetTypeID();
}

/*
 *	Standard bridged-class over-rides
 */
-(id)retain { return (id)CFRetain((CFTypeRef)self); }
-(NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
-(void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
-(NSUInteger)hash { return CFHash((CFTypeRef)self); }

/*
 *	See NSArray.h, -[NSCFArray countByEnumeratingWithState:...] for the gory details
 */
#define PF_DICT_MO 24

/*
 *	NSFastEnumeration support. Based on example code from
 *		http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html
 *
 *	A dictionary enumerates over its keys
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
	PF_HELLO("")
	
	CFIndex count = CFDictionaryGetCount( (CFDictionaryRef)self );
	NSUInteger num = count - state->state;	// 0 if 1st time through an empty array, or at end
											// of a full one
	if( num != 0 )
	{
		num = (len < num) ? len : num; // number of items to copy
		
		// optomised for first reads of small dictionaries
		if( (state->state == 0) && (num <= count) )
			CFDictionaryGetKeysAndValues( (CFDictionaryRef)self, (const void**)stackbuf, NULL );
		else
		{
			// because of course, CFDictionary would have to be awkward and not allow you to 
			//	get only a range keys...
			void *buffer = calloc( count, sizeof(id) );
			CFDictionaryGetKeysAndValues( (CFDictionaryRef)self, (const void**)buffer, NULL );
			void *t_buffer = buffer + (state->state * sizeof(id));
			memcpy( stackbuf, t_buffer, (num * sizeof(id)) ); // should be 16 at most, so could use pointers
			free( buffer );
		}
		
		// set the return values
		state->state += num;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = (unsigned long *)((NSUInteger)self + PF_DICT_MO); // see above
		//printf("Is %u %u + %u?\n", state->mutationsPtr, self, PF_DICT_MO);
	}
	return num;
}


-(NSString *)description
{
	PF_RETURN_TEMP( CFCopyDescription((CFTypeRef)self) )
}

- (NSString *)descriptionInStringsFileFormat 
{
	PF_TODO
}

- (NSString *)descriptionWithLocale:(id)locale 
{
	PF_TODO
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level 
{
	PF_TODO
}

/*
 *	NSMutableDictionary NSMutableDictionaryCreation creation method
 */
- (id)init
{
	PF_HELLO("")
	PF_CHECK_DICT(self)
	
	if( isMutable == YES )
		self = (id)CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	else
		self = (id)CFDictionaryCreate( kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	
	PF_RETURN_NEW(self)
}


- (id)initWithCapacity:(NSUInteger)numItems 
{
	PF_HELLO("")
	PF_CHECK_DICT(self)
	
	if( isMutable == NO ) return nil; // throw an exception?
	self = (id)CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	// find dictionary size hinting code...
	//PF_RETURN_DICT_INIT
	PF_RETURN_NEW(self)
}

/*
 *	NSDictionary creation methods
 */
- (id)initWithObjects:(id *)objects forKeys:(id *)keys count:(NSUInteger)cnt 
{
	PF_HELLO("")
	PF_CHECK_DICT(self)
	
	self = (id)CFDictionaryCreate( kCFAllocatorDefault, (const void**)keys, (const void **)objects, (CFIndex)cnt, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );

	PF_RETURN_DICT_INIT
}

- (id)initWithObjectsAndKeys:(id)firstObject, ... 
{ 
	PF_HELLO("")
	PF_CHECK_DICT(self)
	
	if( firstObject == nil ) return nil; // throw an invalid argument exception?
	
	id *ptr1;
	id *ptr2;
	id *t_ptr1;
	id *t_ptr2;
	id temp;
	
	va_list args;
	va_start( args, firstObject );
	
	NSUInteger count = 1; // firstObject
	while( (temp = va_arg( args, id )) != nil ) count++;
	
	// if we got an odd number of arguments, throw an exception
	if( (count & 1) == 1 )
		[NSException raise: NSInvalidArgumentException format: nil];
	
	ptr1 = calloc( count, sizeof(id) );
	count /= 2;
	ptr2 = ptr1 + count;
	t_ptr1 = ptr1;
	t_ptr2 = ptr2;
	
	va_start( args, firstObject );
	
	// copy the args into the two buffers
	*t_ptr1++ = firstObject;
	*t_ptr2++ = va_arg( args, id );
	while( (temp = va_arg( args, id )) != nil )
	{
		*t_ptr1++ = temp;
		*t_ptr2++ = va_arg( args, id );
	}
	
	self = (id)CFDictionaryCreate( kCFAllocatorDefault, (const void**)ptr2, (const void **)ptr1, (CFIndex)count, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	
	va_end( args );
	free( ptr1 );
	
	PF_RETURN_DICT_INIT
}


- (id)initWithDictionary:(NSDictionary *)otherDictionary 
{ 
	PF_HELLO("")
	PF_CHECK_DICT(self)
	
	if( isMutable == NO )
		self = (id)CFDictionaryCreateCopy( kCFAllocatorDefault, (CFDictionaryRef)otherDictionary );
	else
		self = (id)CFDictionaryCreateMutableCopy( kCFAllocatorDefault, 0, (CFDictionaryRef)otherDictionary );
	
	PF_RETURN_NEW(self)
}


- (id)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag 
{
	PF_HELLO("")

	id *ptr1;
	id *ptr2;
	
	if( flag == NO )
		return [self initWithDictionary: otherDictionary];
	
	CFIndex count = [otherDictionary count];
	if( count == 0 )
		return [self init];
	
	// get all of the objects from otherDictionary
	ptr1 = calloc( (count * 2), sizeof(id) );
	ptr2 = ptr1 + (count * sizeof(id));
	CFDictionaryGetKeysAndValues( (CFDictionaryRef)otherDictionary, (const void**)ptr1, (const void**)ptr2 );
	
	// copy each of the values
	for( int i = 0; i < count; i++ )
		ptr2[i] = [ptr2[i] copyWithZone: nil];
	
	PF_CHECK_DICT(self)

	self = (id)CFDictionaryCreate( kCFAllocatorDefault, (const void**)ptr1, (const void**)ptr2, count, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	
	free( ptr1 );
	
	PF_RETURN_DICT_INIT
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys 
{
	PF_HELLO("")
	PF_CHECK_DICT(self)
	
	id *ptr1; // objects
	id *ptr2; // keys

	CFIndex count;
	
	if( (objects == nil) || (keys == nil) || ((count = [objects count]) != [keys count]) )
		[NSException raise: NSInvalidArgumentException format: nil];

	ptr1 = calloc((count * 2), sizeof(id));
	ptr2 = ptr1 + count;
	CFRange range = CFRangeMake( 0, count );
	
	// these should really use higher-level calls, in case these are 3rd party NSArray subclasses
	CFArrayGetValues( (CFArrayRef)keys, range, (const void **)ptr1 );
	CFArrayGetValues( (CFArrayRef)objects, range, (const void**)ptr2 );
	
	self = (id)CFDictionaryCreate( kCFAllocatorDefault, (const void **)ptr1, (const void **)ptr2, count, &kCFTypeDictionaryKeyCallBacks, &_PFCollectionCallBacks );
	
	free(ptr1);
	
	PF_RETURN_DICT_INIT
}

- (id)initWithContentsOfFile:(NSString *)path 
{
	PF_TODO
	
	if( path == nil ) return nil;
	
	PF_CHECK_DICT(self)
	
	// open a file handle to the path
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath: path];
	if( fh == nil ) return nil;
	
	// read the file into an NSData object
	NSData *data = [fh availableData];
	if( (data == nil) || ([data length] == 0) ) return nil;
	
	// these two steps could be achieved by NSFileManager -contentsOfFileAtPath:, but
	//	first we need to check whether our version works
	
	// parse the data into a property list
	NSPropertyListMutabilityOptions opt = (isMutable) ? NSPropertyListMutableContainersAndLeaves : NSPropertyListImmutable;
	NSPropertyListFormat format;
	NSString *error;
	self = [NSPropertyListSerialization propertyListFromData: data 
											mutabilityOption:(NSPropertyListMutabilityOptions)opt 
													  format: &format 
											errorDescription: &error];
	
	if( error != nil )
	{
		NSLog( error );
		[error release];
		return nil;
	}
	
	if( [self isKindOfClass: [NSDictionary class]] == NO )
		return nil; // the new (incorrect) plist has been autoreleased
	
	// The NSPropertyListMutableContainersAndLeaves above should have taken care 
	//	of the mutable/immutable decision for the return, and the plist will have 
	//	already have been made collectible
	return [self retain];
}

- (id)initWithContentsOfURL:(NSURL *)url 
{
	PF_TODO
	if( url == nil ) return nil;
	if( [url isFileURL] ) return [self initWithContentsOfFile: [url path]];
	
	return nil;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile 
{
	PF_HELLO("")
	
	if( path == nil ) return NO;
	
	// convert it into an NSData item
	NSString *error;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList: self format: NSPropertyListXMLFormat_v1_0 errorDescription: &error];
	if( error != nil )
	{
		NSLog( error );
		[error release];
		return NO;
	}
	
	//NSLog(@"got data 0x%X, length = %u", data, [data length]);
	
	// if we're writing directly to the file location...
	if( useAuxiliaryFile == NO )
		return [[NSFileManager defaultManager] createFileAtPath: path contents: data attributes: nil];
	
	// ...otherwise
	// the temp name won't be unique if we try lots of these in quick sucession
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingFormat: @"PFTempDict-%u", [[NSDate date] timeIntervalSinceReferenceDate]]; 
	
	//NSLog(@"Trying temp path %@", tempPath);
	
	// could maybe check to see if path exists before doing this
	
	if( YES == [[NSFileManager defaultManager] createFileAtPath: tempPath contents: data attributes: nil] )
	{
		//return [[NSFileManager defaultManager] moveItemAtPath: tempPath toPath: path error: NULL];
#warning Replace this with the version above, once NSFileManager supports it
		return [[NSFileManager defaultManager] movePath: tempPath toPath: path handler: nil];
	}
	return NO;	
}


// "the atomically flag is ignored if url of a type that cannot be written atomically."
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically 
{
	PF_TODO
	if( url == nil ) return NO;
	if( [url isFileURL] ) return [self writeToFile: [url path] atomically: atomically];
	
	return NO;
}


/*
 *	NSDictionary instance methods
 */
- (NSUInteger)count
{
	PF_HELLO("")
	return (NSUInteger)CFDictionaryGetCount( (CFDictionaryRef)self );
}

- (id)objectForKey:(id)aKey
{
	PF_HELLO("")
	return (id)CFDictionaryGetValue( (CFDictionaryRef)self , (const void *)aKey );
}

- (NSEnumerator *)keyEnumerator
{
	PF_HELLO("")
	return [[[PFEnumerator alloc] initWithCFDictionaryKeys: self] autorelease];
}

/*
 *	NSDictionary NSExtendedDictionary methods
 */
- (NSEnumerator *)objectEnumerator 
{
	PF_HELLO("")
	return [[[PFEnumerator alloc] initWithCFDictionaryValues: self] autorelease];
}

- (NSArray *)allKeys 
{
	PF_HELLO("")
	
	CFIndex count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( count == 0 )
		return [NSArray array];
	
	id *ptr = calloc( count, sizeof(id) );
	
	CFDictionaryGetKeysAndValues( (CFDictionaryRef)self, (const void **)ptr, NULL );
	CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, count, &kCFTypeArrayCallBacks );

	free( ptr );
	PF_RETURN_TEMP(array)
}


- (NSArray *)allValues 
{
	PF_HELLO("")
	
	CFIndex count = [self count];
	if( count == 0 )
		return [NSArray array];
	
	id *ptr = calloc( count, sizeof(void *) );
	
	CFDictionaryGetKeysAndValues( (CFDictionaryRef)self, NULL, (const void **)ptr );
	CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, count, &kCFTypeArrayCallBacks );

	free( ptr );
	PF_RETURN_TEMP(array)
}

- (NSArray *)allKeysForObject:(id)anObject 
{
	PF_HELLO("")
	
	if( 0 == CFArrayGetCount((CFArrayRef)self) ) return [NSArray array];
	
	// I'm certain that there's a better way to do this
	CFMutableArrayRef array = CFArrayCreateMutable( kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks );
	void *context[2] = { (void *)anObject, (void *)array };
	
	CFDictionaryApplyFunction((CFDictionaryRef)self, _PFKeysForObject, context );
	
	// yes, I know that we're returning a mutable array
	PF_RETURN_TEMP(array)
}


- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary 
{
	PF_HELLO("")
	
	if( otherDictionary == nil ) return NO;
	if( self == otherDictionary ) return YES;

	return (BOOL)CFEqual( (CFTypeRef)self, (CFTypeRef)otherDictionary );
}


- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker 
{
	PF_HELLO("")
	
	NSUInteger count = [keys count];
	if( count == 0 ) return [NSArray array];
	
	// this is going to be inefficient, but it works for now
	id *buffer = calloc( count, sizeof(id) );
	id temp;
	
	for( id key in keys )
	{
		if( YES == CFDictionaryGetValueIfPresent( (CFDictionaryRef)self, key, (void *)&temp ) )
			*buffer++ = temp;
		else
			*buffer++ = marker;
	}
	
	buffer -= count;
	CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, &kCFTypeArrayCallBacks );
	free( buffer );
	PF_RETURN_TEMP(array)
}

/*
 *	"Returns an array of the receiver’s keys, in the order they would be in if the 
 *	receiver were sorted by its values."
 *
 *	Hmm... split the dictionary out into two buffers. Run the compare function over
 *	the values, but apply the re-ordering to both keys and values?
 */
- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator 
{
	PF_TODO
	
	NSUInteger count = CFDictionaryGetCount( (CFDictionaryRef)self );
	if( count == 0 ) return [NSArray array];
	
}

- (void)getObjects:(id *)objects andKeys:(id *)keys 
{
	PF_HELLO("")
	CFDictionaryGetKeysAndValues( (CFDictionaryRef)self, (const void **)keys, (const void **)objects );
}


/*
 *	NSMutableDictionary instance methods
 */
- (void)removeObjectForKey:(id)aKey 
{
	PF_HELLO("")
	PF_CHECK_DICT_MUTABLE(self)
	
	CFDictionaryRemoveValue( (CFMutableDictionaryRef)self, (const void *)aKey );
}

- (void)setObject:(id)anObject forKey:(id)aKey 
{
	PF_HELLO("")
	PF_CHECK_DICT_MUTABLE(self)
	PF_NIL_ARG(anObject)
	PF_NIL_ARG(aKey)
	
	CFDictionarySetValue( (CFMutableDictionaryRef)self, (const void *)aKey, (const void *)anObject );
}

/*
 *	NSMutableDictionary NSExtendedMutableDictionary instance methods
 */
- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary 
{
	PF_TODO
	PF_CHECK_DICT_MUTABLE(self)
	PF_NIL_ARG(otherDictionary)
	
	NSUInteger count = [otherDictionary count];
	if( count == 0 ) return;
	
	NSEnumerator *keyEn = [otherDictionary keyEnumerator];
	NSEnumerator *valueEN = [otherDictionary objectEnumerator];
	
	for( id key in keyEn )
	{
		/*
		 *	This is actually pretty risky. If the other dictionary is an NSCFDictionary
		 *	then we can be fairly certain keys and values will appear in the same order.
		 *	If it's any other kind of dictionary, then all bets are off.
		 */
		CFDictionarySetValue( (CFMutableDictionaryRef)self, (const void *)key, (const void *)[valueEN nextObject] );
	}
}

- (void)removeAllObjects 
{
	PF_HELLO("")
	PF_CHECK_DICT_MUTABLE(self)
	
	CFDictionaryRemoveAllValues( (CFMutableDictionaryRef)self );
}

- (void)removeObjectsForKeys:(NSArray *)keyArray 
{
	PF_TODO
	PF_CHECK_DICT_MUTABLE(self)
	
	if( (CFDictionaryGetCount((CFDictionaryRef)self) == 0) || ([keyArray count] == 0) ) return;
	
	for( id key in keyArray )
		CFDictionaryRemoveValue( (CFMutableDictionaryRef)self, (const void *)key );
}

- (void)setDictionary:(NSDictionary *)otherDictionary 
{
	PF_TODO
	PF_CHECK_DICT_MUTABLE(self)
	PF_NIL_ARG(otherDictionary)
	
	// docs say we should call [self removeAllObjects], but we won't
	CFDictionaryRemoveAllValues( (CFMutableDictionaryRef)self );
	
	CFIndex count = [otherDictionary count];
	if( count == 0 ) return;
	
	// enumerate over other dictionary and add in each key-value pair by hand
	NSEnumerator *keyEn = [otherDictionary keyEnumerator];
	NSEnumerator *valueEN = [otherDictionary objectEnumerator];

	// see addEntriesForDictionary: above for why this is bloody dangerous
	for( id key in keyEn )
		CFDictionaryAddValue( (CFMutableDictionaryRef)self, (const void *)key, (const void *)[valueEN nextObject] );
}

@end



