#import "Sprite.h"

@implementation Sprite

-(instancetype)initWith:(CGPoint)position size:(CGSize)size
{
    self = [super init];
    if(!self)
        return nil;
    
    _position = position;
    _size = size;
    _wvMatrix = GLKMatrix4Identity;
    _visible = YES;
    
    return self;
}

-(instancetype)init
{
    return [self initWith:CGPointMake(0.f, 0.f) size:CGSizeMake(100.f, 100.f)];
}

-(void)update:(float)dt
{
    [self updateMatrix];
}

-(void)updateMatrix
{
    _wvMatrix = GLKMatrix4MakeTranslation(_position.x, _position.y, 0.f);
    _wvMatrix = GLKMatrix4Scale(_wvMatrix, _size.width, _size.height, 1.f);
}

-(void)translateRelative:(CGPoint)point
{
    _position.x += point.x;
    _position.y += point.y;
}

@end
