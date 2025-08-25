import SwiftUI
import SwiftData

struct FinancialsView: View {
    let location: Location
    let onDataChanged: () -> Void
    
    @State private var localFinancials: Financials?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Revenue Projection Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Revenue Projection")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", value: revenueBinding, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    if let notes = localFinancials?.revenueNotes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Cost Projection Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cost Projection")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", value: costBinding, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    if let notes = localFinancials?.costNotes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                
                // Profit Margin Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Profit Margin")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        TextField("0.00", value: profitMarginBinding, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                    
                    if let notes = localFinancials?.profitNotes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Payback Period Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Payback Period")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        TextField("0", value: paybackBinding, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("months")
                            .foregroundColor(.secondary)
                    }
                    
                    if let notes = localFinancials?.paybackNotes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                // ROI Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("ROI Percentage")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        TextField("0.00", value: roiBinding, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                    
                    if let notes = localFinancials?.roiNotes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                
                // Summary Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Financial Summary")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Net Profit:")
                            Spacer()
                            Text(formatCurrency(localFinancials?.netProfit ?? 0))
                                .foregroundColor(netProfitColor)
                        }
                        
                        HStack {
                            Text("Profit Margin:")
                            Spacer()
                            Text("\(String(format: "%.1f", localFinancials?.profitMarginPercentage ?? 0))%")
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("ROI:")
                            Spacer()
                            Text("\(String(format: "%.1f", localFinancials?.roiPercentage ?? 0))%")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Financials")
        .onAppear {
            loadFinancials()
        }
        .alert("Financials Updated", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Computed Bindings
    
    private var revenueBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.revenueProjection ?? 0.0 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.revenueProjection = newValue
                updateFinancials()
            }
        )
    }
    
    private var costBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.costProjection ?? 0.0 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.costProjection = newValue
                updateFinancials()
            }
        )
    }
    
    private var profitMarginBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.profitMargin ?? 0.0 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.profitMargin = newValue
                updateFinancials()
            }
        )
    }
    
    private var paybackBinding: Binding<Int> {
        Binding(
            get: { localFinancials?.paybackPeriod ?? 0 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.paybackPeriod = newValue
                updateFinancials()
            }
        )
    }
    
    private var roiBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.roiPercentage ?? 0.0 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.roiPercentage = newValue
                updateFinancials()
            }
        )
    }
    
    // MARK: - Helper Methods
    
    private func ensureFinancialsExist() {
        if localFinancials == nil {
            localFinancials = Financials()
        }
    }
    
    private func loadFinancials() {
        localFinancials = location.financials
    }
    
    private func updateFinancials() {
        guard let financials = localFinancials else { return }
        
        // Update the location's financials
        location.financials = financials
        
        // Save changes
        Task {
            do {
                try await saveFinancials()
                await MainActor.run {
                    onDataChanged()
                    alertMessage = "Financials updated successfully"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to update financials: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveFinancials() async throws {
        // This would typically save to your storage service
        // For now, we'll just update the local model
        print("Financials updated: \(String(describing: localFinancials))")
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return value.formatted(.currency(code: "USD"))
    }
    
    private var netProfitColor: Color {
        return localFinancials?.netProfit ?? 0 >= 0 ? .green : .red
    }
}

struct FinancialsView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        let financials = Financials()
        financials.revenueProjection = 5000.0
        financials.costProjection = 3000.0
        location.financials = financials
        
        return FinancialsView(location: location, onDataChanged: {})
    }
}
