//
//  Utilities.swift
//  LiverpoolTest
//
//  Created by Emmanuel Casañas Cruz on 12/2/17.
//  Copyright © 2017 Emmanuel Cruz. All rights reserved.
//

import Foundation

class Utilities: NSObject {
	
	
	class func saveHistory(array:NSMutableArray){
		let userDefaults = UserDefaults.standard
		userDefaults.set(array, forKey:"history")
		userDefaults.synchronize()
	}
	
	class func gethistory() -> NSMutableArray {
		let userDefaults = UserDefaults.standard
		if let array = userDefaults.object(forKey: "history") as! NSMutableArray! {
			return array
		} else {
			return NSMutableArray()
		}
	}
	

}