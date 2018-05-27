/*
 *	PureFoundation -- http://www.puredarwin.org
 *	NSArray.m
 *
 *	NSArray, NSMutableArray, __NSCFArray
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "Foundation/NSArray.h"
#import "PFEnumerator.h"
#import "PureFoundation.h"

#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)
#define SELF ((CFArrayRef)self)
#define MSELF ((CFMutableArrayRef)self)

@interface __NSCFArray : NSMutableArray
@end

// These are exposed by CoreFoundation
extern bool _CFArrayIsMutable(CFArrayRef array);
extern void _CFArraySetCapacity(CFMutableArrayRef array, CFIndex cap);
extern void CFQSortArray(void *list, CFIndex count, CFIndex elementSize, CFComparatorFunction comparator, void *context);
// state is defined as "struct __objcFastEnumerationStateEquivalent" in CFArray.c
extern unsigned long _CFArrayFastEnumeration(CFArrayRef array, NSFastEnumerationState *state, void *stackbuffer, unsigned long count);

#pragma mark - callbacks

static void PFArrayFindObjectIndeticalTo(const void *value, void *context) {
	// context points to 3 NSUIntegers: result, position, and object address
    NSUInteger *ctx = (NSUInteger *)context;
	if (ctx[0] == NSNotFound) {
        if (ctx[2] == (NSUInteger)value) {
			ctx[0] = ctx[1];
        } else {
			ctx[1]++;
        }
	}
}

// The comparison function for sortUsingSelector:
static CFComparisonResult PFArraySortUsingSelector(const void *val1, const void *val2, void *context) {
	return (CFComparisonResult)[(id)val1 performSelector:(SEL)context withObject:(id)val2];
}

typedef struct _PerformSelectorContext {
    SEL selector;
    id object;
} _PerformSelectorContext;

static void PFArrayMakePerformSelector(const void *value, void *context) {
    [(id)value performSelector:((_PerformSelectorContext *)context)->selector withObject:((_PerformSelectorContext *)context)->object];
}

#pragma mark - utility functions

static CFArrayRef PFArrayInitFromVAList(void *first, va_list args) {
    va_list dargs;
    va_copy(dargs, args);

    CFIndex count = 1;
    while (va_arg(dargs, void *)) count++;
    va_end(dargs);
    
    void **values;
    if (count == 1) {
        values = &first;
    } else {
        void **ptr = values = malloc(count * sizeof(void *));
        *ptr++ = first;
        while ((*ptr++ = va_arg(args, void *))) {}
    }
    
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    free(values);
    return array;
}

// Returns a pointer to an array of copied objects which the caller must free
static void ** PFArrayShallowCopy(CFArrayRef array, CFIndex count) {
    if (!count) count = CFArrayGetCount(array);
    void **values = calloc(count, sizeof(void *));
    CFArrayGetValues((CFArrayRef)array, CFRangeMake(0, count), (const void **)values);
    void **ptr = values;
    while (count--) {
        *ptr = [(id)*ptr copy];
        ptr++;
    }
    return values;
}

// Attempts to load an array from a plist
// TODO: May want to move this out into a utils class so we can use it for dictionaries
static CFArrayRef PFArrayInitFromURL(CFURLRef url, Boolean mutable) {
    CFReadStreamRef stream = CFReadStreamCreateWithFile(kCFAllocatorDefault, url);
    if (!stream) {
        // TODO: Logging
        return NULL;
    }
    CFErrorRef error = NULL;
    CFOptionFlags options = mutable ? kCFPropertyListMutableContainers : kCFPropertyListImmutable;
    CFArrayRef array = CFPropertyListCreateWithStream(kCFAllocatorDefault, stream, 0, options, NULL, &error);
    if (error) {
        // TODO: Logging
        CFRelease(error);
    }
    CFRelease(stream);
    return array;
}

static CFArrayRef PFArrayInitFromPath(CFStringRef path, Boolean mutable) {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    CFArrayRef array = PFArrayInitFromURL(url, mutable);
    CFRelease(url);
    return array;
}

// Attempts to save an array to a plist
// TODO: May want to generalise this and move this out into a utility class
static BOOL PFArraySaveToURL(CFArrayRef array, CFURLRef url, BOOL atomically, CFErrorRef *error) {
    CFWriteStreamRef stream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, url);
    if (!stream) {
        // TODO: Logging
        // TODO: Create and return an error
        return NO;
    }
    CFPropertyListFormat format = kCFPropertyListXMLFormat_v1_0;
    CFIndex length = CFPropertyListWrite(array, stream, format, 0, error);
    CFRelease(stream);
    return length ? YES : NO;
}

static BOOL PFArraySaveToPath(CFArrayRef array, CFStringRef path, BOOL atomically, CFErrorRef *error) {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    BOOL result = PFArraySaveToURL(array, url, atomically, error);
    CFRelease(url);
    return result;
}

@implementation NSArray

#pragma mark - primatives

- (NSUInteger)count { return 0; }
- (id)objectAtIndex:(NSUInteger)index { return nil; }
- (id)firstObject { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

// TODO: add secure coding

- (void)encodeWithCoder:(NSCoder *)aCoder { }
- (id)initWithCoder:(NSCoder *)aDecoder { return nil; }


#pragma mark - Factory methods

+ (instancetype)array {
	return [(id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS) autorelease];
}

+ (instancetype)arrayWithObject:(id)anObject {
    if (!anObject) {
        return [self array];
    }
	return [(id)CFArrayCreate(kCFAllocatorDefault, (const void **)&anObject, 1, ARRAY_CALLBACKS) autorelease];
}

+ (id)arrayWithObjects:(const id *)objects count:(NSUInteger)count {
    if (!objects || !count) {
        return [self array];
    }
    return [(id)CFArrayCreate(kCFAllocatorDefault, (const void **)objects, count, ARRAY_CALLBACKS) autorelease];
}

+ (id)arrayWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self array];
    }
	va_list args;
	va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    va_end(args);
    return [(id)array autorelease];
}

+ (id)arrayWithArray:(NSArray *)array {
    return [(id)CFArrayCreateCopy(kCFAllocatorDefault, (CFArrayRef)array) autorelease];
}

+ (id)arrayWithContentsOfFile:(NSString *)path {
    return [(id)PFArrayInitFromPath((CFStringRef)path, false) autorelease];
}

+ (id)arrayWithContentsOfURL:(NSURL *)url {
    return [(id)PFArrayInitFromURL((CFURLRef)url, false) autorelease];
}

#pragma mark - Immutable init methods

- (instancetype)init {
    free(self);
    return (id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS);
}

- (instancetype)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    if (!objects || !count) {
        return (id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS);
    }
    return (id)CFArrayCreate(kCFAllocatorDefault, (const void **)objects, count, ARRAY_CALLBACKS);
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    va_end(args);
    return (id)array;
}

- (instancetype)initWithArray:(NSArray *)array {
    free(self);
    return (id)CFArrayCreateCopy(kCFAllocatorDefault, (CFArrayRef)array);
}

// TODO: Check what macOS Foundation returns when pass a nil array
- (id)initWithArray:(NSArray *)array copyItems:(BOOL)copy {
    if (!array) {
        return [self init];
    }
    free (self);
    CFIndex count = CFArrayGetCount((CFArrayRef)array);
    if (!copy || !count) {
        return (id)CFArrayCreateCopy(kCFAllocatorDefault, (CFArrayRef)array);
    }
    
    void **values = PFArrayShallowCopy((CFArrayRef)array, count);
    CFArrayRef newArray = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    free(values);
    return (id)newArray;
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFArrayInitFromPath((CFStringRef)path, false);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFArrayInitFromURL((CFURLRef)url, true);
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf 
									count:(NSUInteger)len
{
	return 0; // TODO
}

#pragma mark - Implementations using atomic methods

// TODO

@end

@implementation NSMutableArray

#pragma mark - Factory methods

+ (instancetype)arrayWithCapacity:(NSUInteger)capacity {
    return [(id)CFArrayCreateMutable(kCFAllocatorDefault, capacity, ARRAY_CALLBACKS) autorelease];
}

+ (instancetype)array {
	return [(id)CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS) autorelease];
}

+ (instancetype)arrayWithObject:(id)anObject {
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS);
    if (anObject) {
        CFArrayAppendValue(array, anObject);
    }
    return [(id)array autorelease];
}

+ (id)arrayWithObjects:(const id *)objects count:(NSUInteger)count {
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)objects, count, ARRAY_CALLBACKS);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    CFRelease(array);
    return [(id)mArray autorelease];
}

+ (id)arrayWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self array];
    }
    va_list args;
    va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    CFRelease(array);
    va_end(args);
    return [(id)mArray autorelease];
}

+ (instancetype)arrayWithArray:(NSArray *)array {
    return [(id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFArrayRef)array) autorelease];
}

+ (instancetype)arrayWithContentsOfFile:(NSString *)path {
    return [(id)PFArrayInitFromPath((CFStringRef)path, true) autorelease];
}

+ (instancetype)arrayWithContentsOfURL:(NSURL *)url {
    return [(id)PFArrayInitFromURL((CFURLRef)url, true) autorelease];
}

#pragma mark - Mutable init methods

- (instancetype)init {
    free(self);
    return (id)CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS);
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFArrayCreateMutable(kCFAllocatorDefault, capacity, ARRAY_CALLBACKS);
}

- (instancetype)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)objects, (CFIndex)count, ARRAY_CALLBACKS);
    CFArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, count, array);
    CFRelease(array);
    return (id)array;
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFArrayRef array = PFArrayInitFromVAList(firstObj, args);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, array);
    CFRelease(array);
    va_end(args);
    return (id)mArray;
}

- (instancetype)initWithArray:(NSArray *)array {
    free(self);
    return (id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFArrayRef)array);
}

// TODO: Write some benchmarks to test whether it is quicker to create a mutable array and copy+append each item in turn
- (instancetype)initWithArray:(NSArray *)array copyItems:(BOOL)copy {
    if (!array) {
        return [self init]; // TODO: Check whether this is the correct behaviour
    }
    free (self);
    CFIndex count = CFArrayGetCount((CFArrayRef)array);
    if (!copy || !count) {
        return (id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFArrayRef)array);
    }
    void **values = PFArrayShallowCopy((CFArrayRef)array, count);
    CFArrayRef newArray = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    free(values);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, newArray);
    CFRelease(newArray);
    return (id)mArray;
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFArrayInitFromPath((CFStringRef)path, true);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFArrayInitFromURL((CFURLRef)url, true);
}

// Instance method prototypes
- (void)addObject:(id)anObject {}
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {}
- (void)removeLastObject {}
- (void)removeObjectAtIndex:(NSUInteger)index {}
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {}

@end


@implementation __NSCFArray

#pragma mark - CF bridging

-(CFTypeID)_cfTypeID {
	return CFArrayGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

/*
 *	sjc -- 9/2/09 -- The format now matches Cocoa's. I thought.
 *
 *	Four spaces are placed before each array element. If a tab is chosen, that is placed 
 *	before the four spaces.
 *
 *	At the moment, this won't pass on [descriptionWithLocale:indent:] because I'm not sure
 *	how other objects should react adding the indent...
 */
