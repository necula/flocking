#import "Follower.h"
#import "Utils.h"

#define TARGET_MIN_DISTANCE 100.f // pixels
#define SEPARATION_DISTANCE 50.f
#define SIGHT_DISTANCE 150.f

static const float MAX_SPEED = 150.f; // pixels/s
static const float TARGET_AVOIDANCE_MAX_SPEED = 350.f; // pixels/s

static const float SEPARATION_DISTANCE_SQ = SEPARATION_DISTANCE * SEPARATION_DISTANCE;
static const float SIGHT_DISTANCE_SQ = SIGHT_DISTANCE * SIGHT_DISTANCE;
static const float TARGET_MIN_DISTANCE_SQ = TARGET_MIN_DISTANCE * TARGET_MIN_DISTANCE;

static const float TARGET_AVOIDANCE_WEIGHT = 50.f;
static const float TARGET_ALIGNMENT_WEIGHT = 0.2f;

static const float SEPARATION_WEIGHT = 5.f;
static const float COHESION_WEIGHT = 0.04f;
static const float ALIGNMENT_WEIGHT = 0.0f;

@implementation Follower

-(instancetype)initWith:(CGPoint)position size:(CGSize)size
{
    self = [super initWith:position size:size];
    if(!self)
        return nil;
    
    float angle = rand() * 2.f * M_PI;
    float speed = rand() * (MAX_SPEED-50.f) + 50.f;
    _heading = CGPointMake(cosf(angle) * speed, sinf(angle) * speed);
    
    return self;
}

-(void)update:(float)dt
{
    int closeFollowers = 0;
    CGPoint averageAlignment = CGPointMake(0.f, 0.f);
    for(Follower* follower in _allFollowers)
    {
        if(follower != self)
        {
            float distToFollowerSq = DistSq(self.position, follower.position);
            if(distToFollowerSq < SEPARATION_DISTANCE_SQ) // separation
            {
                _heading.x += (self.position.x - follower.position.x) * SEPARATION_WEIGHT;
                _heading.y += (self.position.y - follower.position.y) * SEPARATION_WEIGHT;
            }
            else if((_target && _target.visible) && distToFollowerSq < SIGHT_DISTANCE_SQ) // cohesion
            {
                _heading.x += (follower.position.x - self.position.x) * COHESION_WEIGHT;
                _heading.y += (follower.position.y - self.position.y) * COHESION_WEIGHT;
            }
            if((_target && _target.visible) && distToFollowerSq < SIGHT_DISTANCE_SQ) // alignment
            {
                closeFollowers++;
                averageAlignment.x += follower.heading.x;
                averageAlignment.y += follower.heading.y;
            }
        }
    }
    
    if(closeFollowers > 0)
    {
        _heading.x += (averageAlignment.x/closeFollowers) * ALIGNMENT_WEIGHT;
        _heading.y += (averageAlignment.y/closeFollowers) * ALIGNMENT_WEIGHT;
    }
    
    if(_target && _target.visible)
    {
        float distSq = DistSq(self.position, _target.position);
        if(_leader && distSq > TARGET_MIN_DISTANCE_SQ)
        {
            _heading.x += (_target.position.x - self.position.x) * TARGET_ALIGNMENT_WEIGHT;
            _heading.y += (_target.position.y - self.position.y) * TARGET_ALIGNMENT_WEIGHT;
        }
    }
    
    _heading = [self resizeVector:_heading toLength:MAX_SPEED];
    
    if(_target && _target.visible)
    {
        float distSq = DistSq(self.position, _target.position);
        if(distSq < TARGET_MIN_DISTANCE_SQ)
        {
            _heading.x += (self.position.x - _target.position.x)  * TARGET_AVOIDANCE_WEIGHT;
            _heading.y += (self.position.y - _target.position.y)  * TARGET_AVOIDANCE_WEIGHT;
            _heading = [self resizeVector:_heading toLength:TARGET_AVOIDANCE_MAX_SPEED];
        }
    }
    
    CGPoint position = self.position;
    position.x += _heading.x * dt;
    position.y += _heading.y * dt;
    self.position = position;
    
    [self checkBoundaries];
    
    [self updateMatrix];
}

-(void)checkBoundaries
{
    if(self.position.x < 0)
        self.position = CGPointMake(1024, self.position.y);
    else if(self.position.x > 1024)
        self.position = CGPointMake(0, self.position.y);
    if(self.position.y < 0)
        self.position = CGPointMake(self.position.x, 768);
    else if(self.position.y > 768)
        self.position = CGPointMake(self.position.x, 0);
}

-(CGPoint)resizeVector:(CGPoint)vector toLength:(float)newLength
{
    float currentLength = Length(vector);
    if(currentLength > newLength)
    {
        vector.x = vector.x * (newLength/currentLength);
        vector.y = vector.y * (newLength/currentLength);
    }
    return vector;
}

@end
