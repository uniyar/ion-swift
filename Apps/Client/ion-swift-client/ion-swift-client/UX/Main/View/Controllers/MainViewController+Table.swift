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
        let section = TableSection()

        IONManager.shared.peersSubject
            .subscribe(onNext: { peers in
                section.clear()

                let rows = peers.map { (peer) -> TableRow<PeerTableViewCell> in
                    let row = TableRow<PeerTableViewCell>(item: peer)
                    row.on(.click) { _ in
                        AppRouter.shared.viewController = self
                        AppRouter.shared.openChat(with: peer.stringIdentifier)
                    }
                    return row
                }

                section.append(rows: rows)

                self.tableDirector?.reload()
            }).disposed(by: self.disposeBag)

        return section
    }
}
