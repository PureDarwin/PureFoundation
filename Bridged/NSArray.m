/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSArray.m
 *
 *	NSArray, NSMutableArray, NSCFArray
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "Foundation/NSArray.h"
#import "PFEnumerator.h"
#import "NSPropertyList.h"
#import "PureFoundation.h"

//#import "../CF-476.15.patched/CFArray.h"
//#import "../CF-476.15.patched/ForFoundationOnly.h"

/*
 *	Another quick skeleton class cluster to increase the exported symbol count
 */

/*
 *	The bridged NSCFArray class
 */
@interface NSCFArray : NSMutableArray
@end

/*
 *	The dummy NSCFArray variables
 */
static Class _PFNSCFArrayClass = nil;
static Class _PFNSCFMutableArrayClass = nil;

/*
 *	Macro to check for our dummy NSCFData objects, and set isMutable depending on the value
 */
extern bool _CFArrayIsMutable(CFArrayRef array);
extern void _CFArraySetCapacity(CFMutableArrayRef array, CFIndex cap);

#define PF_DUMMY_ARR(array) BOOL isMutable; \
	if( array == (id)&_PFNSCFArrayClass ) isMutable = NO; \
	else if( array == (id)&_PFNSCFMutableArrayClass ) isMutable = YES; \
	else { isMutable = _CFArrayIsMutable((CFArrayRef)array); [array autorelease]; }

#define PF_RETURN_ARRAY_INIT if( isMutable == YES ) { [self autorelease]; self = (id)CFArrayCreateMutableCopy( kCFAllocatorDefault, 0, (CFArrayRef)self ); } \
	PF_RETURN_NEW(self)

#define PF_CHECK_ARR_MUTABLE(array) if( !_CFArrayIsMutable((CFArrayRef)array) ) \
	[NSException raise: NSInternalInconsistencyException format: [NSString stringWithCString: "Attempting mutable array op on a static NSArray" encoding: NSUTF8StringEncoding]];

extern void CFQSortArray(void *list, CFIndex count, CFIndex elementSize, CFComparatorFunction comparator, void *context);

/*
 *	Array call-back functions
 */
void _PFArrayFindObjectIndeticalTo( const void *value, void *context )
{
	// context points to 3 NSUIntegers: result, position, and object
	//NSLog( @"find indentical: %u, %u, 0x%X", ((NSUInteger *)context)[0], ((NSUInteger *)context)[1], ((NSUInteger *)context)[2] );
	
	if( ((NSUInteger *)context)[0] == NSNotFound )
	{
		if( (NSUInteger)value == ((NSUInteger *)context)[2] )
			((NSUInteger *)context)[0] = ((NSUInteger *)context)[1];
		else
			((NSUInteger *)context)[1]++;
	}
}

/*
 *	The comparison function for sortUsingSelector:
 */
CFComparisonResult _PFArraySortUsingSelector( const void *val1, const void *val2, void *context )
{
	return (CFComparisonResult)[(id)val1 performSelector: (SEL)context withObject: (id)val2];
}

CFComparisonResult _PFNSUIntegerCompare( const void *val1, const void *val2, void *context )
{
	if( *(NSUInteger *)val1 < *(NSUInteger *)val2 )
		return kCFCompareLessThan;
	else if( *(NSUInteger *)val1 > *(NSUInteger *)val2 )
		return kCFCompareGreaterThan;
	else
		return kCFCompareEqualTo;
}



/************
 *	NSArray
 ************/
@implementation NSArray

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSArray class] )
		_PFNSCFArrayClass = objc_getClass("NSCFArray");
}

+(id)alloc
{
	PF_HELLO("")
	if( self == [NSArray class] )
		return (id)&_PFNSCFArrayClass;
	else
		return [super alloc];
}

/*
 *	NSArrayCreation class methods
 */
+ (id)array
{
	PF_HELLO("")
	//return [[[self alloc] init] autorelease]; // make sure -init exists and works...
	return [(id)CFArrayCreate( kCFAllocatorDefault, NULL, 0, &_PFCollectionCallBacks ) autorelease];
}

/*
 *	 Since this is meant to be a fast convinience method, we'll call CFArrayCreate() directly
 */
+ (id)arrayWithObject:(id)anObject
{
	PF_HELLO("")

	CFArrayRef new = CFArrayCreate( kCFAllocatorDefault, (const void **)&anObject, 1, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	PF_RETURN_TEMP(new)
}

+ (id)arrayWithObjects:(const id *)objects count:(NSUInteger)cnt
{
	PF_HELLO("")
	return [[[self alloc] initWithObjects: objects count: cnt] autorelease];
}

/*
 *	It's a pain that we can't hand off varidic arguments, so we'll have to duplicate initWithObjects: here
 */
+ (id)arrayWithObjects:(id)firstObj, ... //NS_REQUIRES_NIL_TERMINATION;
{
	PF_HELLO("")
	//PF_NIL_ARG(firstObj)
	
	if( firstObj == nil ) return [self array];
	
	id *ptr;
	//void **t_ptr;
	void *temp;
	
	va_list args;
	va_start( args, firstObj );
	
	// count the number of va_args
	CFIndex count = 1;
	while( (temp = va_arg( args, void* )) != nil ) 
		count++;
	
	//printf("\tCounted %d object, total\n", count );
	
	if( count == 1 )
		ptr = &firstObj;
	else
	{	
		ptr = calloc(count, sizeof(void *));
		//t_ptr = ptr;
		
		va_start( args, firstObj );
		*ptr++ = firstObj;
		while( (temp = va_arg( args, void* )) != nil)
			*ptr++ = temp;
		
		ptr -= count;
	}
	
	//CFArrayRef new = CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, (CFIndex)count, &kCFTypeArrayCallBacks );
	
	// problem was that this was only returning an immutable array, so pass collected args
	// off to initWithObjects:count: to interpret [self alloc]
	NSArray *new = [[[self alloc] initWithObjects: ptr count: count] autorelease];

	if( count != 1 ) free( ptr );
	va_end( args );
	//PF_RETURN_TEMP(new)
	return new; // which has already been made collectible and released
}

+ (id)arrayWithArray:(NSArray *)array
{
	PF_HELLO("")
	return [[[self alloc] initWithArray: array] autorelease];
}

+ (id)arrayWithContentsOfFile:(NSString *)path
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfFile: path] autorelease];
}

