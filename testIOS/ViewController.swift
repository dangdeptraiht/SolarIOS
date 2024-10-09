//
//  ViewController.swift
//  testIOS
//
//  Created by Dang Nguyen on 8/10/24.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var heightConstraints = [UIButton: NSLayoutConstraint]()
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
       }
    
    func loadData() -> [Section]? {
        if let url = Bundle.main.url(forResource: "SolarIOSInterview", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let sections = try JSONDecoder().decode([Section].self, from: data)
                return sections
            } catch {
                print("Error loading data: \(error)")
            }
        }
        return nil
    }
    
    func setupUI() {
        guard let sections = loadData() else { return }
        
        for section in sections {
            let categoryStackView = UIStackView()
            categoryStackView.axis = .vertical
            categoryStackView.spacing = 8
            categoryStackView.translatesAutoresizingMaskIntoConstraints = false
            
            let sectionLabel = UILabel()
            sectionLabel.text = section.category
            sectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
            sectionLabel.textAlignment = .left
            categoryStackView.addArrangedSubview(sectionLabel)
            
            for (index, content) in section.contents.enumerated() {
                let expandableView = UIView()
                expandableView.backgroundColor = .white
                expandableView.layer.cornerRadius = 8
                expandableView.clipsToBounds = true
                expandableView.translatesAutoresizingMaskIntoConstraints = false
                
                let titleButton = UIButton(type: .system)
                titleButton.setTitle("\(index + 1). \(content.title)", for: .normal)
                titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                titleButton.setTitleColor(.black, for: .normal)
                titleButton.contentHorizontalAlignment = .left
                titleButton.titleLabel?.numberOfLines = 0
                titleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                titleButton.addTarget(self, action: #selector(toggleDescription(_:)), for: .touchUpInside)
                titleButton.translatesAutoresizingMaskIntoConstraints = false
                expandableView.addSubview(titleButton)
                
                NSLayoutConstraint.activate([
                    titleButton.leadingAnchor.constraint(equalTo: expandableView.leadingAnchor),
                    titleButton.trailingAnchor.constraint(equalTo: expandableView.trailingAnchor),
                    titleButton.topAnchor.constraint(equalTo: expandableView.topAnchor),
                    titleButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
                ])
                
                let descriptionLabel = UILabel()
                descriptionLabel.text = content.description
                descriptionLabel.font = UIFont.systemFont(ofSize: 14)
                descriptionLabel.numberOfLines = 8
                descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
                expandableView.addSubview(descriptionLabel)
                
                NSLayoutConstraint.activate([
                    descriptionLabel.leadingAnchor.constraint(equalTo: expandableView.leadingAnchor, constant: 8),
                    descriptionLabel.trailingAnchor.constraint(equalTo: expandableView.trailingAnchor, constant: -8),
                    descriptionLabel.topAnchor.constraint(equalTo: titleButton.bottomAnchor, constant: 8),
                    descriptionLabel.bottomAnchor.constraint(equalTo: expandableView.bottomAnchor, constant: -8)
                ])

                let heightConstraint = expandableView.heightAnchor.constraint(equalTo: titleButton.heightAnchor)
                heightConstraint.isActive = true
                heightConstraints[titleButton] = heightConstraint
                
                categoryStackView.addArrangedSubview(expandableView)
            }
            
            mainStackView.addArrangedSubview(categoryStackView)
        }
    }
    
    @objc func toggleDescription(_ sender: UIButton) {
        guard let expandableView = sender.superview, let heightConstraint = heightConstraints[sender] else { return }

        let isCollapsed = heightConstraint.constant > 70

        UIView.animate(withDuration: 0.2, animations: {
            if isCollapsed {
                let titleHeight = sender.titleLabel?.intrinsicContentSize.height ?? 70
                heightConstraint.constant = titleHeight
                
                if let descriptionLabel = expandableView.subviews.last as? UILabel {
                    descriptionLabel.isHidden = true
                    descriptionLabel.setNeedsLayout()
                }
            } else {
                if let descriptionLabel = expandableView.subviews.last as? UILabel {
                    descriptionLabel.isHidden = false

                    let titleHeight = sender.titleLabel?.intrinsicContentSize.height ?? 70
                    let descriptionHeight = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.frame.width - 16, height: CGFloat.greatestFiniteMagnitude)).height

                    heightConstraint.constant = titleHeight + descriptionHeight + 24
                }
            }

            expandableView.layoutIfNeeded()
            self.mainStackView.layoutIfNeeded()
            self.scrollView.contentSize = self.mainStackView.bounds.size
        })
    }
}

