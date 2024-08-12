import RxRelay
import RxSwift
import UIKit

class AppIconManager {
    static let allAppIcons: [AppIcon] = [
        .main,
        .alternate(name: "AppIconDark", title: "Dark"),
        .alternate(name: "AppIconMono", title: "Mono"),
        .alternate(name: "AppIconLeo", title: "Chess"),
        .alternate(name: "AppIconMustang", title: "Chess"),
        .alternate(name: "AppIconYak", title: "Chess"),
        .alternate(name: "AppIconPunk", title: "Calculator"),
        .alternate(name: "AppIcon1874", title: "Calculator"),
        .alternate(name: "AppIcon8ball", title: "Calculator"),
    ]

    private let appIconRelay = PublishRelay<AppIcon>()
    var appIcon: AppIcon {
        didSet {
            appIconRelay.accept(appIcon)
            UIApplication.shared.setAlternateIconName(appIcon.name)
        }
    }

    init() {
        appIcon = Self.currentAppIcon
    }
}

extension AppIconManager {
    var appIconObservable: Observable<AppIcon> {
        appIconRelay.asObservable()
    }

    static var currentAppIcon: AppIcon {
        if let alternateIconName: String = UIApplication.shared.alternateIconName, let appIcon = allAppIcons.first(where: { $0.name == alternateIconName }) {
            return appIcon
        } else {
            return .main
        }
    }
}
