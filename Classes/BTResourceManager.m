//
//  Betwixt - Copyright 2011 Three Rings Design

#import "BTResourceManager+Package.h"
#import "BTResourceFactory.h"
#import "BTResource.h"

@implementation BTResourceManager

+ (BTResourceManager *)sharedManager {
    static BTResourceManager *instance = nil;
    @synchronized(self) {
        if (instance == nil) {
            instance = [[BTResourceManager alloc] init];
        }
    }
    return instance;
}

- (id)init {
    if (!(self = [super init])) {
        return nil;
    }
    _factories = [[NSMutableDictionary alloc] init];
    _resources = [[NSMutableDictionary alloc] init];
    return self;
}

- (BTResource *)getResource:(NSString *)name {
    @synchronized (_resources) {
        return [_resources objectForKey:name];
    }
}

- (BTResource *)requireResource:(NSString *)name {
    BTResource *rsrc = [self getResource:name];
    NSAssert(rsrc != nil, @"No such resource: %@", name);
    return rsrc;
}

- (BOOL)isLoaded:(NSString *)name {
    return [self getResource:name] != nil;
}

- (void)unloadGroup:(NSString *)group {
    @synchronized(_resources) {
        for (BTResource *rsrc in [_resources allValues]) {
            if ([rsrc.group isEqualToString:group]) {
                [_resources removeObjectForKey:rsrc.name];
            }
        }
    }
}

- (void)unloadAll {
    @synchronized(_resources) {
        [_resources removeAllObjects];
    }
}

- (void)registerFactory:(id<BTResourceFactory>)factory forType:(NSString *)type {
    [_factories setObject:factory forKey:type];
}

- (id<BTResourceFactory>)getFactory:(NSString *)type {
    return [_factories objectForKey:type];
}

@end

@implementation BTResourceManager (package)

- (void)add:(BTResource *)rsrc {
    NSAssert(rsrc.group != nil, @"Resource doesn't belong to a group: %@", rsrc);
    NSAssert(rsrc.state == LS_LOADED, @"Resource isn't loaded: %@", rsrc);
    @synchronized (_resources) {
        NSAssert([self getResource:rsrc.name] == nil, 
                 @"A Resource with that name already exists [name=%@]", [rsrc name]);
        [_resources setObject:rsrc forKey:rsrc.name];
    }
}

@end
