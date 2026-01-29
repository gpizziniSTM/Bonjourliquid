import Foundation

struct ActionType: Identifiable, Equatable {
    let id: Int              // id_azione
    let name: String         // azione
    let requiresRange: Bool  // true: selezione date, false: invio immediato

    var actionId: Int { id }
    var actionName: String { name }
}
