//
//  MarshallOperator.swift
//  Community
//
//  Created by David Ilizarov on 10/14/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import Foundation

infix operator ~> {}    // Instant
infix operator ~~> {}   // 0.25 second delay
infix operator ~~~> {}  // 0.5 second delay
infix operator ~~~~> {} // 1 second delay

private let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

func ~> (backgroundClosure: () -> (), mainClosure: () -> ()) {
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), mainClosure)
    }
}

func ~~> (backgroundClosure: () -> (), mainClosure: () -> ()) {
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), mainClosure)
    }
}

func ~~~> (backgroundClosure: () -> (), mainClosure: () -> ()) {
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), mainClosure)
    }
}

func ~~~~> (backgroundClosure: () -> (), mainClosure: () -> ()) {
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), mainClosure)
    }
}