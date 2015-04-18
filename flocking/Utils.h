#pragma once

#import <Foundation/Foundation.h>

float DistSq(CGPoint p1, CGPoint p2)
{
    return ((p2.x-p1.x)*(p2.x-p1.x) + (p2.y-p1.y)*(p2.y-p1.y));
}