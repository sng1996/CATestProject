
//
//  PartnersAssembly.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 07.08.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import Swinject

final class PartnersAssembly: Assembly {

    func assemble(container: Container) {
        container.register(PartnersView.self) { r in
          let store = r.resolve(Store<AppState, AppAction>.self)!
          return PartnersView(store.scope(state: { $0.partnersState }, action: AppAction.partners))
        }
    }
}
