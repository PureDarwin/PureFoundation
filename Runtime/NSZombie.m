//
//  PureFoundation -- http://www.puredarwin.org
//  NSZombie.m
//
//  Created by Stuart Crook on 08/04/2018.
//  LGPL'd. See LICENCE.txt for copyright information.
//

// Copied out of old NSObject.m
// Should be moved into CoreFoundation

// These are implemented in macOS Foundation:
//  BOOL NSDeallocateZombies -- is in docs

typedef void* marg_list;

@interface _NSZombie_
{ Class isa; }
@end

@implementation _NSZombie_

// this simply stops the spurious "zombie class sent initialize" message
+ (void)initialize { }

- (id)retain
{
    fprintf(stderr, "<_NSZombie_ 0x%p> in %s sent -retain\n", self, getprogname());
    return self;
}

- (void)release
{
    fprintf(stderr, "<_NSZombie_ 0x%p> in %s sent -release\n", self, getprogname());
}

- (id)autorelease
{
    fprintf(stderr, "<_NSZombie_ 0x%p> in %s sent -release\n", self, getprogname());
    return self;
}

- (id)forward:(SEL)sel :(marg_list)margs
{
    fprintf(stderr, "<_NSZombie_ 0x%p> in %s sent '%s'\n", self, getprogname(), sel_getName(sel));
    return nil;
}

@end
