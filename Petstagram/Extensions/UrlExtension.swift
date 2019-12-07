//
//  UrlExtension.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/5/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import Foundation

extension URL {
	func query(queryItems : [String:String])->URL{
		var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
		components?.queryItems = queryItems.map({
			URLQueryItem(name: $0.0, value: $0.1)
		})
		guard let url = components?.url else {fatalError("Invalid URL Queries")}
		return url
	}
}
