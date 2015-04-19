#import "Sprite.h"

@interface Player : Sprite

-(void)update:(float)dt;

-(void)touchBegan:(CGPoint)touchPoint;
-(void)touchMoved:(CGPoint)touchPoint;
-(void)touchEnded:(CGPoint)touchPoint;
-(void)touchCancelled:(CGPoint)touchPoint;

@end
