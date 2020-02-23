//
//  BarabaTests.swift
//  BarabaTests
//
//  Created by Soojin Ro on Feb 14, 2020.
//  Copyright © 2020 nsoojin. All rights reserved.
//

@testable import Baraba
import XCTest

class BarabaTests: XCTestCase {
    func testUnsupportedConfiguration() {
        let baraba = Baraba(configuration: .unsupported)
        let delegate = MockBarabaDelegate()
        let scrollView = UIScrollView()
        
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        baraba.resume()
        
        let error = delegate.error
        
        XCTAssertFalse(baraba.isActive)
        XCTAssertNotNil(error)
        
        if let error = error {
            if case BarabaError.unsupportedConfiguration = error {
            } else {
                XCTFail("Expected BarabaError.unsupportedConfiguration, but got \(error)")
            }
        } else {
            XCTFail("error must not be nil.")
        }
    }
}
