//
//  DBManager.swift
//  RanPark
//
//  Created by Gedeon, Albert on 3/30/17.
//

import Foundation
import CoreData

class DBManager: NSObject {
    
    static let sharedInstance = DBManager();
    
    private override init() {
    }
    
    func createEmployee() -> Employee{
        return NSEntityDescription.insertNewObject(forEntityName: "Employee", into: persistentContainer.viewContext) as! Employee;
    }
    
    func createPickDate() -> PickDate{
        return NSEntityDescription.insertNewObject(forEntityName: "PickDate", into: persistentContainer.viewContext) as! PickDate;
    }
    
    func getEmployees() -> Array<Employee>?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Employee");
        var results:Array<Employee>?;
        do {
            results = try persistentContainer.viewContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? Array<Employee>;
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)");
        }
        
        return results;
    }
    
    func deleteEmployee(employee: Employee) {
        persistentContainer.viewContext.delete(employee);
    }
    
    func doesEmployeeExist(name: String) -> Bool{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee");
        fetchRequest.predicate = NSPredicate(format: "employeeName == %@", name);
        
        do {
            let fetchedEmployees = try persistentContainer.viewContext.fetch(fetchRequest) as! [Employee]
            
            if fetchedEmployees.count > 0 {
                return true;
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        return false;
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RanPark")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

}
