/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	PFObjCTypeTools.m
 *
 *	Functions for parsing method description strings
 *
 *	Created by Stuart Crook on 07/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "PFObjCTypeTools.h"
//#import "GSNextRuntime.h"

#import <ffi/ffi.h>
#import <objc/runtime.h>

/*
 *	This file collects together TypeDesc encoding functions from various
 *	sources and refactors them into the minimum number of specific calls
 *	which PureFoundation needs.
 */

#define PF_ALIGNED_SIZE(s,a) (a * ((s + a - 1) / a))

/*
 *	Process the next element of the typedesc pointed to by type, which should
 *	be followed by an integer offset. If the size and offset vars aren't NULL,
 *	return the recovered values in them.
 */
const char *pfenc_process(const char *type, NSUInteger *size, NSUInteger *offset)
{
	//type = pfenc_skip(type); we'll get pfenc_size() to call this
	type = pfenc_size_align(type, size, NULL);
	type = pfenc_offset(type, offset);
	return type;
}

/*
 *	Skip the type qualifier at the start of a type.
 *
 *	Was objc_skip_type_qualifiers() from GNUStep
 */
// inline this?
const char *pfenc_skip(const char* type)
{
	while (*type == _C_CONST
		   || *type == _C_IN
		   || *type == _C_INOUT
		   || *type == _C_OUT
		   || *type == _C_BYCOPY
		   || *type == _C_BYREF
		   || *type == _C_ONEWAY)
    {
		type += 1;
    }
	return type;
}

/*
 *	Return the size and alignment of the type pointed to by type, moving the pointer on 
 *	past it, and optionally return the size and alignment values.
 *
 *	This is based on GNUStep's objc_sizeof_type()
 */
const char *pfenc_size_align(const char *type, NSUInteger *size, NSUInteger *alignment)
{
	NSUInteger s = 0, a = 0;
	type = pfenc_skip(type);

	switch(*type) {
		case _C_ID:
			s = sizeof(id);
			a = __alignof__(id);
			break;
				
		case _C_CLASS:
			s = sizeof(Class);
			a = __alignof__(Class);			
			break;
				
		case _C_SEL:
			s = sizeof(SEL);
			a = __alignof__(SEL);
			break;
				
		case _C_CHR:
			s = sizeof(char);
			a = __alignof__(char);
			break;
				
		case _C_UCHR:
			s = sizeof(unsigned char);
			a = __alignof__(unsigned char);
			break;
				
		case _C_SHT:
			s = sizeof(short);
			a = __alignof__(short);
			break;
				
		case _C_USHT:
			s = sizeof(unsigned short);
			a = __alignof__(unsigned short);
			break;
				
		case _C_INT:
			s = sizeof(int);
			a = __alignof__(int);
			break;
				
		case _C_UINT:
			s = sizeof(unsigned int);
			a = __alignof__(unsigned int);
			break;
				
		case _C_LNG:
			s = sizeof(long);
			a = __alignof__(long);
			break;
				
		case _C_ULNG:
			s = sizeof(unsigned long);
			a = __alignof__(unsigned long);
			break;
				
		case _C_FLT:
			s = sizeof(float);
			a = __alignof__(float);
			break;
				
		case _C_DBL:
			s = sizeof(double);
			a = __alignof__(double);
			break;
				
		case _C_PTR:
		case _C_ATOM:
		case _C_CHARPTR:
			s = sizeof(char*);
			a = __alignof__(char*);
			break;
				
		case _C_ARY_B:
		{
			NSUInteger length; // this isn't technically an offset, but...
			type = pfenc_offset(type, &length);
			type = pfenc_size_align(type, &s, &a);
			s = length * PF_ALIGNED_SIZE(s,a);
		}
		break;
				
		case _C_STRUCT_B:
		{
			NSUInteger acc_size = 0;
			NSUInteger align = -1; // for holding alignment of the initial item
			while (*type != _C_STRUCT_E && *type++ != '='); /* skip "<name>=" */
			while (*type != _C_STRUCT_E)
			{
				// okay, converting this from the GNUStep version
				type = pfenc_size_align(type, &s, &a);
				
				if( align == -1 ) align = a; // set alignment of entire structure
				//align = objc_alignof_type (type);       /* padd to alignment */
				// a = align
#if 0
				acc_size = PF_ALIGNED_SIZE(acc_size, a); //ROUND (acc_size, align);
#else
					//      acc_size = ({int __v=(acc_size); int __a=(align); __a*((__v+__a-1)/__a); });
					//{
					//	int	__v = acc_size;
					//	int	__a = align;
					//	
					//	acc_size = __a * ((__v + __a - 1) / __a);
					//}
#endif
				acc_size += s; //objc_sizeof_type (type);   /* add component size */
					//type = objc_skip_typespec (type);	         /* skip component */
				}
				s = acc_size;
			}
				
		case _C_UNION_B:
		{
			NSUInteger max_size = 0, max_align = 0;
			while (*type != _C_UNION_E && *type++ != '=') /* do nothing */;
			while (*type != _C_UNION_E)
			{
				type = pfenc_size_align(type, &s, &a);
				
				if( s > max_size ) max_size = s;
				if( a > max_align ) max_align = a;
				//max_size = MAX (max_size, objc_sizeof_type (type));
				//type = objc_skip_typespec (type);
			}
			s = max_size;
			a = max_align; // yeah, not quite sure if this holds, but still...
		}
	}

	if( size != NULL ) *size = s;
	if( alignment != NULL) *alignment = a;
	return ++type; // skips single types and closing brackets
}
	
