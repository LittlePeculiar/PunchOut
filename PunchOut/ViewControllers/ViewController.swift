//
//  ViewController.swift
//  PunchOut
//
//  Created by Gina Mullins on 1/17/20.
//  Copyright © 2020 LittlePeculiar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var punchTextField: UITextField!
    @IBOutlet weak var hoursWorkedTextField: UITextField!
    @IBOutlet weak var timeRemainingTextField: UITextField!
    @IBOutlet weak var endOfDayLabel: UILabel!
    @IBOutlet weak var endOfDayView: UIView!
    
    let SECONDS_IN_HOUR = 3600
    let SECONDS_IN_8_HOURS = 8 * 3600
    
    var hours = [String]()
    var minutes = [String]()
    
    var punchTime: String = "" {
        didSet {
            displayHoursWorked()
        }
    }
    var hour: String = "4" {
        didSet {
            displayHoursWorked()
        }
    }
    var minute: String = "50" {
        didSet {
            displayHoursWorked()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    func setupUI() {
        
        // ***** Configure End of Day View *****
        
        // add a border to button view
        
        endOfDayView.layer.borderColor = UIColor.red.cgColor
        endOfDayView.layer.borderWidth = 2.0
        endOfDayView.layer.cornerRadius = 5
        endOfDayView.clipsToBounds = true
        
        // ***** Configure hours worked *****
        
        // create hours array
        
        for index in 1...12 {
            hours.append("\(index)")
        }
        
        // create minutes array
        
        for index in 1...59 {
            let minute = String(format: "%02i", index)
            minutes.append(minute)
        }
        
        // create hours picker for setting hours worked so far
        
        let hourPickerView = UIPickerView()
        hourPickerView.delegate = self
        hoursWorkedTextField.inputView = hourPickerView
        if let hr = Int(hour), let min = Int(minute) {
            hourPickerView.selectRow(hr-1, inComponent: 0, animated: false)
            hourPickerView.selectRow(min-1, inComponent: 1, animated: false)
        }
        
        // ***** Configure punched out *****
        
        // create picker for punching out
        
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .time
        punchTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        // set date picker to current time
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        punchTime = formatter.string(from: currentDateTime)
        punchTextField.text = punchTime
    }
    
    func displayHoursWorked() {
        let hrs = Int(hour) == 1 ? "hr" : "hrs"
        
        let selected = Int(minute) ?? 0
        let mins = selected == 1 ? "min" : "mins"
        
        hoursWorkedTextField.text = hour + "\(hrs) " + "\(selected)" + mins
        displayEndOfDay()
    }
    
    func displayEndOfDay() {
        
        // grab the hours and mins from last punch
        
        var punchHour: Int = 0
        var punchMins: Int = 0
        let array = punchTime.components(separatedBy: ":")
        if array.count > 1 {
            punchHour = Int(array[0]) ?? 0
            let minutesArray = array[1].components(separatedBy: " ")
            if minutesArray.count > 1 {
                punchMins = Int(minutesArray[0]) ?? 0
                let ampm = minutesArray[1].uppercased()
                if ampm == "PM" {
                    if punchHour < 12 {
                        punchHour += 12
                    }
                }
            }
        }
        
        // create a new date using hours and mins from last punch
        
        if let punchedInTime = Calendar.current.date(bySettingHour: punchHour, minute: punchMins, second: 0, of: Date()) {
            
            let hrs = Int(hour) ?? 0
            let mins = Int(minute) ?? 0
            let hrsInSeconds = hrs * SECONDS_IN_HOUR
            let minsInSeconds = mins * 60
            
            let secondsRemaining = SECONDS_IN_8_HOURS - hrsInSeconds - minsInSeconds
            let (h, m, s) = secondsToHoursMinutesSeconds(seconds: secondsRemaining)
            
            var dateComponent = DateComponents()
            dateComponent.hour = h
            dateComponent.minute = m
            dateComponent.second = s
            
            // calculate punch out
            
            if let punchOutTme = Calendar.current.date(byAdding: dateComponent, to: punchedInTime) {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                endOfDayLabel.text = formatter.string(from: punchOutTme)
            }
            
            // and display time remaining
            let hrsLeft = Int(h) == 1 ? "hr " : "hrs "
            let minsLeft = Int(m) == 1 ? "min" : "mins"
            
            timeRemainingTextField.text = "\(h)" + hrsLeft + "\(m)" + minsLeft
            timeRemainingTextField.isUserInteractionEnabled = false
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"

        punchTime = dateFormatter.string(from: sender.date)
        punchTextField.text = punchTime
        displayEndOfDay()
    }

    @IBAction func calculateEndOfDayTapped(_ sender: Any) {
        displayEndOfDay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? hours.count : minutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? hours[row] : minutes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hour = hours[row]
        } else {
            minute = minutes[row]
        }
    }
}
