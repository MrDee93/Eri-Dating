//
//  FiltersViewController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/09/2018.
//  Copyright © 2018 Dayan Yonnatan. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	private var tableView:UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Filters"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFilters))
		let barHeight = UIApplication.shared.statusBarFrame.size.height
		let tableSize = CGRect(x: 0, y: barHeight, width: self.view.frame.width, height: self.view.frame.height - barHeight)
		tableView = UITableView(frame: tableSize, style: .grouped)
		tableView.register(FiltersTVC.self, forCellReuseIdentifier: "FilterCell")
		tableView.allowsMultipleSelection = true
		tableView.delegate = self
		tableView.dataSource = self
		self.view.addSubview(tableView)
		
    }
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		loadSettings()
	}
	@objc func saveFilters() {
		//self.navigationController?.dismiss(animated: true, completion: nil)
		UserDefaults.standard.set(true, forKey: "FilterChanged-ED")
		self.navigationController?.popViewController(animated: true)
		
	}
	func selectedRow(indexPath:IndexPath) {
		if indexPath.section == 0 {
			let row = indexPath.row
			UserDefaults.standard.set(row, forKey: "GenderFilter-ED")
			tickOption(indexPath: indexPath)
		} else {
			let row = indexPath.row
			UserDefaults.standard.set(row, forKey: "PhotoFilter-ED")
			tickOption(indexPath: indexPath)
		}
	}
	func loadSettings() {
		loadGenderPreference()
		loadPhotoPreference()
	}
	func tickOption(indexPath:IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) {
			cell.accessoryType = .checkmark
		}
	}
	func loadGenderPreference() {
		if let genderPreference = UserDefaults.standard.value(forKey: "GenderFilter-ED") as? Int {
			print("ROW:", genderPreference)
			self.tickOption(indexPath: IndexPath(row: genderPreference, section: 0))
			self.tableView.selectRow(at: IndexPath(row: genderPreference, section: 0), animated: true, scrollPosition: .middle)
		}
	}
	func loadPhotoPreference() {
		if let photoPreference = UserDefaults.standard.value(forKey: "PhotoFilter-ED") as? Int {
			self.tickOption(indexPath: IndexPath(row: photoPreference, section: 1))
			self.tableView.selectRow(at: IndexPath(row: photoPreference, section: 1), animated: true, scrollPosition: .middle)
			print("ROW:", photoPreference)
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedRow(indexPath: indexPath)
		print("Selected")
	}
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) {
			cell.accessoryType = .none
		}
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
			for selectedIndexPath in selectedIndexPaths {
				if selectedIndexPath.section == indexPath.section {
					tableView.deselectRow(at: selectedIndexPath, animated: true)
					tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
				}
			}
		}
		return indexPath
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FiltersTVC
		
		//cell.accessoryType = .none
		
		if indexPath.section == 0 {
			
			switch (indexPath.row) {
			case 0:
				cell.textLabel?.text = "Both"
				break
			case 1:
				cell.textLabel?.text = "Female"
				break
			case 2:
				cell.textLabel?.text = "Male"
				break
			default:
				break
			}
		} else {
			switch (indexPath.row) {
			case 0:
				cell.textLabel?.text = "OFF"
				break
			case 1:
				cell.textLabel?.text = "ON"
				break
			default:
				break
			}
		}
		return cell
	}
	/*
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return ["GENDER","PROFILE PHOTO"]
	}*/
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "GENDER"
		}
		return "ONLY SHOW PROFILES WITH PHOTOS"
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 3
		}
		return 2
	}
		
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

