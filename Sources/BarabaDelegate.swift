//
// BarabaDelegate.swift
//
// Copyright (c) 2020 Soojin Ro (https://github.com/nsoojin)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/**
 Methods you can implement to be notified of Baraba events and life cycle changes.
 */
public protocol BarabaDelegate: AnyObject {
    /**
     Tells the delegate that Baraba initiated the auto-scrolling.
     
     The Baraba object scrolls the scrollView when it is active and when user is looking at the screen.
     
     - Parameters:
        - baraba: The baraba object that initiated the scrolling.
     */
    func barabaDidStartScrolling(_ baraba: Baraba)
    
    /**
     Tells the delegate that Baraba stopped the auto-scrolling.
    
     The Baraba object stops the scrolling for several reasons. When the user starts interacting with the scroll view (e.g. dragging), or when camera session is interrupted(e.g. app goes into background). Once it starts scrolling again, `func barabaDidStartScrolling(_:)` method will be called.
     
     When Baraba is not auto-scrolling, aforementioned events will not trigger this method. Also, calling `func pause()` on the Baraba will not trigger this method.
     
     - Parameters:
        - baraba: The baraba object that stopped the scrolling.
    */
    func barabaDidStopScrolling(_ baraba: Baraba)
    
    /**
     Tells the delegate that Baraba has stopped running due to an error.
    
     - Parameters:
        - baraba: The baraba object that failed.
        - error: An error object describing the failure.
    */
    func baraba(_ baraba: Baraba, didFailWithError error: Error)
}

public extension BarabaDelegate {
    func barabaDidStartScrolling(_ baraba: Baraba) {}
    func barabaDidStopScrolling(_ baraba: Baraba) {}
    func baraba(_ baraba: Baraba, didFailWithError error: Error) {}
}
