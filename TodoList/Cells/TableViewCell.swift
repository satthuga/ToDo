//
//  TableViewCell.swift
//  TodoList
//
//  Created by Apple on 11/09/2021.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    let containView: UIView = {
       let view = UIView()
       view.layer.cornerRadius = 5
       view.backgroundColor = .white
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    let completeButtonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(weight: .light)
        imageView.image = UIImage(named: "circle")
        imageView.tintColor = .lightGray
        imageView.isUserInteractionEnabled = true
        
       return imageView
    }()

    let toDoLabel: UILabel = {
       let label = UILabel()
       label.text = "Test to do 1"
       label.textAlignment = .left
       label.font = UIFont.systemFont(ofSize: 18)
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    let listLabel: UILabel = {
        let label = UILabel()
        label.text = "List 1"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
       let label = UILabel()
       label.text = ""
       label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
    }()
    
    let remindImageView: UIImageView = {
       let imageView = UIImageView()
       imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "bell")
        imageView.tintColor = .white
       return imageView
    }()
    
    let repeatImageView: UIImageView = {
       let imageView = UIImageView()
       imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "repeat")
        imageView.tintColor = .white
       return imageView
    }()
    
    let prioritizedButtonImageView: UIImageView = {
       let imageView = UIImageView()
       imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage()
        imageView.isUserInteractionEnabled = true
       return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.backgroundColor = #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
        setupLayout()
    }
    
    func setupLayout(){
        self.addSubview(containView)
        containView.addSubview(completeButtonImageView)
        containView.addSubview(toDoLabel)
        containView.addSubview(listLabel)
        containView.addSubview(dateLabel)
        containView.addSubview(remindImageView)
        containView.addSubview(repeatImageView)
        containView.addSubview(prioritizedButtonImageView)
        
        containView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        containView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3).isActive = true
        containView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -3).isActive = true
        containView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        completeButtonImageView.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: 15).isActive = true
        completeButtonImageView.centerYAnchor.constraint(equalTo: containView.centerYAnchor).isActive = true
        completeButtonImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        completeButtonImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        
        prioritizedButtonImageView.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -20).isActive = true
        prioritizedButtonImageView.centerYAnchor.constraint(equalTo: containView.centerYAnchor).isActive = true
        prioritizedButtonImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        prioritizedButtonImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        toDoLabel.leadingAnchor.constraint(equalTo: listLabel.leadingAnchor).isActive = true
        toDoLabel.centerYAnchor.constraint(equalTo: containView.centerYAnchor, constant: -12).isActive = true
        toDoLabel.widthAnchor.constraint(equalTo: containView.widthAnchor, multiplier: 0.7).isActive = true
        
        listLabel.leadingAnchor.constraint(equalTo: completeButtonImageView.trailingAnchor, constant: 15).isActive = true
        listLabel.topAnchor.constraint(equalTo: toDoLabel.bottomAnchor, constant: 8).isActive = true
        
        dateLabel.leadingAnchor.constraint(equalTo: listLabel.trailingAnchor, constant: 0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: toDoLabel.bottomAnchor, constant: 8).isActive = true
        
        remindImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8).isActive = true
        remindImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor, constant: 1).isActive = true
        remindImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        remindImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        repeatImageView.leadingAnchor.constraint(equalTo: remindImageView.trailingAnchor, constant: 8).isActive = true
        repeatImageView.centerYAnchor.constraint(equalTo: remindImageView.centerYAnchor).isActive = true
        repeatImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        repeatImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
    }
   
}
