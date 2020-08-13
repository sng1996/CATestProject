//
//  AppView.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 21.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
  
  @State var selectedTab = 0
  
  let store: Store<AppState, AppAction>
  
  init(_ store: Store<AppState, AppAction>) {
    self.store = store
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      CurrentResolver.resolve(CategoriesView.self)
        .tabItem {
          Image(systemName: "1.circle")
          Text("Партнеры")
      }.tag(0)
      Text("Что-то еще")
        .tabItem {
          Image(systemName: "2.circle")
          Text("Что-то еще")
      }.tag(1)
    }
  }
}
