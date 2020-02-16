//
//  PeerTableViewCell.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 27.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import IONSwift
import TableKit

class PeerTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var neighborLabel: UILabel!
    @IBOutlet weak var reachableLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
}

extension PeerTableViewCell: ConfigurableCell {
    func configure(with peer: IONRemotePeer) {
        self.nameLabel?.text = peer.name
    }
}
