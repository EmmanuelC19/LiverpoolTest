//
//  SearchCollectionViewController.swift
//  LiverpoolTest
//
//  Created by Emmanuel Casañas Cruz on 12/1/17.
//  Copyright © 2017 Emmanuel Cruz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "prductCell"

class SearchCollectionViewController: UICollectionViewController, UITextFieldDelegate {
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 5
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionViewCell
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		switch kind {
		case UICollectionElementKindSectionHeader:
			let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "searchHeader", for: indexPath)
			let searchField = reusableview.viewWithTag(-1) as! UITextField
			searchField.delegate = self
			
			return reusableview
			
		default:  fatalError("Unexpected element kind")
		}
	}
	
	//Mark TextField Delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchFor(product: textField.text!)
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		print (textField.text!)
		return true
	}
	
	//WebServices
	func searchFor(product:String) {
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
		
		guard var URL = URL(string: "https://www.liverpool.com.mx/tienda/") else {return}
		let URLParams = [
			"s": product,
			"d3106047a194921c01969dfdec083925": "json",
			]
		URL = URL.appendingQueryParameters(URLParams)
		var request = URLRequest(url: URL)
		request.httpMethod = "POST"
		
		// Headers
		
		request.addValue("JSESSIONID=2ZIVnUWoWMdXfHridD2hq7QoTGxbHlb_kncMbcLYMdlNc_gADfW5!1005778925; ORA_OTD_JROUTE=pSbv+Yj7bLA5Yrft", forHTTPHeaderField: "Cookie")
		
		/* Start a new Task */
		let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
			if (error == nil) {
				// Success
				let statusCode = (response as! HTTPURLResponse).statusCode
				print("URL Session Task Succeeded: HTTP \(statusCode)")
			}
			else {
				// Failure
				print("URL Session Task Failed: %@", error!.localizedDescription);
			}
		})
		task.resume()
		session.finishTasksAndInvalidate()
	}
}


protocol URLQueryParameterStringConvertible {
	var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
	var queryParameters: String {
		var parts: [String] = []
		for (key, value) in self {
			let part = String(format: "%@=%@",
							  String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
							  String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
			parts.append(part as String)
		}
		return parts.joined(separator: "&")
	}
	
}

extension URL {
	func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
		let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
		return URL(string: URLString)!
	}

	
	
	
}
