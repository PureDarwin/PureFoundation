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
#import "FileLoaders.h"

#define KEY_CALLBACKS (&kCFTypeDictionaryKeyCallBacks)
#define VALUE_CALLBACKS ((CFDictionaryValueCallBacks *)&_PFCollectionCallBacks)

#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)

#define SELF ((CFDictionaryRef)self)
#define MSELF ((CFMutableDictionaryRef)self)

@interface __NSCFDictionary : NSMutableDictionary
@end

// From CF
extern bool _CFDictionaryIsMutable( CFDictionaryRef dict );
// CFDictionaryRef was originally CFHashRef
// NSFastEnumerationState * was originally struct __objcFastEnumerationStateEquivalent *
extern unsigned long _CFDictionaryFastEnumeration(CFDictionaryRef hc, NSFastEnumerationState *state, void *stackbuffer, unsigned long count);

#pragma mark - callbacks

typedef struct _PFKeysForObject {
    id object;
    CFMutableArrayRef array;
} _PFKeysForObject;

// find objects where isEqual: context[1] and put them into context[2]
static void PFKeysForObject(const void *key, const void *value, void *context) {
    _PFKeysForObject *ctx = context;
    if ([(id)value isEqual:ctx->object]) {
		CFArrayAppendValue(ctx->array, key);
    }
}

static CFDictionaryRef PFDictionaryInitFromVAList(void *first, va_list args) {
    va_list dargs;
    va_copy(dargs, args);
    CFIndex count = 1;
    while (va_arg(dargs, void *)) count++;
    va_end(dargs);
    
    if (count & 1) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    count /= 2;
    
    void **objects = NULL;
    void **keys = NULL;
    if (count == 1) {
        objects = &first;
        keys = va_arg(args, void *);
    } else {
        void **o_ptr = objects = malloc(count * sizeof(void *));
        void **k_ptr = keys = malloc(count * sizeof(void *));
        *o_ptr++ = first;
        *k_ptr++ = va_arg(args, void *);
        while ((*o_ptr++ = va_arg(args, void *))) {
            *k_ptr++ = va_arg(args, void *);
        }
    }
    
    CFDictionaryRef dict = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS);
    if (count > 1) {
        free(objects);
        free(keys);
    }
    return dict;
}

static CFDictionaryRef PFDictionaryInitFromArrays(CFArrayRef keys, CFArrayRef values) {
    CFIndex keysCount = CFArrayGetCount(keys);
    CFIndex valuesCount = CFArrayGetCount(values);
    if (keysCount != valuesCount) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
    void **pKeys = NULL;
    void **pValues = NULL;
    if (keysCount) {
        pKeys = malloc(keysCount * sizeof(void *));
        pValues = malloc(valuesCount * sizeof(void *));
        CFRange range = CFRangeMake(0, keysCount);
        CFArrayGetValues(keys, range, (const void **)pKeys);
        CFArrayGetValues(values, range, (const void **)pValues);
    }
    CFDictionaryRef dict = CFDictionaryCreate(kCFAllocatorDefault, (const void **)pKeys, (const void **)pValues, keysCount, KEY_CALLBACKS, VALUE_CALLBACKS);
    if (keysCount) {
        free(pKeys);
        free(pValues);
    }
    return dict;
}

static CFDictionaryRef PFDictionaryShallowCopyingValues(CFDictionaryRef dict, CFIndex count) {
    if (!count) count = CFDictionaryGetCount(dict);
    void **keys = malloc(count * sizeof(void *));
    void **values = malloc(count * sizeof(void *));
    CFDictionaryGetKeysAndValues(dict, (const void **)keys, (const void **)values);
    CFIndex c = count;
    id *ptr = (id *)values;
    while (c--) *ptr = [*ptr copy];
    CFDictionaryRef newDict = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, count, KEY_CALLBACKS, VALUE_CALLBACKS);
    free(keys);
    free(values);
    return newDict;
}


@implementation NSDictionary

#pragma mark - immutable factory methods

+ (id)dictionary {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, NULL, NULL) autorelease];
}

+ (id)dictionaryWithObject:(id)object forKey:(id)key {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, (const void **)&key, (const void **)&object, 1, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self dictionary];
    }
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    return [(id)dict autorelease];
}

+ (id)dictionaryWithDictionary:(NSDictionary *)dict {
    return [(id)CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)dict) autorelease];
}

