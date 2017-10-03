//
//  EncryptionServiceTests.swift
//  EncryptQRTests
//
//  Created by Lorenzo Rey Vergara on Sep 29, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import XCTest
@testable import EncryptQR

class EncryptionServiceTests: XCTestCase {

	func testEncryptDecryptEncrypt() {
		let secret = UUID().uuidString
		let password = UUID().uuidString
		let service = EncryptionService()
		measure {
			service.encrypt(unencrypted: secret, with: password) { (result) in
				guard let encrypted = result else {
					fatalError("can't encrypt \(secret) with password: \(password)")
				}
				service.decrypt(encrypted: encrypted, with: password, callback: { (decryptedResult) in
					guard let decrypted = decryptedResult else {
						fatalError("can't decrypt \(encrypted) with password: \(password)")
					}
					XCTAssertEqual(decrypted, secret)
				})

			}
		}
	}
}
