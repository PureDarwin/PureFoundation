/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSRecursiveLock.m
 *
 *	NSRecursiveLock
 *
 *	Created by Stuart Crook on 16/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

#import "NSLock.h"

// this was copy & pasted in from NSLock and then altered. don't know why this 
//	wasn't made a sub-class of NSLock in the first place. Unless Apple's version
//	is completely different. which is perfectly possible.

#include <pthread.h>
#include <time.h>

/*
 *	Awkward way of storing two lots of ivars in the NSLock's limited space
 */
typedef struct _pf_nsrlock {
	pthread_mutex_t mutex;
	NSString *name;
} _pf_nsrlock;


/*
 *	ivar:    void *_priv;
 */
@implementation NSRecursiveLock

- (id)init
{
	if( self = [super init] )
	{
		_pf_nsrlock *storage = malloc(sizeof(_pf_nsrlock));
		pthread_mutexattr_t attr;
		if( (pthread_mutexattr_init(&attr) != 0) || (pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE) != 0) || (pthread_mutex_init(&storage->mutex, &attr) != 0) )
		{
			printf("Couldn't create recursive lock\n");
			pthread_mutexattr_destroy(&attr); // well, it might have succeeded
			free(storage);
			NSDeallocateObject(self);
			return nil;
		}
		pthread_mutexattr_destroy(&attr);
		storage->name = nil;
		_priv = storage;
	}
	return self;
}

- (void)dealloc
{
	pthread_mutex_destroy( &((_pf_nsrlock*)_priv)->mutex );
	[((_pf_nsrlock*)_priv)->name release];
	free(_priv);
	[super dealloc];
}

- (void)lock { pthread_mutex_lock( &((_pf_nsrlock*)_priv)->mutex ); }

- (void)unlock 
{
	if( pthread_mutex_unlock( &((_pf_nsrlock*)_priv)->mutex ) != 0 )
		NSLog(@"Couldn't unlock mutex");
}

- (BOOL)tryLock
{
	return ( pthread_mutex_trylock( &((_pf_nsrlock*)_priv)->mutex ) == 0 ) ? YES : NO;
}

- (BOOL)lockBeforeDate:(NSDate *)limit 
{
	NSTimeInterval ti = [limit timeIntervalSinceReferenceDate] - CFAbsoluteTimeGetCurrent();
	
	struct timespec rqtp, rmtp;
	rqtp.tv_sec = 0;
	//rqtp.tv_nsec = 
	rmtp.tv_sec = 0;
	//rmtp.tv_nsec = 0;
	
	while( pthread_mutex_trylock( &((_pf_nsrlock*)_priv)->mutex ) != 0 )
	{
		if( ti < 0 ) return NO; // this gives us a single go even if date was in the past
		
		// this isn't a RTOS, so we'll sleep in large chunks of time
		rqtp.tv_sec = 100000000; // 1/10 second. too long ???
		rmtp.tv_sec = 0;
		ti -= 0.1;
		
		// this ensures we sleep for the 1/10 sec, even if we're woken
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
	[((_pf_nsrlock*)_priv)->name release];
	((_pf_nsrlock*)_priv)->name = [n copyWithZone: nil];
}

- (NSString *)name { return [[((_pf_nsrlock*)_priv)->name copyWithZone: nil] autorelease]; }

@end

