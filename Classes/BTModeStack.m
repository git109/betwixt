//
//  Betwixt - Copyright 2011 Three Rings Design

#import "BTModeStack.h"

#import "BTGeneration+Package.h"

@implementation BTModeStack

- (id)init {
    if (!(self = [super init])) return nil;
    _sprite = [[SPSprite alloc] init];
    _stack = [NSMutableArray array];
    return self;
}

- (void)pushMode:(BTMode*)mode {
    [_stack addObject:mode];
    mode->_stack = self;
    [_sprite addChild:mode.sprite];
    mode.added = YES;
}

- (void)popMode {
    NSAssert([_stack count] > 0, @"Popped empty stack!");
    BTMode *popped = [_stack lastObject];
    [_stack removeLastObject];
    [_sprite removeChild:popped.sprite];
    if ([_stack count]) [_sprite addChild:((BTMode*)[_stack lastObject]).sprite];
}
@end

@implementation BTModeStack (package)

- (void)enterFrame:(SPEnterFrameEvent *)ev {
    [[_stack lastObject] enterFrame:ev];
}

@end