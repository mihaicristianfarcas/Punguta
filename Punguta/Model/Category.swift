//
//  Category.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import Foundation

// MARK: - Category

/// Represents a product category for organization and auto-categorization
///
/// **Key Features**:
/// - Keywords enable automatic product categorization
/// - Default units simplify product creation
/// - Visual styling defined in Category+Visual extension
struct Category: Identifiable, Codable, Hashable {
    
    // MARK: Properties
    
    /// Unique identifier for the category
    let id: UUID
    
    /// Display name of the category (e.g., "Dairy", "Produce")
    var name: String
    
    /// Keywords for auto-categorization (stored in lowercase)
    /// When a product name contains a keyword, this category is suggested
    var keywords: [String]
    
    /// Default unit of measurement for products in this category
    /// Example: "kg" for Produce, "L" for Beverages, "pcs" for Bakery
    var defaultUnit: String?
    
    // MARK: Initializer
    
    init(id: UUID = UUID(), name: String, keywords: [String], defaultUnit: String? = nil) {
        self.id = id
        self.name = name
        // Ensure all keywords are lowercase and unique for case-insensitive matching
        self.keywords = Array(Set(keywords.map { $0.lowercased() }))
        self.defaultUnit = defaultUnit
    }
}

// MARK: - Default Categories
extension Category {
    static let defaultCategories: [Category] = [
        Category(
            name: "Dairy",
            keywords: ["milk", "cheese", "butter", "yogurt", "cream", "sour cream", "cottage cheese", "mozzarella", "cheddar", "parmesan", "feta", "gouda", "brie", "ricotta", "whipping cream", "condensed milk", "evaporated milk", "buttermilk", "custard", "kefir", "cream cheese", "mascarpone", "goat cheese", "lactose-free milk", "almond milk", "soy milk", "oat milk", "lapte", "branza", "unt", "iaurt", "smantana", "smantana acra", "branza de vaci", "mozzarella", "cheddar", "parmezan", "feta", "gouda", "brie", "ricotta", "smantana pentru frisca", "lapte condensat", "lapte evaporat", "lapte fara lactoza", "lapte de migdale", "lapte de soia", "lapte de ovaz"],
            defaultUnit: "kg"
        ),
        Category(
            name: "Produce",
            keywords: ["apple", "banana", "tomato", "lettuce", "carrot", "onion", "potato", "cucumber", "pepper", "spinach", "orange", "strawberry", "grapes", "pear", "peach", "plum", "cherry", "blueberry", "raspberry", "melon", "watermelon", "pineapple", "mango", "kiwi", "lemon", "lime", "garlic", "ginger", "avocado", "broccoli", "cauliflower", "zucchini", "eggplant", "cabbage", "kale", "beet", "radish", "spring onion", "shallot", "herbs", "basil", "parsley", "cilantro", "mint", "mar", "banana", "rosie", "salata", "morcov", "ceapa", "cartof", "castravete", "ardei", "spanac", "portocala", "capsuna", "struguri", "para", "piersica", "pruna", "cirese", "afine", "zmeura", "pepene", "pepene verde", "ananas", "mango", "kiwi", "lamaie", "lime", "usturoi", "ghimbir", "avocado", "brocoli", "conopida", "dovlecel", "vinete", "varza", "kale", "sfecla", "ridiche", "ceapa verde", "sicalot", "ierburi", "busuioc", "patrunjel", "cilantro", "menta"],
            defaultUnit: "kg"
        ),
        Category(
            name: "Meat",
            keywords: ["chicken", "beef", "pork", "lamb", "turkey", "sausage", "bacon", "ham", "steak", "ground beef", "mince", "chorizo", "salami", "prosciutto", "veal", "duck", "goose", "veal", "organ meats", "liver", "kidney", "meatballs", "ribs", "brisket", "poultry", "rotisserie chicken", "pui", "vita", "porc", "miel", "curcan", "carnati", "bacon", "sunca", "friptura", "carne tocata", "carnati chorizo", "salam", "prosciutto", "vita tanara", "rata", "gaste", "organe", "ficat", "rinichi", "chiftelute", "coaste", "pastrama", "pasare", "pui rotisat"],
            defaultUnit: "kg"
        ),
        Category(
            name: "Beverages",
            keywords: ["water", "juice", "soda", "coffee", "tea", "beer", "wine", "coke", "sprite", "lemonade", "sparkling water", "mineral water", "energy drink", "sports drink", "iced tea", "cold brew", "espresso", "latte", "milkshake", "smoothie", "kombucha", "coconut water", "flavored water", "apa", "suc", "bautura carbogazoasa", "cafea", "ceai", "bere", "vin", "coca-cola", "sprite", "limonada", "apa minerala", "apa carbogazoasa", "bautura energizanta", "bautura pentru sportivi", "ceai rece", "espresso", "latte", "milkshake", "smoothie", "kombucha", "apa de cocos", "apa aromata"],
            defaultUnit: "L"
        ),
        Category(
            name: "Bakery",
            keywords: ["bread", "bagel", "croissant", "muffin", "cake", "pastry", "baguette", "rolls", "donuts", "buns", "sourdough", "ciabatta", "pretzel", "brownie", "scone", "tart", "pie", "pita", "flatbread", "focaccia", "naan", "brioche", "paine", "covrigi", "croissant", "briose", "tort", "patiserie", "bagheta", "chifle", "gogosi", "sourdough", "ciabatta", "covrig"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Frozen",
            keywords: ["ice cream", "frozen pizza", "frozen vegetables", "frozen fruits", "popsicle", "frozen meal", "frozen fish", "frozen chips", "frozen berries", "ice", "frozen desserts", "frozen dinners", "frozen pastry", "inghetata", "pizza congelata", "legume congelate", "fructe congelate", "inghetata pe bat", "mezeluri congelate", "peste congelat", "cartofi congelati", "fructe de padure congelate", "gheata", "deserturi congelate", "cinele congelate", "aluat congelat"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Pantry",
            keywords: ["pasta", "rice", "flour", "sugar", "salt", "pepper", "oil", "vinegar", "cereal", "beans", "canned", "tomato paste", "tomato sauce", "broth", "stock", "spices", "herbs", "lentils", "quinoa", "breadcrumbs", "soy sauce", "mustard", "ketchup", "mayonnaise", "peanut butter", "jam", "honey", "syrup", "coconut milk", "chickpeas", "tuna", "sardines", "paste", "orez", "faina", "zahar", "sare", "piper", "ulei", "otet", "cereale", "fasole", "conserva", "pasta de tomate", "sos de tomate", "supa concentrata", "condimente", "ierburi uscate", "linte", "quinoa", "pesmet", "sos de soia", "mustar", "ketchup", "maioneza", "unt de arahide", "dulceata", "miere", "sirop", "lapte de cocos", "napi", "năut", "ton", "sardine"],
            defaultUnit: "kg"
        ),
        Category(
            name: "Snacks",
            keywords: ["chips", "crackers", "cookies", "chocolate", "candy", "popcorn", "nuts", "pretzels", "granola bar", "protein bar", "trail mix", "jerky", "rice cakes", "fruit snacks", "seaweed snacks", "chips", "biscuiti", "fursecuri", "ciocolata", "dulciuri", "popcorn", "nuci", "covrigei", "batoane granola", "batoane proteice", "mix de fructe uscate", "jerky", "tortilla"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Personal Care",
            keywords: ["shampoo", "soap", "toothpaste", "deodorant", "lotion", "tissue", "toilet paper", "conditioner", "body wash", "razor", "shaving cream", "mouthwash", "cotton buds", "cotton pads", "face wash", "sunscreen", "hand sanitizer", "face cream", "sampon", "sapun", "pasta de dinti", "deodorant", "lotinue", "servetele", "hartie igienica", "balsam", "gel de dus", "banda de ras", "spuma de ras", "ata dentara", "betisoare de urechi", "dischete demachiante", "demachiant", "crema de fata", "crema de maini"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Cleaning",
            keywords: ["detergent", "bleach", "cleaner", "sponge", "trash bags", "dish soap", "fabric softener", "laundry detergent", "all-purpose cleaner", "glass cleaner", "floor cleaner", "disinfectant", "dishwasher tablets", "scrub brush", "mop", "broom", "detergent", "inalbitor", "solutie de curatat", "burete", "saci de gunoi", "detergent de vase", "balsam rufe", "detergent rufe", "solutie universala", "solutie pentru geamuri", "solutie pentru pardoseli", "dezinfectant", "pastile masina de spalat vase", "perie de sters", "mop", "matura"],
            defaultUnit: "pcs"
        ),
        // Pharmacy categories
        Category(
            name: "Medicine",
            keywords: ["aspirin", "ibuprofen", "cough syrup", "antibiotic", "allergy", "painkiller", "prescription", "cold medicine", "vitamin c", "thermometer", "antacid", "nitrate", "ointment", "eye drops", "nasal spray", "aspirina", "ibuprofen", "sirop de tuse", "antibiotic", "alergii", "analgezic", "reteta", "medicament pentru raceala", "vitamina c", "termometru", "antiacide", "unguent", "picaturi pentru ochi", "spray nazal"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Vitamins",
            keywords: ["vitamin", "supplement", "multivitamin", "calcium", "omega", "probiotic", "vitamin d", "vitamin c", "iron supplement", "zinc", "fish oil", "collagen", "biotin", "vitamine", "supliment", "multivitamine", "calciu", "omega 3", "probiotic", "vitamina d", "vitamina c", "supliment de fier", "zinc", "ulei de peste", "colagen", "biotina"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "First Aid",
            keywords: ["bandage", "gauze", "band-aid", "antiseptic", "thermometer", "first aid", "plaster", "sterile pad", "adhesive tape", "antibiotic ointment", "tweezers", "safety pins", "bandaj", "tampon steril", "plasture", "antiseptic", "termometru", "trusa prim ajutor", "pansament steril", "tape adeziv", "unguet antibiotic", "penseta", "ace de siguranta"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Beauty",
            keywords: ["makeup", "lipstick", "mascara", "foundation", "perfume", "nail polish", "skincare", "serum", "face mask", "cleanser", "toner", "body lotion", "hair oil", "hair spray", "curling iron", "machiaj", "ruj", "rimel", "fond de ten", "parfum", "lac de unghii", "ingrijire ten", "ser", "masca pentru fata", "demachiant", "toner", "lotinue de corp", "ulei de par", "spray pentru par", "ondulator"],
            defaultUnit: "pcs"
        ),
        // Hardware categories
        Category(
            name: "Tools",
            keywords: ["hammer", "screwdriver", "drill", "saw", "wrench", "pliers", "tape measure", "level", "chisel", "socket set", "utility knife", "allen key", "sandpaper", "nail gun", "ciocan", "surubelnita", "bormasina", "ferastrau", "cheie", "clesti", "ruleta", "nivela", "dalta", "trusa de tubulare", "cutit utilitar", "cheie imbus", "hartie abraziva", "pistol de cuie"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Hardware",
            keywords: ["screw", "nail", "bolt", "nut", "anchor", "hinge", "lock", "washer", "bracket", "shelf pin", "chain", "hook", "eye bolt", "surub", "cui", "buloan", "piulita", "ancora", "balama", "yala", "saiba", "suport", "stift pentru raft", "lant", "carlig", "buloan cu ochi"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Paint",
            keywords: ["paint", "primer", "brush", "roller", "spray paint", "stain", "varnish", "paint thinner", "paint tray", "latex paint", "oil paint", "emulsion", "vopsea", "grund", "pensula", "role", "vopsea spray", "lac", "diluant", "tava pentru vopsea", "vopsea latex", "vopsea pe baza de ulei"],
            defaultUnit: "L"
        ),
        Category(
            name: "Electrical",
            keywords: ["wire", "cable", "outlet", "switch", "bulb", "led", "extension cord", "battery", "fuse", "circuit breaker", "plug", "adapter", "charger", "socket", "sarma", "cablu", "priza", "intrerupator", "bec", "led", "prelungitor", "baterie", "siguranta", "tablou electric", "plug", "adaptor", "incarcator", "priza"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Plumbing",
            keywords: ["pipe", "faucet", "valve", "fitting", "drain", "plunger", "sealant", "washer", "hose", "pipe cutter", "solder", "PVC pipe", "elbow fitting", "teava", "baterie lavoar", "robinet", "racord", "scurgere", "sifon", "desfundator", "etansant", "garnitura", "furtun", "taietor de tevi", "cositor", "teava PVC", "cot"],
            defaultUnit: "pcs"
        ),
        Category(
            name: "Garden",
            keywords: ["soil", "fertilizer", "seeds", "pot", "hose", "rake", "shovel", "gloves", "pruner", "lawn seed", "mulch", "plant food", "weed killer", "garden trowel", "watering can", "pamant", "ingrasamant", "seminte", "ghiveci", "furtun", "grebla", "lopata", "manusi", "foarfeca de gradina", "samanta pentru gazon", "mulci", "ingrasamant pentru plante", "iarbicide", "cazma de gradina", "stropitoare"],
            defaultUnit: "pcs"
        )
    ]
    
    /// Get categories by names, useful for initializing store categories
    static func categories(byNames names: [String]) -> [Category] {
        let categoryMap = Dictionary(uniqueKeysWithValues: defaultCategories.map { ($0.name, $0) })
        return names.compactMap { categoryMap[$0] }
    }
}
