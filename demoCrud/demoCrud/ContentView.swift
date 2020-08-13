//
//  ContentView.swift
//  demoCrud
//
//  Created by 云飛 on 8/11/20.
//  Copyright © 2020 Fei Yun. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
       customView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct customView :View{
    
    @ObservedObject var obeservedData=observable()
    @State var user = ""
    var body:some View{
        NavigationView{
        VStack{
            List{
                
                ForEach(obeservedData.data){i in
                    Text(i.user)
                }.onDelete{ (indexset) in
                    self.obeservedData.deleteData(indexset: indexset, id: self.obeservedData.data[indexset.first!].id)
                }
            }.navigationBarTitle("Coredata")
            HStack{
                TextField("Username",text:$user)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action:{
                    print(self.user)
                    self.obeservedData.addData(user: self.user)
                    self.user=""
                }){
                    Text("Add")
                }
                
            }.padding()
        }
    }
 }
}

class observable:ObservableObject{
    
    @Published var data=[datatype]()
    
    init(){
        let app=UIApplication.shared.delegate as! AppDelegate
        let context=app.persistentContainer.viewContext
        let req=NSFetchRequest<NSFetchRequestResult>(entityName:"Users")
               
               do{
                   let res=try context.fetch(req)
                   for i in res as! [NSManagedObject]{
                      
                    self.data.append(datatype(id: i.objectID, user: i.value(forKey:"user")as! String))
                       
                   }
               }
               catch{
                   print("error")
               }
           }
        
    

    
    
    func addData(user:String){
        
        let app=UIApplication.shared.delegate as! AppDelegate
        let context=app.persistentContainer.viewContext
        let entity=NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
        entity.setValue(user, forKey: "user")
        
        do{
            try context.save()
            print("success")
            data.append(datatype(id: entity.objectID,user:user))
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    
    func deleteData(indexset: IndexSet,id:NSManagedObjectID){
        
        let app=UIApplication.shared.delegate as! AppDelegate
        let context=app.persistentContainer.viewContext
        
        let req=NSFetchRequest<NSFetchRequestResult>(entityName:"Users")
        
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
            print("error")
        }
    }
}
struct datatype:Identifiable{
    var id:NSManagedObjectID
    var user:String
}
