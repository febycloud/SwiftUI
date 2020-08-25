//
//  LogListView.swift
//  ExpenseTracker
//
//  Created by Alfian Losari on 19/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import SwiftUI
import CoreData

struct LogListView: View {
        
    // 1
    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext
    
    @State var logToEdit:ExpenseLog?
    // 2
    @FetchRequest(
        entity: ExpenseLog.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ExpenseLog.date, ascending: false)
        ]
    )
    private var result: FetchedResults<ExpenseLog>
    
    // 3
    init(predicate: NSPredicate?, sortDescriptor: NSSortDescriptor) {
        let fetchRequest = NSFetchRequest<ExpenseLog>(entityName: ExpenseLog.entity().name ?? "ExpenseLog")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        _result = FetchRequest(fetchRequest: fetchRequest)
    }
    
    // 4
    var body: some View {
        List {
            ForEach(result) { (log: ExpenseLog) in
                Button(action: {
                    self.logToEdit = log
                }) {
                    HStack(spacing: 16) {
                        CategoryImageView(category: log.categoryEnum)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(log.nameText).font(.headline)
                            Text(log.dateText).font(.subheadline)
                        }
                        Spacer()
                        Text(log.amountText).font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: onDelete)
            .sheet(item: $logToEdit, onDismiss: {
                self.logToEdit = nil
            }) { (log: ExpenseLog) in
                LogFormView(
                    name: log.name ?? "",
                    amount: log.amount?.doubleValue ?? 0, category: Category(rawValue: log.category ?? "") ?? .food, date: log.date ?? Date(), logToEdit: log,
                    context: self.context
                )
        }
    }
    
     private func onDelete(with indexSet: IndexSet) {
               indexSet.forEach { index in
                let log = result[index]
                context.delete(log)
           }
           try? context.saveContext()
       }
}
}

