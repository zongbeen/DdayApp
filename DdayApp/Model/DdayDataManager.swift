//
//  DdayDataManager.swift
//  Clock
//
//  Created by zongbeen on 2024/04/04.
//

import UIKit
import CoreData

public class DdayDataManager {
    public static let shared = DdayDataManager()
    private init(){}
    private(set) var context: NSManagedObjectContext?
    
    func setup(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveData(title: String, dday: String?, selectedDate: Date?, completion: @escaping () -> Void) {
        guard let context = context else {
            return
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "DdayData", in: context) else {
            return
        }
        guard let data = NSManagedObject(entity: entity, insertInto: context) as? DdayData else {
            return
        }
        data.dday = dday
        data.title = title
        data.selectedDate = selectedDate
        
        do {
            try context.save()
            completion()
        } catch {
            completion()
        }
    }
    
    func getSavedData() -> [DdayData] {
        var data: [DdayData] = []
        guard let context = context else {
            return []
        }
        let request = NSFetchRequest<NSManagedObject>(entityName: "DdayData")
        let descriptor = NSSortDescriptor(key: "selectedDate", ascending: true)
        request.sortDescriptors = [descriptor]
        
        do {
            guard let fetchedData = try context.fetch(request) as? [DdayData] else {
                return data
            }
            data = fetchedData
        } catch {
            print("error")
        }
        return data
    }
    
    func removeData(deleteTarget: DdayData, completion: @escaping () -> Void){
        guard let context = context else {
            print("error")
            completion()
            return
        }
        guard let targetId = deleteTarget.selectedDate else {
            completion()
            return
        }

        let request = NSFetchRequest<NSManagedObject>(entityName: "DdayData")
        request.predicate = NSPredicate(format: "selectedDate = %@", targetId as CVarArg)

        do{
            guard let fetchData = try context.fetch(request) as? [DdayData] else {
                completion()
                return
            }
            guard let data = fetchData.first else {
                completion()
                return
            }
            context.delete(data)

            do{
                try context.save()
                completion()

            }catch{
                completion()
            }
        } catch{
            print("error")
        }
    }
    
    func updateData(targetId:Date,  newData: DdayData, completion: @escaping () -> Void) {
        guard let context = context else {
            print("error")
            completion()
            return
        }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "DdayData")
        request
            .predicate = NSPredicate(format: "selectedDate = %@", targetId as CVarArg)
        
        do{
            guard let fetchedData = try context.fetch(request) as? [DdayData] else {
                completion()
                return
            }
            
            guard var targetData = fetchedData.first else {
                completion()
                return
            }
            
            targetData = newData
            
            if(context.hasChanges){
                do{
                    try context.save()
                }catch{
                    print("error")
                }
            }
            
            completion()
        } catch{
            print("error")
            completion()
            return
        }
    }
}
