//
//  SettingsViewController.swift
//  Reader
//
//  Created by SHUBHAM on 17/08/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private let appearanceManager = AppearanceManager.shared
    private var settingsData: [SettingsSection] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSettingsData()
        setupAppearances()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(ThemeSelectionCell.self, forCellReuseIdentifier: "ThemeCell")
    }
    
    private func setupSettingsData() {
        settingsData = [
            SettingsSection(
                title: "Appearance",
                items: [
                    SettingsItem(
                        title: "Theme",
                        type: .theme,
                        icon: "paintbrush.fill"
                    )
                ]
            ),
            SettingsSection(
                title: "About",
                items: [
                    SettingsItem(
                        title: "Version",
                        type: .info,
                        icon: "info.circle.fill",
                        subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                    ),
                    SettingsItem(
                        title: "Build",
                        type: .info,
                        icon: "hammer.fill",
                        subtitle: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                    )
                ]
            )
        ]
    }
    
    private func setupAppearances() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsData[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = settingsData[indexPath.section].items[indexPath.row]
        
        switch item.type {
        case .theme:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as! ThemeSelectionCell
            cell.configure(with: item, currentTheme: appearanceManager.currentTheme)
            cell.onThemeChanged = { [weak self] theme in
                self?.appearanceManager.currentTheme = theme
            }
            return cell
            
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.subtitle
            cell.imageView?.image = UIImage(systemName: item.icon)
            cell.imageView?.tintColor = .systemBlue
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Settings Models
struct SettingsSection {
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem {
    let title: String
    let type: SettingsItemType
    let icon: String
    let subtitle: String?
    
    init(title: String, type: SettingsItemType, icon: String, subtitle: String? = nil) {
        self.title = title
        self.type = type
        self.icon = icon
        self.subtitle = subtitle
    }
}

enum SettingsItemType {
    case theme
    case info
}

// MARK: - Theme Selection Cell
class ThemeSelectionCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ThemeMode.allCases.map { $0.displayName })
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    var onThemeChanged: ((ThemeMode) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        segmentedControl.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
    }
    
    func configure(with item: SettingsItem, currentTheme: ThemeMode) {
        titleLabel.text = item.title
        iconImageView.image = UIImage(systemName: item.icon)
        
        if let index = ThemeMode.allCases.firstIndex(of: currentTheme) {
            segmentedControl.selectedSegmentIndex = index
        }
    }
    
    @objc private func themeChanged() {
        let selectedTheme = ThemeMode.allCases[segmentedControl.selectedSegmentIndex]
        onThemeChanged?(selectedTheme)
    }
}
