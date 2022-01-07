//
//  MainViewController.swift
//  BlockAreaCode
//
//  Created by Alexey Altoukhov on 10/28/18.
//  Copyright © 2018 Alexey Altoukhov. All rights reserved.
//

import UIKit

class BlockedAreaViewCell: UITableViewCell {
    @IBOutlet weak var BlockedAreaLabel: UILabel!
    @IBOutlet weak var DonePercentLabel: UILabel!
    @IBOutlet weak var ExcludedCountLabel: UILabel!
    
    func updateCell(blockedArea: Int, donePercentage: Double, excludedCount: Int)
    {
        BlockedAreaLabel.text = String(blockedArea)
        DonePercentLabel.text = String(format:"%\(".0")f", donePercentage) + "%"
        ExcludedCountLabel.text = String(excludedCount)
    }
}

class MainViewController: UITableViewController {

    private let _dataClient:DataClient = (UIApplication.shared.delegate as! AppDelegate).dataClient
    
    private var _blockedAreas = [BlockedArea]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _blockedAreas = _dataClient.getAllAreaBlocks()
        if (_blockedAreas.count == 0) {
            _dataClient.addAreaBlock(areaCode: 561)
            print("Added 561")
        }
        
        // Update contacts
        let contacts: [Contact] = Utils.loadContacts()
        _dataClient.updateContacts(contacts: contacts)
        
        update()
        
        //_dataClient.log(message: "test123")
    }

    private func update() {
        if (_dataClient.updatesAvailable()) {
            print("Updating")
            
            Utils.reloadCallExtension { (success) in
                if (success) {
                    DispatchQueue.main.async {
                        self._blockedAreas = self._dataClient.getAllAreaBlocks()
                        self.tableView.reloadData()
                    }
                    
                    self.update()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let allAreaBlocks = _dataClient.getAllAreaBlocks()
        let area561 = allAreaBlocks.first

        if let area561 = area561 {
            print("Total: \(area561.totalNumbers())")
            print("Processed: \(area561.processedCount())")
            print("Done: \(Double(area561.processedCount()) / Double(area561.totalNumbers()) * 100)%")
        }
        
        let contacts = _dataClient.getContacts()
        
        let skipSet: Set<UInt64> = Set<UInt64>(contacts.map{c in UInt64(c.PhoneNumber)!})
        
        print("areaBlocks: \(allAreaBlocks.count)")
        print("contacts: \(contacts.count)")
        print("skipSet: \(skipSet.count)")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _blockedAreas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedAreaCell", for: indexPath) as! BlockedAreaViewCell
        
        let blockedArea = _blockedAreas[indexPath.row]

        cell.updateCell(blockedArea: blockedArea.areaCode(), donePercentage: Double(blockedArea.processedCount()) / Double(blockedArea.totalNumbers()) * 100, excludedCount: blockedArea.getExcludedNumbers().count)
        
        return cell
    }
}
