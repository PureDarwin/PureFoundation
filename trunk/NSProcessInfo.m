/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSProcessInfo.m
 *
 *	NSProcessInfo
 *
 *	Created by Stuart Crook on 03/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSProcessInfo.h"
#import "PureFoundation.h"

#include <sys/types.h>
#include <sys/sysctl.h>
#include <unistd.h>


/*
 *	Functions from libSystem which give us access to arguments and the environment.
 *	Thanks to http://unixjunkie.blogspot.com/2006/07/access-argc-and-argv-from-anywhere.html
 */
#include "/usr/include/crt_externs.h"

NSProcessInfo *_pfProcessInfo = nil;

/*
 *	ivars:	NSDictionary *environment;
 *			NSArray	*arguments;
 *			NSString *hostName;    
 *			NSString *name;
 *			void *reserved;
 */
@implementation NSProcessInfo

+ (NSProcessInfo *)processInfo
{
	if( _pfProcessInfo == nil )
		_pfProcessInfo = [[NSProcessInfo alloc] init];
	return _pfProcessInfo;
}

- (void)dealloc
{
	if( self == _pfProcessInfo ) return;
	[environment release];
	[arguments release];
	[hostName release];
	[name release];
	[super dealloc];
}


/*
 *	Reults are lazily-created and then cached
 */
- (NSDictionary *)environment
{
	if( environment == nil )
	{
		char **env = *_NSGetEnviron();
		char *var;
		int len, eq;
		CFStringRef key, value;
		environment = (NSDictionary *)CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks,(CFDictionaryValueCallBacks *)&_PFCollectionCallBacks );
		
		while( var = *env++ )
		{
			len = eq = 0;
			while( var[len] != '\0' )
			{
				if( (eq == 0) && (var[len] == '=') ) eq = len;
				len++;
			}
			
			key = CFStringCreateWithBytes( kCFAllocatorDefault, (const UInt8 *)var, eq++, kCFStringEncodingASCII, NO );
			value = CFStringCreateWithBytes( kCFAllocatorDefault, (const UInt8 *)var+eq, len-eq, kCFStringEncodingASCII, NO );

			CFDictionaryAddValue( (CFMutableDictionaryRef)environment, (const void *)key, (const void *)value );
			[(id)key release];
			[(id)value release];
		}
	}
	return environment;
}


- (NSArray *)arguments 
{
	if( arguments == nil )
	{
		NSUInteger count = *_NSGetArgc();
		id buffer[count];
		char **argv = *_NSGetArgv();
		
		for( int i = 0; i < count; i++ )
			buffer[i] = [NSString stringWithCString: argv[i] encoding: NSASCIIStringEncoding];
		
		arguments = (NSArray *)CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, (CFArrayCallBacks *)&_PFCollectionCallBacks );
	}
	return arguments; 
}

- (NSString *)hostName 
{
	if( hostName == nil )
	{
		char hname[255]; // long enough?
		if( gethostname(hname, 255) == 0 )
			hostName = [[NSString alloc] initWithCString: hname encoding: NSASCIIStringEncoding];
	}
	return hostName;
}

- (NSString *)processName
{
	if( name == nil )
	{
		name = [[NSString alloc] initWithCString: *_NSGetProgname() encoding: NSASCIIStringEncoding];
	}
	return name; 
}

- (void)setProcessName:(NSString *)newName
{
	[name autorelease];
	name = [newName copyWithZone: nil];
}

- (int)processIdentifier { return getpid(); };


- (NSString *)globallyUniqueString 
{ 
	return [NSString stringWithFormat: @"%u-%@-%u", getpid(), [self hostName], CFAbsoluteTimeGetCurrent()]; 
}

/*
 *	Did I mention portability wasn't a goal?
 */
- (NSUInteger)operatingSystem { return NSMACHOperatingSystem; }
- (NSString *)operatingSystemName { return @"NSMACHOperatingSystem"; }

/* 
 *	"Human readable, localized; appropriate for displaying to user or using in bug 
 *	emails and such; NOT appropriate for parsing"
 *
 *	At the time of writing, OS X reported "Version 10.5.6 (Build 9G55)"
 */
- (NSString *)operatingSystemVersionString 
{ 
	char osversion[32]; // should be plenty of room
	size_t length = 32;
	sysctlbyname( "kern.osrelease", &osversion, &length, NULL, 0 );
	return [NSString stringWithFormat: @"Version %s", osversion];
}


- (NSUInteger)processorCount 
{
	NSUInteger count = 0;
	size_t length = sizeof(count);
	sysctlbyname( "hw.physicalcpu", &count, &length, NULL, 0 );
	return count;
}

- (NSUInteger)activeProcessorCount 
{
	NSUInteger count = 0;
	size_t length = sizeof(count);
	sysctlbyname( "hw.activecpu", &count, &length, NULL, 0 );
	return count;	
}

- (unsigned long long)physicalMemory 
{
	unsigned long long size = 0;
	size_t length = sizeof(size);
	sysctlbyname( "hw.physmem", &size, &length, NULL, 0 );
	return size;	
}

@end