+ (id)arrayWithContentsOfURL:(NSURL *)url
{
	PF_HELLO("")
	return [[[self alloc] initWithContentsOfURL: url] autorelease];
}

/*
 *	NSArray instance methods the compiler needs to see
 */
- (NSUInteger)count
{
	return 0;
}

- (id)objectAtIndex:(NSUInteger)index
{
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
 *	NSMutableArray
 */
@implementation NSMutableArray

+(void)initialize
{
	PF_HELLO("")
	if( self == [NSMutableArray class] )
		_PFNSCFMutableArrayClass = objc_getClass("NSCFArray");
}

/*
 *	Mutable version
 */
+(id)alloc
{
	PF_HELLO("")
	if( self == [NSMutableArray class] )
		return (id)&_PFNSCFMutableArrayClass;
	else
		return [super alloc];
}

/*
 *	NSMutableArray specific class creation method
 */
+ (id)arrayWithCapacity:(NSUInteger)numItems
{
	PF_HELLO("")
	CFMutableArrayRef array = CFArrayCreateMutable( kCFAllocatorDefault, 0, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	// CF:ForFoundationOnly.h line #399
	_CFArraySetCapacity(array, numItems);
	PF_RETURN_TEMP(array)
}


/*
 *	NSArrayCreation class methods, which may need re-implementing to return mutable versions
 */
+ (id)array
{
	PF_HELLO("")
	CFMutableArrayRef array = CFArrayCreateMutable( kCFAllocatorDefault, 0, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	PF_RETURN_TEMP(array);
}

/*
 *	Get a very small speed-increase by calling CF... functions dirrectly here
 */
+ (id)arrayWithObject:(id)anObject
{
	PF_HELLO("")

	CFArrayRef new = CFArrayCreate( kCFAllocatorDefault, (const void **)&anObject, 1, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	CFArrayRef newer = CFArrayCreateMutableCopy( kCFAllocatorDefault, 0, new );
	[(id)new release]; // saves going through CFRelease()
	PF_RETURN_TEMP(newer)
}

// the inherited versions of these, along with our alloc, should work 
//+ (id)arrayWithObjects:(const id *)objects count:(NSUInteger)cnt
//{
//	PF_HELLO("")
//	return [[[super arrayWithObjects: objects count: cnt] mutableCopyWithZone: nil] autorelease];
//}

/*
 *	Because we can't forward varadic wossnames...
 */
//+ (id)arrayWithObjects:(id)firstObj, ...
//{
//	PF_HELLO("")
//	PF_NIL_ARG(firstObj)
//	
//	void **ptr;
//	void **t_ptr;
//	void *temp;
//	
//	va_list args;
//	va_start( args, firstObj );
//	
	// count the number of va_args
//	CFIndex count = 1;
//	while( (temp = va_arg( args, void* )) != nil ) 
//		count++;
	
	//printf("\tCounted %d object, total\n", count );
	
//	if( count == 1 )
//		ptr = (void *)&firstObj;
//	else
//	{	
//		ptr = NSZoneCalloc( nil, count, sizeof(void *) );
//		t_ptr = ptr;
		
//		va_start( args, firstObj );
//		*t_ptr++ = (void *)firstObj;
//		while( (temp = va_arg( args, void* )) != nil)
//			*t_ptr++ = temp;
//	}
	
//	CFArrayRef new = CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, (CFIndex)count, &kCFTypeArrayCallBacks );
	
//	if( count != 1 ) NSZoneFree( nil, ptr );
//	va_end( args );
//	
//	CFArrayRef newer = CFArrayCreateMutableCopy( kCFAllocatorDefault, 0, new );
//	[(id)new release];
//	PF_RETURN_TEMP(newer)
//}

//+ (id)arrayWithArray:(NSArray *)array
//{
//	PF_HELLO("")
//	return [[[super arrayWithArray: array] mutableCopyWithZone: nil] autorelease];
//}

//+ (id)arrayWithContentsOfFile:(NSString *)path
//{
//	PF_HELLO("")
//	return [[[super arrayWithContentsOfFile: path] mutableCopyWithZone: nil] autorelease];
//}

//+ (id)arrayWithContentsOfURL:(NSURL *)url
//{
//	PF_HELLO("")
//	return [[[super arrayWithContentsOfURL: url] mutableCopyWithZone: nil] autorelease];
//}


/*
 *	NSMutableArray specific instance methods, for the compiler
 */
- (void)addObject:(id)anObject {}
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {}
- (void)removeLastObject {}
- (void)removeObjectAtIndex:(NSUInteger)index {}
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {}

@end



/*
 *	NSCFArray
 */
@implementation NSCFArray

/*
 *	Now this class cannot be directly alloc'd
 */
+(id)alloc
{
	PF_HELLO("")
	return nil;
}

/*
 *	Undocumented method used by Apple to support bridging
 */
-(CFTypeID)_cfTypeID
{
	PF_HELLO("")
	return CFArrayGetTypeID();
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
 *	sjc -- 9/2/09 -- The format now matches Cocoa's. I thought.
 *
 *	Four spaces are placed before each array element. If a tab is chosen, that is placed 
 *	before the four spaces.
 *
 *	At the moment, this won't pass on [descriptionWithLocale:indent:] because I'm not sure
 *	how other objects should react adding the indent...
 */
-(NSString *)description
{
	return [self descriptionWithLocale: nil indent: 0];
}


- (NSString *)descriptionWithLocale:(id)locale
{
	PF_TODO
	return [self descriptionWithLocale: locale indent: 0];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
	NSUInteger count = CFArrayGetCount((CFArrayRef)self);
	CFStringRef description, template, contents;
	id object;
	
	if( count == 0 ) 
		return (level == 1) ?  @"\t(\n\t)" : @"(\n)";
	
	template = (level == 1) ? CFSTR("\t(\n\t    %@\n\t)") : CFSTR("(\n    %@\n)");
	
	if( count == 1 )
	{	
		object = (id)CFArrayGetValueAtIndex( (CFArrayRef)self, 0 );
		if( [object isKindOfClass: [NSString class]] )
			contents = (CFStringRef)object;
		else if( (locale != nil) && [object respondsToSelector: @selector(descriptionWithLocale:)] )
			contents = (CFStringRef)[object descriptionWithLocale: locale];
		else
			contents = (CFStringRef)[object description];
	}
	else
	{
		id *buffer = calloc(count, sizeof(id));
		for( object in self )
		{
			if( [object isKindOfClass: [NSString class]] ) // strings are included as is
			   *buffer++ = object;
			else if( (locale != nil) && [object respondsToSelector: @selector(descriptionWithLocale:)] )
				*buffer++ = [object descriptionWithLocale: locale];
			else
			   *buffer++ = [object description];
		}
		buffer -= count;
		
		CFStringRef joiner = (level == 1) ? CFSTR(",\n\t    ") : CFSTR(",\n    ");
		CFArrayRef array = CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, NULL );
		contents = CFStringCreateByCombiningStrings( kCFAllocatorDefault, array, joiner );
		
		free(buffer);
		[(id)array release];
		[(id)contents autorelease];
	}

	description = CFStringCreateWithFormat( kCFAllocatorDefault, NULL, template, contents );
	PF_RETURN_TEMP(description)
}


/**	NSCopying COMPLIANCE **/
- (id)copyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	// at the moment, all allocation goes through the Default CF alloc zone
	CFArrayRef new = CFArrayCreateCopy( kCFAllocatorDefault, (CFArrayRef)self );
	PF_RETURN_NEW(new)
}

/** NSMutableCopying COMPLIANCE **/
- (id)mutableCopyWithZone:(NSZone *)zone
{
	PF_HELLO("")
	CFMutableArrayRef new = CFArrayCreateMutableCopy( kCFAllocatorDefault, 0, (CFArrayRef)self );
	PF_RETURN_NEW(new)
}


/*
 *	This is just evil. Looking at CFArray.h, at the __CFArray structure, there is a _mutations 
 *	count stored 12 bytes in. We point the fast enumerations mutationsPtr at it, and it seems to
 *	catch any attempt at altering a mutable array. Of course, this will break under 64-bit, so needs 
 *	to be conditionally defined to take into account the extra 4 bytes.
 */
#define PF_ARRAY_MO 12
 
/*
 *	NSFastEnumeration support. Based on example code from
 *		http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
	PF_HELLO("")
	
	CFIndex count = CFArrayGetCount( (CFArrayRef)self );
	NSUInteger num = count - state->state; // 0 if 1st time through an empty array, or at end
										  // of a full one
	if( num != 0 )
	{
		num = (len < num) ? len : num; // number of items to copy

		CFRange range = CFRangeMake( state->state, num ); // range to copy across

		CFArrayGetValues( (CFArrayRef)self, range, (const void**)stackbuf ); // do the copy

		// set the return values
		state->state += num;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = (unsigned long *)((NSUInteger)self + PF_ARRAY_MO); // see above
		//printf("Is %u %u + %u?\n", state->mutationsPtr, self, PF_ARRAY_MO);
	}
	return num;
}

// creation methods
- (id)init
{
	PF_DUMMY_ARR(self)
	
	if( isMutable == NO )
		self = (id)CFArrayCreate( kCFAllocatorDefault, NULL, 0, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	else
		self = (id)CFArrayCreateMutable( kCFAllocatorDefault, 0, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	
	PF_RETURN_NEW(self)
}

/*
 *	NSMutableArray creation method
 */
- (id)initWithCapacity:(NSUInteger)numItems
{
	PF_HELLO("")
	//PF_DUMMY_ARR(self) // don't need to set isMutable
	if( self == (id)&_PFNSCFArrayClass )
		[NSException raise: NSInternalInconsistencyException format: @"initWithCapacity NSArray"];
	else if( self != (id)&_PFNSCFMutableArrayClass )
		[self autorelease];
	
	self = (id)CFArrayCreateMutable( kCFAllocatorDefault, 0, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	// from ForFoundationOnly.h line #399
	_CFArraySetCapacity((CFMutableArrayRef)self, numItems);
	PF_RETURN_NEW(self)
}


/*
 *	NSArray creation methods
 */
- (id)initWithObjects:(const id *)objects count:(NSUInteger)cnt
{
	PF_HELLO("")
	PF_DUMMY_ARR(self)

	self = (id)CFArrayCreate( kCFAllocatorDefault, (const void **)objects, (CFIndex)cnt, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	PF_RETURN_ARRAY_INIT
}

- (id)initWithObjects:(id)firstObj, ... //NS_REQUIRES_NIL_TERMINATION
{
	//printf("array initWithObjects:\n");
	PF_NIL_ARG(firstObj)
	PF_DUMMY_ARR(self)

	id *ptr;
	
	va_list args;
	va_start( args, firstObj );
	
	// count the number of va_args
	CFIndex count = 1;
	void *temp;
	while( (temp = va_arg( args, void* )) != nil ) 
		count++;
	
	//printf("\tCounted %d object, total\n", count );
	
	if( count == 1 )
		ptr = &firstObj;
	else
	{	
		ptr = calloc(count, sizeof(id));
		id *t_ptr = ptr;
	
		va_start( args, firstObj );
		*t_ptr++ = firstObj;
		while( (temp = va_arg( args, void* )) != nil)
			*t_ptr++ = temp;
	}
	
	self = (id)CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, (CFIndex)count, (CFArrayCallBacks *)&_PFCollectionCallBacks );

	if( count != 1 ) free(ptr);
	va_end( args );

	PF_RETURN_ARRAY_INIT
}

- (id)initWithArray:(NSArray *)array
{
	PF_HELLO("")
	
	if( (array == nil) || ([array count] == 0) ) return [self init];
	
	PF_DUMMY_ARR(self)

	// use the slower copy methods because array may not be an NSCFArray
	if( isMutable == NO )
		self = [array copyWithZone: nil];
	else
		self = [array mutableCopyWithZone: nil];
	
	PF_RETURN_NEW(self)
}

- (id)initWithArray:(NSArray *)array copyItems:(BOOL)flag //AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER;
{
	PF_HELLO("")

	CFIndex count;
	// check whether there's anything to copy
	if( (array == nil) || ((count = [array count]) == 0) ) return [self init];
	
	// check whether we need to copy what there is
	if( flag == NO ) return [self initWithArray: array];
	
	PF_DUMMY_ARR(self)

	//if( (flag == NO) || (count == 0) )
	//	PF_RETURN_NEW([array copyWithZone: nil])

	// temp scratch space to hold all objects
	id *ptr = calloc(count, sizeof(id));
	//const void**ptr2 = (const void**)ptr1;
	
	// foreach item in array, -copyWithZone: nil, then put them into a new array and return
	// could probably use an enumerator about here...
	//for( int i = 0; i < count; i++ )
	//	ptr[i] = [[array objectAtIndex: i] copyWithZone: nil];
	for( id object in array )
		*ptr++ = [object copyWithZone: nil];
	ptr -= count;
	
	self = (id)CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, count, &_PFCollectionCallBacks );

	free(ptr);

	PF_RETURN_ARRAY_INIT
}
 


- (id)initWithContentsOfFile:(NSString *)path
{
	PF_HELLO("")

	if( path == nil ) return nil;
	
	PF_DUMMY_ARR(self)
	
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
	   
	if( [self isKindOfClass: [NSArray class]] == NO )
		return nil; // the new (incorrect) plist has been autoreleased
	
	// The NSPropertyListMutableContainersAndLeaves above should have taken care 
	//	of the mutable/immutable decision for the return, and the plist will have 
	//	already have been made collectible
	return [self retain];
}

- (id)initWithContentsOfURL:(NSURL *)url
{
	PF_HELLO("Untested, pending NSData initWithURL")
	
	if( url == nil ) return nil;
	// could loose this once dataWithContentsOfURL: is up and running
	if( [url isFileURL] ) return [self initWithContentsOfFile: [url path]];
	
	PF_DUMMY_ARR(self)
	
	// read the URL into an NSData object
	NSData *data = [NSData dataWithContentsOfURL: url];
	if( (data == nil) || ([data length] == 0) ) return nil;
	
	// REST COPIED FROM initWithContentsOfFile ABOVE
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
	
	if( [self isKindOfClass: [NSArray class]] == NO )
		return nil; // the new (incorrect) plist has been autoreleased
	
	// The NSPropertyListMutableContainersAndLeaves above should have taken care 
	//	of the mutable/immutable decision for the return, and the plist will have 
	//	already have been made collectible
	return [self retain];
	
}

/*
 *	Complimentary writeTo... methods
 */
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
	PF_HELLO("")
	
	if( path == nil ) return NO;
	
	// check that self can be written out as a property list
	//	don't bother -- it's done again by dataFromPropertyList:
	//if( [NSPropertyListSerialization propertyList: self isValidForFormat: NSPropertyListXMLFormat_v1_0] == NO )
	//	return NO;
	
	// convert it into an NSData item
	NSString *error;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList: self format: NSPropertyListXMLFormat_v1_0 errorDescription: &error];
	if( error != nil )
	{
		NSLog( error );
		[error release];
		return NO;
	}
	
	// if we're writing directly to the file location...
	if( useAuxiliaryFile == NO )
		return [[NSFileManager defaultManager] createFileAtPath: path contents: data attributes: nil];
	
	// ...otherwise
		// the temp name won't be unique if we try lots of these in quick sucession
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingFormat: @"PFTempArray-%u", [[NSDate date] timeIntervalSinceReferenceDate]]; 
	
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


- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
	PF_TODO

	if( url == nil ) return NO;
	if( [url isFileURL] ) return [self writeToFile: [url path] atomically: atomically];
	
	
	return NO;
}



