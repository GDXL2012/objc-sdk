//
//  LCIMTestCaseClient.swift
//  AVOS
//
//  Created by zapcannon87 on 19/12/2017.
//  Copyright © 2017 LeanCloud Inc. All rights reserved.
//

import XCTest

class LCIMTestCaseClient: LCIMTestBase {
    
    var globalClient: AVIMClient?
    
    override func setUp() {
        
        super.setUp()
        
        var client: AVIMClient? = AVIMClient(clientId: "LCIMTestCaseClient.globalClient")
        
        if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
            
            client!.open(callback: { (success, error) in
                
                XCTAssertTrue(success)
                XCTAssertNil(error)
                XCTAssertEqual(client!.status, .opened)
                
                semaphore.breakWaiting = true
            })
            
        }) {
            
            XCTFail("timeout")
            
            client = nil
        }
        
        self.globalClient = client
    }
    
    override func tearDown() {
        
        super.tearDown()
        
        if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
            
            self.globalClient?.close(callback: { (success, error) in
                
                XCTAssertTrue(success)
                XCTAssertNil(error)
                XCTAssertEqual(self.globalClient?.status, .closed)
                
                semaphore.breakWaiting = true
            })
            
        }) {
            
            XCTFail("timeout")
        }
    }
    
    func testClientOpenCloseMultiple() {
        
        let openCloseClient: AVIMClient = AVIMClient(clientId: "LCIMTestCaseClient.testClientOpenCloseMultiple")
        
        for _ in 0..<5 {
            
            if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
                
                openCloseClient.open(callback: { (success, error) in
                    
                    XCTAssertTrue(success)
                    XCTAssertNil(error)
                    XCTAssertEqual(openCloseClient.status, .opened)
                    
                    semaphore.breakWaiting = true
                })
                
            }) {
                
                XCTFail("timeout")
            }
            
            if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
                
                openCloseClient.close(callback: { (success, error) in
                    
                    XCTAssertTrue(success)
                    XCTAssertNil(error)
                    XCTAssertEqual(openCloseClient.status, .closed)
                    
                    semaphore.breakWaiting = true
                })
                
            }) {
                
                XCTFail("timeout")
            }
        }
    }
    
    func testCreateConversation() {
        
        guard let client: AVIMClient = self.globalClient else {
            
            XCTFail()
            
            return
        }
        
        if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
            
            client.createConversation(
                withName: "LCIMTestCaseClient.testCreateConversation",
                clientIds: []
            ) { (conv, error) in
                
                semaphore.breakWaiting = true
                
                guard let conv: AVIMConversation = conv else  {
                    
                    XCTFail("\(error!)")
                    
                    return
                }
                
                XCTAssertNil(error)
                
                XCTAssertNotNil(conv.conversationId)
                XCTAssertNotNil(conv.createAt)
                
                XCTAssertFalse(conv.transient)
                XCTAssertFalse(conv.system)
                XCTAssertFalse(conv.temporary)
            }
            
        }) {
            
            XCTFail("timeout")
        }
    }
    
    func testCreateChatRoom() {
        
        guard let client: AVIMClient = self.globalClient else {
            
            XCTFail()
            
            return
        }
        
        if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
            
            client.createChatRoom(
                withName: "LCIMTestCaseClient.testCreateChatRoom",
                attributes: ["test" : "test"]
            ) { (chatRoom, error) in
                
                semaphore.breakWaiting = true
                
                guard let chatRoom: AVIMChatRoom = chatRoom else {
                    
                    XCTFail("\(error!)")
                    
                    return
                }
                
                XCTAssertNil(error)
                
                XCTAssertNotNil(chatRoom.conversationId)
                XCTAssertNotNil(chatRoom.createAt)
                
                XCTAssertTrue(chatRoom.transient)
                XCTAssertFalse(chatRoom.system)
                XCTAssertFalse(chatRoom.temporary)
            }
            
        }) {
            
            XCTFail("timeout")
        }
    }
    
    func testCreateTemporaryConversation() {
        
        guard let client: AVIMClient = self.globalClient else {
            
            XCTFail()
            
            return
        }
        
        if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
            
            client.createTemporaryConversation(
                withClientIds: [],
                timeToLive: 0
            ) { (tempConv, error) in
                
                semaphore.breakWaiting = true
                
                guard let tempConv: AVIMTemporaryConversation = tempConv else {
                    
                    XCTFail("\(error!)")
                    
                    return
                }
                
                XCTAssertNil(error)
                
                let convId: String? = tempConv.conversationId
                
                XCTAssertNotNil(convId)
                XCTAssertTrue(convId!.hasPrefix(kTempConvIdPrefix))
                XCTAssertNotNil(tempConv.createAt)
                
                XCTAssertFalse(tempConv.transient)
                XCTAssertFalse(tempConv.system)
                XCTAssertTrue(tempConv.temporary)
            }
            
        }) {
            
            XCTFail("timeout")
        }
    }
    
    func testCreateUniqueConversation() {
        
        guard let client: AVIMClient = self.globalClient else {
            
            XCTFail()
            
            return
        }
        
        var uniqueId: String? = nil
        
        for i in 0..<2 {
            
            if self.runloopTestAsync(closure: { (semaphore) -> (Void) in
                
                client.createConversation(
                    withName: "LCIMTestCaseClient.testCreateUniqueConversation",
                    clientIds: ["testCreateUniqueConversation.otherId.1"],
                    attributes: nil,
                    options: [.unique]
                ) { (conv, error) in
                    
                    semaphore.breakWaiting = true
                    
                    guard let conv: AVIMConversation = conv else  {
                        
                        XCTFail("\(error!)")
                        
                        return
                    }
                    
                    XCTAssertNil(error)
                    
                    XCTAssertNotNil(conv.conversationId)
                    
                    if i == 0 {
                        
                        uniqueId = conv.conversationId
                    }
                    
                    if i == 1 {
                        
                        XCTAssertTrue(uniqueId == conv.conversationId)
                    }
                    
                    XCTAssertNotNil(conv.createAt)
                    
                    XCTAssertFalse(conv.transient)
                    XCTAssertFalse(conv.system)
                    XCTAssertFalse(conv.temporary)
                }
                
            }) {
                
                XCTFail("timeout")
            }
        }
    }
    
}
