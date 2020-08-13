//
//  CATestProjectTests.swift
//  CATestProjectTests
//
//  Created by Сергей Гаврилко on 20.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import Combine
import ComposableArchitecture
import XCTest
@testable import CATestProject

class CATestProjectTests: XCTestCase {
    
    func testCategoriesLoad() {
        let expected = [
            Category(id: "1", name: "Популярные", title: "popularpartners"),
        ]
        
        var mock = PartnersClient.mock
        mock.categories = { Effect(value: expected) }
        
        let store = TestStore(
            initialState: CategoriesState(),
            reducer: categoriesReducer,
            environment: CategoriesEnvironment(
                partnersClient: mock,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        )
        
        store.assert([
            .send(.loadTriggered) {
                $0.categoriesRequestInFlight = true
            },
            .do {
                _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 0.1)
            },
            .receive(CategoriesAction.response(Result.success(expected))) {
                $0.categories = expected
                $0.categoriesRequestInFlight = false
            },
        ])
    }
}
