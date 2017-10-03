//
//  EncryptionService.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Sep 30, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import CryptoSwift
import CocoaLumberjack
import CoreImage

class EncryptionService: NSObject {
	private func generateCipher(with key: String) -> Cipher? {
		guard key.count >= Constants.MINIMUMPASSWORDLENGTH else {
			return nil
		}
		let pass = Array(key.utf8)
		let salt = Array(pass.toHexString().utf8)

		guard
			let password = try? PKCS5
				.PBKDF2(password: pass, salt: salt, iterations: 4096, variant: .sha256)
				.calculate()
			else {
				DDLogWarn("Unable to encrypt password")
				return nil
		}
		return try? AES(key: password, iv: nil)
	}

	func encrypt(unencrypted text: String,
	             with key: String,
	             callback: ((String?) -> Void)?) {
		DispatchQueue.global(qos: .background).async {
			guard let cipher = self.generateCipher(with: key) else {
				DDLogWarn("Unable to create cipher for encryption")
				DispatchQueue.main.async {
					callback?(nil)
				}
				return
			}
			guard let encrypted = try? text.encryptToBase64(cipher: cipher) else {
				DDLogWarn("Unable to Encrypt secret")
				DispatchQueue.main.async {
					callback?(nil)
				}
				return
			}
			DispatchQueue.main.async {
				callback?(encrypted)
			}
		}

	}

	func decrypt(encrypted text: String,
	             with key: String,
	             callback: ((String?) -> Void)?) {
		DispatchQueue.global(qos: .background).async {
			guard let cipher = self.generateCipher(with: key) else {
				DDLogWarn("Unable to create cipher for decryption")
				DispatchQueue.main.async {
					callback?(nil)
				}
				return
			}
			DispatchQueue.main.async {
				callback?(try? text.decryptBase64ToString(cipher: cipher))
			}
		}

	}

}
