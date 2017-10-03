//
//  Photo.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Sep 30, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import NYTPhotoViewer

class Photo: NSObject, NYTPhoto {

	var placeholderImage: UIImage?
	var attributedCaptionTitle: NSAttributedString?
	var attributedCaptionSummary: NSAttributedString?
	var attributedCaptionCredit: NSAttributedString?

	var image: UIImage?
	var imageData: Data?
	init(image: UIImage) {
		self.image = image
		self.imageData = UIImagePNGRepresentation(image)
	}
}
