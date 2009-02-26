/*
 *	PureFoundation -- http://code.google.com/p/purefoundation/
 *	NSBundle.m
 *
 *	NSBundle
 *
 *	Created by Stuart Crook on 15/02/2009.
 *	LGPL'd. See LICENCE.txt for copyright information.
 */

/*
 *	The NSBundle class wraps the CFBundle class, holding a CFBundle object for the bundle in
 *	question and routing most of its method calls through the CF equivalent. NSBundle objects
 *	are cached in the _pfBundleStore dictionary, keyed to the CFBundle they wrap.
 *
 *	Currently, none of the obj-c methods are implemented.
 *
 *	We may have to look at over-riding the usual retain/release memory management, in order to
 *	stop cahced objects being released. (Or alternatively, set the -dealloc method to remove the
 *	object from the cache.)
 */

#import "NSBundle.h"
#import "PureFoundation.h"

/*
 *	Constants
 */
NSString * const NSBundleDidLoadNotification = @"NSBundleDidLoadNotification";
NSString * const NSLoadedClasses = @"NSLoadedClasses";

/*
 *	Class-specific storage
 *
 *	We'll cache NSBundles in a non-retaining dictionary, keyed to the CFBundle they wrap,
 *	and dish them up in place of the CFBundles the CF bundle functions return.
 */
NSBundle *_pfMainBundle = nil;
CFMutableDictionaryRef _pfBundleStore = nil;

/*
 *	Functions for wrapping, storing and retrieving bundles
 */
NSBundle *_pfWrapBundle( CFBundleRef cfBundle )
{
	if( cfBundle == NULL ) return NULL;
	
	NSBundle *nsBundle = (NSBundle *)CFDictionaryGetValue( _pfBundleStore, (const void *)cfBundle );
	if( nsBundle == NULL ) // bundle wasn't in store, so...
	{	// create and init an NSBundle object by hand
		nsBundle = NSAllocateObject([NSBundle class], 0, nil);
		CFRetain(cfBundle);
		nsBundle->_cfBundle = (id)cfBundle;
		// other init code...
		CFDictionaryAddValue( _pfBundleStore, (const void *)cfBundle, (const void *)nsBundle );
	}
	return nsBundle;
}

/*
 *	ivars:
 *		NSUInteger	_flags;
 *		id		    _cfBundle;
 *		NSUInteger	_refCount;
 *		Class		_principalClass;
 *		id          _tmp1;
 *		id          _tmp2;
 *		void		*_reserved1;
 *		void		*_reserved0;
 */

@implementation NSBundle

+ (void)initialize
{
	if( self == [NSBundle class] )
		_pfBundleStore = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, NULL, NULL );
}

/*
 *	Creation
 */
+ (NSBundle *)bundleWithPath:(NSString *)path { return [[[self alloc] initWithPath: path] autorelease]; }

/*
 *	I guess we should really have alloc return a dummy object, to avoid the hassle of 
 *	allocating and then releasing a bundle object
 */
- (id)initWithPath:(NSString *)path 
{
	CFURLRef url = CFURLCreateWithFileSystemPath( kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, YES );
	if( url == NULL ) return nil;
	self = _pfWrapBundle( CFBundleCreate( kCFAllocatorDefault, url ) );
	if( self != NULL )
	{
		// think of some other setup to do
		
	}
	[(id)url release];
	return self;
}



/*
 *	Class methods
 */
+ (NSBundle *)mainBundle
{
	if( _pfMainBundle == nil )
	{
		_pfMainBundle = _pfWrapBundle( CFBundleGetMainBundle() );
	}
	return _pfMainBundle;
}

+ (NSBundle *)bundleForClass:(Class)aClass {}

+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier 
{ 
	return _pfWrapBundle( CFBundleGetBundleWithIdentifier((CFStringRef)identifier) ); 
}

+ (NSArray *)allBundles 
{
	CFArrayRef all = CFBundleGetAllBundles();
	NSUInteger count = CFArrayGetCount(all);
	id buffer[count]; // maximum number we'l' return
	
	UInt32 packageType, packageCreator;
	NSUInteger finalCount = 0;
	id *ptr = buffer;
	for( id cfBundle in (NSArray *)all )
	{
		CFBundleGetPackageInfo( (CFBundleRef)cfBundle, &packageType, &packageCreator );
		if( packageType != 'FMWK' )
		{
			*ptr++ = _pfWrapBundle( (CFBundleRef)cfBundle );
			finalCount++;
		}
	}
	
	return [(id)CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, finalCount, (CFArrayCallBacks *)&_PFCollectionCallBacks ) autorelease];
}

