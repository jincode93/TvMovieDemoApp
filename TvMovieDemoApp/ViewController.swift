//
//  ViewController.swift
//  TvMovieDemoApp
//
//  Created by Zerom on 4/15/24.
//

import UIKit
import SnapKit
import RxSwift

// 레이아웃 기준
fileprivate enum Section: Hashable {
    case double
    case banner
    case horizontal(String)
    case vertical(String)
}

// 셀 기준
fileprivate enum Item: Hashable {
    case normal(Content)
    case bigImage(Movie)
    case list(Movie)
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    let buttonView = ButtonView()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        
        collectionView.register(NormalCollectionViewCell.self, 
                                forCellWithReuseIdentifier: NormalCollectionViewCell.id)
        
        collectionView.register(BigimageCollectionViewCell.self,
                                forCellWithReuseIdentifier: BigimageCollectionViewCell.id)
        
        collectionView.register(ListCollectionViewCell.self,
                                forCellWithReuseIdentifier: ListCollectionViewCell.id)
        
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderView.id)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section,Item>?
    
    // Subject - 이벤트를 발생 시키면서 Observable 형태도 되는 것
    let tvTrigger = PublishSubject<Void>()
    let movieTrigger = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDataSource()
        bindViewModel()
        bindView()
        tvTrigger.onNext(())
    }
    
    private func setUI() {
        self.view.addSubview(buttonView)
        self.view.addSubview(collectionView)
        
        buttonView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(buttonView.snp.bottom)
        }
    }
    
    private func bindViewModel() {
        let input = ViewModel.Input(tvTrigger: tvTrigger.asObservable(),
                                    movieTrigger: movieTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        // MARK: - TV Data Binding
        output.tvList.bind { [weak self] tvList in
            var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
            
            let items = tvList.map { Item.normal(Content(tv: $0)) }
            let section = Section.double
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            
            self?.dataSource?.apply(snapshot)
        }.disposed(by: disposeBag)
        
        // MARK: - Movie Data Binding
        output.movieResult.bind { [weak self] result in
            
            switch result {
            case .success(let movieResult):
                var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                
                let bigImageList = movieResult.nowPlaying.results.map { Item.bigImage($0) }
                let bannerSection = Section.banner
                snapshot.appendSections([bannerSection])
                snapshot.appendItems(bigImageList, toSection: bannerSection)
                
                let normalList = movieResult.popular.results.map { Item.normal(Content(movie: $0)) }
                let horizontalSection = Section.horizontal("Popular Movies")
                snapshot.appendSections([horizontalSection])
                snapshot.appendItems(normalList, toSection: horizontalSection)
                
                let itemList = movieResult.upcoming.results.map { Item.list($0) }
                let verticalSection = Section.vertical("Upcoming Movies")
                snapshot.appendSections([verticalSection])
                snapshot.appendItems(itemList, toSection: verticalSection)
                
                self?.dataSource?.apply(snapshot)
                
            case .failure(let error):
                // Toast, dialig
                print(error)
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindView() {
        buttonView.tvButton.rx.tap.bind { [weak self] in
            self?.tvTrigger.onNext(Void())
        }.disposed(by: disposeBag)
        
        buttonView.movieButton.rx.tap.bind { [weak self] in
            self?.movieTrigger.onNext(Void())
        }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.bind { [weak self] indexPath in
            let item = self?.dataSource?.itemIdentifier(for: indexPath)
            switch item {
            case .normal(let content):
                let navigationController = UINavigationController()
                let viewController = ReviewViewController(id: content.id, contentType: content.type)
                navigationController.viewControllers = [viewController]
                self?.present(navigationController, animated: true)
            default:
                print("default")
            }
        }.disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 30
        
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            switch section {
            case .banner:
                return self?.createBannerSection()
            case .horizontal:
                return self?.createHorizontalSection()
            case .vertical:
                return self?.createVerticalSection()
            default:
                return self?.createDoubleSection()
            }
            
        }, configuration: config)
    }
    
    private func createDoubleSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       repeatingSubitem: item,
                                                       count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(640))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                               heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createVerticalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(320))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     repeatingSubitem: item,
                                                     count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .topLeading)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,Item>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                switch item {
                case .normal(let contentData):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: NormalCollectionViewCell.id,
                        for: indexPath
                    ) as? NormalCollectionViewCell
                    
                    cell?.configure(title: contentData.title, 
                                    review: contentData.vote,
                                    desc: contentData.overview,
                                    imageURL: contentData.posterURL)
                    return cell
                    
                case .bigImage(let movieData):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BigimageCollectionViewCell.id,
                        for: indexPath
                    ) as? BigimageCollectionViewCell
                    
                    cell?.configure(title: movieData.title,
                                    overview: movieData.overview,
                                    vote: movieData.vote,
                                    url: movieData.posterURL)
                    return cell
                    
                case .list(let movieData):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ListCollectionViewCell.id,
                        for: indexPath
                    ) as? ListCollectionViewCell
                    
                    cell?.configure(title: movieData.title,
                                    releaseDate: movieData.releaseDate,
                                    url: movieData.posterURL)
                    return cell
                }
        })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, 
                                                                         withReuseIdentifier: HeaderView.id,
                                                                         for: indexPath)
            let section = self?.dataSource?.sectionIdentifier(for: indexPath.section)
            
            switch section {
            case .horizontal(let title):
                (header as? HeaderView)?.configure(title: title)
            case .vertical(let title):
                (header as? HeaderView)?.configure(title: title)
            default:
                print("Default")
            }
            
            return header
        }
    }
}

