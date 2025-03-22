import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    // Basic sorts
    case atomicNumber = "Atomic Number"
    case name = "Element Name"
    case symbol = "Symbol"
    
    // Physical properties
    case atomicMass = "Atomic Mass"
    case density = "Density"
    case meltingPoint = "Melting Point"
    case boilingPoint = "Boiling Point"
    
    // Classification
    case category = "Category"
    case period = "Period"
    case group = "Group"
    case block = "Block (s, p, d, f)"
    case phase = "State (Solid/Liquid/Gas)"
    
    // Historical
    case discoveryDate = "Discovery Date"
    case discoveredBy = "Discovered By"
    
    var id: String { self.rawValue }
    
    // Group sort options into sections
    static var sections: [(String, [SortOption])] {
        [
            ("Basic", [.atomicNumber, .name, .symbol]),
            ("Physical Properties", [.atomicMass, .density, .meltingPoint, .boilingPoint]),
            ("Classification", [.category, .period, .group, .block, .phase]),
            ("Historical", [.discoveryDate, .discoveredBy])
        ]
    }
    
    func sortElements(_ elements: [ElementData]) -> [ElementData] {
        switch self {
        case .atomicNumber:
            return elements.sorted(by: { $0.number < $1.number })
        case .name:
            return elements.sorted(by: { $0.name < $1.name })
        case .symbol:
            return elements.sorted(by: { $0.symbol < $1.symbol })
        case .atomicMass:
            return elements.sorted(by: { $0.atomic_mass < $1.atomic_mass })
        case .density:
            // Use nil coalescing for optional values
            return elements.sorted(by: { ($0.density ?? 0) < ($1.density ?? 0) })
        case .meltingPoint:
            return elements.sorted(by: { ($0.melt ?? 0) < ($1.melt ?? 0) })
        case .boilingPoint:
            return elements.sorted(by: { ($0.boil ?? 0) < ($1.boil ?? 0) })
        case .category:
            return elements.sorted(by: { $0.category < $1.category })
        case .period:
            return elements.sorted(by: { $0.period < $1.period })
        case .group:
            return elements.sorted(by: { $0.group < $1.group })
        case .block:
            return elements.sorted(by: { $0.block < $1.block })
        case .phase:
            return elements.sorted(by: { $0.phase < $1.phase })
        case .discoveryDate, .discoveredBy:
            // Sort by discoverer name as an approximation of discovery date
            return elements.sorted(by: { 
                ($0.discovered_by ?? "") < ($1.discovered_by ?? "")
            })
        }
    }
}
