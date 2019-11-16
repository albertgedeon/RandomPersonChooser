//
//  ViewController.swift
//  RanPark
//
//  Created by Gedeon, Albert on 3/30/17.
//

import UIKit

class ViewController: UITableViewController, UITextFieldDelegate {
    
    var myAlert:UIAlertController? = nil;
    var rootLayer:CALayer = CALayer();
    var emitterLayer:CAEmitterLayer = CAEmitterLayer();

    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder();
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ViewController.displayAddUserPrompt)), animated: true);
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "employeeCell");
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if(event?.subtype == UIEvent.EventSubtype.motionShake) {
            selectEmployee();
        }
    }
    
    func selectEmployee(){
        let employees = DBManager.sharedInstance.getEmployees();
        
        if (employees?.count)! > 0 {
            var highestPickCount = 0;
            
            for employee in employees!{
                if highestPickCount < (employee.picks?.count)! {
                    highestPickCount = (employee.picks?.count)!;
                }
            }
            
            let elegibleEmployees:NSMutableArray = NSMutableArray();
            
            for employee in employees!{
                if highestPickCount > (employee.picks?.count)! {
                    elegibleEmployees.add(employee);
                }
            }
            
            if elegibleEmployees.count == 0 {
                elegibleEmployees.addObjects(from: employees!);
            }

            let randomNumber:UInt32 = arc4random_uniform(UInt32(elegibleEmployees.count))
            
            let selectedEmployee:Employee = elegibleEmployees[Int(randomNumber)] as! Employee;
            
            employeePicked(employee: selectedEmployee);
        }
        else{
            //No Employees
        }
    }
    
    func employeePicked(employee:Employee){
        let pickDate = DBManager.sharedInstance.createPickDate();
        pickDate.date = NSDate() as Date;
        employee.addToPicks(pickDate);
        
        DBManager.sharedInstance.saveContext();
        
        self.tableView.reloadData();
        
        let alert = UIAlertController.init(title: "Winner", message: employee.employeeName, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: { (alertAction) in
        }));
        self.navigationController?.present(alert, animated: true, completion: nil);
    }
    
    @objc func displayAddUserPrompt() {
        myAlert = UIAlertController.init(title: "Add Employee", message: nil, preferredStyle: UIAlertController.Style.alert);
        myAlert?.addTextField { textField in
            textField.delegate = self;
            textField.autocapitalizationType = .words;
            textField.returnKeyType = .done;
        };
        myAlert?.addAction(UIAlertAction.init(title: "Add", style: UIAlertAction.Style.default, handler: { (alertAction) in
            self.addEmployee(employeeName: (self.myAlert?.textFields?[0].text)!);
        }));
        myAlert?.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alertAction) in
        }));
        
        self.navigationController?.present(myAlert!, animated: true, completion: nil);
    }
    
    func resetPicks(){
        let employees = DBManager.sharedInstance.getEmployees();
        
        if (employees?.count)! > 0 {
            for employee in employees!{
                employee.removeFromPicks(employee.picks!);
            }
        }
        DBManager.sharedInstance.saveContext();
    }
    
    // MARK: - UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            DBManager.sharedInstance.deleteEmployee(employee: (DBManager.sharedInstance.getEmployees()?[indexPath.row])!);
            self.resetPicks();
            self.tableView.reloadData();
        }
    }
    
    // MARK: - UITableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (DBManager.sharedInstance.getEmployees()?.count)!;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell", for: indexPath);
        let employee = DBManager.sharedInstance.getEmployees()?[indexPath.row];
        
        cell.textLabel?.text = employee?.employeeName;
        
//        if (employee?.picks?.count)! > 0 {
//            let dateFormatter = DateFormatter();
//            dateFormatter.dateFormat = "MMM dd, yyyy";
//            let pick:PickDate = employee?.picks?.firstObject as! PickDate;
//            cell.detailTextLabel?.text = dateFormatter.string(for: pick.date);
//        }
        
        cell.detailTextLabel?.text = "Hello";
        
        return cell;
    }
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        addEmployee(employeeName: textField.text!);
        return true;
    }
    
    func addEmployee(employeeName: String) {
        if employeeName.count > 0 {
            if !DBManager.sharedInstance.doesEmployeeExist(name: employeeName) {
                let employee = DBManager.sharedInstance.createEmployee();
                employee.employeeName = employeeName;
                
                self.resetPicks();
                self.tableView.reloadData();
            }
        }
    }
}

