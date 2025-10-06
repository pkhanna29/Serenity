//
//  HomeViewControllerWrapper.swift
//  Help2
//
//  Created by Pranav Khanna on 6/16/25.
//

import SwiftUI
import UIKit

struct HomeViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = HomePageViewController()
        vc.view.backgroundColor = .white
        vc.view.translatesAutoresizingMaskIntoConstraints = false

        let container = UIViewController()
        container.view.backgroundColor = .white

        container.addChild(vc)
        container.view.addSubview(vc.view)

        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: container.view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor)
        ])

        vc.didMove(toParent: container)
        return container
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