/*
 *	NSArray instance methods the compiler needs to see
 */
- (NSUInteger)count
{
	PF_HELLO("")
	return (NSUInteger)CFArrayGetCount( (CFArrayRef)self );
}

- (id)objectAtIndex:(NSUInteger)index
{
	PF_HELLO("")
	return (id)CFArrayGetValueAtIndex( (CFArrayRef)self, (CFIndex)index );
}

/*
 *	@interface NSArray (NSExtendedArray) instance methods
 */
- (NSArray *)arrayByAddingObject:(id)anObject
{
	PF_HELLO("Test this")
	PF_NIL_ARG(anObject)
	
	CFIndex count = CFArrayGetCount((CFArrayRef)self); //(CFIndex)[self count];
	if( count == 0 ) return [NSArray arrayWithObject: anObject]; // leaks?
	
	/*
	 *	??? allocate this on the stack ???
	 */
	id *ptr = calloc((count + 1), sizeof(id));
	CFRange range = CFRangeMake( 0, count );
	CFArrayGetValues( (CFArrayRef)self, range, (const void **)ptr );

	// insert the extra object at the end
	ptr[count] = anObject;
	
	CFArrayRef new = CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, (count + 1), &kCFTypeArrayCallBacks );
	free(ptr);
	PF_RETURN_TEMP(new)
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray
{
	PF_HELLO("test this")
	PF_NIL_ARG(otherArray)
	
	CFIndex count1 = CFArrayGetCount((CFArrayRef)self); //[self count];
	CFIndex count2 = [otherArray count];
	
	if( count1 == 0 )
	{
		if( count2 == 0 ) { return [NSArray array]; }
		else { return [otherArray copyWithZone: nil]; }
	}
	else if( count2 == 0 ) return [self copyWithZone: nil];
	
	id *ptr = calloc((count1 + count2), sizeof(id));
	
	// get first set of objects
	CFRange range = CFRangeMake( 0, count1);
	CFArrayGetValues( (CFArrayRef)self, range, (const void **)ptr );
	
	range.length = count2;
	CFArrayGetValues( (CFArrayRef)otherArray, range, (const void**)(ptr+count1) ); //*sizeof(void *))) );
	
	CFArrayRef new = CFArrayCreate( kCFAllocatorDefault, (const void**)ptr, (count1 + count2), &kCFTypeArrayCallBacks );
	free(ptr);
	PF_RETURN_TEMP(new)
}

