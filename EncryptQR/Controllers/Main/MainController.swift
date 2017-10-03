//
//  EncryptController.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Sep 29, 2017.
//Copyright © 2017 enzosv. All rights reserved.
//

import Foundation
import CryptoSwift
import CoreImage
import NYTPhotoViewer

protocol MainViewInputs:class {
	func set(textView text: String)
	func setActions(enabled: Bool)
	func setTextViewActions(enabled: Bool)
	func present(controller: UIViewController)
	func dismissKeyboard()
	func startLoading(title: String?, message text: String?)
	func stopLoading(title: String?, message text: String?, wait seconds: Double?)

	func animatePassphraseFieldUp(curve: UIViewAnimationOptions, duration: Double, height: CGFloat)
	func animatePassphraseFieldDown(curve: UIViewAnimationOptions, duration: Double)
}

protocol MainViewEvents:class {
	func viewWillAppear()
	func viewWillDisappear()

	func share(decoded text: String)
	func preview(decoded text: String)
	func scan()
	func requestEncrypt(unencrypted text: String, with passphrase: String?)
	func decrypt(encrypted text: String, with passphrase: String?)
	func textsChanged(textView text: String, passphrase: String?)

	var willBeginEdittingPassphrase: Bool {
		get set
	}
	var willStopEdittingPasphrase: Bool {
		get set
	}
}

class MainController: NSObject {
	weak var view: MainViewInputs!
	var willBeginEdittingPassphrase = false
	var willStopEdittingPasphrase = false

	init(with view: MainViewInputs) {
		self.view = view
	}

	private func showPassphraseError() {
		let alert = UIAlertController(title: "Passphrase does not match",
		                              message: "Please try again",
		                              preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok",
		                              style: .default,
		                              handler: { (_) in
										alert.dismiss(animated: true, completion: nil)
		}))
		view.dismissKeyboard()
		view.present(controller: alert)
	}

	private func encrypt(text: String, key: String) {
		view.dismissKeyboard()
		view.startLoading(title: "Encrypting", message: nil)
		let service = EncryptionService()
		service.encrypt(unencrypted: text, with: key, callback: { [weak self] (result) in
			guard let strongSelf = self else {
				return
			}
			guard let encrypted = result else {
				strongSelf.view.stopLoading(title: "Encryption error", message: nil, wait: 1.5)
				return
			}
			strongSelf.view.stopLoading(title: nil, message: nil, wait: nil)
			strongSelf.view.set(textView: encrypted)
		})
	}

	private func obfuscate(text: String) -> String {
		var obfuscated = ""
		for _ in 0...text.count-1 {
			obfuscated += "•"
		}
		return obfuscated
	}

	@objc private func keyboardWillAppear(notification: Notification) {
		guard willBeginEdittingPassphrase else {
			return
		}
		willBeginEdittingPassphrase = false
		guard
			let info = notification.userInfo,
			let height = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?
				.cgRectValue.height,
			let duration = (info[UIKeyboardAnimationDurationUserInfoKey]) as? Double,
			let animation = (info[UIKeyboardAnimationCurveUserInfoKey]) as? UInt

			else {
				return
		}
		let curve = UIViewAnimationOptions(rawValue: animation)
		view.animatePassphraseFieldUp(curve: curve, duration: duration, height: height)
	}

	@objc private func keyboardWillDisappear(notification: Notification) {
		guard willStopEdittingPasphrase else {
			return
		}
		willStopEdittingPasphrase = false
		guard
			let info = notification.userInfo,
			let duration = (info[UIKeyboardAnimationDurationUserInfoKey]) as? Double,
			let animation = (info[UIKeyboardAnimationCurveUserInfoKey]) as? UInt
			else {
				return
		}
		let curve = UIViewAnimationOptions(rawValue: animation)
		view.animatePassphraseFieldDown(curve: curve, duration: duration)
	}
}

extension MainController: MainViewEvents {

	func viewWillAppear() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self,
		                               selector: #selector(keyboardWillAppear(notification:)),
		                               name: .UIKeyboardWillShow,
		                               object: nil)
		notificationCenter.addObserver(self,
		                               selector: #selector(keyboardWillDisappear(notification:)),
		                               name: .UIKeyboardWillHide,
		                               object: nil)
	}

	func viewWillDisappear() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		notificationCenter.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}

	func textsChanged(textView text: String, passphrase: String?) {
		view.setTextViewActions(enabled: text.count > 0)
		view.setActions(enabled: text.count > 0
			&& (passphrase?.count ?? 0)
			>= Constants.MINIMUMPASSWORDLENGTH)

	}

	func share(decoded text: String) {
		let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
		view.dismissKeyboard()
		view.present(controller: controller)
	}

	func preview(decoded text: String) {
		view.dismissKeyboard()
		guard
			let qr = QRService().createQR(from: text, size: UIScreen.main.bounds.width*UIScreen.main.scale)
			else {
				return
		}
		let controller = NYTPhotosViewController(photos: [Photo(image: qr)])
		view.present(controller: controller)
	}

	func scan() {
		view.dismissKeyboard()
		let scanner = QRScannerViewController()
		scanner.modalPresentationStyle = .formSheet
		scanner.didScanCode = { [weak self] (code) in
			guard let strongSelf = self else {
				return
			}
			strongSelf.view.set(textView: code)
			DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
				scanner.dismiss(animated: true, completion: nil)
			})
		}
		view.present(controller: scanner)
	}

	func decrypt(encrypted text: String, with passphrase: String?) {
		view.dismissKeyboard()
		guard text.count > 0,
			let key = passphrase,
			key.count >= Constants.MINIMUMPASSWORDLENGTH else {
				return
		}
		view.startLoading(title: "Decrypting", message: nil)
		EncryptionService()
			.decrypt(encrypted: text, with: key) { [weak self] (result) in
				guard let strongSelf = self else {
					return
				}
				guard let decrypted = result else {
					strongSelf.view
						.stopLoading(title: "Decryption error",
						             message: "Please double check your password and try again",
						             wait: 1.5)
					return
				}
				strongSelf.view.stopLoading(title: nil, message: nil, wait: nil)
				strongSelf.view.set(textView: decrypted)
		}
	}

	func requestEncrypt(unencrypted text: String, with passphrase: String?) {
		view.dismissKeyboard()
		guard
			text.count > 0,
			let key = passphrase,
			key.count >= Constants.MINIMUMPASSWORDLENGTH
			else {
				return
		}
		let alert = UIAlertController(title: "Confirm passphrase", message: nil, preferredStyle: .alert)
		var textField: UITextField!

		alert.addTextField { [weak self] (field) in
			guard let strongSelf = self else {
				return
			}
			field.placeholder = strongSelf.obfuscate(text: key)
			field.isSecureTextEntry = true
			field.clearsOnInsertion = false
			field.clearsOnBeginEditing = false
			field.clearButtonMode = .always
			field.returnKeyType = .done
			textField = field
		}
		let encryptCallback: ((UIAlertAction) -> Void)? = { [weak self] (_) in
			guard let strongSelf = self else {
				return
			}
			alert.dismiss(animated: true, completion: nil)
			guard textField.text == key else {
				strongSelf.showPassphraseError()
				return
			}
			strongSelf.encrypt(text: text, key: key)
		}
		alert.addAction(UIAlertAction(title: "Encrypt", style: .default, handler: encryptCallback))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
			alert.dismiss(animated: true, completion: nil)
		}))
		view.present(controller: alert)
	}
}
