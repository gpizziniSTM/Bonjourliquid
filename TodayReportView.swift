import SwiftUI

struct TodayReportView: View {
    @ObservedObject var viewModel: AbsenceViewModel
    
    @State private var events: [ExportTodayEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // Date range picker
            Form {
                Section(header: Text("Periodo")) {
                    DatePicker("Da", selection: $startDate, displayedComponents: .date)
                    DatePicker("A", selection: $endDate, displayedComponents: .date)
                }
                
                Section {
                    Button(action: { Task { await loadReport() } }) {
                        HStack {
                            if isLoading {
                                ProgressView().padding(.trailing, 8)
                            }
                            Text("Carica Report")
                        }
                    }
                    .disabled(isLoading)
                }
            }
            
            // Error message
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Events list
            if events.isEmpty && !isLoading {
                Text("Nessuna assenza nel periodo")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(events) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.azione)
                                    .font(.headline)
                                Text(event.user_name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(formatDate(event.data_inizio))
                                    .font(.caption)
                                if event.data_inizio != event.data_fine {
                                    Text("→ \(formatDate(event.data_fine))")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Report")
        .onAppear { Task { await loadReport() } }
    }
    
    private func loadReport() async {
        isLoading = true
        errorMessage = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)
        
        do {
            let response = try await viewModel.fetchTodayReport(
                startDate: startStr,
                endDate: endStr
            )
            self.events = response
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
        return dateString
    }
}
