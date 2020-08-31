//
//  CategoriesView.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 21.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CategoriesView: View {
    struct ViewState: Equatable {
        var categories: [Category] = []
        var selectedCategory: Category?
        var activityIndicatorEnabled = false
        var errorAlertEnabled = false
    }
    
    enum ViewAction {
        case viewAppeared
        case categoryTapped(category: Category?)
        case errorAlertClosed
    }
    
    let store: Store<AppState, AppAction>
    let searchBar = SearchBar()
    
    var onAppearAction: ((ViewStore<ViewState, ViewAction>) -> Void)? = { viewStore in
        viewStore.send(.viewAppeared)
    }
    
    init(_ store: Store<AppState, AppAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store.scope(state: { $0.viewState }, action: AppAction.viewAction)) { viewStore in
            NavigationView {
                HStack {
                    if viewStore.activityIndicatorEnabled {
                        ActivityIndicator()
                    } else {
                        CategoriesListView(self.store, searchBar: self.searchBar)
                    }
                }
                .navigationBarTitle("Партнеры")
                .add(self.searchBar)
            }
            .onAppear {
                self.onAppearAction?(viewStore)
            }
            .alert(isPresented:
                viewStore.binding(
                    get: { $0.errorAlertEnabled },
                    send: CategoriesView.ViewAction.errorAlertClosed
                )
            ) {
                Alert(title: Text("Ошибка"),
                      message: Text("Сообщение об ошибке"),
                      dismissButton: .default(Text("ОК")))
            }
        }
    }
}

struct CategoriesListView: View {
    let store: Store<AppState, AppAction>
    @ObservedObject var searchBar: SearchBar
    
    init(_ store: Store<AppState, AppAction>, searchBar: SearchBar) {
        self.store = store
        self.searchBar = searchBar
    }
    
    var body: some View {
        WithViewStore(store.scope(state: { $0.viewState }, action: AppAction.viewAction)) { viewStore in
            List {
                ForEach(viewStore.categories.filter {
                    self.searchBar.text.isEmpty ||
                    $0.name.localizedStandardContains(self.searchBar.text)
                }) { category in
                    NavigationLink(
                        destination: CurrentResolver.resolve(PartnersView.self),
                        tag: category,
                        selection: viewStore.binding(
                            get: { $0.selectedCategory },
                            send: CategoriesView.ViewAction.categoryTapped(category:)
                        )
                    ) {
                        HStack {
                            Image(systemName: "person")
                            Text(category.name)
                        }
                    }
                }
            }
        }
    }
}

extension AppState {
    var viewState: CategoriesView.ViewState {
        CategoriesView.ViewState(
            categories: categoriesState.categories,
            selectedCategory: partnersState.currentCategory,
            activityIndicatorEnabled: categoriesState.categoriesRequestInFlight,
            errorAlertEnabled: categoriesState.responseWithError
        )
    }
}

extension AppAction {
    static func viewAction(_ localAction: CategoriesView.ViewAction) -> Self {
        switch localAction {
        case .viewAppeared:
            return .categories(.loadTriggered)
        case .categoryTapped(let category):
            return .partners(.categorySelected(category))
        case .errorAlertClosed:
            return .categories(.errorMessageViewed)
        }
    }
}
