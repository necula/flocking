attribute vec2 position;

varying lowp vec2 texCoords;

uniform mat4 modelViewProjectionMatrix;

void main()
{
    texCoords = (position + 1.0) * 0.5;
    
    gl_Position = modelViewProjectionMatrix * vec4(position, 0.0, 1.0);
}