- (NSString *)componentsJoinedByString:(NSString *)separator
{
	PF_HELLO("")
	PF_NIL_ARG(separator)
	
	NSUInteger count = [self count];
	if( count == 0 )
		return [NSString string];
	else if( count == 1 )
		return [self description]; // I think this works...
	
	CFStringRef new = CFStringCreateByCombiningStrings( kCFAllocatorDefault, (CFArrayRef)self, (CFStringRef)separator );

	PF_RETURN_TEMP(new)
}

- (BOOL)containsObject:(id)anObject
{
	PF_HELLO("")
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( count == 0 ) return NO;

	CFRange range = CFRangeMake( 0, count );
	
	return CFArrayContainsValue( (CFArrayRef)self, range, (const void *)anObject );
}


- (id)firstObjectCommonWithArray:(NSArray *)otherArray
{
	PF_HELLO("")
	
	// this is a little expensive, but we can't guarentee that otherArray is a NSCFArray
	for( id object in self )
		if( [otherArray containsObject: object] )
			return object;
	return nil;
}


- (void)getObjects:(id *)objects
{
	PF_HELLO("")
	
	NSRange range = NSMakeRange( 0, [self count] );
	[self getObjects: objects range: range];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
	PF_HELLO("")

	if( objects == NULL ) return;
	
	NSUInteger count = [self count];
	if( count == 0 ) return;
	if( (range.location >= count) || ((range.location+range.length) > count) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );
	
	CFArrayGetValues( (CFArrayRef)self, r, (const void **)objects );
}


