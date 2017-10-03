//
//  QRService.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Oct 3, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import CoreImage
import CocoaLumberjack

class QRService: NSObject {

	func createQR(from string: String, size: CGFloat) -> UIImage? {
		let stringData = string.data(using: String.Encoding.utf8)
		guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
			DDLogWarn("Unable to create filter")
			return nil
		}
		filter.setValue(stringData, forKey: "inputMessage")
		filter.setValue("H", forKey: "inputCorrectionLevel")
		guard let img = filter.outputImage else {
			DDLogWarn("No filter.outputImage")
			return nil
		}
		let scale = size/100
		let transform = CGAffineTransform(scaleX: scale, y: scale)
		let scaledImage = UIImage(ciImage: img.transformed(by: transform))

		UIGraphicsBeginImageContext(scaledImage.size)
		scaledImage.draw(in: CGRect(origin: CGPoint.zero, size: scaledImage.size))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage
	}
}
