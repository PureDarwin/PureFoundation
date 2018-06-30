//
//  PureFoundation - http://puredarwin.org
//
//  NSAssertionHandler.m
//  Foundation
//
//  Created by Stuart Crook on 28/06/2018.
//

#import <Foundation/Foundation.h>

// TODO: Audit and then properly implement this class

@implementation NSAssertionHandler

+ (NSAssertionHandler *)currentHandler
{
    PF_HELLO("")
    
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    NSAssertionHandler *handler = [dict objectForKey: @"NSAssertionHandler"];
    if( handler == nil )
    {
        NSLog(@"no assertion handler set in dict 0x%p", dict);
        handler = [[NSAssertionHandler alloc] init];
        [dict setObject: handler forKey: @"NSAssertionHandler"];
    }
    return handler;
}

- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format,...
{
    va_list args;
    va_start( args, format );
    
    CFStringRef desc = CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, args );
    
    NSLog( @"*** Assertion failure in [%s %s], %@:%u (%@)", object_getClassName(object), sel_getName(selector), fileName, line, format );
    [NSException raise: NSInternalInconsistencyException format: (NSString *)desc];
    
    [(id)desc release];
    va_end( args );
}

- (void)handleFailureInFunction:(NSString *)functionName
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format,...
{
    va_list args;
    va_start( args, format );
    
    CFStringRef desc = CFStringCreateWithFormatAndArguments( kCFAllocatorDefault, NULL, (CFStringRef)format, args );
    
    NSLog( @"*** Assertion failure in %@(), %@:%u (%@)", functionName, fileName, line, format );
    [NSException raise: NSInternalInconsistencyException format: (NSString *)desc];
    
    [(id)desc release];
    va_end( args );
}

@end