- (NSUInteger)indexOfObject:(id)anObject
{
	PF_HELLO("")
	
	NSRange range = NSMakeRange( 0, [self count] );
	return [self indexOfObject: anObject inRange: range];
}


- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{
	PF_HELLO("")
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( (anObject == nil) || (count == 0) ) return NSNotFound;
	if( (range.location >= count) || ((range.location+range.length) > count) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );
	
	CFIndex result = CFArrayGetFirstIndexOfValue( (CFArrayRef)self, r, (const void *)anObject );
	return (result == -1) ? NSNotFound : (NSUInteger)result;
}

// addresses must be identical
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject
{
	PF_HELLO("")
							// was [self count] -- marginally faster
	NSRange range = NSMakeRange( 0, CFArrayGetCount((CFArrayRef)self) );
	return [self indexOfObjectIdenticalTo: anObject inRange: range];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
	PF_TODO

	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( (anObject == nil) || (count == 0) ) return NSNotFound;
	if( (range.location >= count) || ((range.location+range.length) > count) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );

	/*
	 *	This probably takes longer than it needs to over large arrays, but it
	 *	dispatches far fewer (eg. no) messages than any alternative I can think
	 *	of right now
	 */
	NSUInteger context[3] = { NSNotFound, r.location, (NSUInteger)anObject };
	CFArrayApplyFunction( (CFArrayRef)self, r, _PFArrayFindObjectIndeticalTo, context );
	return context[0];
}

