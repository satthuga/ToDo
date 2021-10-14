//
//  SideMenuViewCell.swift
//  TodoList
//
//  Created by Apple on 19/09/2021.
//

import UIKit

class SideMenuViewCell: UITableViewCell {
    let containView: UIView = {
       let view = UIView()
       view.backgroundColor = .white
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "list.dash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
        imageView.tintColor = .gray
        imageView.isUserInteractionEnabled = true
        
       return imageView
    }()

    let listNameLabel: UILabel = {
       let label = UILabel()
       label.text = "Test 1"
       label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.backgroundColor = .white
        setupLayout()
    }
    
    func setupLayout(){
        self.addSubview(containView)
        containView.addSubview(iconImageView)
        containView.addSubview(listNameLabel)
       
        containView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        containView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        containView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        containView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        listNameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15).isActive = true
        listNameLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        listNameLabel.widthAnchor.constraint(equalTo: containView.widthAnchor, multiplier: 0.7).isActive = true
        
        
    }
   
}
