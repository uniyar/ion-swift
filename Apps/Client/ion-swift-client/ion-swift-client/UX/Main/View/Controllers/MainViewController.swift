//
//  MainViewController.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 23.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import IONSwift
import RxSwift
import TableKit

class MainViewController: UIViewController {
    internal let disposeBag = DisposeBag()
    internal var tableDirector: TableDirector?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindViewModel()

        self.prepareTable()
    }

    func bindViewModel() {
        IONManager.shared.discoveredPeerSubject
            .subscribe(onNext: { remotePeer in
                print(remotePeer.stringIdentifier + " discovered")
            }).disposed(by: self.disposeBag)

        IONManager.shared.removedPeerSubject
            .subscribe(onNext: { remotePeer in
                print(remotePeer.stringIdentifier + " removed")
            }).disposed(by: self.disposeBag)
    }
}
