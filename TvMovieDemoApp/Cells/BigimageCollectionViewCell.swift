//
//  BigimageCollectionViewCell.swift
//  TvMovieDemoApp
//
//  Created by Zerom on 4/16/24.
//

import UIKit
import Kingfisher

final class BigimageCollectionViewCell: UICollectionViewCell {
    static let id = "BigimageCollectionViewCell"
    
    private let posterImage = UIImageView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        addSubview(posterImage)
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(reviewLabel)
        stackView.addArrangedSubview(descLabel)
        
        posterImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(500)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(posterImage.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.bottom.equalToSuperview().offset(-14)
        }
    }
    
    public func configure(title: String, overview: String, vote: String, url: String) {
        titleLabel.text = title
        descLabel.text = overview
        reviewLabel.text = vote
        posterImage.kf.setImage(with: URL(string: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