+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    return [(id)PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects) autorelease];
}

+ (id)dictionaryWithContentsOfFile:(NSString *)path {
    return [(id)PFPropertyListInitFromPath((CFStringRef)path, false) autorelease];
}

+ (id)dictionaryWithContentsOfURL:(NSURL *)url {
    return [(id)PFPropertyListInitFromURL((CFURLRef)url, false) autorelease];
}

#pragma mark - immutable init methods

- (id)init {
    free(self);
    return (id)CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    return [(id)CFDictionaryCreate(kCFAllocatorDefault, (const void**)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

- (id)initWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    return (id)dict;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    free(self);
    return (id)CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)otherDictionary);
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)copy {
    free(self);
    CFIndex count = CFDictionaryGetCount((CFDictionaryRef)otherDictionary);
    if (!count) {
        return (id)CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
    }
    if (!copy) {
        return (id)CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)otherDictionary);
    }
    return (id)PFDictionaryShallowCopyingValues((CFDictionaryRef)otherDictionary, count);
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    free(self);
    return (id)PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
}

- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFPropertyListInitFromPath((CFStringRef)path, false);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFPropertyListInitFromURL((CFURLRef)url, false);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
    free(self);
    return nil;
}

#pragma mark - instance method prototypes

- (NSUInteger)count { return 0; }
- (id)objectForKey:(id)aKey { return nil; }
- (NSEnumerator *)keyEnumerator { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len { return 0; }

@end


@implementation NSMutableDictionary

#pragma mark - mutable factory methods

+ (id)dictionary {
    return [(id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithCapacity:(NSUInteger)capacity {
	return [(id)CFDictionaryCreateMutable(kCFAllocatorDefault, capacity, KEY_CALLBACKS, VALUE_CALLBACKS) autorelease];
}

+ (id)dictionaryWithObject:(id)object forKey:(id)key {
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
    CFDictionaryAddValue(dict, (const void *)key, (const void *)object);
    return [(id)dict autorelease];
}

+ (id)dictionaryWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    CFDictionaryRef dict = PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return [(id)mDict autorelease];
}

+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self init];
    }
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    CFDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return [(id)mDict autorelease];
}

+ (id)dictionaryWithDictionary:(NSDictionary *)dict {
    return [(id)CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)dict) autorelease];
}

+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    CFDictionaryRef dict = PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return [(id)mDict autorelease];
}

+ (id)dictionaryWithContentsOfFile:(NSString *)path {
    return [(id)PFPropertyListInitFromPath((CFStringRef)path, true) autorelease];
}

+ (id)dictionaryWithContentsOfURL:(NSURL *)url {
    return [(id)PFPropertyListInitFromURL((CFURLRef)url, true) autorelease];
}

#pragma mark - mutable initialisers

- (id)init {
    free(self);
    return (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFDictionaryCreateMutable(kCFAllocatorDefault, capacity, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects forKeys:(const id<NSCopying> *)keys count:(NSUInteger)count {
    free(self);
    return (id)CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)objects, count, KEY_CALLBACKS, VALUE_CALLBACKS);
}

- (id)initWithObjectsAndKeys:(id)firstObject, ... {
    if (!firstObject) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObject);
    CFDictionaryRef dict = PFDictionaryInitFromVAList(firstObject, args);
    va_end(args);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return (id)mDict;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    free(self);
    return (id)CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)otherDictionary);
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)copy {
    free(self);
    CFIndex count = CFDictionaryGetCount((CFDictionaryRef)otherDictionary);
    if (!count) {
        return (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, KEY_CALLBACKS, VALUE_CALLBACKS);
    }
    if (!copy) {
        return (id)CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)otherDictionary);
    }
    CFDictionaryRef dict = PFDictionaryShallowCopyingValues((CFDictionaryRef)otherDictionary, count);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return (id)mDict;
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    free(self);
    CFDictionaryRef dict = PFDictionaryInitFromArrays((CFArrayRef)keys, (CFArrayRef)objects);
    CFMutableDictionaryRef mDict = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, dict);
    CFRelease(dict);
    return (id)mDict;
}

- (id)initWithContentsOfFile:(NSString *)path {
    free(self);
    return (id)PFPropertyListInitFromPath((CFStringRef)path, true);
}

- (id)initWithContentsOfURL:(NSURL *)url {
    free(self);
    return (id)PFPropertyListInitFromURL((CFURLRef)url, true);
}

