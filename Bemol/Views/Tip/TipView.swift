import UIKit

final class TipView: UIView {
  enum Edge {
    case topLeft
    case topCenter
    case topRight
    case leftBottom
  }

  struct Action {
    let title: String
    let perform: () -> Void
  }

  // MARK: - Subviews

  private lazy var caret: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .tooltip
    view.widthAnchor.constraint(equalToConstant: .caretSize).isActive = true
    view.heightAnchor.constraint(equalToConstant: .caretSize).isActive = true
    view.layer.cornerRadius = .cornerRadiusSm
    view.transform = CGAffineTransform(rotationAngle: .pi / 4)
    view.isUserInteractionEnabled = false

    return view
  }()

  private lazy var titleLabel: UIView = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .boldFootnote
    label.text = title
    label.textColor = .white
    label.textAlignment = .left
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    label.adjustsFontForContentSizeCategory = true
    label.maximumContentSizeCategory = .large
    label.isUserInteractionEnabled = false

    return label
  }()

  private lazy var messageLabel: UIView = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .footnote
    label.text = message
    label.textColor = .white
    label.textAlignment = .left
    label.numberOfLines = 0
    label.adjustsFontSizeToFitWidth = true
    label.adjustsFontForContentSizeCategory = true
    label.maximumContentSizeCategory = .large
    label.isUserInteractionEnabled = false
    label.widthAnchor.constraint(greaterThanOrEqualToConstant: .labelMinWidth).isActive = true

    return label
  }()

  private lazy var button: UIButton = {
    let button = UIButton(configuration: .plain())
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configuration?.buttonSize = .small
    button.configuration?.baseForegroundColor = .systemOrange
    button.configuration?.title = action.title
    button.addAction(
      UIAction { [weak self] _ in
        self?.action.perform()
      },
      for: .touchUpInside
    )
    button.isUserInteractionEnabled = true

    return button
  }()

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if button.frame.contains(point) {
      return button
    }

    return super.hitTest(point, with: event)
  }

  private lazy var bubble: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .tooltip
    view.layer.cornerRadius = .cornerRadiusMd
    view.isUserInteractionEnabled = false

    return view
  }()

  // MARK: - Constraints

  private lazy var labelMaxWidthConstraint = messageLabel
    .widthAnchor
    .constraint(lessThanOrEqualToConstant: .labelMaxWidth)

  // MARK: - Sizing

  var maxWidth: CGFloat = .tipViewDefaultMaxWidth {
    didSet {
      labelMaxWidthConstraint.constant = max(
        min(maxWidth, .tipViewDefaultMaxWidth) - (.labelHorizontalMargin * 2),
        .labelMinWidth
      )
      layoutIfNeeded()
    }
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(
      width: messageLabel.systemLayoutSizeFitting(
        UIView.layoutFittingCompressedSize
      ).width + .labelHorizontalMargin * 2,
      height: (.caretSize / 2)
        + (messageLabel.intrinsicContentSize.height + .labelVerticalMargin * 2)
        + .caretSize / 4
    )
  }

  // MARK: - Properties

  let edge: Edge
  let title: String
  let message: String
  let action: Action

  // MARK: - Initialization

  init(edge: Edge, title: String, message: String, action: Action) {
    self.edge = edge
    self.title = title
    self.message = message
    self.action = action
    super.init(frame: .zero)
    setUpViewHierarchy()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpViewHierarchy() {
    addSubview(caret)
    addSubview(bubble)
    addSubview(titleLabel)
    addSubview(messageLabel)
    addSubview(button)

    NSLayoutConstraint.activate([
      bubble.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -.labelHorizontalMargin),
      bubble.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: .labelHorizontalMargin),
      titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      button.widthAnchor.constraint(equalTo: widthAnchor),
      labelMaxWidthConstraint
    ])

    switch edge {
    case .topLeft:
      caret.layer.maskedCorners = [.layerMinXMinYCorner]
      NSLayoutConstraint.activate([
        caret.topAnchor.constraint(equalTo: topAnchor, constant: .caretSize / 4),
        caret.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: .spacingSm),
        bubble.topAnchor.constraint(equalTo: caret.bottomAnchor, constant: -.caretSize / 2),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .labelVerticalMargin),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    case .topCenter:
      caret.layer.maskedCorners = [.layerMinXMinYCorner]
      NSLayoutConstraint.activate([
        caret.topAnchor.constraint(equalTo: topAnchor, constant: .caretSize / 4),
        caret.centerXAnchor.constraint(equalTo: centerXAnchor),
        bubble.topAnchor.constraint(equalTo: caret.bottomAnchor, constant: -.caretSize / 2),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .labelVerticalMargin),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    case .topRight:
      caret.layer.maskedCorners = [.layerMinXMinYCorner]
      NSLayoutConstraint.activate([
        caret.topAnchor.constraint(equalTo: topAnchor, constant: .caretSize / 4),
        caret.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -.spacingSm),
        bubble.topAnchor.constraint(equalTo: caret.bottomAnchor, constant: -.caretSize / 2),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .labelVerticalMargin),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    case .leftBottom:
      caret.layer.maskedCorners = [.layerMinXMaxYCorner]
      NSLayoutConstraint.activate([
        caret.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -.caretSize / 2),
        caret.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -.spacingSm),
        bubble.topAnchor.constraint(equalTo: topAnchor),
        titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: .spacingSm),
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingXs),
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: .spacingXs),
        bubble.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingXs),
      ])
    }
  }
}

// MARK: - Reusable constants

@MainActor
private extension CGFloat {
  static let caretSize: CGFloat = 12
  static let labelHorizontalMargin: CGFloat = .spacingSm
  static let labelVerticalMargin: CGFloat = .spacingSm
  static let labelMaxWidth: CGFloat = tipViewDefaultMaxWidth - (.labelHorizontalMargin * 2)
  static let labelMinWidth: CGFloat = 64 - (.labelHorizontalMargin * 2)
}

extension CGFloat {
  static let tipViewDefaultMaxWidth: CGFloat = 232
}
