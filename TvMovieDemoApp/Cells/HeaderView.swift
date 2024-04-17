//
//  HeaderView.swift
//  TvMovieDemoApp
//
//  Created by Zerom on 4/16/24.
//

import UIKit

final class HeaderView: UICollectionReusableView {
    static let id = "HeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    public func configure(title: String) {
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

