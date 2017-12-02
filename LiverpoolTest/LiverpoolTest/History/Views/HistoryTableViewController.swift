//
//  HistoryTableViewController.swift
//  LiverpoolTest
//
//  Created by Emmanuel Casañas Cruz on 12/2/17.
//  Copyright © 2017 Emmanuel Cruz. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class HistoryTableViewController: UITableViewController, DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
	
	var historyArray:NSMutableArray?

    override func viewDidLoad() {
        super.viewDidLoad()
		historyArray = Utilities.gethistory()
		tableView.tableFooterView = UIView()
		
		self.tableView.emptyDataSetDelegate = self
		self.tableView.emptyDataSetSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (historyArray?.count)!
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
		let element = historyArray![indexPath.row]
		cell.textLabel?.text = element as? String
        return cell
    }
	
	//Mark Empty Data Source Delegate
	
	func image (forEmptyDataSet scrollView: UIScrollView) -> UIImage {
		return UIImage(named: "history_icon")!
	}
	
	func  title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		return NSAttributedString.init(string: "¡Ups!")
	}
	
	func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		return NSAttributedString.init(string: "Parece que aún no realizas ninguna busqueda.")
		
		
	}
}

