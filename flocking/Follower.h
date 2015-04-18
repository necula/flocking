#import "Sprite.h"

@interface Follower : Sprite

@property (nonatomic) bool leader;
@property (nonatomic) Sprite* target;
@property (nonatomic, weak) NSArray* allFollowers;

@property (nonatomic) CGPoint heading;

-(void)update:(float)dt;

@end
