#pragma once

#import <Foundation/Foundation.h>

#define foo4random() (rand()/(float)RAND_MAX) //(arc4random() / ((unsigned)RAND_MAX + 1))

static inline float DistSq(CGPoint p1, CGPoint p2)
{
    return ((p2.x-p1.x)*(p2.x-p1.x) + (p2.y-p1.y)*(p2.y-p1.y));
}

static inline float Length(CGPoint p)
{
    return sqrtf(p.x*p.x + p.y*p.y);
}