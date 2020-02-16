//
//  ChatViewController.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 16.02.2020.
//  Copyright © 2020 kxpone. All rights reserved.
//

import RxSwift
import UIKit

class ChatViewController: UIViewController {
    var viewModel: ChatViewModel?
    let disposeBag = DisposeBag()

    @IBOutlet weak var inputImageView: UIImageView!
    @IBOutlet weak var outputImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewModel?.startCamera()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.viewModel?.stopCamera()
    }

    private func bindViewModel() {
        self.viewModel?.outputFrameSubject
            .subscribe(onNext: { frame in
                self.outputImageView.image = frame
            }).disposed(by: self.disposeBag)

        self.viewModel?.inputFrameSubject
            .subscribe(onNext: { frame in
                self.inputImageView.image = frame
            }).disposed(by: self.disposeBag)
    }
}
