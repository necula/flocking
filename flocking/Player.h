#import "Sprite.h"

@interface Player : Sprite

@property (nonatomic) bool touchActive;
@property (nonatomic) bool touchMoving;
@property (nonatomic) CGPoint lastTouchPoint;

-(void)update:(float)dt;

- (void)touchBegan:(CGPoint)touchPoint;
- (void)touchMoved:(CGPoint)touchPoint;
- (void)touchEnded:(CGPoint)touchPoint;
- (void)touchCancelled:(CGPoint)touchPoint;
-(BOOL)containsPoint:(CGPoint)point;

@end
