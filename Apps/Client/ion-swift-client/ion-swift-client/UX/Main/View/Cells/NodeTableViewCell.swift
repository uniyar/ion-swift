//
//  NodeTableViewCell.swift
//  ion-swift-client
//
//  Created by Ivan Manov on 27.12.2019.
//  Copyright © 2019 kxpone. All rights reserved.
//

import IONSwift
import TableKit

class NodeTableViewCell: UITableViewCell {
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

extension NodeTableViewCell: ConfigurableCell {
    func configure(with _: Any) { // Node) {
//        self.nameLabel?.text = node.name
//        if let bestAddress = node.bestAddress {
//            self.addressLabel?.text = ("via: " + bestAddress.hostName + ", cost: \(bestAddress.cost.description)")
//        }
//        self.costLabel?.text = ""
//        for address in node.directAddresses {
//            self.costLabel?.text! += ("via: " + address.hostName + ", cost: \(address.cost.description)" + "\n")
//        }
//        self.neighborLabel.text = node.isNeighbor ? "Yes" : "No"
//        self.reachableLabel.text = node.isReachable ? "Yes" : "No"
    }
}
