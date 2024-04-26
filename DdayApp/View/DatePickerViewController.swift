//
//  PickerViewController.swift
//  Day
//
//  Created by zongbeen on 2024/04/03.
//

import UIKit

class DatePickerViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ddayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ddayResultLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!

    let manager = DdayDataManager.shared
    var data: DdayData?

    var dday: String?
    var daysLeft: Int?
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        getCurrentDay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupNavigationBar() {
        self.title = "Add List"
        
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(leftBarButtonTapped))
        let rightBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        
        leftBarButton.tintColor = .systemOrange
        rightBarButton.tintColor = .systemOrange
        
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    private func getCurrentDay() {
        let currentDate = Date()
        datePicker.date = currentDate
        updateDdayLabel()
    }
    
    func updateDdayLabel() {
        selectedDate = datePicker.date
        let currentDate = Date()
        let currentDateOnly = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
        let selectedDateOnly = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate!)
        daysLeft = Calendar.current.dateComponents([.day], from: currentDateOnly, to: selectedDateOnly).day ?? 0
        
        // D-Day업데이트
        if daysLeft! > 0 {
            dday = "D-\(daysLeft ?? 0)"
            ddayResultLabel.text = "D-\(daysLeft ?? 0)"
        } else if daysLeft == 0 {
            dday = "D-Day"
            ddayResultLabel.text = "D-Day"
        } else {
            dday = "D+\(abs(daysLeft ?? 0))"
            ddayResultLabel.text = "D+\(abs(daysLeft ?? 0))"
        }
    }
    
    @objc func leftBarButtonTapped(){
        self.dismiss(animated: true)
    }
    
    @objc func rightBarButtonTapped() {
        updateDdayLabel()
        if data != nil {
            let newData = data
            newData?.dday = dday
            newData?.title = titleTextField.text
            newData?.selectedDate = selectedDate
            manager.updateData(targetId: data!.selectedDate!, newData: newData!) {
                guard let tabBarViewController = self.presentingViewController as? UITabBarController else{
                    return
                }
                guard let navigationController = tabBarViewController.viewControllers![0] as? DdayNavigationViewController else {
                    return
                }
                guard let viewController = navigationController.viewControllers.first as? DdayViewController else {
                    return
                }
                viewController.tableView.reloadData()
                self.dismiss(animated: true)
            }
        } else {
            manager.saveData(title: titleTextField.text ?? "empty", dday: dday!, selectedDate: selectedDate) {
                guard let tabBarViewController = self.presentingViewController as? UITabBarController else{
                    return
                }
                guard let navigationController = tabBarViewController.viewControllers![0] as? DdayNavigationViewController else {
                    return
                }
                guard let viewController = navigationController.viewControllers.first as? DdayViewController else {
                    return
                }
                viewController.tableView.reloadData()
                self.dismiss(animated: true)
            }
        }
    }
    
    func reloadAfterChangeAlarmData(){
        self.dismiss(animated: true)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        // datePicker의 값을 변경할 때마다 D-Day를 다시 계산하여 업데이트
        updateDdayLabel()
    }
}
