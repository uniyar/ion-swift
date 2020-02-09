//
//  MainViewController+Table.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 27.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import IONSwift
import RxSwift
import TableKit

extension MainViewController {
    func prepareTable() {
        self.tableDirector = TableDirector(tableView: self.tableView)
        self.tableDirector?.append(section: self.peersSection())
        self.tableDirector?.reload()
    }

    private func peersSection() -> TableSection {
        let tableSection = TableSection()

//        IONManager.shared.nodesSubject
//            .subscribe(onNext: { [weak self] nodes in
//                guard let self = self else { return }
//                tableSection.clear()
//
//                nodes.values.forEach { node in
//                    if node.isReachable {
//                        let nodeRow = TableRow<NodeTableViewCell>(item: node)
//                        tableSection.append(row: nodeRow)
//                    }
//                }
//
//                self.tableDirector?.reload()
//            }).disposed(by: self.disposeBag)

        return tableSection
    }
}