/*
 *	Was objc_skip_offset
 */
const char *pfenc_offset(const char *type, NSUInteger *offset)
{
	NSUInteger o = 0;
	
	if (*type == '+') type++;
	if (*type == '-') type++;
	
	while (isdigit(*type)) o = (o * 10) + (*type++ - '0');
	
	if( offset != NULL ) *offset = o;
	return type;
}

/*
 *	return a zero-terminated copy of the type string
 */
const char *pfenc_copy(const char *type)
{
	const char *end = pfenc_size_align(type, NULL, NULL); // skips past modifier and typedesc
	NSUInteger length = end - type;
	char *result = malloc(length+1);
	strncpy(result, type, length);
	result[length] = '\0';
	return result;
}







//// OLD FUNCTIONS, WILL DISAPPEAR SOMEDAY

/*
 *	Count the number of arguments in a type string
 */
unsigned int pf_encoding_getNumberOfArguments(const char *typedesc)
{
	unsigned nargs;
	
    // First, skip the return type
    typedesc = objc_skip_typespec(typedesc);
	
    // Next, skip stack size
	typedesc = objc_skip_argspec(typedesc);
	
    //while ((*typedesc >= '0') && (*typedesc <= '9'))
    //    typedesc += 1;
	
    // Now, we have the arguments - count how many
    nargs = 0;
    while (*typedesc)
    {
        // Traverse argument type
        typedesc = objc_skip_typespec(typedesc);
		
        // Skip GNU runtime's register parameter hint
        if (*typedesc == '+') typedesc++;
		
        // Traverse (possibly negative) argument offset
		typedesc = objc_skip_argspec(typedesc);
		
        //if (*typedesc == '-')
        //    typedesc += 1;
        //while ((*typedesc >= '0') && (*typedesc <= '9'))
        //    typedesc += 1;
		
        // Made it past an argument
        nargs += 1;
    }
	
    return nargs;
	
}

/*
 *
 */
unsigned int pf_encoding_getSizeOfArguments(const char *typedesc)
{
	unsigned		stack_size;
	
    // Get our starting points
    stack_size = 0;
	
    // Skip the return type
    typedesc = objc_skip_typespec(typedesc);
	
    // Convert ASCII number string to integer
    while ((*typedesc >= '0') && (*typedesc <= '9'))
        stack_size = (stack_size * 10) + (*typedesc++ - '0');
	
    return stack_size;
	
}

char *pf_encoding_copyReturnType(const char *t)
{
	size_t len;
    const char *end;
    char *result;
	
    if (!t) return NULL;
	
    end = objc_skip_typespec(t);
    len = end - t;
    result = malloc(len + 1);
    strncpy(result, t, len);
    result[len] = '\0';
    return result;
	
}

char *pf_encoding_copyArgumentType(const char *t, unsigned int index)
{
	size_t len;
    const char *end;
    char *result;
    //int offset;
	
    if (!t) return NULL;
	
	t = objc_skip_argspec(t); // skip the return type and stack size
	
	while( index-- )
		t = objc_skip_argspec(t); // skip over index arguments
		
    if (*t == '\0') return NULL; // check we didn't overshoot
	
    end = objc_skip_typespec(t);
    len = end - t;
    result = malloc(len + 1);
    strncpy(result, t, len);
    result[len] = '\0';
    return result;	
}


inline unsigned int pf_get_offset(const char **typedesc)
{
	const char *type = *typedesc;
	unsigned int offset = 0;
	if (*type == '+') type++;
	if (*type == '-') type++;
	while (isdigit(*type))
		offset = (offset * 10) + (*type++ - '0');
	*typedesc = type;
	return offset;
}


/*
 *	These functions were taken from the Cocotron project, file objc_forward_ffi.m. 
 *	If you don't like the LGLP, you can find a copy of this routine under a more 
 *	liberal licence there.
 *
 *	Original license:
 */

	/* 
	 Parts of this come from PyObjC, http://pyobjc.sourceforge.net/
	 Copyright 2002, 2003 - Bill Bumgarner, Ronald Oussoren, Steve Majewski, Lele Gaifax, et.al.
	 Copyright 2008 Johannes Fortmann
 
	 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
	 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

//static 
//ffi_type* 
//array_to_ffi_type(const char* argtype)
//{	
//	ffi_type* type=ffi_try_find_type(argtype);
//	if(type)
//		return type;
	
	/* We don't have a type description yet, dynamicly 
	 * create it.
	 */
