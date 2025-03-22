import Foundation

class ElementService {
    static let shared = ElementService()
    
    private var elements: [ElementData] = []
    
    private init() {
        loadElements()
    }
    
    private func loadElements() {
        guard let url = Bundle.main.url(forResource: "Periodic Table JSON", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // For debugging, print a sample of the JSON data
            if let jsonString = String(data: data.prefix(1000), encoding: .utf8) {
                print("JSON preview: \(jsonString.prefix(200))...")
            }
            
            // Set decoding strategy to handle null values more gracefully
            decoder.keyDecodingStrategy = .useDefaultKeys
            decoder.dateDecodingStrategy = .deferredToDate
            
            let periodicTable = try decoder.decode(PeriodicTable.self, from: data)
            self.elements = periodicTable.elements.filter { 
                // Filter out incomplete elements that might cause issues
                !$0.name.isEmpty && $0.symbol.count > 0 
            }
            print("Successfully loaded \(self.elements.count) elements")
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key not found: \(key) - \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        } catch let DecodingError.valueNotFound(type, context) {
            print("Value not found: \(type) - \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type mismatch: \(type) - \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    func getAllElements() -> [ElementData] {
        return elements
    }
    
    func getElement(byNumber number: Int) -> ElementData? {
        return elements.first { $0.number == number }
    }
    
    func searchElements(query: String) -> [ElementData] {
        if query.isEmpty {
            return elements
        }
        
        let lowercasedQuery = query.lowercased()
        return elements.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.symbol.lowercased().contains(lowercasedQuery) ||
            String($0.number).contains(lowercasedQuery) ||
            $0.category.lowercased().contains(lowercasedQuery)
        }
    }
}
