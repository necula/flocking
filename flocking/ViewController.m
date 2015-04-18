#import "ViewController.h"
#import "Player.h"
#import "Follower.h"
#import "Utils.h"
#import "ShaderUtils.h"
#import <OpenGLES/ES2/glext.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    NUM_ATTRIBUTES
};

GLfloat gQuadVertexData[] =
{
    1.f,-1.f,
    -1.f,-1.f,
    -1.f, 1.f,
    -1.f, 1.f,
    1.f, 1.f,
    1.f,-1.f,
};

@interface ViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic) GLKMatrix4 projMatrix;


@property (nonatomic) GLKTextureInfo* qTexture;

@property (nonatomic) Player* player;
@property (nonatomic) NSMutableArray* followers;

- (void)setupGL;
- (void)tearDownGL;
@end

static const int followersNum = 25;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    self.preferredFramesPerSecond = 60;
    
    [self setupGL];
    
    _player = [[Player alloc] initWith:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2) size:CGSizeMake(65, 65)];
    _player.visible = false;
    // TODO: error checking
    _qTexture = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Q" ofType:@"png"] options:nil error:nil];
    
    const CGSize followerSize = CGSizeMake(20, 20);
    _followers = [[NSMutableArray alloc] initWithCapacity:followersNum];
    for(int i = 0; i < followersNum; i++)
    {
        CGPoint followerPos = CGPointMake(foo4random() * self.view.bounds.size.width, foo4random() * self.view.bounds.size.height);
        Follower* follower = [[Follower alloc] initWith:followerPos size:followerSize];
        if(i == 0)
        {
            follower.leader = true;
            follower.target = _player;
        }
        else
        {
            follower.leader = true;
            follower.target = _player;//(Sprite*)[_followers lastObject];
        }
        follower.allFollowers = _followers;
        [_followers addObject:follower];
    }
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];

    _program = [ShaderUtils loadShaders:@"Shader"];
    if(!_program)
        return;
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "tex");
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gQuadVertexData), gQuadVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player touchBegan:[[touches anyObject] locationInView:self.view]];
    
    if(!_player.visible)
    {
        _player.position = [[touches anyObject] locationInView:self.view];
        _player.visible = true;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player touchMoved:[[touches anyObject] locationInView:self.view]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player touchEnded:[[touches anyObject] locationInView:self.view]];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player touchCancelled:[[touches anyObject] locationInView:self.view]];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    _projMatrix = GLKMatrix4MakeOrtho(0, self.view.bounds.size.width, self.view.bounds.size.height, 0, -1, 1);
    
    [_player update:self.timeSinceLastUpdate];
    
    for(Follower* follower in _followers)
        [follower update:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(66/255.f, 43/255.f, 132/255.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    glUseProgram(_program);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(_qTexture.target, _qTexture.name);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    // Draw followers.
    for(Follower* follower in _followers)
    {
        if(follower.visible)
        {
            GLKMatrix4 wvpMatrix = GLKMatrix4Multiply(_projMatrix, follower.wvMatrix);
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, wvpMatrix.m);
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
    }
    
    // Draw player.
    if(_player.visible)
    {
        GLKMatrix4 wvpMatrix = GLKMatrix4Multiply(_projMatrix, _player.wvMatrix);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, wvpMatrix.m);
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

}

#pragma mark -  OpenGL ES 2 shader compilation

@end
