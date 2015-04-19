#import "ViewController.h"
#import "Follower.h"
#import "MathUtils.h"

static const float TARGET_MIN_DISTANCE = 100.f; // Points.
static const float SEPARATION_DISTANCE = 50.f; // Points.
static const float SIGHT_DISTANCE = 150.f; // Points.

static const float TARGET_AVOIDANCE_WEIGHT = 50.f;
static const float TARGET_CHASE_WEIGHT = 0.2f;

static const float SEPARATION_WEIGHT = 5.f;
static const float COHESION_WEIGHT = 0.04f;
static const float ALIGNMENT_WEIGHT = 0.0f;

@interface Follower ()

@property (nonatomic) float SEPARATION_DISTANCE_SQ;
@property (nonatomic) float SIGHT_DISTANCE_SQ;
@property (nonatomic) float TARGET_MIN_DISTANCE_SQ;
@property (nonatomic) float TARGET_AVOIDANCE_MAX_SPEED; // Points/sec.
@property (nonatomic) float TARGET_CHASE_MAX_SPEED; // Points/sec.

@end

@implementation Follower

-(instancetype)initWith:(CGPoint)position size:(CGSize)size
{
    self = [super initWith:position size:size];
    if(!self)
        return nil;

    const float sceneScaleSq = (g_sceneScale*g_sceneScale);
    _TARGET_MIN_DISTANCE_SQ = TARGET_MIN_DISTANCE*TARGET_MIN_DISTANCE * sceneScaleSq;
    _SEPARATION_DISTANCE_SQ = SEPARATION_DISTANCE*SEPARATION_DISTANCE * sceneScaleSq;
    _SIGHT_DISTANCE_SQ = SIGHT_DISTANCE*SIGHT_DISTANCE * sceneScaleSq;
    
    _TARGET_CHASE_MAX_SPEED = 150.f * g_sceneScale;
    _TARGET_AVOIDANCE_MAX_SPEED = 350.f * g_sceneScale;
    
    const float angle = (rand()/(float)RAND_MAX) * 2.f * M_PI;
    const float speed = (rand()/(float)RAND_MAX) * (_TARGET_CHASE_MAX_SPEED-50.f) + 50.f;
    _velocity = CGPointMake(cosf(angle) * speed, sinf(angle) * speed);
    
    return self;
}

-(void)update:(float)dt
{
    for(Follower* follower in _allFollowers)
    {
        if(follower != self)
        {
            float distToFollowerSq = DistSq(self.position, follower.position);
            if(distToFollowerSq < _SEPARATION_DISTANCE_SQ) // Separation.
            {
                _velocity.x += (self.position.x - follower.position.x) * SEPARATION_WEIGHT;
                _velocity.y += (self.position.y - follower.position.y) * SEPARATION_WEIGHT;
            }
            else if((_target && _target.visible) && distToFollowerSq < _SIGHT_DISTANCE_SQ) // Cohesion.
            {
                _velocity.x += (follower.position.x - self.position.x) * COHESION_WEIGHT;
                _velocity.y += (follower.position.y - self.position.y) * COHESION_WEIGHT;
            }
            if((_target && _target.visible) && distToFollowerSq < _SIGHT_DISTANCE_SQ) // Alignment.
            {
                _velocity.x += follower.velocity.x * ALIGNMENT_WEIGHT;
                _velocity.y += follower.velocity.y * ALIGNMENT_WEIGHT;
            }
        }
    }
    
    if(_target && _target.visible)
    {
        float distSq = DistSq(self.position, _target.position);
        if(distSq > _TARGET_MIN_DISTANCE_SQ)
        {
            _velocity.x += (_target.position.x - self.position.x) * TARGET_CHASE_WEIGHT;
            _velocity.y += (_target.position.y - self.position.y) * TARGET_CHASE_WEIGHT;
        }
    }
    
    _velocity = ResizeToLength(_velocity, _TARGET_CHASE_MAX_SPEED);
    
    if(_target && _target.visible)
    {
        // Followers should get out of the target's way at a greater speed (TARGET_AVOIDANCE_MAX_SPEED > TARGET_CHASE_MAX_SPEED).
        float distSq = DistSq(self.position, _target.position);
        if(distSq < _TARGET_MIN_DISTANCE_SQ)
        {
            _velocity.x += (self.position.x - _target.position.x)  * TARGET_AVOIDANCE_WEIGHT;
            _velocity.y += (self.position.y - _target.position.y)  * TARGET_AVOIDANCE_WEIGHT;
            _velocity = ResizeToLength(_velocity, _TARGET_AVOIDANCE_MAX_SPEED);
        }
    }
    
    [self translateRelative:CGPointMake(_velocity.x*dt, _velocity.y*dt)];
    
    [self checkBoundaries];
    
    [self updateMatrix];
}

-(void)checkBoundaries
{
    if(self.position.x < 0)
        self.position = CGPointMake(g_screenSize.width, self.position.y);
    else if(self.position.x > g_screenSize.width)
        self.position = CGPointMake(0, self.position.y);
    if(self.position.y < 0)
        self.position = CGPointMake(self.position.x, g_screenSize.height);
    else if(self.position.y > g_screenSize.height)
        self.position = CGPointMake(self.position.x, 0);
}

@end
