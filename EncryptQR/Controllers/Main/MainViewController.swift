//
//  EncryptViewController.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Sep 29, 2017.
//Copyright © 2017 enzosv. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import SnapKit

class MainViewController: UIViewController {
	private lazy var eventHandler: MainViewEvents = {
		return MainController(with: self)
	}()

	private lazy var textContainer: UIView = {
		let v = UIView()
		v.backgroundColor = .white
		v.layer.cornerRadius = 5
		v.clipsToBounds = true
		return v
	}()

	private lazy var textView: UITextView = {
		let tv = UITextView()
		tv.isScrollEnabled = true
		return tv
	}()

	private lazy var shareButton: UIButton = {
		let b = UIButton(type: .system)
		b.isEnabled = false
		b.setTitle("Share", for: .normal)
		return b
	}()

	private lazy var clearButton: UIButton = {
		let b = UIButton(type: .system)
		b.isEnabled = false
		b.setTitle("Clear", for: .normal)
		return b
	}()

	private lazy var previewButton: UIButton = {
		let b = UIButton(type: .system)
		b.isEnabled = false
		b.setTitle("Preview", for: .normal)
		return b
	}()

	private lazy var scanButton: UIButton = {
		let b = UIButton(type: .system)
		b.setTitle("Scan QR", for: .normal)
		return b
	}()

	private lazy var passphraseField: JVFloatLabeledTextField = {
		let f = JVFloatLabeledTextField()
		f.setPlaceholder("Passphrase", floatingTitle: "Passphrase")
		f.isSecureTextEntry = true
		f.clearsOnInsertion = false
		f.clearsOnBeginEditing = false
		f.clearButtonMode = .always
		f.returnKeyType = .done
		f.backgroundColor = .white
		f.layer.cornerRadius = 5
		f.leftViewMode = .always
		f.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
		return f
	}()

	private lazy var encryptButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Encrypt", for: .normal)
		button.isEnabled = false
		return button
	}()

	private lazy var decryptButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Decrypt", for: .normal)
		button.isEnabled = false
		return button
	}()

	private lazy var loaderView: LoaderView = {
		let v = LoaderView()
		return v
	}()

	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
		updateLayout()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		eventHandler.viewWillAppear()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		eventHandler.viewWillDisappear()
	}

	private func setup() {
		view.backgroundColor = UIColor(red: 0.8922713054093233, green: 0.9016098268101015, blue: 0.9171435111009384, alpha: 1)
		textContainer.addSubview(scanButton)
		textContainer.addSubview(shareButton)
		textContainer.addSubview(clearButton)
		textContainer.addSubview(previewButton)
		textContainer.addSubview(textView)
		view.addSubview(textContainer)
		view.addSubview(passphraseField)
		view.addSubview(encryptButton)
		view.addSubview(decryptButton)
		view.addSubview(loaderView)

		setupTextViewToolbar()
		setupPassphraseFieldToolbar()
		textView.delegate = self
		passphraseField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
		passphraseField.delegate = self
		scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
		encryptButton.addTarget(self, action: #selector(encryptAction), for: .touchUpInside)
		decryptButton.addTarget(self, action: #selector(decryptAction), for: .touchUpInside)
		shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
		clearButton.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
		previewButton.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
	}

	func setupTextViewToolbar() {
		let share = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareAction))
		let clear = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearAction))
		let preview = UIBarButtonItem(title: "Preview", style: .plain, target: self, action: #selector(previewAction))
		let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
		let toolbar = UIToolbar()
		toolbar.sizeToFit()
		let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		toolbar.items = [share, clear, preview, space, done]
		textView.inputAccessoryView = toolbar
	}

	func setupPassphraseFieldToolbar() {
		let decrypt = UIBarButtonItem(title: "Decrypt", style: .plain, target: self, action: #selector(decryptAction))
		let encrypt = UIBarButtonItem(title: "Encrypt", style: .plain, target: self, action: #selector(encryptAction))
		let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
		let toolbar = UIToolbar()
		toolbar.sizeToFit()
		toolbar.items = [decrypt, encrypt, space, done]
		passphraseField.inputAccessoryView = toolbar
	}

	private func updateLayout() {
		layoutTextContainer()
		passphraseField.snp.remakeConstraints { (make) in
			make.left.equalTo(textContainer)
			make.top.equalTo(textContainer.snp.bottom).offset(20)
			make.right.equalTo(textContainer)
			make.height.equalTo(44)
			make.bottom.equalTo(encryptButton.snp.top).offset(-20)
		}

		encryptButton.snp.remakeConstraints { (make) in
			make.right.equalToSuperview()
			make.width.equalTo(view.bounds.width*0.5)
			make.bottom.equalToSuperview()
			make.height.equalTo(44)
		}

		decryptButton.snp.remakeConstraints { (make) in
			make.top.equalTo(encryptButton)
			make.left.equalToSuperview()
			make.width.equalTo(view.bounds.width*0.5)
			make.bottom.equalToSuperview()
			make.height.equalTo(44)
		}

		loaderView.snp.remakeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}

	}

	private func layoutTextContainer() {
		textContainer.snp.remakeConstraints { (make) in
			make.left.equalToSuperview().offset(20)
			make.topMargin.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
		}

		textView.snp.remakeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}

		shareButton.snp.remakeConstraints { (make) in
			make.top.equalTo(textView.snp.bottom)
			make.left.equalToSuperview()
			make.width.equalTo(textContainer.snp.width).dividedBy(3)
			make.height.equalTo(32)
		}

		clearButton.snp.remakeConstraints { (make) in
			make.top.equalTo(shareButton)
			make.left.equalTo(shareButton.snp.right)
			make.width.equalTo(textContainer.snp.width).dividedBy(3)
			make.height.equalTo(32)
		}

		previewButton.snp.remakeConstraints { (make) in
			make.top.equalTo(shareButton)
			make.right.equalToSuperview()
			make.width.equalTo(textContainer.snp.width).dividedBy(3)
			make.height.equalTo(32)
		}

		scanButton.snp.remakeConstraints { (make) in
			make.top.equalTo(shareButton.snp.bottom)
			make.left.equalToSuperview()
			make.bottom.equalToSuperview()
			make.width.equalTo(textContainer.snp.width)
			make.height.equalTo(44)
		}
	}

	@objc private func scanAction() {
		eventHandler.scan()
	}

	@objc private func encryptAction() {
		eventHandler.requestEncrypt(unencrypted: textView.text, with: passphraseField.text)
	}

	@objc private func decryptAction() {
		eventHandler.decrypt(encrypted: textView.text, with: passphraseField.text)
	}

	@objc private func shareAction() {
		eventHandler.share(decoded: textView.text)
	}

	@objc private func clearAction() {
		textView.text = ""
		eventHandler.textsChanged(textView: "", passphrase: passphraseField.text)
	}

	@objc private func previewAction() {
		eventHandler.preview(decoded: textView.text)
	}

}

