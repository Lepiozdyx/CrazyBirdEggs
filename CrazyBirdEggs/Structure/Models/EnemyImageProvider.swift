import SwiftUI

enum EnemyImageProvider {
    static func getEnemyImage(for level: Int) -> Image {
        let safeLevelId = min(max(level, 1), 10)
        
        let imageName = "lvl\(safeLevelId)"
        return Image(ImageResource(name: imageName, bundle: .main))
    }
}
