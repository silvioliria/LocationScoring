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
                // Traffic & Conversion Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Traffic & Conversion")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Daily Foot Traffic:")
                            Spacer()
                            Text("\(location.generalMetrics?.footTrafficDaily ?? 0)")
                                .foregroundColor(.secondary)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        HStack {
                            Text("Capture Rate:")
                            Spacer()
                            TextField("0.05", value: capturePctBinding, format: .percent)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                        }
                        
                        if let notes = localFinancials?.capturePctNotes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Transaction Metrics Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transaction Metrics")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Days per Month:")
                            Spacer()
                            TextField("30", value: daysBinding, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                        }
                        
                        HStack {
                            Text("Avg Ticket:")
                            Spacer()
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("2.50", value: avgTicketBinding, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                        
                        if let notes = localFinancials?.avgTicketNotes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Cost Metrics Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cost Metrics")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("COGS per Vend:")
                            Spacer()
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("0.75", value: cogsBinding, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Variable Costs per Vend:")
                            Spacer()
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("0.25", value: variableCostsBinding, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                        
                        if let notes = localFinancials?.cogsNotes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let notes = localFinancials?.variableCostsNotes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                
                // Route Metrics Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Route Metrics")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Route Visit Cost:")
                            Spacer()
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("50.00", value: routeVisitCostBinding, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Visits per Month:")
                            Spacer()
                            TextField("4", value: routeVisitsBinding, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                        }
                        
                        if let notes = localFinancials?.routeVisitCostNotes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                // Financial Terms Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Financial Terms")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Host Commission:")
                            Spacer()
                            TextField("0.15", value: commissionPctBinding, format: .percent)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                        }
                        
                        HStack {
                            Text("CAPEX (Equipment):")
                            Spacer()
                            Text("$")
                                .foregroundColor(.secondary)
                            TextField("0.00", value: capexBinding, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                        
                        if let notes = localFinancials?.commissionPctNotes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                
                // Calculated Results Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Calculated Results")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Expected Transactions/Day:")
                            Spacer()
                            Text("\(String(format: "%.1f", calculatedTxDay))")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Gross Revenue/Month:")
                            Spacer()
                            Text(formatCurrency(calculatedGrossMonthly))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Product Costs/Month:")
                            Spacer()
                            Text(formatCurrency(calculatedProductCostsMonthly))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("Route Costs/Month:")
                            Spacer()
                            Text(formatCurrency(calculatedRouteCostsMonthly))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("Commission/Month:")
                            Spacer()
                            Text(formatCurrency(calculatedCommissionMonthly))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.purple)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Net Profit/Month:")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(formatCurrency(calculatedNetMonthly))
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .foregroundColor(calculatedNetMonthly >= 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Per-Vend Margin:")
                            Spacer()
                            Text("\(String(format: "%.1f", calculatedPerVendMarginPct * 100))%")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(calculatedPerVendMarginPct >= 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Break-even Tx/Day:")
                            Spacer()
                            Text("\(String(format: "%.1f", calculatedBreakevenTxDay))")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        if calculatedCapex > 0 {
                            HStack {
                                Text("Payback Period:")
                                Spacer()
                                Text("\(String(format: "%.1f", calculatedPaybackMonths)) months")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
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
    
    private var capturePctBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.capturePct ?? 0.05 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateCapturePct(newValue, notes: localFinancials?.capturePctNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var daysBinding: Binding<Int> {
        Binding(
            get: { localFinancials?.days ?? 30 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateDays(newValue, notes: localFinancials?.daysNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var avgTicketBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.avgTicket ?? 2.50 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateAvgTicket(newValue, notes: localFinancials?.avgTicketNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var cogsBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.cogs ?? 0.75 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateCogs(newValue, notes: localFinancials?.cogsNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var variableCostsBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.variableCosts ?? 0.25 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateVariableCosts(newValue, notes: localFinancials?.variableCostsNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var routeVisitCostBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.routeVisitCost ?? 50.0 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateRouteVisitCost(newValue, notes: localFinancials?.routeVisitCostNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var routeVisitsBinding: Binding<Int> {
        Binding(
            get: { localFinancials?.routeVisits ?? 4 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateRouteVisits(newValue, notes: localFinancials?.routeVisitsNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var commissionPctBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.commissionPct ?? 0.15 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateCommissionPct(newValue, notes: localFinancials?.commissionPctNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    private var capexBinding: Binding<Double> {
        Binding(
            get: { localFinancials?.capex ?? 0.0 },
            set: { newValue in
                ensureFinancialsExist()
                localFinancials?.updateCapex(newValue, notes: localFinancials?.capexNotes ?? "")
                updateFinancials()
            }
        )
    }
    
    // MARK: - Calculated Values
    
    private var calculatedTxDay: Double {
        let footTraffic = Double(location.generalMetrics?.footTrafficDaily ?? 0)
        let capturePct = localFinancials?.capturePct ?? 0.05
        return footTraffic * capturePct
    }
    
    private var calculatedGrossMonthly: Double {
        let avgTicket = localFinancials?.avgTicket ?? 2.50
        let days = Double(localFinancials?.days ?? 30)
        return avgTicket * calculatedTxDay * days
    }
    
    private var calculatedProductCostsMonthly: Double {
        let cogs = localFinancials?.cogs ?? 0.75
        let variableCosts = localFinancials?.variableCosts ?? 0.25
        let days = Double(localFinancials?.days ?? 30)
        return (cogs + variableCosts) * calculatedTxDay * days
    }
    
    private var calculatedRouteCostsMonthly: Double {
        let routeVisitCost = localFinancials?.routeVisitCost ?? 50.0
        let routeVisits = Double(localFinancials?.routeVisits ?? 4)
        return routeVisitCost * routeVisits
    }
    
    private var calculatedCommissionMonthly: Double {
        let commissionPct = localFinancials?.commissionPct ?? 0.15
        return commissionPct * calculatedGrossMonthly
    }
    
    private var calculatedNetMonthly: Double {
        return calculatedGrossMonthly - calculatedProductCostsMonthly - calculatedRouteCostsMonthly - calculatedCommissionMonthly
    }
    
    private var calculatedPerVendMarginPct: Double {
        let avgTicket = localFinancials?.avgTicket ?? 2.50
        let commissionPct = localFinancials?.commissionPct ?? 0.15
        let cogs = localFinancials?.cogs ?? 0.75
        let variableCosts = localFinancials?.variableCosts ?? 0.25
        
        guard avgTicket > 0 else { return 0.0 }
        return (avgTicket * (1 - commissionPct) - (cogs + variableCosts)) / avgTicket
    }
    
    private var calculatedBreakevenTxDay: Double {
        let days = Double(localFinancials?.days ?? 30)
        let avgTicket = localFinancials?.avgTicket ?? 2.50
        let commissionPct = localFinancials?.commissionPct ?? 0.15
        let cogs = localFinancials?.cogs ?? 0.75
        let variableCosts = localFinancials?.variableCosts ?? 0.25
        
        let denominator = days * (avgTicket * (1 - commissionPct) - (cogs + variableCosts))
        guard denominator > 0 else { return 0.0 }
        return calculatedRouteCostsMonthly / denominator
    }
    
    private var calculatedPaybackMonths: Double {
        let capex = localFinancials?.capex ?? 0.0
        let net = max(calculatedNetMonthly, 0.01) // Prevent division by zero
        return capex / net
    }
    
    private var calculatedCapex: Double {
        return localFinancials?.capex ?? 0.0
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
}

struct FinancialsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = try! ModelContainer(for: Location.self, LocationType.self, OfficeMetrics.self, GeneralMetrics.self, Financials.self, Scorecard.self, User.self, MetricDefinition.self, MetricInstance.self, LocationMetrics.self).mainContext
        
        let locationType = LocationType(type: .office)
        let location = Location(name: "Sample Office", address: "123 Main St", comment: "Test location", locationType: locationType)
        
        let generalMetrics = GeneralMetrics(footTrafficDaily: 200)
        location.generalMetrics = generalMetrics
        
        let financials = Financials()
        location.financials = financials
        
        // Insert into context
        context.insert(location)
        
        return FinancialsView(location: location, onDataChanged: {})
            .environmentObject(SharedModelContext.shared)
    }
}
