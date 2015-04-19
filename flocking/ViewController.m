#import "ViewController.h"
#import "Player.h"
#import "Follower.h"
#import "MathUtils.h"
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

static const int FOLLOWERS_NUM = 25;

static const int PLAYER_SIZE = 65;
static const int FOLLOWER_SIZE = 20;

CGSize g_screenSize;
float g_sceneScale;

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
    
    self.preferredFramesPerSecond = 60;
    
    [self setupGL];
    
    g_screenSize = self.view.bounds.size;
    if(g_screenSize.width < g_screenSize.height)
    {
        g_screenSize.width = self.view.bounds.size.height;
        g_screenSize.height = self.view.bounds.size.width;
    }
    
    g_sceneScale = g_screenSize.height / 768.f;
    
    _player = [[Player alloc] initWith:CGPointMake(g_screenSize.width/2, g_screenSize.height/2) size:CGSizeMake(g_sceneScale * PLAYER_SIZE, g_sceneScale * PLAYER_SIZE)];
    _player.visible = false;
    
    const CGSize followerSize = CGSizeMake(g_sceneScale * FOLLOWER_SIZE, g_sceneScale * FOLLOWER_SIZE);
    _followers = [[NSMutableArray alloc] initWithCapacity:FOLLOWERS_NUM];
    for(int i = 0; i < FOLLOWERS_NUM; i++)
    {
        CGPoint followerPos = CGPointMake((rand()/(float)RAND_MAX) * self.view.bounds.size.width, (rand()/(float)RAND_MAX) * self.view.bounds.size.height);
        Follower* follower = [[Follower alloc] initWith:followerPos size:followerSize];
        follower.target = _player;
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
    
    _qTexture = nil;
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
    
    _qTexture = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Q" ofType:@"png"] options:nil error:nil];
    
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
    
    _qTexture = nil;
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

@end
