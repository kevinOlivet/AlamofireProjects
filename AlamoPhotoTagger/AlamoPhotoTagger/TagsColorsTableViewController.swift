//
//  TagColorsTableViewController.swift
//  AlamoPhotoTagger
//
//  Created by Jon Olivet on 10/31/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit

class TagsColorsTableViewController: UITableViewController {

  var data: [TagsColorTableData] = []

// MARK: - TableView Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellData = data[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "TagOrColorCell", for: indexPath)
    cell.textLabel?.text = cellData.label
    return cell
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let cellData = data[indexPath.row]

    guard let color = cellData.color else {
      cell.textLabel?.textColor = .black
      cell.backgroundColor = .white
      return
    }

    var red = CGFloat(0.0), green = CGFloat(0.0), blue = CGFloat(0.0), alpha = CGFloat(0.0)
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let threshold = CGFloat(105)
    let bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));

    let textColor: UIColor = (255 - bgDelta < threshold) ? .black : .white;
    cell.textLabel?.textColor = textColor
    cell.backgroundColor = color
  }
}
