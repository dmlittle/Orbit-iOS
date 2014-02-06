//
//  CGVectorMath.h
//  Orbitz
//
//  Created by Donald Little on 2/5/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>

static inline CGFloat CGDistanceBetweenPoints(CGPoint p1, CGPoint p2) {
    return sqrtf((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y));
}

static inline CGPoint CGPointMinusPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

static inline CGVector CGVectorFromPointToPoint(CGPoint p1, CGPoint p2) {
    return CGVectorMake(p1.x - p2.x, p1.y - p2.y);
}

static inline CGFloat CGVectorMagnitude(CGVector v1) {
    return sqrtf(v1.dx * v1.dx + v1.dy * v1.dy);
}