//
//  PungutaApp.swift
//  Punguta
//
//  Created by Mihai-Cristian Farcas on 20.10.2025.
//

import SwiftUI
import SwiftData

@main
struct PungutaApp: App {
    
    // MARK: SwiftData Container
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure SwiftData with all models
            modelContainer = try ModelContainer(
                for: Category.self, Product.self, ShoppingList.self, ShoppingListItem.self, Store.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
            
            // Seed default data on first launch
            seedDefaultDataIfNeeded(container: modelContainer)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
    
    // MARK: - Data Seeding
    
    /// Seeds default categories if the database is empty
    private func seedDefaultDataIfNeeded(container: ModelContainer) {
        let context = ModelContext(container)
        
        // Check if categories already exist
        let fetchDescriptor = FetchDescriptor<Category>()
        let existingCategories = (try? context.fetch(fetchDescriptor)) ?? []
        
        // Only seed if database is empty
        guard existingCategories.isEmpty else {
            print("✅ Categories already exist, skipping seed")
            return
        }
        
        print("🌱 Seeding default categories...")
        
        // Create all default categories
        let categories = [
            Category(name: "Dairy", keywords: ["milk", "cheese", "butter", "yogurt", "cream", "sour cream", "cottage cheese", "mozzarella", "cheddar", "parmesan", "feta", "gouda", "brie", "ricotta", "whipping cream", "condensed milk", "evaporated milk", "buttermilk", "custard", "kefir", "cream cheese", "mascarpone", "goat cheese", "lactose-free milk", "almond milk", "soy milk", "oat milk", "lapte", "branza", "unt", "iaurt", "smantana"], defaultUnit: "kg"),
            Category(name: "Produce", keywords: ["apple", "banana", "tomato", "lettuce", "carrot", "onion", "potato", "cucumber", "pepper", "spinach", "orange", "strawberry", "grapes", "pear", "peach", "plum", "cherry", "blueberry", "raspberry", "melon", "watermelon", "pineapple", "mango", "kiwi", "lemon", "lime", "garlic", "ginger", "avocado", "broccoli", "cauliflower", "zucchini", "eggplant", "cabbage", "kale", "beet", "radish", "mar", "rosie", "salata", "morcov", "ceapa", "cartof", "castravete", "ardei", "spanac", "portocala", "capsuna", "struguri"], defaultUnit: "kg"),
            Category(name: "Meat", keywords: ["chicken", "beef", "pork", "lamb", "turkey", "sausage", "bacon", "ham", "steak", "ground beef", "mince", "chorizo", "salami", "prosciutto", "veal", "duck", "goose", "liver", "kidney", "meatballs", "ribs", "brisket", "poultry", "rotisserie chicken", "pui", "vita", "porc", "miel", "curcan", "carnati", "sunca", "friptura", "carne tocata"], defaultUnit: "kg"),
            Category(name: "Beverages", keywords: ["water", "juice", "soda", "coffee", "tea", "beer", "wine", "coke", "sprite", "lemonade", "sparkling water", "mineral water", "energy drink", "sports drink", "iced tea", "cold brew", "espresso", "latte", "milkshake", "smoothie", "kombucha", "coconut water", "apa", "suc", "cafea", "ceai", "bere", "vin", "limonada", "apa minerala"], defaultUnit: "L"),
            Category(name: "Bakery", keywords: ["bread", "bagel", "croissant", "muffin", "cake", "pastry", "baguette", "rolls", "donuts", "buns", "sourdough", "ciabatta", "pretzel", "brownie", "scone", "tart", "pie", "pita", "flatbread", "focaccia", "naan", "brioche", "paine", "covrigi", "briose", "tort", "patiserie", "bagheta", "chifle", "gogosi"], defaultUnit: "pcs"),
            Category(name: "Frozen", keywords: ["ice cream", "frozen pizza", "frozen vegetables", "frozen fruits", "popsicle", "frozen meal", "frozen fish", "frozen chips", "frozen berries", "ice", "frozen desserts", "inghetata", "pizza congelata", "legume congelate", "fructe congelate", "peste congelat", "cartofi congelati"], defaultUnit: "pcs"),
            Category(name: "Pantry", keywords: ["pasta", "rice", "flour", "sugar", "salt", "pepper", "oil", "vinegar", "cereal", "beans", "canned", "tomato paste", "tomato sauce", "broth", "stock", "spices", "herbs", "lentils", "quinoa", "breadcrumbs", "soy sauce", "mustard", "ketchup", "mayonnaise", "peanut butter", "jam", "honey", "syrup", "coconut milk", "chickpeas", "tuna", "sardines", "paste", "orez", "faina", "zahar", "sare", "piper", "ulei", "otet", "cereale", "fasole", "conserva"], defaultUnit: "kg"),
            Category(name: "Snacks", keywords: ["chips", "crackers", "cookies", "chocolate", "candy", "popcorn", "nuts", "pretzels", "granola bar", "protein bar", "trail mix", "jerky", "rice cakes", "fruit snacks", "biscuiti", "fursecuri", "ciocolata", "dulciuri", "nuci", "covrigei"], defaultUnit: "pcs"),
            Category(name: "Personal Care", keywords: ["shampoo", "soap", "toothpaste", "deodorant", "lotion", "tissue", "toilet paper", "conditioner", "body wash", "razor", "shaving cream", "mouthwash", "cotton buds", "cotton pads", "face wash", "sunscreen", "hand sanitizer", "sampon", "sapun", "pasta de dinti", "servetele", "hartie igienica", "balsam", "gel de dus"], defaultUnit: "pcs"),
            Category(name: "Cleaning", keywords: ["detergent", "bleach", "cleaner", "sponge", "trash bags", "dish soap", "fabric softener", "laundry detergent", "all-purpose cleaner", "glass cleaner", "floor cleaner", "disinfectant", "dishwasher tablets", "scrub brush", "mop", "broom", "inalbitor", "solutie de curatat", "burete", "saci de gunoi", "balsam rufe", "dezinfectant"], defaultUnit: "pcs"),
            Category(name: "Medicine", keywords: ["aspirin", "ibuprofen", "cough syrup", "antibiotic", "allergy", "painkiller", "prescription", "cold medicine", "vitamin c", "thermometer", "antacid", "ointment", "eye drops", "nasal spray", "sirop de tuse", "analgezic", "reteta", "medicament pentru raceala", "unguent", "picaturi pentru ochi"], defaultUnit: "pcs"),
            Category(name: "Vitamins", keywords: ["vitamin", "supplement", "multivitamin", "calcium", "omega", "probiotic", "vitamin d", "iron supplement", "zinc", "fish oil", "collagen", "biotin", "vitamine", "supliment", "multivitamine", "calciu", "probiotic", "vitamina d", "supliment de fier"], defaultUnit: "pcs"),
            Category(name: "First Aid", keywords: ["bandage", "gauze", "band-aid", "antiseptic", "thermometer", "first aid", "plaster", "sterile pad", "adhesive tape", "antibiotic ointment", "tweezers", "safety pins", "bandaj", "tampon steril", "plasture", "antiseptic", "termometru", "trusa prim ajutor", "pansament steril"], defaultUnit: "pcs"),
            Category(name: "Beauty", keywords: ["makeup", "lipstick", "mascara", "foundation", "perfume", "nail polish", "skincare", "serum", "face mask", "cleanser", "toner", "body lotion", "hair oil", "hair spray", "machiaj", "ruj", "rimel", "fond de ten", "parfum", "lac de unghii", "ingrijire ten", "ser", "masca pentru fata"], defaultUnit: "pcs"),
            Category(name: "Tools", keywords: ["hammer", "screwdriver", "drill", "saw", "wrench", "pliers", "tape measure", "level", "chisel", "socket set", "utility knife", "allen key", "sandpaper", "nail gun", "ciocan", "surubelnita", "bormasina", "ferastrau", "cheie", "clesti", "ruleta", "nivela", "dalta"], defaultUnit: "pcs"),
            Category(name: "Hardware", keywords: ["screw", "nail", "bolt", "nut", "anchor", "hinge", "lock", "washer", "bracket", "shelf pin", "chain", "hook", "eye bolt", "surub", "cui", "buloan", "piulita", "ancora", "balama", "yala", "saiba", "suport", "lant", "carlig"], defaultUnit: "pcs"),
            Category(name: "Paint", keywords: ["paint", "primer", "brush", "roller", "spray paint", "stain", "varnish", "paint thinner", "paint tray", "latex paint", "oil paint", "emulsion", "vopsea", "grund", "pensula", "role", "vopsea spray", "lac", "diluant", "tava pentru vopsea"], defaultUnit: "L"),
            Category(name: "Electrical", keywords: ["wire", "cable", "outlet", "switch", "bulb", "led", "extension cord", "battery", "fuse", "circuit breaker", "plug", "adapter", "charger", "socket", "sarma", "cablu", "priza", "intrerupator", "bec", "led", "prelungitor", "baterie", "siguranta"], defaultUnit: "pcs"),
            Category(name: "Plumbing", keywords: ["pipe", "faucet", "valve", "fitting", "drain", "plunger", "sealant", "washer", "hose", "pipe cutter", "solder", "PVC pipe", "elbow fitting", "teava", "baterie lavoar", "robinet", "racord", "scurgere", "sifon", "desfundator", "etansant", "garnitura", "furtun"], defaultUnit: "pcs"),
            Category(name: "Garden", keywords: ["soil", "fertilizer", "seeds", "pot", "hose", "rake", "shovel", "gloves", "pruner", "lawn seed", "mulch", "plant food", "weed killer", "garden trowel", "watering can", "pamant", "ingrasamant", "seminte", "ghiveci", "furtun", "grebla", "lopata", "manusi", "foarfeca de gradina"], defaultUnit: "pcs")
        ]
        
        // Insert all categories
        for category in categories {
            context.insert(category)
        }
        
        // Save the context
        do {
            try context.save()
            print("✅ Successfully seeded \(categories.count) categories")
        } catch {
            print("❌ Failed to seed categories: \(error)")
        }
    }
}
