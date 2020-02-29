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
    var delegate = MockBarabaDelegate()
    var scrollView = UIScrollView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 2000)))
    
    override func setUp() {
        delegate = MockBarabaDelegate()
        scrollView = UIScrollView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        scrollView.contentSize = CGSize(width: 100, height: 10_000)
    }
    
    func testUnsupportedConfiguration() {
        let baraba = Baraba(configuration: .unsupported)
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        
        baraba.resume()
        
        let error = delegate.error
        
        XCTAssert(Baraba.isConfigurationSupported(.unsupported) == false)
        XCTAssert(baraba.isActive == false)
        XCTAssert(error != nil)
        
        if let error = error {
            if case BarabaError.unsupportedConfiguration = error {
                //Correct case
            } else {
                XCTFail("Expected BarabaError.unsupportedConfiguration, but got \(error)")
            }
        } else {
            XCTFail("error must not be nil.")
        }
    }
    
    func testScrollViewNil() {
        let baraba = Baraba(configuration: .mock)
        baraba.delegate = delegate
        
        baraba.resume()
        
        let error = delegate.error
        
        XCTAssert(baraba.isActive == false, "Baraba should not be active if scroll view is nil at resume()")
        XCTAssert(error == nil, "scroll view being nil does not make an error object")
    }
    
    func testHardwareDenied() {
        let baraba = Baraba(configuration: .hardwareDenied)
        baraba.delegate = delegate
        baraba.scrollView = scrollView
        
        baraba.resume()
        
        let error = delegate.error
        
        XCTAssert(baraba.isActive == false)
        XCTAssert(error != nil)
        
        if let error = error {
            if case BarabaError.cameraUnauthorized = error {
                //Correct case
            } else {
                XCTFail("Expected BarabaError.cameraUnauthorized, but got \(error)")
            }
        } else {
            XCTFail("error must not be nil.")
        }
    }
    
    func testSingleScroll() {
        let mockTracker = MockFaceTracker()
        let config = BarabaConfiguration(tracker: mockTracker)
        let baraba = Baraba(configuration: config)
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        
        let testExpectation = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.trackerDidStartTrackingFace(mockTracker)
            usleep(0_500_000)
            
            delegate.trackerDidEndTrackingFace(mockTracker)
            usleep(0_500_000)
            
            testExpectation.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 2)
        XCTAssert(baraba.isActive == true)
        XCTAssert(delegate.numberOfScrollStarts == 1, "numberOfScrollStarts should be 1, instead of \(delegate.numberOfScrollStarts)")
        XCTAssert(delegate.numberOfScrollStops == 1, "numberOfScrollStarts should be 1, instead of \(delegate.numberOfScrollStarts)")
    }
    
    func testScrollSpeed() {
        let mockTracker = MockFaceTracker()
        let config = BarabaConfiguration(tracker: mockTracker)
        let baraba = Baraba(configuration: config)
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        baraba.preferredScrollSpeed = 600
        
        let testExpectation = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.trackerDidStartTrackingFace(mockTracker)
            usleep(2_000_000)
            
            delegate.trackerDidEndTrackingFace(mockTracker)
            usleep(0_050_000)
            
            testExpectation.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 3)
        XCTAssert(scrollView.contentOffset.y > 1200*0.9, "Scroll view's contentOffset is \(scrollView.contentOffset.y)")
        XCTAssert(scrollView.contentOffset.y < 1200*1.1, "Scroll view's contentOffset is \(scrollView.contentOffset.y)")
        XCTAssert(delegate.numberOfScrollStarts == 1, "numberOfScrollStarts should be 1, instead of \(delegate.numberOfScrollStarts)")
        XCTAssert(delegate.numberOfScrollStops == 1, "numberOfScrollStarts should be 1, instead of \(delegate.numberOfScrollStarts)")
    }
    
    func testTrackerFail() {
        let mockTracker = MockFaceTracker()
        let config = BarabaConfiguration(tracker: mockTracker)
        let baraba = Baraba(configuration: config)
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        
        let testExpectation = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.tracker(mockTracker, didFailWithError: MockError())
            testExpectation.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 1)
        
        if let error = delegate.error, case let BarabaError.cameraFailed(underlying) = error {
            XCTAssert(underlying is MockError, "error: \(error)")
            XCTAssert(delegate.numberOfScrollStarts == 0)
            XCTAssert(delegate.numberOfScrollStops == 0)
        } else {
            XCTFail("error should not be nil, and be BarabaError.cameraFailed. (\(String(describing: delegate.error)))")
        }
    }
    
    func testInterruptionWhileLooking() {
        let mockTracker = MockFaceTracker()
        let config = BarabaConfiguration(tracker: mockTracker)
        let baraba = Baraba(configuration: config)
        baraba.scrollView = scrollView
        baraba.preferredScrollSpeed = 240
        baraba.delegate = delegate
        
        let testExpectation = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.trackerDidStartTrackingFace(mockTracker)
            usleep(1_500_000)
            
            delegate.trackerWasInterrupted(mockTracker)
            usleep(0_500_000)
            delegate.trackerInterruptionEnded(mockTracker)
            usleep(1_000_000)
            
            delegate.trackerDidEndTrackingFace(mockTracker)
            usleep(0_500_000)
            
            testExpectation.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 5)
        XCTAssert(baraba.isActive)
        XCTAssert(scrollView.contentOffset.y > 600*0.9, "Scroll view's contentOffset is \(scrollView.contentOffset.y)")
        XCTAssert(scrollView.contentOffset.y < 600*1.1, "Scroll view's contentOffset is \(scrollView.contentOffset.y)")
        XCTAssert(delegate.numberOfScrollStarts == 2, "numberOfScrollStarts should be 2, instead of \(delegate.numberOfScrollStarts)")
        XCTAssert(delegate.numberOfScrollStops == 2, "numberOfScrollStops should be 2, instead of \(delegate.numberOfScrollStarts)")
    }
    
    func testInterruptionWhileNotLooking() {
        let mockTracker = MockFaceTracker()
        let config = BarabaConfiguration(tracker: mockTracker)
        let baraba = Baraba(configuration: config)
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        
        let testExpectation = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.trackerDidStartTrackingFace(mockTracker)
            usleep(2_000_000)
            
            delegate.trackerDidEndTrackingFace(mockTracker)
            delegate.trackerWasInterrupted(mockTracker)
            usleep(0_050_000)

            delegate.trackerInterruptionEnded(mockTracker)
            usleep(0_050_000)
            
            testExpectation.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 3)
        XCTAssert(baraba.isActive)
        XCTAssert(scrollView.contentOffset.y > 360*0.9, "Scroll view's contentOffset is \(scrollView.contentOffset.y)")
        XCTAssert(scrollView.contentOffset.y < 360*1.1, "Scroll view's contentOffset is \(scrollView.contentOffset.y)")
        XCTAssert(delegate.numberOfScrollStarts == 1, "numberOfScrollStarts should be 1, instead of \(delegate.numberOfScrollStarts)")
        XCTAssert(delegate.numberOfScrollStops == 1, "numberOfScrollStops should be 1, instead of \(delegate.numberOfScrollStarts)")
    }
    
    func testBarabaDelegateExtension() {
        let mockTracker = MockFaceTracker()
        let config = BarabaConfiguration(tracker: mockTracker)
        let baraba = Baraba(configuration: config)
        baraba.scrollView = scrollView
        
        let emptyDelegate = EmptyBarabaDelegate()
        baraba.delegate = emptyDelegate
        
        let testExpectation = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.trackerDidStartTrackingFace(mockTracker)
            usleep(0_500_000)
            
            delegate.trackerDidEndTrackingFace(mockTracker)
            usleep(0_050_000)
                
            testExpectation.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 3)
        
        baraba.pause()
        
        let testExpectation2 = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.tracker(mockTracker, didFailWithError: MockError())
            usleep(0_500_000)
                
            testExpectation2.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 1)
        
        XCTAssert(true)
    }
    
    func testResumeOnActiveBaraba() {
        let baraba = Baraba(configuration: .mock)
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        
        baraba.resume()
        
        XCTAssert(baraba.isActive == true)
        XCTAssert(delegate.error == nil)
        
        baraba.resume()
        
        XCTAssert(baraba.isActive == true)
        XCTAssert(delegate.error == nil)
    }
    
    func testRemoveScrollView() {
        let mockTracker = MockFaceTracker()
        let config = BarabaConfiguration(tracker: mockTracker)
        let baraba = Baraba(configuration: config)
        baraba.scrollView = scrollView
        baraba.delegate = delegate
        
        let testExpectation = expectation(description: "Baraba expectation")
        
        mockTracker.action = { delegate in
            delegate.trackerDidStartTrackingFace(mockTracker)
            usleep(0_500_000)
            
            baraba.scrollView = nil
            usleep(0_100_000)
            
            testExpectation.fulfill()
        }
        
        baraba.resume()
        
        waitForExpectations(timeout: 1)
        XCTAssert(baraba.isActive == false)
        XCTAssert(baraba.isScrolling == false)
    }
    
    func testPreferredScrollSpeed() {
        let baraba = Baraba(configuration: .mock)
        
        baraba.preferredScrollSpeed = 100
        XCTAssert(baraba.actualScrollSpeed == 120)
        
        baraba.preferredScrollSpeed = 150
        XCTAssert(baraba.actualScrollSpeed == 180)
        
        baraba.preferredScrollSpeed = -10
        XCTAssert(baraba.actualScrollSpeed == 60)
    }
}

struct MockError: Error {}
