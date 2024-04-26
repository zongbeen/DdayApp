//
//  ViewController.swift
//  Day
//
//  Created by zongbeen on 2024/04/02.
//

import UIKit

class DdayViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var data: [DdayData] {
        get {
            return getDdayData()
        }
    }
    var isEditingMode = false
    let manager = DdayDataManager.shared
    
    lazy var leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action:#selector(leftBarButtonTapped))
        return barButtonItem
    }()
    lazy var rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonTapped))
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func setupNavigationBar(){
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Record"
        leftBarButton.tintColor = .systemOrange
        rightBarButton.tintColor = .systemOrange
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    func setupTableView() {
        tableView.reloadData()
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.backgroundColor = .black
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    func getDdayData() -> [DdayData] {
        return manager.getSavedData()
    }
    @objc func leftBarButtonTapped(){
        isEditingMode = !isEditingMode
        if isEditingMode {
            leftBarButton.title = "Done"
        } else {
            leftBarButton.title = "Edit"
        }
        setEditing(!tableView.isEditing, animated: true)
    }
    
    @objc func rightBarButtonTapped() {
        let datePickerViewController = self.storyboard?.instantiateViewController(identifier: "DatePickerViewController") as! DatePickerViewController
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        let _ = tableView.visibleCells.map { cell in
            guard let cell = cell as? TableViewCell else {
                return
            }
            if(editing){
                cell.ddayLabel.isHidden = true
            }else{
                UIView.transition(with: cell.ddayLabel,duration: 0.5, options: .transitionCrossDissolve) {
                    cell.ddayLabel.isHidden = false
                }
            }
        }
    }
    func calculateDday(selectedDate: Date) -> String {
        let currentDate = Date()
        let currentDateOnly = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
        let selectedDateOnly = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        let daysLeft = Calendar.current.dateComponents([.day], from: currentDateOnly, to: selectedDateOnly).day ?? 0
        if daysLeft > 0 {
            return "D-\(daysLeft)"
        } else if daysLeft == 0 {
            return "D-Day"
        } else {
            return "D+\(abs(daysLeft))"
        }
    }
}

extension DdayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.data = data[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            manager.removeData(deleteTarget: data[indexPath.row]) {
                tableView.reloadData()
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DdayViewController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DdayViewController", let indexPath = tableView.indexPathForSelectedRow{
            
            guard let navigationController = segue.destination as? DatePickerNavigationViewController else {
                return
            }
            
            guard let viewController = navigationController.viewControllers.first as? DatePickerViewController else {
                return
            }
            
            viewController.data = data[indexPath.row]

            viewController.loadViewIfNeeded()
            
            viewController.datePicker.setDate(data[indexPath.row].selectedDate!, animated: false)
            
            viewController.titleTextField.text = data[indexPath.row].title
//            calculateDday
            viewController.ddayResultLabel.text = calculateDday(selectedDate: viewController.datePicker.date)
//            viewController.tableView.reloadData()
        }
    }
}
