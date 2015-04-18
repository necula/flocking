#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Sprite : NSObject

@property (nonatomic) CGPoint       position;
@property (nonatomic) CGSize        size;
@property (nonatomic) GLKMatrix4    wvMatrix;
@property (nonatomic) BOOL          visible;

-(instancetype)init;
-(instancetype)initWith:(CGPoint)position size:(CGSize)size;

-(void)update:(float)dt;
-(void)updateMatrix;

-(void)translateRelative:(CGPoint)point;

@end
