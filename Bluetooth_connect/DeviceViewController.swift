//
//  DelayViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 7/6/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate {
    
    
    @IBOutlet weak var addTestButton: UIButton!
    @IBOutlet weak var addDelayButton: UIButton!
    @IBOutlet weak var loopCountTextField: UITextField!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var listOfTestTableView: UITableView!
    
    var sensorName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loopCountTextField.delegate = self
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: loopCountTextField.frame.height - 1, width: loopCountTextField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 0x41/255, green: 0xb2/255, blue: 0x5b/255, alpha: 1).cgColor
        loopCountTextField.borderStyle = .none
        loopCountTextField.layer.addSublayer(bottomLine)

        addTestButton.layer.cornerRadius = addTestButton.layer.bounds.height / 3
        addDelayButton.layer.cornerRadius = addDelayButton.layer.bounds.height / 3
        
        listOfTestTableView.delegate = self
        listOfTestTableView.dataSource = self
        listOfTestTableView.dragDelegate = self
        listOfTestTableView.dropDelegate = self
        listOfTestTableView.dragInteractionEnabled = true
        
        let tabBarItem = UITabBarItem(title: "Device", image: UIImage(named: "1")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "1sel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        self.tabBarItem = tabBarItem

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0x31/255, green: 0x30/255, blue: 0x30/255, alpha: 1)], for: .selected)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let name = sensorName{
            deviceNameLabel.text = name
        }
        self.listOfTestTableView.reloadData()
        
        totalHr = 0
        totalMin = 0
        totalSec = 0
    }
       
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touched anywhere on screen ended
        self.view.endEditing(true)
    }
       
    // objective-c function for when keyboard appears
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -(self.view.frame.width * 0.22)
    }
   
    // objective-c function for when keyboard disappear
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
   
    // when hitting enter on the textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let config = configsList[indexPath.row]
        if config is DelayConfig {
            let storyboard = UIStoryboard(name: "TestingNavigationController", bundle: nil)
            if #available(iOS 13.0, *) {
                let controller = storyboard.instantiateViewController(identifier: "delayController") as! DelayConfigurationViewController
                controller.delayName = config.name
                controller.delayHour = config.hour
                controller.delayMin = config.min
                controller.delaySec = config.sec
                controller.updateIndex = indexPath.row
                controller.isUpdate = true
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                performSegue(withIdentifier: "toDelayConfiguration", sender: self)
            }
        
            
        }
        else{
            print("Test config")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            configsList.remove(at: indexPath.row)
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
          // do nothing....
      }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        configsList.rearrange(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testTableViewCell") as! TestTableViewCell
        
        let config = configsList[indexPath.row]
        let hour = config.hour
        let min = config.min
        let sec = config.sec
        let delayStr = constructDelayString(hour: hour, min: min, sec: sec)
        
        cell.cellTitle.text = config.name
        cell.cellRuntime.text = "Run Time: " + delayStr
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.default
        
        updateTotalDuration(hour: hour, min: min, sec: sec)
        return cell
    }
    
    private func updateTotalDuration(hour: Int, min: Int, sec: Int){
        totalSec += sec
        totalMin += totalSec / 60
        totalSec %= 60
        
        totalMin += min
        totalHr += totalMin / 60
        totalMin %= 60
        
        totalHr += hour
        delayLabel.text = constructDelayString(hour: totalHr, min: totalMin, sec: totalSec)
    }
    
    private func constructDelayString(hour: Int, min: Int, sec: Int) -> String{
        var delayStr = ""
        
        if hour < 10{
            delayStr = delayStr + "0" + String(hour) + ":"
        }
        else{
            delayStr = delayStr + String(hour) + ":"
        }
        
        if min < 10{
            delayStr = delayStr + "0" + String(min) + ":"
        }
        else{
            delayStr = delayStr + String(min) + ":"
        }
        
        if sec < 10{
            delayStr = delayStr + "0" + String(sec) + ":"
        }
        else{
            delayStr = delayStr + String(sec) + ":"
        }
        return delayStr
    }
    
    @IBAction func addTestButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toTestConfiguration", sender: self)
    }
    
    @IBAction func addDelayButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toDelayConfiguration", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
