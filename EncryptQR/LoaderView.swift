//
//  LoaderView.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Oct 2, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import UIKit

class LoaderView: UIView {
	private lazy var containerView: UIView = {
		let v = UIView()
		v.backgroundColor = .white
		v.layer.cornerRadius = 5
		v.layer.borderWidth = 1
		v.layer.borderColor = UIColor.lightGray.cgColor
		return v
	}()

	private lazy var spinner: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		indicator.hidesWhenStopped = true
		return indicator
	}()

	private lazy var textLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()

	private lazy var subTextLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = .black
		label.font = UIFont.systemFont(ofSize: 12)
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()

	init() {
		super.init(frame: CGRect.zero)
		setup()
		updateLayout()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
		updateLayout()
	}

	private func setup() {
		isHidden = true
		backgroundColor = UIColor(white: 0, alpha: 0.75)
		addSubview(containerView)
		containerView.addSubview(spinner)
		containerView.addSubview(textLabel)
		containerView.addSubview(subTextLabel)
	}

	private func updateLayout() {
		containerView.snp.remakeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.6)
			make.center.equalToSuperview()
		}

		textLabel.snp.remakeConstraints { (make) in
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.top.equalToSuperview().offset(20)
			make.height.equalTo(21)
		}

		spinner.snp.remakeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-20).priority(2)
			make.top.equalTo(textLabel.snp.bottom).offset(20)
		}

		subTextLabel.snp.remakeConstraints { (make) in
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.top.equalTo(textLabel.snp.bottom).offset(8)
			make.bottom.equalToSuperview().offset(-20).priority(1)
		}
	}
}

extension LoaderView {
	func startLoading(title: String?, message text: String?) {
		spinner.startAnimating()
		textLabel.text = title
		subTextLabel.text = text
		isHidden = false
	}

	func stopLoading(title: String?, message text: String?, wait seconds: Double?) {
		spinner.stopAnimating()
		textLabel.text = title
		subTextLabel.text = text
		guard let wait = seconds else {
			isHidden = true
			return
		}
		let deadline = DispatchTime.now() + wait
		DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
			self?.isHidden = true
		}
	}
}