- (BOOL)isEqualToArray:(NSArray *)otherArray
{
	PF_TODO
	PF_NIL_ARG(otherArray) // ???
	
	if( self == otherArray ) return YES;
	return CFEqual( (CFTypeRef)self, (CFTypeRef)otherArray );
}

- (id)lastObject
{
	PF_HELLO("")
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( count == 0 ) return nil;
	return (id)CFArrayGetValueAtIndex( (CFArrayRef)self, --count );
}

/*
 *	These skip NSEnumerator and instantiate our own enumerator subclass
 */
- (NSEnumerator *)objectEnumerator
{
	PF_HELLO("")
	return [[[PFEnumerator alloc] initWithCFArray: self] autorelease];
}

- (NSEnumerator *)reverseObjectEnumerator
{
	PF_HELLO("")
	return [[[PFReverseEnumerator alloc] initWithCFArray: self] autorelease];
}

/*
 *	"Analyzes the receiver and returns a “hint” that speeds the sorting of the array when the 
 *	hint is supplied to sortedArrayUsingFunction:context:hint:."
 *
 *	The "hint" 
 */
- (NSData *)sortedArrayHint
{
	PF_HELLO("")
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self);
	if( count == 0 ) return [[NSData alloc] init];
	
	NSUInteger *buffer = calloc(count, sizeof(id));
	for( id object in self )
		*buffer++ = [object hash];
	buffer -= count;
	
	return (NSData *)CFDataCreateWithBytesNoCopy( kCFAllocatorDefault, (const UInt8 *)buffer, (count * sizeof(id)), kCFAllocatorMalloc );
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context
{
	PF_HELLO("")

	NSUInteger count = CFArrayGetCount((CFArrayRef)self);
	if( count == 0 ) return [[NSArray alloc] init];
	if( count == 1 ) return [self copyWithZone: nil];
	
	CFMutableArrayRef array = CFArrayCreateMutableCopy( kCFAllocatorDefault, 0, (CFArrayRef)self );
	CFRange range = CFRangeMake( 0, count );
	CFArraySortValues( array, range, (CFComparatorFunction)comparator, context );
	PF_RETURN_NEW(array)
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint
{
	PF_TODO

	NSUInteger count = CFArrayGetCount((CFArrayRef)self);
	// get the easy cases out of the way
	if( count == 0 ) return [[NSArray alloc] init];
	if( count == 1 ) return [self copyWithZone: nil];
	
	// create a mutable copy to work on
	CFMutableArrayRef array = CFArrayCreateMutableCopy( kCFAllocatorDefault, 0, (CFArrayRef)self );
	
	// maybe do something with CFMergeSortArray
	// use hint to determine how many entries have changed
	//CFIndex start = 0;
	//CFIndex dataLength = [hint length] / sizeof(NSUInteger);
	//
	//NSLog( @"dataLength = %u", dataLength );
	//
	//if( dataLength != 0 )
	//{
	//	NSUInteger *data = (NSUInteger *)[hint bytes];
	//	for( id object in self )
	//	{
	//		if( *data++ != [object hash] ) break; // found first difference
	//		if( ++start == dataLength ) break; // reached end of data
	//	}
	//}
	//
	//if( start != count )
	//{
	//	CFRange range = CFRangeMake( start, (count - start) );
	//
	//	NSLog(@"only need to search from %u for %u", range.location, range.length);
	//
	//	CFArraySortValues( (CFMutableArrayRef)array, range, (CFComparatorFunction)comparator, context );
	//}
	//PF_RETURN_NEW(array)
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator
{
	PF_HELLO("")
	
	// what do we do if comparator is nil ???
	
	// get some quick cases out of the way
	CFIndex count = CFArrayGetCount((CFArrayRef)self);
	if( count == 0 ) return [NSArray array]; // autoreleased
	if( count == 1 ) PF_RETURN_TEMP([self copyWithZone: nil]) // just one way of doing it...
	
	// create a mutable copy to work on
	CFMutableArrayRef array = CFArrayCreateMutableCopy( kCFAllocatorDefault, 0, (CFArrayRef)self ); //[self mutableCopyWithZone: nil];
	CFRange range = CFRangeMake( 0, count);
	CFArraySortValues( array, range, _PFArraySortUsingSelector, (void *)comparator );
	PF_RETURN_TEMP(array)
}

/*
 *	This is added by NSSortDescript.h, and will be implemented after they are
 */
- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors { return nil; }


- (NSArray *)subarrayWithRange:(NSRange)range
{
	PF_HELLO("")
	
	NSUInteger count = [self count];
	if( (count == 0) || (range.length == 0) || (range.location >= count) || ((range.location+range.length) > count) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );
	void **ptr = calloc( range.length, sizeof(id) );
	
	CFArrayGetValues( (CFArrayRef)self, r, (const void **)ptr );
	
	CFArrayRef new = CFArrayCreate( kCFAllocatorDefault, (const void **)ptr, range.length, &kCFTypeArrayCallBacks );
	free( ptr );
	PF_RETURN_TEMP(new)
}


- (void)makeObjectsPerformSelector:(SEL)aSelector
{
	PF_HELLO("Test this")
	PF_NIL_ARG(aSelector)
	
	//CFRange range = CFRangeMake( 0, [self count] );
	//CFArrayApplyFunction( (CFArrayRef)self, range, _PFArrayPerformSelector, (void *)aSelector );
	
	// okay, enough pretending to be clever by using ApplyFunction
	for( id object in self )
		[object performSelector: aSelector];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument
{
	PF_HELLO("test this")
	PF_NIL_ARG(aSelector)
	//PF_NIL_ARG(argument)
	
	//NSUInteger context[2] = { (NSUInteger)aSelector, (NSUInteger)argument }; 
	//CFRange range = CFRangeMake( 0, [self count] );
	//CFArrayApplyFunction( (CFArrayRef)self, range, _PFArrayPerformSelectorWithObject, (void *)context );
	
	for( id object in self )
		[object performSelector: aSelector withObject: argument];
}

//#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
	PF_TODO
	
	// if [set count] == 0 return an empty set
	// get arrayCount. ret empty array if it's 0
	// alloc enough space for all ids
	// for setCount.
	//		if index > arrayCount NSRangeException
	//		write into memory space
	// done: create a new array

}


/*
 *	NSMutableArray specific instance methods
 */
- (void)addObject:(id)anObject
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	PF_NIL_ARG(anObject)
	
	CFArrayAppendValue( (CFMutableArrayRef)self, (const void *)anObject );
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	PF_NIL_ARG(anObject)
	
	if( index > [self count] )
		[NSException raise: NSRangeException format: nil];
	
	CFArrayInsertValueAtIndex( (CFMutableArrayRef)self, (CFIndex)index, (const void *)anObject );
}

- (void)removeLastObject
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	NSUInteger count = [self count];
	if( count == 0 )
		[NSException raise: NSRangeException format: nil];
	
	CFArrayRemoveValueAtIndex( (CFMutableArrayRef)self, (CFIndex)--count );
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	if( index >= [self count] )
		[NSException raise: NSRangeException format: nil];
	
	CFArrayRemoveValueAtIndex( (CFMutableArrayRef)self, (CFIndex)index );
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	PF_NIL_ARG(anObject)
	
	if( index >= [self count] )
		[NSException raise: NSRangeException format: nil];
	
	// I presume that the replaced object is correctly released
	CFArraySetValueAtIndex( (CFMutableArrayRef)self, (CFIndex)index, (const void *)anObject );
}

