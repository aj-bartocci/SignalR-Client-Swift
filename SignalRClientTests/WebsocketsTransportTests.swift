//
//  WebsocketsTransportTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 2/23/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class TestTransportDelegate: TransportDelegate {
    var transportDidOpenHandler: (() -> Void)?
    var transportDidReceiveDataHandler: ((_ data: Data) -> Void)?
    var transportDidCloseHandler: ((_ error: Error?) -> Void)?

    func transportDidOpen() -> Void {
        transportDidOpenHandler?()
    }

    func transportDidReceiveData(_ data: Data) -> Void {
        transportDidReceiveDataHandler?(data)
    }

    func transportDidClose(_ error: Error?) -> Void {
        transportDidCloseHandler?(error)
    }
}

class WebsocketsTransportTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatWebsocketsTransportCanSendAndReceiveMessage() {
        let didOpenExpectation = expectation(description: "transport opened")
        let didReceiveDataExpectation = expectation(description: "transport received data")
        let didCloseExpectation = expectation(description: "transport closed")

        let wsTransport = WebsocketsTransport()
        let transportDelegate = TestTransportDelegate()
        let message = "Hello, World!"

        transportDelegate.transportDidOpenHandler = {
            do {
                try wsTransport.send(data: message.data(using: .utf8)!)
                didOpenExpectation.fulfill()
            }
            catch {
                print(error)
            }
        }

        transportDelegate.transportDidReceiveDataHandler = { data in
            wsTransport.close()
            XCTAssertEqual(message, String(data: data, encoding: .utf8))
            didReceiveDataExpectation.fulfill()
        }

        transportDelegate.transportDidCloseHandler = { error in
            didCloseExpectation.fulfill()
        }

        wsTransport.delegate = transportDelegate
        wsTransport.start(url: URL(string:"http://localhost:5000/echo")!, query: "")
        
        waitForExpectations(timeout: 5 /*seconds*/)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
