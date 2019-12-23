//
//  UserProfileViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	let coreDataModel = AuthenticationItems(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
	

    override func viewDidLoad() {
        super.viewDidLoad()
		setNavigationBar()
    }
    
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 35)!]
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.stack.3d.up"), style: .plain, target: self, action: #selector(temporaryMethodForLoggingOut))
		self.navigationController?.navigationBar.tintColor = .label
	}
	
	@objc func temporaryMethodForLoggingOut(){
		
		coreDataModel.coreDataEmail = nil
		coreDataModel.coreDataPassword = nil
		coreDataModel.coreDataCredential = nil
		coreDataModel.coreDataUserName = nil
		
		appDelegate.saveContext()
		
		performSegue(withIdentifier: Keys.Segues.signOut, sender: nil)
	}
}
