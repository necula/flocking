varying lowp vec4 colorVarying;
varying lowp vec2 texCoords;
uniform sampler2D tex;

void main()
{
    highp vec4 color = texture2D(tex, texCoords);
    if(color.w < 0.1)
        discard;
    gl_FragColor = color;
}