- (NSString *)description {
	return [self descriptionWithLocale:nil indent:0];
}


- (NSString *)descriptionWithLocale:(id)locale {
	return [self descriptionWithLocale:locale indent:0];
}

// TODO: check that this works and looks sane
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return (id)CFArrayCreateCopy(kCFAllocatorDefault, SELF);
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return (id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return _CFArrayFastEnumeration(SELF, state, stackbuf, len);
}

#pragma mark - saving arrays

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically {
	if (!path.length) return NO;
    return PFArraySaveToPath(SELF, (CFStringRef)path, atomically, NULL);
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
	if (!url) return NO;
    return PFArraySaveToURL(SELF, (CFURLRef)url, atomically, NULL);
}

#pragma mark - primatives

- (NSUInteger)count {
	return (NSUInteger)CFArrayGetCount(SELF);
}

- (id)objectAtIndex:(NSUInteger)index {
	return (id)CFArrayGetValueAtIndex(SELF, (CFIndex)index);
}

#pragma mark - NSArray (NSExtendedArray)

- (NSArray *)arrayByAddingObject:(id)anObject {
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    if (anObject) {
        CFArrayAppendValue(mArray, &anObject);
    }
    return [(id)mArray autorelease];
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFIndex count = 0;
    if (otherArray && (count = CFArrayGetCount((CFArrayRef)otherArray))) {
        CFArrayAppendArray(mArray, (CFArrayRef)otherArray, CFRangeMake(0, count));
    }
    return [(id)mArray autorelease];
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
	return [(id)CFStringCreateByCombiningStrings(kCFAllocatorDefault, SELF, (CFStringRef)separator) autorelease];
}

