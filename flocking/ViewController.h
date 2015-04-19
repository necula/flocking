#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

extern CGSize g_screenSize;
extern float g_sceneScale;

@class Player;

@interface ViewController : GLKViewController
{
    GLuint _program;

    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic) GLKMatrix4 projMatrix;
@property (strong, nonatomic) GLKTextureInfo* qTexture;
@property (strong, nonatomic) Player* player;
@property (strong, nonatomic) NSMutableArray* followers;

- (void)setupGL;
- (void)tearDownGL;

@end

