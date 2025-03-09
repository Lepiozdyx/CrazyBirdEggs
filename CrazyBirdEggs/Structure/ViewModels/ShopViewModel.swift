import Foundation

@MainActor
final class ShopViewModel: ObservableObject {
    @Published private(set) var boughtSkin: Set<Int> {
        didSet { UserDefaults.standard.set(Array(boughtSkin), forKey: "boughtSkin") }
    }
    
    @Published private(set) var selectedSkin: Int {
        didSet { UserDefaults.standard.set(selectedSkin, forKey: "selectedSkin") }
    }
    
    let availableSkins: [HeroSkin] = [
        HeroSkin(id: 1, image: .hero, price: 0),
        HeroSkin(id: 2, image: .hero2, price: 300),
        HeroSkin(id: 3, image: .hero3, price: 500),
        HeroSkin(id: 4, image: .hero4, price: 1000)
    ]
    
    init() {
        let bought = Set(UserDefaults.standard.array(forKey: "boughtSkin") as? [Int] ?? [0])
        boughtSkin = bought.isEmpty ? [0] : bought
        
        let selected = UserDefaults.standard.integer(forKey: "selectedSkin")
        if bought.contains(selected) {
            selectedSkin = selected
        } else {
            selectedSkin = 0
        }
    }
    
    var currentSkin: HeroSkin {
        availableSkins.first { $0.id == selectedSkin } ?? availableSkins[0]
    }
    
    func isSkinBought(_ skin: HeroSkin) -> Bool {
        boughtSkin.contains(skin.id)
    }
    
    func buySkin(_ skin: HeroSkin) {
        guard !isSkinBought(skin) else { return }
        boughtSkin.insert(skin.id)
        selectedSkin = skin.id
    }
    
    func selectSkin(_ skin: HeroSkin) {
        guard isSkinBought(skin) else { return }
        selectedSkin = skin.id
    }
}