//	size_t field_count = atoi(argtype+1);
//	size_t i;
	
//	type = NSZoneMalloc(NULL, sizeof(*type));
	
//	type->size=objc_sizeof_type(argtype);
//	type->alignment=objc_alignof_type(argtype);
	
	/* Libffi doesn't really know about arrays as part of larger 
	 * data-structres (e.g. struct foo { int field[3]; };). We fake it
	 * by treating the nested array as a struct. These seems to work 
	 * fine on MacOS X.
	 */
//	type->type = FFI_TYPE_STRUCT;
//	type->elements = NSZoneMalloc(NULL, (1+field_count) * sizeof(ffi_type*));
	
//	while (isdigit(*++argtype));
//	type->elements[0] = signature_to_ffi_type(argtype);
//	for (i = 1; i < field_count; i++) {
//		type->elements[i] = type->elements[0];
//	}
//	type->elements[field_count] = 0;
	
//	ffi_insert_type(argtype, type);
//	return type;
//}


//static 
//ffi_type* 
//struct_to_ffi_type(const char* argtype)
//{
//	ffi_type* type=ffi_try_find_type(argtype);
//	if(type)
//		return type;
//	const char* curtype;
	
	
	/* We don't have a type description yet, dynamicly 
	 * create it.
	 */
//	size_t field_count = num_struct_fields(argtype);
	
//	type = NSZoneMalloc(NULL, sizeof(*type));
	
//	type->size = objc_sizeof_type(argtype);
//	type->alignment = objc_alignof_type(argtype);
	
//	type->type = FFI_TYPE_STRUCT;
//	type->elements = NSZoneMalloc(NULL, (1+field_count) * sizeof(ffi_type*));
	
//	field_count = 0;
//	curtype = argtype+1;
//	while (*curtype != _C_STRUCT_E && *curtype != '=') curtype++;
//	if (*curtype == '=') {
//		curtype ++;
//		while (*curtype != _C_STRUCT_E) {
//			type->elements[field_count] = 
//			signature_to_ffi_type(curtype);
//			field_count++;
//			curtype = objc_skip_typespec(curtype); // objc_skip_type_specifier(curtype);
//		}
//	}
//	type->elements[field_count] = NULL;
	
//	ffi_insert_type(argtype, type);
	
//	return type;
//}

/*
 *	This one was causing boot to lock up. Not sure why. Maybe it clashes with a symbol
 *	exported somewhere else
 */

////static 
//ffi_type*
//signature_to_ffi_type(const char* argtype)
//{
//	switch (*argtype) {
//		case _C_VOID: return &ffi_type_void;
//		case _C_ID: return &ffi_type_pointer;
//		case _C_CLASS: return &ffi_type_pointer;
//		case _C_SEL: return &ffi_type_pointer;
//		case _C_CHR: return &ffi_type_schar;
////#ifdef _C_BOOL
//		case _C_BOOL: 
//			/* sizeof(bool) == 4 on PPC32, and 1 on all others */
////#if defined(__ppc__) && !defined(__LP__)
////			return &ffi_type_sint;
////#else
//			return &ffi_type_schar;
////#endif
//			
////#endif	
//		case _C_UCHR: return &ffi_type_uchar;
//		case _C_SHT: return &ffi_type_sshort;
//		case _C_USHT: return &ffi_type_ushort;
//		case _C_INT: return &ffi_type_sint;
//		case _C_UINT: return &ffi_type_uint;
//			
//			/* The next to defintions are incorrect, but the correct definitions
//			 * don't work (e.g. give testsuite failures). 
//			 */
////#ifdef __LP64__
////		case _C_LNG: return &ffi_type_sint64;  /* ffi_type_slong */
////		case _C_ULNG: return &ffi_type_uint64;  /* ffi_type_ulong */
////#else -- longs are 32-bit even on 64-bit (I think this includes unsigned longs)
//		case _C_LNG: return &ffi_type_sint;  /* ffi_type_slong */
//		case _C_ULNG: return &ffi_type_uint;  /* ffi_type_ulong */
////#endif
//		case _C_LNGLNG: return &ffi_type_sint64;
//		case _C_ULNG_LNG: return &ffi_type_uint64;
//		case _C_FLT: return &ffi_type_float;
//		case _C_DBL: return &ffi_type_double;
//		case _C_CHARPTR: return &ffi_type_pointer;
//		case _C_PTR: return &ffi_type_pointer;
//		case _C_ARY_B: 
//			return  NULL; // :-- array_to_ffi_type(argtype);
//		case _C_IN: 
//		case _C_OUT: 
//		case _C_INOUT: 
//		case _C_CONST:
//			return signature_to_ffi_type(argtype+1);
//		case _C_STRUCT_B: 
//			return NULL; // :-- struct_to_ffi_type(argtype);
//		case _C_UNDEF:
//			return &ffi_type_pointer;
//		default:
//			NSLog(@"Type '%c' not supported", *argtype);
//			return NULL;
//	}
//}


