//
//  ExpenseLog+Extension.swift
//  ExpenseTracker
//
//  Created by 云飛 on 8/25/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import Foundation
import CoreData

extension ExpenseLog:Identifiable{
    
    var categoryEnum: Category {
        Category(rawValue: category ?? "") ?? .other
    }
    var nameText:String{
        name ?? ""
    }
    var dateText:String{
        Utils.dateFormatter.localizedString(for: date ?? Date(), relativeTo: Date())
    }
    
    static func predicate(with categories: [Category], searchText: String) -> NSPredicate? {
        var predicates = [NSPredicate]()
        
        // 2
        if !categories.isEmpty {
            let categoriesString = categories.map { $0.rawValue }
            predicates.append(NSPredicate(format: "category IN %@", categoriesString))
        }
        
        // 3
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText.lowercased()))
        }
        
        // 4
        if predicates.isEmpty {
            return nil
        } else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
    
    static func fetchAllCategoriesTotalAmountSum(context: NSManagedObjectContext, completion: @escaping ([(sum: Double, category: Category)]) -> ()) {
       
               // 2
           let keypathAmount = NSExpression(forKeyPath: \ExpenseLog.amount)
           let expression = NSExpression(forFunction: "sum:", arguments: [keypathAmount])
           
           let sumDesc = NSExpressionDescription()
           sumDesc.expression = expression
           sumDesc.name = "sum"
           sumDesc.expressionResultType = .decimalAttributeType
           
           // 3
           let request = NSFetchRequest<NSFetchRequestResult>(entityName: ExpenseLog.entity().name ?? "ExpenseLog")
           request.returnsObjectsAsFaults = false
           request.propertiesToGroupBy = ["category"]
           request.propertiesToFetch = [sumDesc, "category"]
           request.resultType = .dictionaryResultType
           
           // 4
           context.perform {
               do {
                   let results = try request.execute()
                   let data = results.map { (result) -> (Double, Category)? in
                       guard
                           let resultDict = result as? [String: Any],
                           let amount = resultDict["sum"] as? Double, amount > 0,
                           let categoryKey = resultDict["category"] as? String,
                           let category = Category(rawValue: categoryKey) else {
                               return nil
                       }
                       return (amount, category)
                   }.compactMap { $0 }
                   completion(data)
               } catch let error as NSError {
                   print((error.localizedDescription))
                   completion([])
               }
           }
           
       }
    
}