- (BOOL)containsObject:(id)anObject {
	CFIndex count = CFArrayGetCount(SELF);
	if (!anObject || !count) return NO;
	return CFArrayContainsValue(SELF, CFRangeMake(0, count), (const void *)anObject);
}

- (id)firstObjectCommonWithArray:(NSArray *)otherArray {
    if (otherArray && CFArrayGetCount(SELF) && [otherArray count]) {
        for (id object in self) {
            if ([otherArray containsObject:object]) return object;
        }
    }
	return nil;
}

- (void)getObjects:(id *)objects {
    CFIndex count = CFArrayGetCount(SELF);
    if (!objects || !count) return;
    CFArrayGetValues(SELF, CFRangeMake(0, count), (const void **)objects);
}

- (void)getObjects:(id *)objects range:(NSRange)range {
    NSUInteger count = CFArrayGetCount(SELF);
	if (!objects || !count) return;

    if (range.location >= count || range.location + range.length > count) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	
	CFArrayGetValues(SELF, CFRangeMake(range.location, range.length), (const void **)objects);
}

- (NSUInteger)indexOfObject:(id)anObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!anObject || !count) return NSNotFound;
    CFIndex index = CFArrayGetFirstIndexOfValue(SELF, CFRangeMake(0, count), (const void *)anObject);
    return index == -1 ? NSNotFound : index;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
	NSUInteger count = CFArrayGetCount(SELF);
	if (!anObject || !count) return NSNotFound;
    
    if (range.location >= count || range.location + range.length > count) {
		[NSException raise: NSRangeException format: @"TODO"];
    }
	
	CFIndex result = CFArrayGetFirstIndexOfValue(SELF, CFRangeMake(range.location, range.length), (const void *)anObject);
	return result == -1 ? NSNotFound : result;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!anObject || !count) return NSNotFound;
    NSUInteger context[3] = { NSNotFound, 0, (NSUInteger)anObject };
    CFArrayApplyFunction(SELF, CFRangeMake(0, count), PFArrayFindObjectIndeticalTo, context);
    return context[0];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
	NSUInteger count = CFArrayGetCount(SELF);
	if (!anObject || !count) return NSNotFound;
	
    if (range.location >= count || range.location + range.length > count) {
		[NSException raise: NSRangeException format: @"TODO"];
    }
	
	NSUInteger context[3] = { NSNotFound, range.location, (NSUInteger)anObject };
	CFArrayApplyFunction(SELF, CFRangeMake(range.location, range.length), PFArrayFindObjectIndeticalTo, context);
	return context[0];
}

