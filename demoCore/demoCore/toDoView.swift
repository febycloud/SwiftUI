//
//  toDoView.swift
//  demoCore
//
//  Created by 云飛 on 8/15/20.
//  Copyright © 2020 Fei Yun. All rights reserved.
//

import SwiftUI
import CoreData

struct toDoView: View {
    @ObservedObject var observedData = observable()
    @State var todo = ""
    
    var body: some View{
        
        
        NavigationView{
            
            VStack{
                    
                    List{
                        
                        ForEach(observedData.data){i in
                            
                            Text(i.todo)
                        }.onDelete { (indexset) in
                            
                            self.observedData.deleteTodo(indexset: indexset, id: self.observedData.data[indexset.first!].id)
                        }
                }.navigationBarTitle("CoreData")
                    
                    HStack{
                        
                        TextField("Todos", text: $todo).textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            
                            print(self.todo)
                            self.observedData.addTodo(todo: self.todo)
                            self.todo = ""
                            
                        }) {
                            
                            Text("Add")
                        }
                    }.padding()
            }
        }

    }
}

struct toDoView_Previews: PreviewProvider {
    static var previews: some View {
        toDoView()
    }
}

struct datatype:Identifiable {
   var id : NSManagedObjectID
   var todo : String
}

class observable:ObservableObject{
    
    @Published var data=[datatype]()
    
    init(){
        let app=UIApplication.shared.delegate as! AppDelegate
        let context=app.persistentContainer.viewContext
        let req=NSFetchRequest<NSFetchRequestResult>(entityName: "Todos")
        
        do{
            let res=try context.fetch(req)
            
            for i in res as! [NSManagedObject]{
                self.data.append(datatype(id: i.objectID, todo: i.value(forKey: "todo") as! String))
            }
        }
        catch{
            
        }
    }
    //add data
    func addTodo(todo:String){
        
        let app=UIApplication.shared.delegate as! AppDelegate
        let context=app.persistentContainer.viewContext
        let entity=NSEntityDescription.insertNewObject(forEntityName: "Todos", into: context)
        entity.setValue(todo, forKey: "todo")
        do{
            try context.save()
            print("success")
        }
        catch{
            
        }
    }
    //delete data
    func deleteTodo(indexset:IndexSet,id:NSManagedObjectID){
        let app=UIApplication.shared.delegate as! AppDelegate
        let context=app.persistentContainer.viewContext
        let req=NSFetchRequest<NSFetchRequestResult>(entityName: "Todos")
        do{
            let res=try context.fetch(req)
            
            for i in res as! [NSManagedObject]{
                if i.objectID==id{
                    try context.execute(NSBatchDeleteRequest(objectIDs: [id]))
                    self.data.remove(atOffsets:indexset)
                }
            }
        }
        catch{
            
        }
        
    }
  //update data
    func updateTodo(id:NSManagedObjectID,todo:String){
        let app=UIApplication.shared.delegate as! AppDelegate
        let context=app.persistentContainer.viewContext
        let req=NSFetchRequest<NSFetchRequestResult>(entityName: "Todos")
        do{
            let res=try context.fetch(req)
            for i in res as! [NSManagedObject]{
                if i.objectID==id{
                     context.setValue(todo, forKey: "todo")
                    try context.save()
                    
                }
            }
        }
        catch{
            
        }
    }

    
}



