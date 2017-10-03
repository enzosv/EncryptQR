//
//  QRScannerViewController.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Oct 3, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaLumberjack

class QRScannerViewController: UIViewController {

	private lazy var closeButton: UIButton = {
		let b = UIButton(type: .system)
		b.tintColor = .white
		b.setImage(UIImage(named: "cross"), for: .normal)
		return b
	}()

	private lazy var captureSession: AVCaptureSession = {
		let session = AVCaptureSession()
		return session
	}()

	private lazy var captureMetadataOutput: AVCaptureMetadataOutput = {
		let output = AVCaptureMetadataOutput()
		return output
	}()

	private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
		let layer = AVCaptureVideoPreviewLayer()
		layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
		return layer
	}()

	private lazy var qrFrameView: UIView = {
		let v = UIView()
		v.layer.borderWidth = 2
		v.layer.borderColor = UIColor.green.cgColor
		return v
	}()

	var alert: UIAlertController?
	var didScanCode: ((String) -> Void)?
	override func viewDidLoad() {
		super.viewDidLoad()

		setupScanner()
		view.addSubview(closeButton)
		view.addSubview(qrFrameView)
		closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
		closeButton.snp.remakeConstraints { (make) in
			make.right.equalToSuperview().offset(-20)
			make.top.equalToSuperview().offset(20)
			make.width.equalTo(16)
			make.height.equalTo(16)
		}

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		captureSession.startRunning()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let alert = alert {
			present(alert, animated: true, completion: nil)
		}
	}

	private func setupScanner() {
		guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
			let alert = UIAlertController(title: "Error", message: "Camera not availalbe", preferredStyle: .alert)
			alert.addAction(
				UIAlertAction(title: "Close", style: .cancel, handler: { (_) in
					alert.dismiss(animated: true, completion: nil)
					self.dismiss(animated: true, completion: nil)
				}))
			self.alert = alert
			return
		}
		do {
			let input = try AVCaptureDeviceInput(device: captureDevice)
			captureSession.addInput(input)
			captureSession.addOutput(captureMetadataOutput)

			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

			videoPreviewLayer.session = captureSession
			videoPreviewLayer.frame = view.layer.bounds
			view.layer.addSublayer(videoPreviewLayer)
		} catch {
			DDLogError("\(error)")
			return
		}
	}

	@objc private func closeAction() {
		dismiss(animated: true, completion: nil)
	}
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
	func metadataOutput(_ output: AVCaptureMetadataOutput,
	                    didOutput metadataObjects: [AVMetadataObject],
	                    from connection: AVCaptureConnection) {
		guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
			return
		}
		qrFrameView.frame = videoPreviewLayer
			.transformedMetadataObject(for: metadataObj)?.bounds ?? CGRect.zero
		guard let stringCode = metadataObj.stringValue else {
			return
		}
		captureSession.stopRunning()
		didScanCode?(stringCode)
	}
}