- (BOOL)isEqualToArray:(NSArray *)otherArray {
    if (!otherArray) return NO;
	return (self == otherArray) || CFEqual((CFTypeRef)self, (CFTypeRef)otherArray);
}

- (id)firstObject {
    CFIndex count = CFArrayGetCount(SELF);
    return count ? (id)CFArrayGetValueAtIndex(SELF, 0) : nil;
}

- (id)lastObject {
	CFIndex count = CFArrayGetCount(SELF);
    return count ? (id)CFArrayGetValueAtIndex(SELF, --count) : nil;
}

// These skip NSEnumerator and instantiate our own enumerator subclass
- (NSEnumerator *)objectEnumerator {
	return [[[PFEnumerator alloc] initWithCFArray:self] autorelease];
}

- (NSEnumerator *)reverseObjectEnumerator {
	return [[[PFReverseEnumerator alloc] initWithCFArray:self] autorelease];
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context {
    NSUInteger count = CFArrayGetCount(SELF);
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    if (comparator && count > 0) {
        CFArraySortValues(mArray, CFRangeMake(0, count), (CFComparatorFunction)comparator, context);
    }
    return [(id)mArray autorelease];
}

/*	"Analyzes the receiver and returns a “hint” that speeds the sorting of the array when the
 *	hint is supplied to sortedArrayUsingFunction:context:hint:."
 */
- (NSData *)sortedArrayHint {
    PF_TODO
    return nil;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint {
	PF_TODO
    return [self sortedArrayUsingFunction:comparator context:context];
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    CFMutableArrayRef mArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    CFIndex count = CFArrayGetCount(SELF);
    if (comparator && count > 1) {
        CFArraySortValues(mArray, CFRangeMake(0, count), PFArraySortUsingSelector, (void *)comparator);
    }
    return [(id)mArray autorelease];
}

// TODO: This is added in NSSortDescriptor.h, and will be implemented once sort decriptors are
- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors { return nil; }

- (NSArray *)subarrayWithRange:(NSRange)range {
    NSUInteger count = CFArrayGetCount(SELF);
    if (!count || !range.length) {
        return [(id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS) autorelease];
    }
    if (range.location >= count || range.location + range.length > count) {
		[NSException raise: NSRangeException format:@"TODO"];
    }
	
	void **values = calloc(range.length, sizeof(void *));
    CFArrayGetValues(SELF, CFRangeMake(range.location, range.length), (const void **)values);
	CFArrayRef newArray = CFArrayCreate(kCFAllocatorDefault, (const void **)values, range.length, ARRAY_CALLBACKS);
	free(values);
    return [(id)newArray autorelease];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    CFIndex count = CFArrayGetCount(SELF);
    if (!aSelector || !count) return;
    _PerformSelectorContext context = { aSelector, nil };
    CFArrayApplyFunction(SELF, CFRangeMake(0, count), PFArrayMakePerformSelector, &context);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    CFIndex count = CFArrayGetCount(SELF);
    if (!aSelector || !count) return;
    _PerformSelectorContext context = { aSelector, argument };
    CFArrayApplyFunction(SELF, CFRangeMake(0, count), PFArrayMakePerformSelector, &context);
}

// TODO: Requires NSIndexSet
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
	PF_TODO
    return nil;
}

// NSMutableArray specific instance methods

- (void)addObject:(id)anObject {
    if (!anObject) return;
	CFArrayAppendValue(MSELF, (const void *)anObject);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    if (index > CFArrayGetCount(SELF)) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFArrayInsertValueAtIndex(MSELF, index, (const void *)anObject);
}

- (void)removeLastObject {
	CFIndex count = CFArrayGetCount(SELF);
    if (!count) return;
	CFArrayRemoveValueAtIndex(MSELF, --count);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (index >= CFArrayGetCount(SELF)) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFArrayRemoveValueAtIndex(MSELF, index);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    if (index >= CFArrayGetCount(SELF)) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFArraySetValueAtIndex(MSELF, index, (const void *)anObject);
}

// NSMutableArray (NSExtendedMutableArray)

- (void)addObjectsFromArray:(NSArray *)otherArray {
    CFIndex count = 0;
    if (otherArray && (count = CFArrayGetCount((CFArrayRef)otherArray))) {
        CFArrayAppendArray(MSELF, (CFArrayRef)otherArray, CFRangeMake(0, count));
    }
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    CFIndex count = CFArrayGetCount(SELF);
    if (idx1 >= count || idx2 >= count) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFArrayExchangeValuesAtIndices(MSELF, idx1, idx2);
}

- (void)removeAllObjects {
	CFArrayRemoveAllValues(MSELF);
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
	CFIndex count = CFArrayGetCount(SELF);
    if (range.location >= count || range.location + range.length > count) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
    CFIndex index = CFArrayGetFirstIndexOfValue(SELF, CFRangeMake(range.location, range.length), (const void *)anObject);
    if (index != -1) {
        CFArrayRemoveValueAtIndex(MSELF, index);
    }
}

- (void)removeObject:(id)anObject {
    CFIndex count = CFArrayGetCount(SELF);
    if (!count) return;
    CFRange range = CFRangeMake(0, count);
    CFIndex index;
    do {
        index = CFArrayGetFirstIndexOfValue(SELF, range, (const void *)anObject);
        if (index != -1) {
            CFArrayRemoveValueAtIndex(MSELF, index);
            range.location = index;
            range.length = count - index;
        }
    } while (index != -1 && range.length);
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    NSUInteger index = NSNotFound;
    NSUInteger end = range.location + range.length;
    do {
        index = [self indexOfObjectIdenticalTo:anObject inRange:range];
        if (index != NSNotFound) {
            CFArrayRemoveValueAtIndex(MSELF, index);
            range.location = index;
            range.length = end - index;
        }
    } while (index != NSNotFound && range.length);
}

- (void)removeObjectIdenticalTo:(id)anObject {
    NSUInteger index = NSNotFound;
    NSUInteger count = CFArrayGetCount(SELF);
    NSRange range = NSMakeRange(0, count);
    do {
        index = [self indexOfObjectIdenticalTo: anObject];
        if (index != NSNotFound) {
            CFArrayRemoveValueAtIndex(MSELF, index);
            range.location = index;
            range.length = count - index;
        }
    } while (index != NSNotFound && range.length);
}

- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)indexCount {
    CFIndex count = CFArrayGetCount(SELF);
	if (!count || !indices || !indexCount) return;
    while (indexCount--) {
        NSUInteger index = *indices++;
        if (index >= count) {
            [NSException raise:NSRangeException format:@"TODO"];
        }
        CFArrayRemoveValueAtIndex(MSELF, index);
        count--;
    }
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    if (!CFArrayGetCount(SELF) || ![otherArray count]) return;
    for (id object in otherArray) {
		[self removeObject:object];
    }
}

