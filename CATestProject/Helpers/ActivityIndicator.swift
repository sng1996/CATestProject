//
//  ActivityIndicator.swift
//  CATestProject
//
//  Created by Сергей Гаврилко on 06.08.2020.
//  Copyright © 2020 Сергей Гаврилко. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: View {
  var body: some View {
    UIViewRepresented(makeUIView: { _ in
      let view = UIActivityIndicatorView()
      view.startAnimating()
      return view
    })
  }
}
