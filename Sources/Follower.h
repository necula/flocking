#import "Sprite.h"

@interface Follower : Sprite

@property (nonatomic, weak) Sprite* target;
@property (nonatomic, weak) NSArray* allFollowers;
@property (nonatomic) CGPoint velocity;

-(void)update:(float)dt;

@end