// Unlike the implementation described in Apple's documentation, this version does not use -removeObjectAtIndex:
- (void)removeObjectsInRange:(NSRange)range {
	CFIndex count = CFArrayGetCount(SELF);
    if (range.location >= count || range.location + range.length > count) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	CFArrayReplaceValues(MSELF, CFRangeMake(range.location, range.length), NULL, 0);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
	CFIndex count = CFArrayGetCount(SELF);
    if (range.location >= count || range.location + range.length > count) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	
	NSUInteger otherCount = [otherArray count];
    if (otherRange.location > otherCount || otherRange.location + otherRange.length > otherCount) {
		[NSException raise:NSRangeException format:@"TODO"];
    }
	
	void **values = calloc(otherRange.length, sizeof(void *));
    [otherArray getObjects:(id *)values range:otherRange];
	CFArrayReplaceValues(MSELF, CFRangeMake(range.location, range.length), (const void **)values, otherRange.length);
	free(values);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
	[self replaceObjectsInRange:range withObjectsFromArray:otherArray range:NSMakeRange(0, [otherArray count])];
}

- (void)setArray:(NSArray *)otherArray {
    CFArrayRemoveAllValues(MSELF);
	NSUInteger otherCount = [otherArray count];
    if (otherCount) {
        void **values = calloc(otherCount, sizeof(void *));
        [otherArray getObjects:(id *)values];
        CFArrayReplaceValues(MSELF, CFRangeMake(0, 0), (const void **)values, otherCount);
        free(values);
    }
}

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context {
	CFIndex count = CFArrayGetCount(SELF);
	if (!compare || count < 2) return;
	CFArraySortValues(MSELF, CFRangeMake(0, count), (CFComparatorFunction)compare, context);
}

- (void)sortUsingSelector:(SEL)comparator {
	CFIndex count = CFArrayGetCount(SELF);
	if (!comparator || count < 2) return;
	CFArraySortValues(MSELF, CFRangeMake(0, count), PFArraySortUsingSelector, (void *)comparator);
}

// TODO: These methods require NSIndexSet

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
	PF_TODO
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
	PF_TODO
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
	PF_TODO
}

@end

#undef ARRAY_CALLBACKS
#undef SELF
#undef MSELF
