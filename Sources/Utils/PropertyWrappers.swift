//
// PropertyWrappers.swift
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

@propertyWrapper
internal struct Minimum<T: Comparable> {
    internal let min: T
    internal var value: T
    
    internal var wrappedValue: T {
        get {
            value
        }
        set {
            if newValue < min {
                value = min
            } else {
                value = newValue
            }
        }
    }
    
    internal init(wrappedValue: T, min: T) {
        precondition(wrappedValue >= min)
        self.min = min
        self.value = wrappedValue
    }
}

@propertyWrapper
internal struct Multiple {
    internal let multiplier: Int
    internal var value: Int
    
    internal var wrappedValue: Int {
        get {
            value
        }
        set {
            if newValue.isMultiple(of: multiplier) {
                value = newValue
            } else {
                let quotient = max(Int(round(Double(newValue) / Double(multiplier))), 1)
                value = multiplier * quotient
            }
        }
    }
    
    internal init(wrappedValue: Int, multiplier: Int) {
        precondition(wrappedValue.isMultiple(of: multiplier))
        self.value = wrappedValue
        self.multiplier = multiplier
    }
}
