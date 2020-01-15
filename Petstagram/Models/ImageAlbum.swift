//
//  ImageAlbum.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/14/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

struct ImageAlbum : Hashable, Identifiable {
	var images : UIImage = UIImage()
	var id = UUID().uuidString
	
	func hash(into hasher :inout Hasher){
		hasher.combine(id)
	}
}
