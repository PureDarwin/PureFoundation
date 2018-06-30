/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSZone.m
 *
 *	Memory management functions
 *
 *	Created by Stuart Crook on 21/01/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/*
 *	PureFoundation's memory management is built on top of CFLite's. All objects
 *	-- bridged or NS -- are allocated using the default allocator. This is partly
 *	so that a common deallocation method can be used, but mostly in the hope that
 *	our NS objects will magically inherit garbage collectability, which the CFLite
 *	source seems to suggest its own objects have.
 */

#import "NSZone.h"

#include <sys/sysctl.h>

/*
 *	Implement NSZone functionality using CFAllocators?
 */
// eg.?
struct _NSZone {
	CFAllocatorRef	allocator;
	NSString *name;
};

NSZone _PFDefaultZone = { NULL, NULL };


// return the default malloc zone
NSZone *NSDefaultMallocZone(void) 
{
//	PF_HELLO("")
//	if( _PFDefaultZone.name == NULL )
//	{
//		_PFDefaultZone.name = @"Default Zone";
//		_PFDefaultZone.allocator = CFAllocatorGetDefault();
//	}
//	return &_PFDefaultZone;
	
	return nil;
}

// A pointer to a new zone of startSize bytes, which will grow and shrink by granularity bytes. If canFree is 0, the allocator will never free memory, and malloc will be fast. Returns NULL if a new zone could not be created.
NSZone *NSCreateZone(NSUInteger startSize, NSUInteger granularity, BOOL canFree) 
{
	return NULL; // don't support this for now
}

// Frees zone after adding any of its pointers still in use to the default zone. (This strategy prevents retained objects from being inadvertently destroyed.)
void NSRecycleZone(NSZone *zone) 
{

}

// Sets the name of zone to name, which can aid in debugging.
void NSSetZoneName(NSZone *zone, NSString *name) 
{
//	if( (zone != NULL) && (zone != &_PFDefaultZone) )
//		zone->name = [name retain]; // should we copy it, just to be safe ???
}

// A string containing the name associated with zone. If zone is nil, the default zone is used. If no name is associated with zone, the returned string is empty.
NSString *NSZoneName(NSZone *zone) 
{
//	if( zone == nil ) zone = NSDefaultMallocZone();
//	return zone->name;
	return @"";
}

//The zone for the block of memory indicated by pointer, or NULL if the block was not allocated from a zone.
NSZone *NSZoneFromPointer(void *ptr) 
{
	return NSDefaultMallocZone(); // sloppy, but if ptr is real is should have come from here
}

// Allocates size bytes in zone and returns a pointer to the allocated memory. This function returns NULL if it was unable to allocate the requested memory.
void *NSZoneMalloc(NSZone *zone, NSUInteger size) 
{
//	if( zone == nil ) zone = NSDefaultMallocZone();
	//CFAllocatorRef allocator = CFAllocatorGetDefault(); // zone->allocator;
	void *ptr = CFAllocatorAllocate( kCFAllocatorDefault, (CFIndex)size, 0);
	for( int i = 0; i < size; i++ ) ((UInt8 *)ptr)[i] = 0;
	return ptr;
}

// Allocates enough memory from zone for numElems elements, each with a size numBytes bytes, and returns a pointer to the allocated memory. The memory is initialized with zeros. This function returns NULL if it was unable to allocate the requested memory.
void *NSZoneCalloc(NSZone *zone, NSUInteger numElems, NSUInteger byteSize) 
{
	NSUInteger size = numElems * byteSize;
	return NSZoneMalloc( zone, size );
}

//Changes the size of the block of memory pointed to by ptr to size bytes. It may allocate new memory to replace the old, in which case it moves the contents of the old memory block to the new block, up to a maximum of size bytes. ptr may be NULL. This function returns NULL if it was unable to allocate the requested memory.
void *NSZoneRealloc(NSZone *zone, void *ptr, NSUInteger size) 
{
	//if( zone == nil ) zone = NSDefaultMallocZone();
	//CFAllocatorRef allocator = CFAllocatorGetDefault(); //zone->allocator;
	return CFAllocatorReallocate( kCFAllocatorDefault, ptr, (CFIndex)size, 0 );
}

// Returns memory to the zone from which it was allocated. The standard C function free does the same, but spends time finding which zone the memory belongs to.
void NSZoneFree(NSZone *zone, void *ptr) 
{
	//if( zone == nil ) zone = NSDefaultMallocZone();
	//CFAllocatorRef allocator = CFAllocatorGetDefault(); // zone->allocator;
	CFAllocatorDeallocate( kCFAllocatorDefault, ptr );
}


/*
 *	Garbage Collector optomised calls
 */
// AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
// A pointer to the allocated memory, or NULL if the function is unable to allocate the requested memory.
// options: 0 or NSScannedOption: A value of 0 allocates nonscanned memory; a value of NSScannedOption allocates scanned memory.
void *__strong NSAllocateCollectable(NSUInteger size, NSUInteger options) 
{
	void *ptr = NSZoneMalloc( nil, size );
	return (void *)NSMakeCollectable((CFTypeRef)ptr);
}

// AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
// option: same as above
void *__strong NSReallocateCollectable(void *ptr, NSUInteger size, NSUInteger options) 
{
	ptr = NSZoneRealloc( nil, ptr, size );
	return (void *)NSMakeCollectable((CFTypeRef)ptr);
}



void *NSAllocateMemoryPages(NSUInteger bytes) 
{
	NSUInteger size = NSRoundUpToMultipleOfPageSize(bytes);
	void *ptr = NSZoneMalloc( nil, size );
	if( ptr == NULL )
		[NSException raise: NSInvalidArgumentException format: nil];
	return ptr;
}

void NSDeallocateMemoryPages(void *ptr, NSUInteger bytes) 
{
	NSZoneFree( nil, ptr );
}

void NSCopyMemoryPages(const void *source, void *dest, NSUInteger bytes) 
{
	PF_TODO
}



/*
 *	The implementation of these functions are based on GNUStep, from NSPage.m
 */

	/** Implementation of page-related functions for GNUstep
	 Copyright (C) 1996, 1997 Free Software Foundation, Inc.
 
	 Written by:  Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
	 Created: May 1996
 
	 This file is part of the GNUstep Base Library.
 
	 This library is free software; you can redistribute it and/or
	 modify it under the terms of the GNU Lesser General Public
	 License as published by the Free Software Foundation; either
	 version 2 of the License, or (at your option) any later version.
 
	 This library is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 Library General Public License for more details.
 
	 You should have received a copy of the GNU Lesser General Public
	 License along with this library; if not, write to the Free
	 Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
	 Boston, MA 02111 USA.
 
	 <title>NSPage class reference</title>
	 $Date: 2008-12-19 09:06:14 +0000 (Fri, 19 Dec 2008) $ $Revision: 27341 $
	 */

/* Cache the size of a memory page here, so we don't have to make the
 getpagesize() system call repeatedly. */
static NSUInteger ns_page_size = 0;

// ...

/**
 * Return the number of bytes in a memory page.
 */
NSUInteger NSPageSize (void)
{
	size_t length = sizeof( ns_page_size );
	int mib[2]; 
	
	if (!ns_page_size)
	{
		mib[0] = CTL_HW;
		mib[1] = HW_PAGESIZE;
		if( sysctl( mib, 2, &ns_page_size, &length, NULL, 0 ) < 0 )
			NSLog( @"sysctl error, length = %u", length );
	}
	
	//printf("page size = %u\n", ns_page_size );
	
	return ns_page_size;
}

/**
 * Return log base 2 of the number of bytes in a memory page.
 */
NSUInteger NSLogPageSize (void)
{
	NSUInteger tmp_page_size = NSPageSize();
	NSUInteger log = 0;
	
	while (tmp_page_size >>= 1)
		log++;
	return log;
}

/**
 * Round bytes down to the nearest multiple of the memory page size,
 * and return it.
 */
NSUInteger NSRoundDownToMultipleOfPageSize (NSUInteger bytes)
{
	NSUInteger a = NSPageSize();
	
	return (bytes / a) * a;
}

/**
 * Round bytes up to the nearest multiple of the memory page size,
 * and return it.
 */
NSUInteger NSRoundUpToMultipleOfPageSize (NSUInteger bytes)
{
	NSUInteger a = NSPageSize();
	
	return ((bytes % a) ? ((bytes / a + 1) * a) : bytes);
}

//#if __linux__
//#include	<sys/sysinfo.h>
//#endif

/**
 * Return the number of bytes of real (physical) memory available.
 */
NSUInteger NSRealMemoryAvailable ()
{
	NSUInteger mem = 0;
	size_t length = sizeof( mem );
	int mib[2]; 
	
	mib[0] = CTL_HW;
	mib[1] = HW_PHYSMEM;
		
	sysctl( mib, 2, &mem, &length, NULL, 0 );

	//printf("real mem = %u\n", mem);
	
	return mem;
	
//#if __linux__
//	struct sysinfo info;
//	
//	if ((sysinfo(&info)) != 0)
//		return 0;
//	return  info.freeram;
//#elif defined(__MINGW32__)
//	MEMORYSTATUSEX memory;
//	
//	memory.dwLength = sizeof(memory);
//	GlobalMemoryStatusEx(&memory);
//	return memory.ullAvailPhys;
//#elif defined(__BEOS__)
//	system_info info;
//	
//	if (get_system_info(&info) != B_OK)
//		return 0;
//	return (info.max_pages - info.used_pages) * B_PAGE_SIZE;
//#else
//	fprintf (stderr, "NSRealMemoryAvailable() not implemented.\n");
//	return 0;
//#endif
}


