//
//  NormalCollectionViewCell.swift
//  TvMovieDemoApp
//
//  Created by Zerom on 4/16/24.
//

import UIKit
import Kingfisher

final class NormalCollectionViewCell: UICollectionViewCell {
    static let id = "NormalCollectionViewCell"
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 8
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(reviewLabel)
        self.addSubview(descLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        reviewLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(reviewLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    public func configure(title: String, review: String, desc: String, imageURL: String) {
        imageView.kf.setImage(with: URL(string: imageURL))
        titleLabel.text = title
        reviewLabel.text = review
        descLabel.text = desc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