+ (NSArray *)allFrameworks 
{
	CFArrayRef all = CFBundleGetAllBundles();
	NSUInteger count = CFArrayGetCount(all);
	id buffer[count]; // maximum number we'l' return
	
	UInt32 packageType, packageCreator;
	NSUInteger finalCount = 0;
	id *ptr = buffer;
	for( id cfBundle in (NSArray *)all )
	{
		CFBundleGetPackageInfo( (CFBundleRef)cfBundle, &packageType, &packageCreator );
		if( packageType == 'FMWK' )
		{
			*ptr++ = _pfWrapBundle( (CFBundleRef)cfBundle );
			finalCount++;
		}
	}
	
	return [(id)CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, finalCount, (CFArrayCallBacks *)&_PFCollectionCallBacks ) autorelease];	
}

+ (NSArray *)preferredLocalizationsFromArray:(NSArray *)localizationsArray 
{
	return [(id)CFBundleCopyPreferredLocalizationsFromArray( (CFArrayRef)localizationsArray ) autorelease];
}

+ (NSArray *)preferredLocalizationsFromArray:(NSArray *)localizationsArray forPreferences:(NSArray *)preferencesArray 
{
	return [(id)CFBundleCopyLocalizationsForPreferences( (CFArrayRef)localizationsArray, (CFArrayRef)preferencesArray ) autorelease];
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath 
{
	CFURLRef bundleURL = CFURLCreateWithFileSystemPath( kCFAllocatorDefault, (CFStringRef)bundlePath, kCFURLPOSIXPathStyle, YES );
	CFURLRef pathURL = CFBundleCopyResourceURLInDirectory( bundleURL, (CFStringRef)name, (CFStringRef)ext, NULL );
	CFStringRef path = CFURLCopyPath(pathURL);
	CFRelease(bundleURL);
	CFRelease(pathURL);
	return [(id)path autorelease];
}

+ (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)bundlePath 
{
	CFURLRef bundleURL = CFURLCreateWithFileSystemPath( kCFAllocatorDefault, (CFStringRef)bundlePath, kCFURLPOSIXPathStyle, YES );
	CFArrayRef array = CFBundleCopyResourceURLsOfTypeInDirectory( bundleURL, (CFStringRef)ext, NULL );
	NSUInteger count = CFArrayGetCount(array);
	id buffer[count];
	
	id *ptr = buffer;
	for( id url in (NSArray *)array )
		*ptr++ = [(id)CFURLCopyPath((CFURLRef)url) autorelease];
	
	CFRelease(bundleURL);
	[(id)array release];
	return [(id)CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, (CFArrayCallBacks *)&_PFCollectionCallBacks ) autorelease];	
}


/*
 *	Instance methods
 */

// private function we don't use but other code might
- (CFBundleRef)_cfBundle { return (CFBundleRef)_cfBundle; }

- (NSArray *)executableArchitectures 
{ 
	return [(id)CFBundleCopyExecutableArchitectures((CFBundleRef)_cfBundle) autorelease];
}

- (BOOL)load 
{ 
	if( YES == CFBundleIsExecutableLoaded( (CFBundleRef)_cfBundle ) ) return YES;
	if( NO == CFBundleLoadExecutable( (CFBundleRef)_cfBundle ) ) return NO;
	
	// send notifications...
	
	return YES;
}

- (BOOL)loadAndReturnError:(NSError **)error 
{ 
	if( YES == CFBundleIsExecutableLoaded( (CFBundleRef)_cfBundle ) ) return YES;
	if( NO == CFBundleLoadExecutableAndReturnError( (CFBundleRef)_cfBundle, (CFErrorRef *)error) ) return NO;
	
	// send notifications
	
	return YES;
}

- (BOOL)isLoaded { return CFBundleIsExecutableLoaded( (CFBundleRef)_cfBundle ); }

- (BOOL)unload
{
	if( NO == CFBundleIsExecutableLoaded( (CFBundleRef)_cfBundle ) ) return YES;
	CFBundleUnloadExecutable( (CFBundleRef)_cfBundle );
	return CFBundleIsExecutableLoaded( (CFBundleRef)_cfBundle ) ? NO : YES;
}

- (BOOL)preflightAndReturnError:(NSError **)error 
{ 
	return CFBundlePreflightExecutable( (CFBundleRef)_cfBundle, (CFErrorRef *)error); 
}

- (NSString *)bundlePath 
{
	CFURLRef url = CFBundleCopyBundleURL( (CFBundleRef)_cfBundle );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];
}

- (NSString *)resourcePath 
{
	CFURLRef url = CFBundleCopyResourcesDirectoryURL( (CFBundleRef)_cfBundle );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];	
}

- (NSString *)executablePath 
{
	CFURLRef url = CFBundleCopyExecutableURL( (CFBundleRef)_cfBundle );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];		
}

- (NSString *)pathForAuxiliaryExecutable:(NSString *)executableName 
{
	CFURLRef url = CFBundleCopyAuxiliaryExecutableURL( (CFBundleRef)_cfBundle, (CFStringRef)executableName );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];	
}

