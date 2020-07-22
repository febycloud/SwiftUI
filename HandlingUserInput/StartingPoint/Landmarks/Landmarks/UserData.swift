//
//  UserData.swift
//  Landmarks
//
//  Created by 云飛 on 7/20/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import SwiftUI
import Combine

final class UserData:ObservableObject{
    
   @Published var showFavoritesOnly=false
   @Published var landmarks=landmarkData
}


