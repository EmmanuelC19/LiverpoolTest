//
//  SearchCollectionViewController.swift
//  LiverpoolTest
//
//  Created by Emmanuel Casañas Cruz on 12/1/17.
//  Copyright © 2017 Emmanuel Cruz. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
import DZNEmptyDataSet

private let reuseIdentifier = "prductCell"

class SearchCollectionViewController: UICollectionViewController, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	
	var arrayOfProducts: NSMutableArray?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		arrayOfProducts = NSMutableArray()
		self.collectionView?.emptyDataSetSource = self
		self.collectionView?.emptyDataSetDelegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (arrayOfProducts?.count)!
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let selectedProduct = arrayOfProducts![indexPath.row] as! Product
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionViewCell
		let imageUrl = URL(string: selectedProduct.image)
		
		cell.tilteLabel.text = selectedProduct.productName
		cell.priceLabel.text = "$" + selectedProduct.price
		
		cell.productImageView.sd_showActivityIndicatorView()
		cell.productImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage (named: "product_placeholder"), options: SDWebImageOptions.highPriority, completed: nil)
		
		
		
		if(selectedProduct.location == "false"){
			cell.locationLabel.text = "Online"
		} else {
			cell.locationLabel.text = "Tiendas & Online"
		}
		
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
		saveSearchInHistory(search: textField.text!)
		textField.resignFirstResponder()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return true
	}
	
	
	func showAlertWith(title:String, message:String){
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func saveSearchInHistory(search:String){
		let array = Utilities.gethistory().mutableCopy() as! NSMutableArray
		if (!array.contains(search)) {
			array.add(search)
		}
		Utilities.saveHistory(array: array)
	}
	
	func getArrayOfProducts(array:[[String: Any]]) -> NSMutableArray {
		
		let finalArray = NSMutableArray()
		
		for element in array {
			let attributes = element["attributes"] as! [String: Any]
			let title = getStringValueFromArray(array: attributes["product.displayName"] as! [String])
			let price = getStringValueFromArray(array: attributes["sku.list_Price"] as! [String])
			let image = getStringValueFromArray(array: attributes["sku.thumbnailImage"] as! [String])
			let location = getStringValueFromArray(array: attributes["isAvailabilityShop"] as! [String])
			
			let product:Product = Product()
			product.productName = title
			product.image = image
			product.price = price
			product.location = location
			
			finalArray.add(product)
		}
		return finalArray
	}
	
	func getStringValueFromArray(array:[String]) -> String{
		let string = array.first
		return string!
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
				let json = try? JSONSerialization.jsonObject(with: data!, options: [])
				
				if let dictionary = json as? [String: Any] {
					if let content = dictionary["contents"] as? [[String: Any]] {
						let contArray = content[0]["mainContent"] as? [[String: Any]]
						let records = contArray![3]
						let secondLevel = records["contents"] as? [[String: Any]]
						let thirdLevel = secondLevel![0]["records"] as? [[String: Any]]
						self.arrayOfProducts =  self.getArrayOfProducts(array: thirdLevel!)
						DispatchQueue.main.async {
							self.collectionView?.reloadData()
						}
					}else {
						print("No es Array")
					}
					
				}
				
				//let statusCode = (response as! HTTPURLResponse).statusCode
				
				
			} else {
				self.showAlertWith(title: "ERROR", message: error!.localizedDescription)
			}
		})
		task.resume()
		session.finishTasksAndInvalidate()
	}
	
	//Mark Empty Data Source Delegate
	
	func image (forEmptyDataSet scrollView: UIScrollView) -> UIImage {
		return UIImage(named: "product_placeholder")!
	}
	
	func  title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		return NSAttributedString.init(string: "¡Bienvenido!")
	}
	
	func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		return NSAttributedString.init(string: "Encuentra tus productos favoritos usando nuestro buscador.")
		
		
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
