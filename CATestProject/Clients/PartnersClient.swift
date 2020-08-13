//
//  PartnersClient.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 20.07.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct Category: Decodable, Equatable, Identifiable, Hashable {
  let id: String
  let name: String
  let title: String
}

struct Partner: Decodable, Equatable, Identifiable {
  let id: Int
  let name: String
  let installmentMin: Int
}

struct PartnersClient {
  var categories: () -> Effect<[Category], Failure>
  var partners: (String) -> Effect<[Partner], Failure>

  struct Failure: Error, Equatable {}
}

extension PartnersClient {
    
  static let live = PartnersClient(
    categories: {
      let url = URL(string: "https://api.sovest.ru/reports/api/v1/partners/categories")!
      return URLSession.shared.dataTaskPublisher(for: url)
        .map { data, _ in data }
        .decode(type: [Category].self, decoder: JSONDecoder())
        .mapError { _ in Failure() }
        .eraseToEffect()
    },
    partners: { categoryTitle in
      let url = URL(string: "https://api.sovest.ru/reports/api/v1/partners/categories/\(categoryTitle)?width=500&height=400")!

      return URLSession.shared.dataTaskPublisher(for: url)
        .map { data, _ in data }
        .decode(type: [Partner].self, decoder: JSONDecoder())
        .mapError { _ in Failure() }
        .eraseToEffect()
    })
}

extension PartnersClient {
  static let mock = PartnersClient(
    categories: {
      Effect(value: [])
    },
    partners: { _ in
      Effect(value: [])
    })
}
