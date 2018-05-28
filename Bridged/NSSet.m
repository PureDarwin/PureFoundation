/*
 *  PureFoundation -- http://www.puredarwin.org
 *	NSSet.m
 *
 *	NSSet, NSMutableSet, NSCFSet
 *
 *	Created by Stuart Crook on 26/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import <Foundation/NSSet.h>
#import "PureFoundation.h"
#import "PFEnumerator.h"

#define SET_CALLBACKS   (&_PFCollectionCallBacks)

#define ARRAY_CALLBACKS ((CFArrayCallBacks *)&_PFCollectionCallBacks)

#define SELF ((CFSetRef)self)
#define MSELF ((CFMutableSetRef)self)

@interface __NSCFSet : NSMutableSet
@end

// From CF
// CFSetRef was CFHashRef
// NSFastEnumerationState was struct __objcFastEnumerationStateEquivalent
CF_EXPORT unsigned long _CFSetFastEnumeration(CFSetRef hc, NSFastEnumerationState *state, void *stackbuffer, unsigned long count);

static CFSetRef PFSetInitFromVAList(void *first, va_list args) {
    va_list dargs;
    va_copy(dargs, args);
    CFIndex count = 1;
    while (va_arg(dargs, void *)) count++;
    va_end(dargs);
    
    void **objects = NULL;
    if (count == 1) {
        objects = &first;
    } else {
        void **ptr = objects = malloc(count * sizeof(void *));
        *ptr++ = first;
        while ((*ptr++ = va_arg(args, void *))) {}
    }
    
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
    if (count > 1) free(objects);
    return set;
}

static CFSetRef PFSetShallowCopy(CFSetRef set, CFIndex count) {
    if (!count) count = CFSetGetCount(set);
    void **values = calloc(count, sizeof(void *));
    CFSetGetValues(set, (const void **)values);
    void **ptr = values;
    while (count--) {
        *ptr = [(id)*ptr copy];
        ptr++;
    }
    CFSetRef newSet = CFSetCreate(kCFAllocatorDefault, (const void **)values, count, SET_CALLBACKS);
    free(values);
    return newSet;
}


@implementation NSSet

#pragma mark - immutable factory methods

+ (id)set {
    return [(id)CFSetCreate(kCFAllocatorDefault, NULL, 0, SET_CALLBACKS) autorelease];
}

+ (id)setWithObject:(id)object {
    return [(id)CFSetCreate(kCFAllocatorDefault, (const void **)&object, 1, SET_CALLBACKS) autorelease];
}

+ (id)setWithObjects:(const id *)objects count:(NSUInteger)count {
    return [(id)CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS) autorelease];
}

+ (id)setWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self set];
    }
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    return [(id)set autorelease];
}

+ (id)setWithSet:(NSSet *)set {
    return [(id)CFSetCreateCopy(kCFAllocatorDefault, (CFSetRef)set) autorelease];
}

+ (id)setWithArray:(NSArray *)array {
	PF_HELLO("")
	return [[[self alloc] initWithArray: array] autorelease];
}

#pragma mark - immutable init methods

- (id)init {
    free(self);
    return (id)CFSetCreate(kCFAllocatorDefault, NULL, 0, SET_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    return (id)CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    return (id)set;
}

- (id)initWithSet:(NSSet *)set {
    free(self);
    return (id)CFSetCreateCopy(kCFAllocatorDefault, (CFSetRef)set);
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)copy {
    CFIndex count = CFSetGetCount((CFSetRef)set);
    if (!count) {
        return [self init];
    }
    if (!copy) {
        return [self initWithSet:set];
    }
    free(self);
    return (id)PFSetShallowCopy((CFSetRef)set, count);
}

- (id)initWithArray:(NSArray *)array {
    free(self);
    CFIndex count = CFArrayGetCount((CFArrayRef)array);
    if (!count) {
        return (id)CFSetCreate(kCFAllocatorDefault, NULL, 0, SET_CALLBACKS);
    }
    void *values = malloc(count * sizeof(void *));
    [array getObjects:values];
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)values, count, SET_CALLBACKS);
    free(values);
    return (id)set;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
    free(self);
    return nil;
}

#pragma mark - instance method prototypes

- (NSUInteger)count { return 0; }
- (id)member:(id)object { return nil; }
- (NSEnumerator *)objectEnumerator { return nil; }

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone { return nil; }

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len { return 0; }

@end


@implementation NSMutableSet

#pragma mark - mutable factory methods

+ (id)set {
	return [(id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS) autorelease];
}

+ (id)setWithCapacity:(NSUInteger)capacity {
	return [(id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS) autorelease];
}

+ (id)setWithObject:(id)object {
    CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    CFSetAddValue(set, object);
    return [(id)set autorelease];
}

+ (id)setWithObjects:(const id *)objects count:(NSUInteger)count {
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

+ (id)setWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self set];
    }
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, 0, set);
    CFRelease(self);
    return [(id)mSet autorelease];
}

+ (id)setWithSet:(NSSet *)set {
    return [(id)CFSetCreateMutableCopy(kCFAllocatorDefault, 0, (CFSetRef)set) autorelease];
}

+ (id)setWithArray:(NSArray *)array {
    NSUInteger count = [array count];
    if (!count) {
        return [(id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS) autorelease];
    }
    void **values = malloc(count * sizeof(void *));
    [array getObjects:(id *)values];
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)values, count, SET_CALLBACKS);
    free(values);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return [(id)mSet autorelease];
}

#pragma mark - mutable init methods

- (id)init {
    free(self);
    return (id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
}

- (id)initWithObjects:(const id *)objects count:(NSUInteger)count {
    free(self);
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void **)objects, count, SET_CALLBACKS);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return (id)mSet;
}

- (id)initWithObjects:(id)firstObj, ... {
    if (!firstObj) {
        return [self init];
    }
    free(self);
    va_list args;
    va_start(args, firstObj);
    CFSetRef set = PFSetInitFromVAList(firstObj, args);
    va_end(args);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, 0, set);
    CFRelease(self);
    return (id)mSet;
}

- (id)initWithSet:(NSSet *)set {
    free(self);
    return (id)CFSetCreateMutableCopy(kCFAllocatorDefault, 0, (CFSetRef)set);
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)copy {
    CFIndex count = CFSetGetCount((CFSetRef)set);
    if (!count) {
        return [self init];
    }
    if (!copy) {
        return [self initWithSet:set];
    }
    free(self);
    CFSetRef newSet = PFSetShallowCopy((CFSetRef)set, count);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, newSet);
    CFRelease(newSet);
    return (id)mSet;
}

- (id)initWithArray:(NSArray *)array {
    free(self);
    NSUInteger count = [array count];
    if (!count) {
        return (id)CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    }
    void **values = malloc(count * sizeof(void *));
    [array getObjects:(id *)values];
    CFSetRef set = CFSetCreate(kCFAllocatorDefault, (const void**)values, count, SET_CALLBACKS);
    free(values);
    CFMutableSetRef mSet = CFSetCreateMutableCopy(kCFAllocatorDefault, count, set);
    CFRelease(set);
    return (id)mSet;
}

- (id)initWithCapacity:(NSUInteger)capacity {
    free(self);
    return (id)CFSetCreateMutable(kCFAllocatorDefault, capacity, SET_CALLBACKS);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    PF_TODO
    free(self);
    return nil;
}

#pragma mark - mutable instance method prototypes

- (void)addObject:(id)object { }
- (void)removeObject:(id)object { }

@end


@implementation __NSCFSet

- (CFTypeID)_cfTypeID {
	return CFSetGetTypeID();
}

// Standard bridged-class over-rides
- (id)retain { return (id)CFRetain((CFTypeRef)self); }
- (NSUInteger)retainCount { return (NSUInteger)CFGetRetainCount((CFTypeRef)self); }
- (oneway void)release { CFRelease((CFTypeRef)self); }
- (void)dealloc { } // this is missing [super dealloc] on purpose, XCode
- (NSUInteger)hash { return CFHash((CFTypeRef)self); }

/*
 *	See NSArray.h, -[NSCFArray countByEnumeratingWithState:...] for the gory details
 *
 *	This actually points to its _count var, which should also do the trick
 */
