//
//  PartnersView.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 21.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct PartnersView: View {
  struct State: Equatable {
    var currentCategory: Category?
    var partners: [Partner] = []
  }
  
  enum Action {
    case viewAppeared
    case viewDisappeared
  }
  
  let store: Store<PartnersState, PartnersAction>
  
  init(_ store: Store<PartnersState, PartnersAction>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(self.store.scope(state: { $0.viewState }, action: PartnersAction.viewAction)) { viewStore in
      List {
        ForEach(viewStore.partners) { partner in
          VStack(alignment: .leading) {
            Text(partner.name)
            Text("Минимальный срок рассрочки \(partner.installmentMin)")
              .foregroundColor(.gray)
          }
        }
      }
      .navigationBarTitle(viewStore.currentCategory?.name ?? "Unknown")
      .onAppear {
          viewStore.send(.viewAppeared)
      }
      .onDisappear {
        viewStore.send(.viewDisappeared)
      }
    }
  }
}

extension PartnersState {
  var viewState: PartnersView.State {
    PartnersView.State(
      currentCategory: currentCategory,
      partners: partners
    )
  }
}

extension PartnersAction {
  static func viewAction(_ localAction: PartnersView.Action) -> Self {
    switch localAction {
    case .viewAppeared:
      return .loadTriggered
    case .viewDisappeared:
      return .cleanDataTriggered
    }
  }
}
