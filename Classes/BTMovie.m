//
// Betwixt - Copyright 2012 Three Rings Design

#import "BTMovie.h"
#import "BTMovie+Package.h"
#import "BTApp.h"
#import "BTMovieResourceKeyframe.h"
#import "BTResourceManager.h"
#import "BTTextureResource.h"
#import "BTMovieResourceLayer.h"

NSString * const BTMovieFirstFrame = @"BTMovieFirstFrame";
NSString * const BTMovieLastFrame = @"BTMovieLastFrame";
@interface BTMovieLayer : SPSprite {
@public
    int keyframeIdx;
    NSMutableArray *keyframes;
}
@end

@implementation BTMovieLayer
-(BTMovieResourceKeyframe*)kfAtIdx:(int)idx {
    return (BTMovieResourceKeyframe*)[keyframes objectAtIndex:idx];
}

- (id)initWithLayer:(BTMovieResourceLayer*)layer {
    if (!(self = [super init])) return nil;
    self.name = layer->name;
    keyframes = layer->keyframes;
    BTTextureResource *tex = [[BTApp resourceManager] requireResource:[self kfAtIdx:0]->libraryItem];
    // TODO - texture offset
    SPImage *img = [[SPImage alloc] initWithTexture:tex.texture];
    img.x = tex.offset.x;
    img.y = tex.offset.y;
    [self addChild:img];
    return self;
}

- (void)drawFrame:(int)frame {
    while (keyframeIdx < [keyframes count] - 1 && [self kfAtIdx:keyframeIdx + 1]->index <= frame) {
        keyframeIdx++;
    }
    BTMovieResourceKeyframe *kf = [self kfAtIdx:keyframeIdx];
    if (keyframeIdx == [keyframes count] - 1|| kf->index == frame) {
        self.x = kf->x;
        self.y = kf->y;
        self.scaleX = kf->scaleX;
        self.scaleY = kf->scaleY;
        self.rotation = kf->rotation;
    } else {
        // TODO - interpolation types other than linear
        float interped = (frame - kf->index)/(float)kf->duration;
        BTMovieResourceKeyframe *nextKf = [self kfAtIdx:keyframeIdx + 1];
        self.x = kf->x + (nextKf->x - kf->x) * interped;
        self.y = kf->y + (nextKf->y - kf->y) * interped;
        self.scaleX = kf->scaleX + (nextKf->scaleX - kf->scaleX) * interped;
        self.scaleY = kf->scaleY + (nextKf->scaleY - kf->scaleY) * interped;
        self.rotation = kf->rotation + (nextKf->rotation - kf->rotation) * interped;
    }
}
@end

@implementation BTMovie {
    int _frame;
    RABoolValue *_playing;
    float _playTime, _duration;
    RAObjectSignal *_labelPassed;
    NSArray *_labels;
}

- (void)drawFrame:(BOOL)resetKeframes {
    if (resetKeframes) for (BTMovieLayer *layer in _sprite) layer->keyframeIdx = 0;
    for (BTMovieLayer *layer in _sprite) [layer drawFrame:_frame];
}

- (void)fireLabelsFrom:(int)startFrame to:(int)endFrame {
    for (int ii = startFrame; ii <= endFrame; ii++) {
        for (NSString *label in [_labels objectAtIndex:ii]) [_labelPassed emitEvent:label];
    }
}

- (void)update:(float)dt {
    if (!_playing.value) return;
    _playTime += dt;
    if (_playTime > _duration) _playTime = fmodf(_playTime, _duration);

    int oldFrame = _frame;
    _frame = (int)(_playTime * 30);
    BOOL differentFrame = oldFrame != _frame;
    BOOL wrapped = _frame < oldFrame;
    if (differentFrame) [self drawFrame:wrapped];

    if (dt >= _duration) {
        [self fireLabelsFrom:oldFrame + 1 to:[_labels count] - 1];
        [self fireLabelsFrom:0 to:oldFrame];
    } else if (differentFrame) {
        if (wrapped) {
            [self fireLabelsFrom:oldFrame + 1 to:[_labels count] - 1];
            [self fireLabelsFrom:0 to:_frame];
        } else [self fireLabelsFrom:oldFrame + 1 to:_frame];
    }
}

- (RAConnection*)monitorLabel:(NSString *)label withUnit:(RAUnitBlock)slot {
    return [_labelPassed connectSlot:^(id labelFired) {
        if ([labelFired isEqual:label]) slot();
    }];

}

- (id)initWithLayers:(NSMutableArray*)layers andLabels:(NSArray*)labels {
    if (!(self = [super init])) return nil;
    for (BTMovieResourceLayer *layer in layers) {
        BTMovieLayer *mLayer = [[BTMovieLayer alloc] initWithLayer:layer];
        [_sprite addChild:mLayer];
    }
    _labels = labels;
    _duration = [labels count] / 30.0;
    _playing = [[RABoolValue alloc] init];
    _playing.value = YES;
    _labelPassed = [[RAObjectSignal alloc] init];
    [self drawFrame:NO];
    return self;
}

@synthesize duration=_duration, playing=_playing, labelPassed=_labelPassed;
@end
