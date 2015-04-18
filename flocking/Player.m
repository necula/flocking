#import "Player.h"

@implementation Player


-(void)update:(float)dt
{
    [self updateMatrix];
}

- (void)touchBegan:(CGPoint)touchPoint
{
    if(![self containsPoint:touchPoint])
        return;
    
    _touchActive = YES;
    _lastTouchPoint = touchPoint;
}

- (void)touchMoved:(CGPoint)touchPoint
{
    if(_touchActive)
    {
        CGPoint delta = CGPointMake(touchPoint.x - _lastTouchPoint.x, touchPoint.y - _lastTouchPoint.y);
        [self translateRelative:delta];
        _lastTouchPoint = touchPoint;
    }
}

- (void)touchEnded:(CGPoint)touchPoint
{
    _touchActive = false;
}

- (void)touchCancelled:(CGPoint)touchPoint
{
    _touchActive = false;
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
