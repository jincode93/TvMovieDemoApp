//
//  ReviewHeaderCollectionViewCell.swift
//  TvMovieDemoApp
//
//  Created by Zerom on 4/17/24.
//

import UIKit
import SnapKit
import Kingfisher

final class ReviewHeaderCollectionViewCell: UICollectionViewCell {
    static let id = "ReviewHeaderCollectionViewCell"
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    public func configure(title: String, url: String) {
        if url.isEmpty {
            imageView.image = UIImage(systemName: "person.fill")
        } else {
            imageView.kf.setImage(with: URL(string: url))
        }
        
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
