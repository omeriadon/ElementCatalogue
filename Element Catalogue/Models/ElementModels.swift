import Foundation

struct ElementData: Codable, Identifiable, Hashable {
    var id: Int { number }
    let name: String
    let appearance: String?
    let atomic_mass: Double
    let boil: Double?
    let category: String
    let density: Double?
    let discovered_by: String? // Changed to optional to handle null values
    let melt: Double?
    let molar_heat: Double?
    let named_by: String?
    let number: Int
    let period: Int
    let group: Int
    let phase: String
    let source: String
    let bohr_model_image: String?  // Changed to optional
    let bohr_model_3d: String?     // Changed to optional
    let spectral_img: String?
    let summary: String
    let symbol: String
    let xpos: Int
    let ypos: Int
    let wxpos: Int
    let wypos: Int
    let shells: [Int]
    let electron_configuration: String
    let electron_configuration_semantic: String
    let electron_affinity: Double?
    let electronegativity_pauling: Double?
    let ionization_energies: [Double]
    let cpk_hex: String?
    let image: ElementImage?
    let block: String
    
    enum CodingKeys: String, CodingKey {
        case name, appearance, atomic_mass, boil, category, density, discovered_by, melt, molar_heat
        case named_by, number, period, group, phase, source, bohr_model_image, bohr_model_3d, spectral_img
        case summary, symbol, xpos, ypos, wxpos, wypos, shells, electron_configuration
        case electron_configuration_semantic, electron_affinity, electronegativity_pauling
        case ionization_energies, block, image
        case cpk_hex = "cpk-hex"
    }
}

struct ElementImage: Codable, Hashable {
    let title: String
    let url: String
    let attribution: String
}

struct PeriodicTable: Codable {
    let elements: [ElementData]
}
