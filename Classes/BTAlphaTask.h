//
// Betwixt - Copyright 2012 Three Rings Design

#import "BTDisplayObjectTask.h"

@interface BTAlphaTask : BTDisplayObjectTask

+ (BTAlphaTask*)withTime:(float)seconds alpha:(float)alpha;
+ (BTAlphaTask*)withTime:(float)seconds alpha:(float)alpha interpolator:(BTInterpolator*)interp;
+ (BTAlphaTask*)withTime:(float)seconds alpha:(float)alpha target:(SPDisplayObject*)target;
+ (BTAlphaTask*)withTime:(float)seconds alpha:(float)alpha interpolator:(BTInterpolator*)interp 
        target:(SPDisplayObject*)target;

- (id)initWithTime:(float)seconds alpha:(float)alpha;
- (id)initWithTime:(float)seconds alpha:(float)alpha interpolator:(BTInterpolator*)interp;
- (id)initWithTime:(float)seconds alpha:(float)alpha target:(SPDisplayObject*)target;
- (id)initWithTime:(float)seconds alpha:(float)alpha interpolator:(BTInterpolator*)interp 
           target:(SPDisplayObject*)target;
@end