- (NSString *)privateFrameworksPath 
{
	CFURLRef url = CFBundleCopyPrivateFrameworksURL( (CFBundleRef)_cfBundle );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];			
}

- (NSString *)sharedFrameworksPath 
{
	CFURLRef url = CFBundleCopySharedFrameworksURL( (CFBundleRef)_cfBundle );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];			
}

- (NSString *)sharedSupportPath 
{
	CFURLRef url = CFBundleCopySharedSupportURL( (CFBundleRef)_cfBundle );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];			
}

- (NSString *)builtInPlugInsPath 
{
	CFURLRef url = CFBundleCopyBuiltInPlugInsURL( (CFBundleRef)_cfBundle );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];	
}

- (NSString *)bundleIdentifier { return (NSString *)CFBundleGetIdentifier( (CFBundleRef)_cfBundle ); }

- (Class)classNamed:(NSString *)className {}

- (Class)principalClass {}

/* In the following methods, bundlePath is an absolute path to a bundle, and may not be nil; subpath is a relative path to a subdirectory inside the relevant global or localized resource directory, and should be nil if the resource file in question is not in a subdirectory. */
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext 
{
	CFURLRef url = CFBundleCopyResourceURL( (CFBundleRef)_cfBundle, (CFStringRef)name, (CFStringRef)ext, NULL);
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath 
{
	CFURLRef url = CFBundleCopyResourceURL( (CFBundleRef)_cfBundle, (CFStringRef)name, (CFStringRef)ext, (CFStringRef)subpath );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName 
{
	CFURLRef url = CFBundleCopyResourceURLForLocalization( (CFBundleRef)_cfBundle, (CFStringRef)name, (CFStringRef)ext, (CFStringRef)subpath, (CFStringRef)localizationName );
	CFStringRef path = CFURLCopyPath(url);
	CFRelease(url);
	return [(id)path autorelease];
}

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath 
{
	CFArrayRef array = CFBundleCopyResourceURLsOfType( (CFBundleRef)_cfBundle, (CFStringRef)ext, (CFStringRef)subpath );
	NSUInteger count = CFArrayGetCount(array);
	id buffer[count];
	
	id *ptr = buffer;
	for( id url in (NSArray *)array )
		*ptr++ = [(id)CFURLCopyPath((CFURLRef)url) autorelease];
	
	[(id)array release];
	return [(id)CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, (CFArrayCallBacks *)&_PFCollectionCallBacks ) autorelease];
}

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName 
{
	CFArrayRef array = CFBundleCopyResourceURLsOfTypeForLocalization( (CFBundleRef)_cfBundle, (CFStringRef)ext, (CFStringRef)subpath, (CFStringRef)localizationName );
	NSUInteger count = CFArrayGetCount(array);
	id buffer[count];
	
	id *ptr = buffer;
	for( id url in (NSArray *)array )
		*ptr++ = [(id)CFURLCopyPath((CFURLRef)url) autorelease];
	
	[(id)array release];
	return [(id)CFArrayCreate( kCFAllocatorDefault, (const void **)buffer, count, (CFArrayCallBacks *)&_PFCollectionCallBacks ) autorelease];	
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName 
{
	/*
	 *	I think this method actually does more than this, but that behaviour is controlled by user preference
	 *	keys, which we haven't implemented yet
	 */
	return [(id)CFBundleCopyLocalizedString( (CFBundleRef)_cfBundle, (CFStringRef)key, (CFStringRef)value, (CFStringRef)tableName ) autorelease];
}

- (NSDictionary *)infoDictionary { return (NSDictionary *)CFBundleGetInfoDictionary( (CFBundleRef)_cfBundle ); }

- (NSDictionary *)localizedInfoDictionary 
{ 
	return (NSDictionary *)CFBundleGetLocalInfoDictionary( (CFBundleRef)_cfBundle );
}

- (id)objectForInfoDictionaryKey:(NSString *)key 
{
	return (id)CFBundleGetValueForInfoDictionaryKey( (CFBundleRef)_cfBundle, (CFStringRef)key );
}

- (NSArray *)localizations { return [(id)CFBundleCopyBundleLocalizations( (CFBundleRef)_cfBundle ) autorelease]; }

- (NSArray *)preferredLocalizations 
{
	// I think that this is the correct behaviour
	CFArrayRef localizations = CFBundleCopyBundleLocalizations( (CFBundleRef)_cfBundle );
	CFArrayRef preferred = CFBundleCopyPreferredLocalizationsFromArray(localizations);
	[(id)localizations release];
	return [(id)preferred autorelease];
}

- (NSString *)developmentLocalization { return (NSString *)CFBundleGetDevelopmentRegion( (CFBundleRef)_cfBundle ); }

@end