/*
 *	NSMutableArray (NSExtendedMutableArray) instance methods
 */
- (void)addObjectsFromArray:(NSArray *)otherArray
{
	PF_TODO
	PF_CHECK_ARR_MUTABLE(self)
	PF_NIL_ARG(otherArray) // not mentioned in docs
	
	NSUInteger count = [otherArray count];
	if( count == 0 ) return; // nothing to do
	CFRange range = CFRangeMake( 0, count );
	
	CFArrayAppendArray( (CFMutableArrayRef)self, (CFArrayRef)otherArray, range );
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	// not mentioned in docs but we'll do this anyway
	if( (idx1 >= [self count]) || (idx2 >= [self count]) )
		[NSException raise: NSRangeException format: nil];
	
	CFArrayExchangeValuesAtIndices( (CFMutableArrayRef)self, (CFIndex)idx1, (CFIndex)idx2 );
}

- (void)removeAllObjects
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	CFArrayRemoveAllValues( (CFMutableArrayRef)self );
}

- (void)removeObject:(id)anObject inRange:(NSRange)range
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( (range.location >= count) || ((range.location+range.length) > count) )
		[NSException raise: NSRangeException format: nil];
		
	NSUInteger index = [self indexOfObject: anObject inRange: range];
	if( index != NSNotFound )
		[self removeObjectAtIndex: index];
}

- (void)removeObject:(id)anObject
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	NSRange range = NSMakeRange( 0, CFArrayGetCount((CFArrayRef)self) ); //[self count] );
	[self removeObject: anObject inRange: range];
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( (range.location >= count) || ((range.location+range.length) > count) )
		[NSException raise: NSRangeException format: nil];
	
	NSUInteger index = [self indexOfObjectIdenticalTo: anObject inRange: range];
	if( index != NSNotFound )
		[self removeObjectAtIndex: index];
}

