//
//  CategoriesAssembly.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 07.08.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import Swinject

final class CategoriesAssembly: Assembly {

    func assemble(container: Container) {
        container.register(CategoriesView.self) { r in
          let store = r.resolve(Store<AppState, AppAction>.self)!
          return CategoriesView(store)
        }
    }
}
