//
//  CustomLogFormatter.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Sep 28, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import CocoaLumberjack

class CustomLogFormatter: NSObject, DDLogFormatter {

	lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEE, MMM d yyyy h:mma"
		return formatter
	}()

	override init() {
		super.init()
		#if DEBUG
			DDLog.add(DDTTYLogger.sharedInstance)
		#endif
	}

	func format(message logMessage: DDLogMessage) -> String? {
		var level: String
		switch logMessage.level {
		case .debug:
			level = "🔎"
		case .warning:
			level = "⚠️"
		case .error:
			level = "❗️"
		case .info:
			level = "ℹ️"
		case .verbose:
			level = "🗣"
		case .all:
			level = "All"
		case .off:
			level = "Off"
		}
		let date = dateFormatter.string(from: logMessage.timestamp)
		let meta = "\(logMessage.fileName): \(logMessage.line): \(logMessage.function ?? "No Function")"
		return "\n\(level)\(date) [\(meta)]):\n\(logMessage.message)"
	}
}
