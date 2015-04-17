attribute vec2 position;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;

void main()
{
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);

    colorVarying = diffuseColor;
    
    gl_Position = modelViewProjectionMatrix * vec4(position, 0.0, 1.0);
}
