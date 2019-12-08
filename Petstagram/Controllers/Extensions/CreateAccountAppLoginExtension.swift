//
//  CreateAccountAppLoginExtension.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

extension AppLogin : UIGestureRecognizerDelegate {
	

	
	func createViewForAccountCreation(){
		
		
		let dragGesture : UIPanGestureRecognizer = {
			let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(panGesture:)))
			pan.delegate = self
			return pan
		}()
		
		view.addSubview(accountCreationUIView)
		
		NSLayoutConstraint.activate([
			accountCreationUIView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			accountCreationUIView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 812),
			accountCreationUIView.heightAnchor.constraint(equalToConstant: loginArea.frame.height),
			accountCreationUIView.widthAnchor.constraint(equalToConstant: loginArea.frame.width)
		])
		
		/*
		print(view.frame.height)
		print(loginArea.frame.height)
		print(loginArea.center)
		print(view.center)
		print("viewCenter - loginCenter = \(view.center.y - loginArea.center.y)")
		print("viewFrame - loginFrame = \(view.frame.height - loginArea.frame.height)")
		*/
		
		UIView.animate(withDuration: 0.8) {
			self.accountCreationUIView.transform = CGAffineTransform(translationX: 0, y: -750)
		}
		
		accountCreationUIView.addGestureRecognizer(dragGesture)
		
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		
		return true
	}
	
	@objc func handleGesture(panGesture : UIPanGestureRecognizer){
		
		let translation = panGesture.translation(in: self.view)
		guard let viewToDrag = panGesture.view else {return}
//		guard let originalCenter = panGesture.view?.center.y else {fatalError()}
		let originalCenter :CGFloat = 1210
		
		if panGesture.state == .changed {
			
			viewToDrag.center = CGPoint(x: viewToDrag.center.x, y: viewToDrag.center.y + translation.y)
			
			if viewToDrag.center.y > originalCenter {
				panGesture.setTranslation(CGPoint(x: 0, y: 0), in: viewToDrag)
			}else{
				viewToDrag.center.y = originalCenter
			}
			
		}
		
		if panGesture.state == .ended {
			if viewToDrag.center.y > 1250 {
				UIView.animate(withDuration: 0.5, animations: {
					self.accountCreationUIView.transform = .identity
				}) { _ in
					self.accountCreationUIView.removeFromSuperview()
				}
			}
		}
	}
	
	
}
