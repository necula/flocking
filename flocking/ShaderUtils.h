#pragma once

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ROOT_CLASS
@interface ShaderUtils

+ (GLuint)loadShaders:(NSString*)shaderName;

@end
