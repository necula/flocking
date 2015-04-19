#import "Player.h"

@interface Player ()
    @property (nonatomic) bool touchActive;
    @property (nonatomic) bool touchMoving;
    @property (nonatomic) CGPoint lastTouchPoint;
@end

@implementation Player

-(void)update:(float)dt
{
    [self updateMatrix];
}

- (void)touchBegan:(CGPoint)touchPoint
{
    if(!self.visible || ![self containsPoint:touchPoint])
        return;
    
    _touchActive = YES;
    _lastTouchPoint = touchPoint;
}

- (void)touchMoved:(CGPoint)touchPoint
{
    if(_touchActive)
    {
        _touchMoving = true;
        CGPoint delta = CGPointMake(touchPoint.x - _lastTouchPoint.x, touchPoint.y - _lastTouchPoint.y);
        [self translateRelative:delta];
        _lastTouchPoint = touchPoint;
    }
}

- (void)touchEnded:(CGPoint)touchPoint
{
    // Check if it's a tap gesture.
    if(_touchActive && !_touchMoving && [self containsPoint:touchPoint])
        self.visible = false;
    
    _touchActive = false;
    _touchMoving = false;
}

- (void)touchCancelled:(CGPoint)touchPoint
{
    _touchActive = false;
    _touchMoving = false;
}

-(BOOL)containsPoint:(CGPoint)point
{
    if(point.x >= (self.position.x - self.size.width) &&
       point.x <= (self.position.x + self.size.width) &&
       point.y >= (self.position.y - self.size.height) &&
       point.y <= (self.position.y + self.size.height))
        return YES;
    return NO;
}

@end