extension MainViewController: MainViewInputs {
	func animatePassphraseFieldUp(curve: UIViewAnimationOptions, duration: Double, height: CGFloat) {
		let offset = -(height+(passphraseField.inputView?.bounds.height ?? 0))
		passphraseField.snp.remakeConstraints({ (make) in
			make.left.equalTo(textContainer)
			make.top.equalTo(textContainer.snp.bottom).offset(20)
			make.right.equalTo(textContainer)
			make.height.equalTo(44)
			make.bottom.equalToSuperview().offset(offset)
		})
		UIView.animate(withDuration: duration, delay: 0, options:curve, animations: {
			self.passphraseField.superview?.layoutIfNeeded()
		}, completion: nil)
	}

	func animatePassphraseFieldDown(curve: UIViewAnimationOptions, duration: Double) {
		passphraseField.snp.remakeConstraints({ (make) in
			make.left.equalTo(textContainer)
			make.top.equalTo(textContainer.snp.bottom).offset(20)
			make.right.equalTo(textContainer)
			make.height.equalTo(44)
			make.bottom.equalTo(encryptButton.snp.top).offset(-20)
		})
		UIView.animate(withDuration: duration, delay: 0, options:curve, animations: {
			self.passphraseField.superview?.layoutIfNeeded()
		}, completion: nil)
	}

	func setActions(enabled: Bool) {
		if passphraseField.isFirstResponder,
			let toolbar = passphraseField.inputAccessoryView as? UIToolbar,
			let items = toolbar.items {
			for item in items {
				guard item.style == .plain else {
					continue
				}
				item.isEnabled = enabled
			}
		}
		encryptButton.isEnabled = enabled
		decryptButton.isEnabled = enabled
	}

	func setTextViewActions(enabled: Bool) {
		if textView.isFirstResponder,
			let toolbar = textView.inputAccessoryView as? UIToolbar,
			let items = toolbar.items {
			for item in items {
				guard item.style == .plain else {
					continue
				}
				item.isEnabled = enabled
			}
		}
		shareButton.isEnabled = enabled
		clearButton.isEnabled = enabled
		previewButton.isEnabled = enabled
	}

	func startLoading(title: String?, message text: String?) {
		loaderView.startLoading(title: title, message: text)
	}

	func stopLoading(title: String?, message text: String?, wait seconds: Double?) {
		loaderView.stopLoading(title: title, message: text, wait: seconds)
	}

	func set(textView text: String) {
		textView.text = text
		eventHandler.textsChanged(textView: text, passphrase: passphraseField.text)
	}

	func present(controller: UIViewController) {
		present(controller, animated: true, completion: nil)
	}

	@objc func dismissKeyboard() {
		if textView.isFirstResponder {
			textView.resignFirstResponder()
		} else if passphraseField.isFirstResponder {
			eventHandler.willStopEdittingPasphrase = true
			passphraseField.resignFirstResponder()
		}
	}
}

extension MainViewController: UITextFieldDelegate {

	func textFieldDidBeginEditing(_ textField: UITextField) {
		eventHandler.textsChanged(textView: textView.text, passphrase: passphraseField.text)
	}

	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		eventHandler.willBeginEdittingPassphrase = true
		return true
	}

	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		eventHandler.willStopEdittingPasphrase = true
		return true
	}

	@objc func textFieldEditingChanged(_ textField: UITextField) {
		eventHandler.textsChanged(textView: textView.text, passphrase: passphraseField.text)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		eventHandler.willStopEdittingPasphrase = true
		textField.resignFirstResponder()
		return true
	}
}

extension MainViewController: UITextViewDelegate {

	func textViewDidBeginEditing(_ textView: UITextView) {
		eventHandler.textsChanged(textView: textView.text, passphrase: passphraseField.text)
	}

	func textViewDidChange(_ textView: UITextView) {
		eventHandler.textsChanged(textView: textView.text, passphrase: passphraseField.text)
	}

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		dismissKeyboard()
	}
}