#pragma mark - instance method prototypes

- (void)removeObjectForKey:(id)aKey {}
- (void)setObject:(id)anObject forKey:(id)aKey {}

@end


@implementation __NSCFDictionary

-(CFTypeID)_cfTypeID {
	return CFDictionaryGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)length {
    return _CFDictionaryFastEnumeration((CFDictionaryRef)self, state, stackbuf, length);
}

#pragma mark - instance methods

- (NSString *)description {
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale {
	PF_TODO
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
	PF_TODO
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionInStringsFileFormat {
    PF_TODO
    return nil;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically {
    return PFPropertyListSaveToPath(SELF, (CFStringRef)path, atomically, NULL);
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
    return PFPropertyListSaveToURL(SELF, (CFURLRef)url, atomically, NULL);
}

#pragma mark - instance methods

- (NSUInteger)count {
	return CFDictionaryGetCount(SELF);
}

- (id)objectForKey:(id)aKey {
    return aKey ? (id)CFDictionaryGetValue(SELF, (const void *)aKey ) : nil;
}

// TODO: PFEnumerator should become NSEnumerator
- (NSEnumerator *)keyEnumerator {
	return [[[PFEnumerator alloc] initWithCFDictionaryKeys: self] autorelease];
}

// TODO: PFEnumerator should become NSEnumerator
- (NSEnumerator *)objectEnumerator {
	return [[[PFEnumerator alloc] initWithCFDictionaryValues: self] autorelease];
}

- (NSArray *)allKeys {
	CFIndex count = CFDictionaryGetCount(SELF);
    const void **keys = NULL;
    if (count) {
        keys = calloc(count, sizeof(void *));
        CFDictionaryGetKeysAndValues(SELF, keys, NULL);
    }
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, keys, count, ARRAY_CALLBACKS);
    if (keys) free(keys);
	return [(id)array autorelease];
}

- (NSArray *)allValues {
    CFIndex count = CFDictionaryGetCount(SELF);
    const void **values = NULL;
    if (count) {
        values = calloc(count, sizeof(void *));
        CFDictionaryGetKeysAndValues(SELF, NULL, values);
    }
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, values, count, ARRAY_CALLBACKS);
    if (values) free(values);
    return [(id)array autorelease];
}

- (NSArray *)allKeysForObject:(id)anObject {
    if (!anObject || !CFDictionaryGetCount(SELF)) {
        return [(id)CFArrayCreate(kCFAllocatorDefault, NULL, 0, ARRAY_CALLBACKS) autorelease];
    }
    _PFKeysForObject context = { anObject, CFArrayCreateMutable(kCFAllocatorDefault, 0, ARRAY_CALLBACKS) };
	CFDictionaryApplyFunction(SELF, PFKeysForObject, &context);
    return [(id)context.array autorelease];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary {
	if (!otherDictionary) return NO;
	return (self == otherDictionary) || CFEqual((CFTypeRef)self, (CFTypeRef)otherDictionary);
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {
	NSUInteger count = [keys count];
	if (!count) return [NSArray array];
	
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
- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
	PF_TODO
    return nil;
}

- (void)getObjects:(id *)objects andKeys:(id *)keys {
	CFDictionaryGetKeysAndValues(SELF, (const void **)keys, (const void **)objects);
}

#pragma mark - NSMutableDictionary instance methods

- (void)removeObjectForKey:(id)aKey {
    if (!aKey) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
	CFDictionaryRemoveValue(MSELF, (const void *)aKey);
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    if (!anObject || !aKey) {
        [NSException raise:NSInvalidArgumentException format:@"TODO"];
    }
	CFDictionarySetValue(MSELF, (const void *)aKey, (const void *)anObject);
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
	NSUInteger count = [otherDictionary count];
	if (!count) return;
	
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

- (void)removeAllObjects {
	CFDictionaryRemoveAllValues(MSELF);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
	if( (CFDictionaryGetCount((CFDictionaryRef)self) == 0) || ([keyArray count] == 0) ) return;
	
	for( id key in keyArray )
		CFDictionaryRemoveValue( (CFMutableDictionaryRef)self, (const void *)key );
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
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

#undef KEY_CALLBACKS
#undef VALUE_CALLBACKS
#undef ARRAY_CALLBACKS
#undef SELF
#undef MSELF
