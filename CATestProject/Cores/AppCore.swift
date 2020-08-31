//
//  AppCore.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 21.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
  var categoriesState = CategoriesState()
  var partnersState = PartnersState()
}

enum AppAction {
  case categories(CategoriesAction)
  case partners(PartnersAction)
}

struct AppEnvironment {
  var networkClient: NetworkClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  categoriesReducer.pullback(
    state: \.categoriesState,
    action: /AppAction.categories,
    environment: {
      CategoriesEnvironment(
        partnersClient: $0.networkClient.partnersClient,
        mainQueue: $0.mainQueue
      )
    }
  ),
  partnersReducer.pullback(
    state: \.partnersState,
    action: /AppAction.partners,
    environment: {
      PartnersEnvironment(
        partnersClient: $0.networkClient.partnersClient,
        mainQueue: $0.mainQueue
      )
    }
  )
)

let appReducerMock = Reducer<AppState, AppAction, AppEnvironment>.combine(
  categoriesReducerMock.pullback(
    state: \.categoriesState,
    action: /AppAction.categories,
    environment: {
      CategoriesEnvironment(
        partnersClient: $0.networkClient.partnersClient,
        mainQueue: $0.mainQueue
      )
    }
  ),
  partnersReducerMock.pullback(
    state: \.partnersState,
    action: /AppAction.partners,
    environment: {
      PartnersEnvironment(
        partnersClient: $0.networkClient.partnersClient,
        mainQueue: $0.mainQueue
      )
    }
  )
)

struct NetworkClient {
  var partnersClient: PartnersClient
}

extension NetworkClient {
  static let live = NetworkClient(
    partnersClient: PartnersClient.live
  )
  
  static let mock = NetworkClient(
    partnersClient: PartnersClient.mock
  )
}
