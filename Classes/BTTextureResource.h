//
// Betwixt - Copyright 2012 Three Rings Design

#import "BTResource.h"
#import "BTDisplayObjectCreator.h"

#define BTTEXTURE_RESOURCE_NAME @"texture"

@protocol BTResourceFactory;
@class GDataXMLElement;

@interface BTTextureResource : BTResource<BTDisplayObjectCreator> {
@protected
    SPTexture* _texture;
    SPPoint* _offset;
}

+ (id<BTResourceFactory>) sharedFactory;
+ (BTTextureResource*)require:(NSString*)name;

@property(nonatomic,readonly) SPTexture* texture;
@property(nonatomic,readonly) SPPoint* offset;

- (id)initWithXml:(GDataXMLElement*)xml;

@end
