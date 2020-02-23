//
// UtilsTests.swift
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

import XCTest
@testable import Baraba

class UtilsTests: XCTestCase {

    func testDebouncer() {
        let debouncer = Debouncer(delay: 0.3)
        
        let expectationCancel = expectation(description: "This job should cancel")
        expectationCancel.isInverted = true
        let expectationSuccess = expectation(description: "This job should succeed")
        
        debouncer.schedule {
            expectationCancel.fulfill()
        }
        
        debouncer.schedule {
            expectationSuccess.fulfill()
        }
       
        waitForExpectations(timeout: 0.5)
    }
    
    func testMinimum() {
        var mock = MockMinimum(50)
        
        mock.value = 20
        XCTAssertTrue(mock.value == 30)
        
        mock.value = 70
        XCTAssertTrue(mock.value == 70)
        
        mock.value = -20
        XCTAssertTrue(mock.value == 30)
        
        mock.value = 29
        XCTAssertTrue(mock.value == 30)
    }
}

private struct MockMinimum {
    @Minimum(min: 30) var value: Int = 0
    
    init(_ initial: Int) {
        value = initial
    }
}
