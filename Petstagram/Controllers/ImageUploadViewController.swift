//
//  ImageUploadViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

class ImageUploadViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		selectImageWithPicker()
	}
	
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 35)!]
		self.navigationController?.navigationBar.tintColor = .label
	}
	
}

extension ImageUploadViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	func selectImageWithPicker(){
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self

		if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			imagePickerController.sourceType = .photoLibrary
			
			present(imagePickerController, animated: true)
		}

	}


}

