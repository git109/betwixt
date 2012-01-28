//
//  Betwixt - Copyright 2011 Three Rings Design

#import "BTMode.h"
#import "BTModeStack.h"
#import "BTKeyed.h"
#import "BTMode+Protected.h"
#import "BTMode+Package.h"

@implementation BTMode {
    RAFloatSignal *_update;
    SPSprite *_sprite;
    NSMutableDictionary *_keyedObjects;
    NSMutableDictionary *_groups;
}

- (id)init {
    if (!(self = [super init])) return nil;
    _sprite = [[SPSprite alloc] init];
    _update = [[RAFloatSignal alloc] init];
    _keyedObjects = [[NSMutableDictionary alloc] init];
    _groups = [[NSMutableDictionary alloc] init];
    return self;
}

- (BTNode*)nodeForKey:(NSString*) key {
    return [_keyedObjects objectForKey:key];
}

- (NSArray*)nodesForGroup:(NSString*)group {
    return [_groups objectForKey:group];
}

- (BTMode*) mode {
    return self;
}

- (void)displayNode:(BTNode<BTDisplayable>*)node {
    [self addNode:node];
    [_sprite addChild:node.display];
}

- (void) detach {
    [_stack popMode];
}

- (SPDisplayObject*)display {
    return _sprite;
}

- (void)update:(float)dt {
    [_update emitEvent:dt];
}

- (void)enter {
}

- (void) exit {
}

- (void)addKeys:(BTNode<BTKeyed>*)node {
    for (NSString *key in ((id<BTKeyed>)node).keys) {
        NSAssert1(![_keyedObjects objectForKey:key], @"Object key '%@' already used", key);
        [_keyedObjects setObject:node forKey:key];
    }
}

- (void)addGroups:(BTNode<BTGrouped>*)node {
    for (NSString *group in ((id<BTGrouped>)node).groups) {
        NSMutableArray *members = [_groups objectForKey:group];
        if (!members) {
            members = [[NSMutableArray alloc] init];
            [_groups setObject:members forKey:group];
        }
        [members addObject:node];
    }
}

@synthesize sprite=_sprite, update=_update, stack=_stack;

@end