#define PF_SET_MO 24

/*
 *	NSFastEnumeration support. Based on example code from
 *		http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html
 *
 *	A dictionary enumerates over its keys
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)length {
    return _CFSetFastEnumeration(SELF, state, state, length);
}

-(NSString *)description {
	return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale {
    PF_TODO
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSUInteger)count {
	return CFSetGetCount(SELF);
}

- (id)member:(id)object {
    return object ? (id)CFSetGetValue(SELF, (const void *)object) : nil;
}

// TODO: Replace PFEnumerator with a NSEnumerator
- (NSEnumerator *)objectEnumerator {
	return [[[PFEnumerator alloc] initWithCFSet: self] autorelease];
}

- (NSArray *)allObjects {
    CFIndex count = CFSetGetCount(SELF);
    void **values = NULL;
    if (count) {
        values = malloc(count * sizeof(void *));
        CFSetGetValues(SELF, (const void **)values);
    }
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, ARRAY_CALLBACKS);
    if (count) free(values);
	return [(id)array autorelease];
}

- (id)anyObject {
    // TODO: See if there's a better way of doing this. Maybe implement in CF.
	NSUInteger count = CFSetGetCount((CFSetRef)self);
	if (!count) return nil;
	void *objects = malloc(count * sizeof(void *));
	CFSetGetValues((CFSetRef)self, (const void **)objects);
	id randomishObject = *(id *)objects;
	free(objects);
	return randomishObject;
}

- (BOOL)containsObject:(id)anObject {
    return anObject ? CFSetContainsValue(SELF, (const void *)anObject) : NO;
}

- (BOOL)isEqualToSet:(NSSet *)otherSet {
    if (!otherSet) return NO;
	return (self == otherSet) || CFEqual((CFTypeRef)self, (CFTypeRef)otherSet);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    if (!aSelector) return;
    for (id object in self) {
		[object performSelector:aSelector];
    }
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    if (!aSelector) return;
    for (id object in self) {
        [object performSelector:aSelector withObject:argument];
    }
}

- (BOOL)intersectsSet:(NSSet *)otherSet {
    // TODO: Check the logic used here
    if (!otherSet || ![otherSet count] || !CFSetGetCount(SELF)) {
        return NO;
    }
    for (id object in otherSet) {
        if (CFSetContainsValue(SELF, (const void *)object)) {
            return YES;
        }
    }
	return NO;
}

- (BOOL)isSubsetOfSet:(NSSet *)otherSet {
    for (id object in self) {
        if (!CFSetContainsValue((CFSetRef)otherSet, (const void *)object)) {
            return NO;
        }
    }
	return YES;
}

- (NSSet *)setByAddingObject:(id)anObject {
    CFMutableSetRef set = CFSetCreateMutableCopy(kCFAllocatorDefault, 0, SELF);
    if (anObject) {
        CFSetAddValue(set, (const void *)anObject);
    }
    return [(id)set autorelease];
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other {
    CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    for (id object in other) {
        CFSetAddValue(set, (const void *)object);
    }
    return [(id)set autorelease];
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other {
    CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 0, SET_CALLBACKS);
    for (id object in other) {
        CFSetAddValue(set, (const void *)object);
    }
    return [(id)set autorelease];
}

- (void)addObject:(id)object {
    if (!object) return;
	CFSetAddValue(MSELF, (const void*)object);
}

- (void)removeObject:(id)object {
    if (!object) return;
	CFSetRemoveValue(MSELF, (const void*)object);
}

- (void)removeAllObjects {
	CFSetRemoveAllValues(MSELF);
}

- (void)addObjectsFromArray:(NSArray *)array {
    for (id object in array) {
		CFSetAddValue(MSELF, (const void *)object);
    }
}

- (void)setSet:(NSSet *)otherSet {
    CFSetRemoveAllValues(MSELF);
    for (id object in otherSet) {
        CFSetAddValue(MSELF, (const void *)object);
    }
}

- (void)intersectSet:(NSSet *)otherSet {
    // TODO: Check logic here
    if (!otherSet || ![otherSet count]) {
        CFSetRemoveAllValues(MSELF);
        return;
    }
	CFMutableSetRef mSet = CFSetCreateMutable(kCFAllocatorDefault, 0, NULL);
	// find all of the objects which are in self but not otherSet...
    for (id object in self) {
        if (![otherSet containsObject:object]) {
			CFSetAddValue(mSet, (const void *)object);
        }
    }
	// ...and then remove them
    for (id object in (NSSet *)mSet) {
		CFSetRemoveValue(MSELF, (const void *)object);
    }
    CFRelease(mSet);
}

- (void)minusSet:(NSSet *)otherSet {
    // TODO: Check logic here
	if (!otherSet || ![otherSet count] || !CFSetGetCount(SELF)) return;
    for (id object in otherSet) {
		CFSetRemoveValue(MSELF, (const void *)object);
    }
}

- (void)unionSet:(NSSet *)otherSet {
    // TODO: Check logic here
	if (!otherSet || ![otherSet count]) return;
    for (id object in otherSet) {
		CFSetAddValue(MSELF, (const void *)object);
    }
}

@end
