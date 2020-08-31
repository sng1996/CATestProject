//
//  PartnersCore.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 21.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture

struct CategoriesState: Equatable {
    var categories: [Category] = []
    var categoriesRequestInFlight = false
    var responseWithError = false
}

//enum State {
//    case loading
//    //    categoriesRequestInFlight = true
//    //    responseWithError = false
//    //    categories = []
//    case success(Data)
//    //    categoriesRequestInFlight = false
//    //    responseWithError = false
//    //    categories = data
//    case error
//    //    categoriesRequestInFlight = false
//    //    responseWithError = true
//    //    categories = []
//    case initial
//    //    categoriesRequestInFlight = false
//    //    responseWithError = false
//    //    categories = []
//}

enum CategoriesAction: Equatable {
    case loadTriggered
    case response(Result<[Category], PartnersClient.Failure>)
    case errorMessageViewed
}

struct CategoriesEnvironment {
    var partnersClient: PartnersClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let categoriesReducer = Reducer<CategoriesState, CategoriesAction, CategoriesEnvironment> { state, action, environment in
    switch action {
    case .loadTriggered:
        struct CategoryId: Hashable {}
        state.categoriesRequestInFlight = true
        return environment.partnersClient
            .categories()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(CategoriesAction.response)
            .cancellable(id: CategoryId(), cancelInFlight: true)
        
    case .response(.success(let response)):
        state.categories = response
        state.categoriesRequestInFlight = false
        return .none
        
    case .response(.failure):
        state.categoriesRequestInFlight = false
        state.responseWithError = true
        return .none
        
    case .errorMessageViewed:
        state.responseWithError = false
        return .none
    }
}

let categoriesReducerMock = Reducer<CategoriesState, CategoriesAction, CategoriesEnvironment> { state, action, environment in
    switch action {
    case .loadTriggered:
        state.categoriesRequestInFlight = true
        return .none
        
    case .response(.success(let response)):
        state.categories = response
        state.categoriesRequestInFlight = false
        return .none
        
    case .response(.failure):
        state.categoriesRequestInFlight = false
        state.responseWithError = true
        return .none
        
    case .errorMessageViewed:
        state.responseWithError = false
        return .none
    }
}
