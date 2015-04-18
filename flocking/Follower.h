#import "Sprite.h"

@interface Follower : Sprite

@property (nonatomic) Sprite* target;

-(instancetype)initWithTarget:(Sprite*)target;

-(void)update:(float)dt;

@end
