//
//  TimeFrames.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/20/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation

/// Enum that controls which string user sees in PostViewController's tableview for time since post was made.
enum TimeFrames {
	case seconds(time:Int, unit : String = "seconds")
	case minutes(time:Int, unit : String = "minutes")
	case hours(time:Int, unit : String = "hours")
	case days(time:Int, unit : String = "days")
}

extension TimeFrames {
	
	var message:String {
		
		switch self {
		case .seconds(time: let time, unit: let unit):
			return "Posted: \(time) \(unit) ago."
		case.minutes(time: var time, unit: let unit):
			time = time / 60
			return "Posted: \(time) \(unit) ago."
		case .hours(time: var time, unit: let unit):
			time = time / (60*60)
			return "Posted: \(time) \(unit) ago."
		case .days(time: var time, unit: let unit):
			time = time / (60*60*24)
			return "Posted: \(time) \(unit) ago."
		}
	}
}
