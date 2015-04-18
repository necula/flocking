#import "Follower.h"
#import "Utils.h"

#define MAX_SPEED 300.f // pixels/s
#define MIN_DISTANCE 50.f // pixels
#define MIN_DISTANCE_SQ (MIN_DISTANCE*MIN_DISTANCE)

@implementation Follower

-(instancetype)initWithTarget:(Sprite *)target
{
    self = [super init];
    if(!self)
        return nil;
    
    _target = target;
    
    return self;
}

-(void)update:(float)dt
{
    float distSq = DistSq(self.position, _target.position);
    if(distSq > MIN_DISTANCE_SQ)
    {
        float deltaY = _target.position.y - self.position.y;
        float deltaX = _target.position.x - self.position.x;
        float angle = atan2f(deltaY, deltaX);
        
        CGPoint position = self.position;
        position.x += cosf(angle) * MAX_SPEED * dt;
        position.y += sinf(angle) * MAX_SPEED * dt;
        self.position = position;
    }
    
    [self updateMatrix];
}

@end
