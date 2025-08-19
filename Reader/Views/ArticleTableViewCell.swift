//
//  ArticleTableViewCell.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    static let identifier = "ArticleTableViewCell"
    
    // MARK: - UI Elements
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = LayoutConstants.CornerRadius.small
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: LayoutConstants.FontSize.headline)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: LayoutConstants.FontSize.body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: LayoutConstants.FontSize.caption)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: LayoutConstants.FontSize.caption)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    var onBookmarkTapped: (() -> Void)?
    private var imageWidthConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(articleImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bookmarkButton)
        
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // Create constraints that can be updated for adaptive layout
        imageWidthConstraint = articleImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.ImageSize.thumbnail)
        imageHeightConstraint = articleImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.ImageSize.thumbnail)
        leadingConstraint = articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.Margins.horizontal)
        trailingConstraint = bookmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.Margins.horizontal)
        
        NSLayoutConstraint.activate([
            // Image constraints
            leadingConstraint,
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.Spacing.medium),
            imageWidthConstraint,
            imageHeightConstraint,
            
            // Bookmark button constraints
            trailingConstraint,
            bookmarkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.Spacing.medium),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: LayoutConstants.Spacing.medium),
            titleLabel.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -LayoutConstants.Spacing.small),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.Spacing.medium),
            
            // Description label constraints
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutConstants.Spacing.tiny),
            
            // Source and date labels
            sourceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sourceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: LayoutConstants.Spacing.small),
            sourceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -LayoutConstants.Spacing.medium),
            
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: sourceLabel.topAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: sourceLabel.trailingAnchor, constant: LayoutConstants.Spacing.small)
        ])
    }
    
    // MARK: - Configuration
    func configure(with article: Article, isBookmarked: Bool) {
        titleLabel.text = article.displayTitle
        descriptionLabel.text = article.displayDescription
        sourceLabel.text = article.displayAuthor
        dateLabel.text = article.formattedDate
        bookmarkButton.isSelected = isBookmarked
        
        // Load image
        loadImage(from: article.urlToImage)
    }
    
    private func loadImage(from urlString: String?) {
        articleImageView.image = UIImage(systemName: "photo")
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.articleImageView.image = image
            }
        }.resume()
    }
    
    @objc private func bookmarkTapped() {
        onBookmarkTapped?()
    }
    
    // MARK: - Adaptive Layout
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForTraitCollection()
    }
    
    private func updateLayoutForTraitCollection() {
        let imageSize = AdaptiveLayoutHelper.adaptiveImageSize(for: traitCollection)
        let margin = AdaptiveLayoutHelper.adaptiveMargin(for: traitCollection)
        
        imageWidthConstraint.constant = imageSize
        imageHeightConstraint.constant = imageSize
        leadingConstraint.constant = margin
        trailingConstraint.constant = -margin
        
        // Update font sizes
        titleLabel.font = UIFont.boldSystemFont(ofSize: AdaptiveLayoutHelper.adaptiveFontSize(base: LayoutConstants.FontSize.headline, for: traitCollection))
        descriptionLabel.font = UIFont.systemFont(ofSize: AdaptiveLayoutHelper.adaptiveFontSize(base: LayoutConstants.FontSize.body, for: traitCollection))
        sourceLabel.font = UIFont.systemFont(ofSize: AdaptiveLayoutHelper.adaptiveFontSize(base: LayoutConstants.FontSize.caption, for: traitCollection))
        dateLabel.font = UIFont.systemFont(ofSize: AdaptiveLayoutHelper.adaptiveFontSize(base: LayoutConstants.FontSize.caption, for: traitCollection))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.image = UIImage(systemName: "photo")
        onBookmarkTapped = nil
    }
}
