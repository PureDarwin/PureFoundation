/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSInvocation.m
 *
 *	NSInvocation
 *
 *	Created by Stuart Crook on 07/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSInvocation.h"
#import "PureFoundation.h"
#import <objc/message.h>
#import "GSNextRuntime.h"
#import "PFObjCTypeTools.h"
#include <ffi/ffi.h>

#define PF_RET_UNKNOWN	0
#define PF_RET_SIMPLE	1
#define PF_RET_SMALL	2
#define PF_RET_FLOAT	3
#define PF_RET_STRUCT	4

// storage for some useful info, going into _container
typedef struct __PFInvocationStorage { 
	ffi_cif cif;
	unsigned int *offsets;
	unsigned int *sizes;
} _PFInvocationStorage;

@interface NSInvocation (NSInvocationPFPrivateInit)
-(id)initWithMethodSignature:(NSMethodSignature *)sig;
@end

/*
 *
 *	void *_frame;	// pass to ffi_call as args
 *	void *_retdata;	// depending on return type, either add to the front of _frame 
 *					//	or pass as return value to ffi_call
 *	id _signature;	// will point to the NSMethodSignature object
 *	id _container;	// the ffi_cfi we'll be using
 *	uint8_t _retainedArgs;  // treated as a BOOL
 *	uint8_t _reserved[15];  // _reserved[0] as an "invoked" flag
 *							// _reserved[1] as a return type marker
 *							// _reserved[2] as argument count (a bit limiting, I know)
 *			// _reserved[3-6] point to list of argument offsets
 *			// _reserved[7-10] point to a list of argument sizes
 *
 *	To make things a little easier, we'll map across this structure:
 */
typedef struct _pf_inv {
	void *_frame;
	void *_retdata;
	id _signature;
	//ffi_cfi _cfi;
	BOOL _retainedArgs;
	BOOL _invoked;
	char _retType;
	uint8_t _argCount;
	NSUInteger *_offsets;
	NSUInteger *_sizes;
} _pf_inv;


/*
 *	NSInvocation
 */
@implementation NSInvocation

+ (NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)sig
{
	return [[[self alloc] initWithMethodSignature: sig] autorelease];
}

