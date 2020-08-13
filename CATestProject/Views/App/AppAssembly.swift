//
//  AppAssembly.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 07.08.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import Swinject

final class AppAssembly: Assembly {
  func assemble(container: Container) {
    container.register(Store<AppState, AppAction>.self) { r in
      return Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(
            networkClient: NetworkClient.live,
          mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      ))
    }.inObjectScope(.container)
    
    container.register(AppView.self) { r in
      let store = r.resolve(Store<AppState, AppAction>.self)!
      return AppView(store)
    }
  }
}
