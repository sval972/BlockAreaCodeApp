//
//  LogViewController.swift
//  BlockAreaCode
//
//  Created by Alexey Altoukhov on 3/11/19.
//  Copyright © 2019 Alexey Altoukhov. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    private let _dataClient:DataClient = (UIApplication.shared.delegate as! AppDelegate).dataClient
    
    @IBOutlet weak var logTxtView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        logTxtView.text = _dataClient.readLog()
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
