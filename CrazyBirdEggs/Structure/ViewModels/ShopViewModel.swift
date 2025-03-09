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
        HeroSkin(id: 0, image: .hero, price: 0),
        HeroSkin(id: 1, image: .hero2, price: 300),
        HeroSkin(id: 2, image: .hero3, price: 500),
        HeroSkin(id: 3, image: .hero4, price: 1000)
    ]
    
    init() {
        // Загружаем купленные скины или устанавливаем default (0) если ничего не сохранено
        let bought = Set(UserDefaults.standard.array(forKey: "boughtSkin") as? [Int] ?? [])
        
        // Всегда добавляем базовый скин (id = 0) как доступный по умолчанию
        var initialBoughtSkins = bought
        initialBoughtSkins.insert(0)
        boughtSkin = initialBoughtSkins
        
        // Загружаем выбранный скин или используем 0 (базовый), если выбора нет или выбран недоступный
        let selected = UserDefaults.standard.integer(forKey: "selectedSkin")
        if initialBoughtSkins.contains(selected) {
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
