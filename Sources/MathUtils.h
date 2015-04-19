#import <Foundation/Foundation.h>

static inline float DistSq(CGPoint p1, CGPoint p2)
{
    return ((p2.x-p1.x)*(p2.x-p1.x) + (p2.y-p1.y)*(p2.y-p1.y));
}

static inline float Length(CGPoint v)
{
    return sqrtf(v.x*v.x + v.y*v.y);
}

static inline CGPoint ResizeToLength(CGPoint v, float newLength)
{
    float currentLength = Length(v);
    if(currentLength > newLength)
    {
        v.x = v.x * (newLength/currentLength);
        v.y = v.y * (newLength/currentLength);
    }
    return v;
}