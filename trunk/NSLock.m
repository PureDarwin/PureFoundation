/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSLock.m
 *
 *	NSLock
 *
 *	Created by Stuart Crook on 16/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSLock.h"

#include <pthread.h>
#include <time.h>

/*
 *	Awkward way of storing two lots of ivars in the NSLock's limited space
 */
typedef struct _pf_nslock {
	pthread_mutex_t mutex;
	NSString *name;
} _pf_nslock;


/*
 *	ivar:    void *_priv;
 */
@implementation NSLock

- (id)init
{
	if( self = [super init] )
	{
		_pf_nslock *storage = malloc(sizeof(_pf_nslock));
		if( pthread_mutex_init(&storage->mutex, NULL) != 0 )
		{
			free(storage);
			NSDeallocateObject(self);
			return nil;
		}
		storage->name = nil;
		_priv = storage;
	}
	return self;
}

- (void)dealloc
{
	pthread_mutex_destroy( &((_pf_nslock*)_priv)->mutex );
	[((_pf_nslock*)_priv)->name release];
	free(_priv);
	[super dealloc];
}

- (void)lock { pthread_mutex_lock( &((_pf_nslock*)_priv)->mutex ); }

- (void)unlock 
{
	if( pthread_mutex_unlock( &((_pf_nslock*)_priv)->mutex ) != 0 )
		NSLog(@"Couldn't unlock mutex");
}

- (BOOL)tryLock
{
	return ( pthread_mutex_trylock( &((_pf_nslock*)_priv)->mutex ) == 0 ) ? YES : NO;
}

- (BOOL)lockBeforeDate:(NSDate *)limit 
{
	NSTimeInterval ti = [limit timeIntervalSinceReferenceDate] - CFAbsoluteTimeGetCurrent();

	struct timespec rqtp, rmtp;
	rqtp.tv_sec = 0;
	//rqtp.tv_nsec = 
	rmtp.tv_sec = 0;
	//rmtp.tv_nsec = 0;
	
	while( pthread_mutex_trylock( &((_pf_nslock*)_priv)->mutex ) != 0 )
	{
		if( ti < 0 ) return NO; // this gives us a single go even if date was in the past
		
		// this isn't a RTOS, so we'll sleep in granular chunks
		rqtp.tv_sec = 100000000; // 1/10 second. too long ???
		rmtp.tv_sec = 0;
		ti -= 0.1;
		
		// this ensure we sleep for the 1/10 sec, even if we're woken
		while( nanosleep(&rqtp, &rmtp) != 0 )
		{
			rqtp.tv_nsec = rqtp.tv_nsec;
			rmtp.tv_nsec = 0;
		}
	}
	return YES; // mutex_trylock succeeded
}

- (void)setName:(NSString *)n 
{
	[((_pf_nslock*)_priv)->name release];
	((_pf_nslock*)_priv)->name = [n copyWithZone: nil];
}

- (NSString *)name { return [[((_pf_nslock*)_priv)->name copyWithZone: nil] autorelease]; }

@end


