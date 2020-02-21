//
//  CollectionViewBuilder.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/15/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class CollectionViewBuilder {
	
	private var cellFractionalHeight : CGFloat
	private var cellFractionalWidth : CGFloat
	private var groupFractionalHeight : CGFloat
	private var groupFractionalWidth : CGFloat
	private var evenInsets : CGFloat
	private var columns : Int
	
	init(cellFractionalHeight:CGFloat,cellFractionalWidth:CGFloat,  groupFractionalHeight:CGFloat, groupFractionalWidth:CGFloat,  columns:Int, evenInsets : CGFloat) {
		
		self.cellFractionalWidth = cellFractionalWidth
		self.cellFractionalHeight = cellFractionalHeight
		self.groupFractionalWidth = groupFractionalWidth
		self.groupFractionalHeight = groupFractionalHeight
		self.evenInsets = evenInsets
		self.columns = columns
	}
	
	/// Returns a UICollectionViewLayout that will display user images.
	func setLayout() -> UICollectionViewLayout {
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(cellFractionalWidth), heightDimension: .fractionalHeight(cellFractionalHeight))
		let cell = NSCollectionLayoutItem(layoutSize: itemSize)
		cell.contentInsets = NSDirectionalEdgeInsets(top: evenInsets, leading: evenInsets, bottom: evenInsets, trailing: evenInsets)
		
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth), heightDimension: .fractionalHeight(groupFractionalHeight))
		let cellGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: cell, count: columns)
		
		let section = NSCollectionLayoutSection(group: cellGroup)
		
		let layout = UICollectionViewCompositionalLayout(section: section)
		
		return layout
	}
}