-(id)initWithMethodSignature: (NSMethodSignature *)sig
{
	const char *typedesc;
	unsigned int returnSize = 0;
	unsigned int frameSize = 0;
	unsigned int framePadding = 0;
	unsigned int mallocSize = 0;
	unsigned int argCount = 0;
	

	ffi_type *rtype; // the return value for the cif
	
	//printf("Welcome to my NSInvocation attempt\n");
	
	// do we have a method signature to build to?
	if( (sig == nil) || ((typedesc = [sig _typeString]) == NULL) ) return nil;
	
	//printf("\ttypedesc: %s\n", typedesc);
	
	// process the method type description, return type first
	typedesc = objc_skip_type_qualifiers(typedesc);

	//printf("\treturn type: %c\n", typedesc);
	
	// which of the objc_msgSend functions should we use?
	// should also set the cif return type -- rtype -- here, too
	if( *typedesc == _C_UNION_B )
		return nil; // we don't do unions
	else if( *typedesc == _C_STRUCT_B )
	{
		_reserved[1] = PF_RET_STRUCT;
		framePadding = sizeof(void *);
		mallocSize = sizeof(ffi_type *); // one extra ffi argument
	}
	else if( (*typedesc == _C_FLT) || (*typedesc == _C_DBL) ) 
		_reserved[1] = PF_RET_FLOAT;
	else
		_reserved[1] = PF_RET_SIMPLE;
	
	returnSize = objc_sizeof_type(typedesc);
	if( returnSize < sizeof(long) )
	{ 
		_reserved[1] = PF_RET_SMALL;
		returnSize = sizeof(ffi_arg);
	}
	else
	{	// promoted size, copied from GSNextRuntime.m objc_promoted_size()
		returnSize = sizeof(void*) * ((returnSize + sizeof (void*) - 1) / sizeof(void*));
	}
	
	//printf("\tinvocation type: %u\n", _reserved[1]);
	//printf("\treturn size: %u\n", returnSize);
	
	// move on to the frame size provided by the runtime
	typedesc = objc_skip_typespec(typedesc);
	frameSize = pf_get_offset(&typedesc); // reads the number from the pointer
	
	argCount = [sig numberOfArguments];
	
	//printf("\tframeSize: %u\n", frameSize);
	//printf("\targ count: %u\n", argCount);
	
	// in an attempt at being clever, we'll alloc all of our storage at once
	mallocSize += returnSize + frameSize + framePadding + (2 * argCount * sizeof(unsigned int)) + sizeof(_PFInvocationStorage);
	
	mallocSize = (unsigned int)malloc(mallocSize); // make it a little easier to divide up
	
	//printf("\tmalloced storage at 0x%X\n", mallocSize);
	
	// neatly divide up the memory
	// _frame gets mallocSize
	//printf("\t_frame at 0x%X\n", mallocSize);
	_frame = (void *)mallocSize;
	
	// _retdata gets that + returnSize
	mallocSize += returnSize;
	//printf("\t_retdata at 0x%X\n", mallocSize);
	_retdata = (void *)mallocSize;
	
	// _container gets that + frameSize + framePadding
	mallocSize += frameSize + framePadding;
	//printf("\t_container at 0x%X\n", mallocSize);
	_container = (id)mallocSize;
	
	// _container.offsets gets that + sizeof(_PFInvocationStorage)
	mallocSize += sizeof(_PFInvocationStorage);
	//printf("\t_frame.offsets at 0x%X\n", mallocSize);
	((_PFInvocationStorage *)_container)->offsets = (unsigned int*)mallocSize;
	unsigned int *offsets = (unsigned int *)mallocSize;
	
	// _container.sizes gets that + (argCount * sizeof(unsigned int))
	mallocSize += (argCount * sizeof(unsigned int));
	//printf("\t_frame.sizes at 0x%X\n", mallocSize);
	((_PFInvocationStorage *)_container)->sizes = (unsigned int *)mallocSize;
	unsigned int *sizes = (unsigned int *)mallocSize;
	
	// arg_ptr gets that + (argCount * sizeof(unsigned int))
	mallocSize += (argCount * sizeof(unsigned int));
	//printf("\targ_ptr at 0x%X\n", mallocSize);
	ffi_type **arg_ptr = (ffi_type **)mallocSize;
	
	// this adjusts upwards the pointer we're be using in the loop
	if( _reserved[1] == PF_RET_STRUCT ) 
		*arg_ptr++ = rtype;
	
	// we could use a while( *typedesc != '\0' ), but this means we don't go over
	// the alloced memory if the string was interpreted wrongly
	for( int i = 0; i < argCount; i++ )
	{
		//printf("\tloop %u for type %c\n", i, *typedesc);
		arg_ptr[i] = signature_to_ffi_type(typedesc);
		//printf("\t\tffi type: 0x%X\n", arg_ptr[i]);
		sizes[i] = objc_sizeof_type(typedesc);
		//printf("\t\tsize: %u\n", sizes[i]);
		typedesc = objc_skip_typespec(typedesc);
		offsets[i] = pf_get_offset(&typedesc); // + framePadding; ???? 
		//printf("\t\toffset: %u\n", offsets[i]);
	}
	
	// this is to re-adjust the pointer back to what it was
	if( _reserved[1] == PF_RET_STRUCT )
	{
		arg_ptr--;
		argCount++;
	}
	
	// create the cif structure
				// was &(((_PFInvocationStorage*)_container)->cif)
	if( ffi_prep_cif( (ffi_cif *)_container, FFI_DEFAULT_ABI, argCount, rtype, arg_ptr ) != FFI_OK )
	{
		free(_frame); 
		//printf("\t--- ffi_prep_cif failed\n");
		return nil;
	}
	
	//printf("\tffi_prep_cif suceeded, and I think we're done\n");
	
	// fix up the instance variables
	_signature = [sig retain];
	_retainedArgs = NO;
	_reserved[0] = NO;
	_reserved[2] = (uint8_t)argCount;
	
	// and we're done setting-up
	return self;
}

- (NSMethodSignature *)methodSignature
{
	return _signature;
}

/*
 *	"If the receiver hasn’t already done so, retains the target and all object 
 *	arguments of the receiver and copies all of its C-string arguments."
 */
- (void)retainArguments
{
	// if _retainedArgs == YES, we've already retained the existing arguments and
	//	retained new args as they're added
	if( _retainedArgs != YES )
	{
		
	}
}

- (BOOL)argumentsRetained
{
	return (BOOL)_retainedArgs;
}

- (id)target
{
	return nil;
}

- (void)setTarget:(id)target
{
}

- (SEL)selector
{
	return nil;
}

- (void)setSelector:(SEL)selector {}

- (void)getReturnValue:(void *)retLoc {}
- (void)setReturnValue:(void *)retLoc {}

- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx {}
- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx {}

- (void)invoke 
{
	//objc_msgSendv(self, @selector(invok), 0, NULL );
	
}
- (void)invokeWithTarget:(id)target {}


@end