- (void)removeObjectIdenticalTo:(id)anObject
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	NSUInteger index = [self indexOfObjectIdenticalTo: anObject];
	if( index != NSNotFound )
		[self removeObjectAtIndex: index];
	
}

- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt
{
	PF_HELLO("This does not currently work...")
	PF_CHECK_ARR_MUTABLE(self)

	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( (count == 0) || (cnt == 0) ) return;
	
	// start by sorting the indiced
	NSUInteger *buffer;
	
	if( cnt == 1 )
		buffer = indices;
	else
	{	// we copy and then sort the indicies
		buffer = (NSUInteger *)calloc(cnt, sizeof(NSUInteger));
		for( int i = 0; i < cnt; i++)
			buffer[i] = indices[i];
		CFQSortArray(buffer, cnt, sizeof(NSUInteger), _PFNSUIntegerCompare, NULL);
	}
	
	buffer += cnt; // move to the end of the sorted indicies
	for( int i = 0; i < cnt; i++ )
	{
		if( *--buffer >= (count - i) ) // the current length of the array
			[NSException raise: NSRangeException format: nil];
		
		CFArrayRemoveValueAtIndex( (CFMutableArrayRef)self, (CFIndex)*buffer );
	}
	
	if( cnt != 1 ) free(buffer);
}

- (void)removeObjectsInArray:(NSArray *)otherArray
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)

	for( id object in otherArray )
		[self removeObject: object];
}

// unlike what the Apple docs say, this version does not use removeObjectAtIndex:
- (void)removeObjectsInRange:(NSRange)range
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( count == 0 ) return;
	if( (range.location >= count) || ((range.location+range.length) > count) )
		[NSException raise: NSRangeException format: nil];
	
	CFRange r = CFRangeMake( range.location, range.length );
	CFArrayReplaceValues( (CFMutableArrayRef)self, r, NULL, 0 );
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange
{
	PF_HELLO("test this")
	PF_CHECK_ARR_MUTABLE(self)
	
	// check that range is valid for self
	NSUInteger count1 = CFArrayGetCount((CFArrayRef)self); //[self count];
	if( (count1 == 0) || (range.location >= count1) || ((range.location+range.length) > count1) )
		[NSException raise: NSRangeException format: nil];
	
	// check that range is valid for otherArray
	NSUInteger count2 = [otherArray count];
	if( (count2 == 0) || (otherRange.location > count2) || ((otherRange.location+otherRange.length) > count2) )
		[NSException raise: NSRangeException format: nil];
	
	// get a CFRange of values to copy from otherArray
	CFRange r = CFRangeMake( otherRange.location, otherRange.length );
	
	// get the values from otherArray...
	void **ptr = calloc( otherRange.length, sizeof(id) );
	CFArrayGetValues( (CFArrayRef)otherArray, r, (const void **)ptr );

	// ...and insert them into self
	r = CFRangeMake( range.location, range.length );
	CFArrayReplaceValues( (CFMutableArrayRef)self, r, (const void **)ptr, (CFIndex)otherRange.length );

	free( ptr );
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray
{
	PF_HELLO("test this")
	PF_CHECK_ARR_MUTABLE(self)

	NSRange otherRange = NSMakeRange( 0, [otherArray count] );
	[self replaceObjectsInRange: range withObjectsFromArray: otherArray range: otherRange];
}

- (void)setArray:(NSArray *)otherArray
{
	PF_HELLO("test this")
	PF_CHECK_ARR_MUTABLE(self)
	PF_NIL_ARG(otherArray)
	
	CFIndex count = (CFIndex)[otherArray count];
	//if( count == 0 ) ???
	CFRange range = CFRangeMake( 0, count );
	
	// get values from otherArray...
	void **ptr = calloc( count, sizeof(void *) );
	CFArrayGetValues( (CFArrayRef)otherArray, range, (const void **)ptr );
	
	range = CFRangeMake( 0, [self count] );
	CFArrayReplaceValues( (CFMutableArrayRef)self, range, (const void **)ptr, count );
	
	free( ptr );
}

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	NSUInteger count = CFArrayGetCount((CFArrayRef)self);
	if( count < 1 ) return;
	
	CFRange range = CFRangeMake( 0, count );
	CFArraySortValues( (CFMutableArrayRef)self, range, (CFComparatorFunction)compare, context );
}

- (void)sortUsingSelector:(SEL)comparator
{
	PF_HELLO("")
	PF_CHECK_ARR_MUTABLE(self)
	
	CFIndex count = CFArrayGetCount((CFArrayRef)self);
	if( count < 1 ) return;
	
	CFRange range = CFRangeMake( 0, count);
	CFArraySortValues( (CFMutableArrayRef)self, range, _PFArraySortUsingSelector, (void *)comparator );
}

/*
 *	Leave these for now because they need NSIndexSets
 */
//#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
	PF_TODO
	PF_CHECK_ARR_MUTABLE(self)
	
	// iteration
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
	PF_TODO
	PF_CHECK_ARR_MUTABLE(self)
	
	// iteration
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
	PF_TODO
	PF_CHECK_ARR_MUTABLE(self)
	
	// iteration
}

@end

