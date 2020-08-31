//
//  SnapshotTests.swift
//  CATestProjectTests
//
//  Created by Сергей Гаврилко on 31.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

@testable import CATestProject
import XCTest
import SnapshotTesting
import ComposableArchitecture
import SwiftUI

class SnapshotTests: XCTestCase {
    
    func testSnapshots() {
        let expected = [
            Category(id: "1", name: "Популярные", title: "popularpartners"),
        ]
        
//        let scheduler = DispatchQueue.main.eraseToAnyScheduler()
//        var mock = NetworkClient.mock
//        mock.partnersClient.categories = {
//            Effect(value: expected)
//                .delay(for: 0.1, scheduler: scheduler)
//                .eraseToEffect()
//        }
        
        let store = Store(
            initialState: AppState(),
            reducer: appReducerMock,
            environment: AppEnvironment(
                networkClient: NetworkClient.mock,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        )
        
        let viewStore = ViewStore(store)
        
        var view = CategoriesView(store)
        view.onAppearAction = nil
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.categories(.loadTriggered))
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.categories(.response(.success(expected))))
        assertSnapshot(matching: vc, as: .image)
    }
}
