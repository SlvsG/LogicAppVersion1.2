import SwiftUI

struct LogicaConjuntosView: View {
    // Estados para conjuntos
    @State private var conjuntosNumericos: [String] = ["3, 4, 5", "5, 6, 7"]
    @State private var universoNumerico: String = "1, 2, 3, 4, 5, 6, 7, 8, 9, 10"
    @State private var conjuntosAlfabeticos: [String] = ["a, b, c", "b, c, d", "c, d, e"]
    @State private var universoAlfabetico: String = "a, b, c, d, e, f, g, h"
    @State private var operacion: String = "Intersección"
    @State private var resultadoNumerico: Set<String> = []
    @State private var resultadoAlfabetico: Set<String> = []
    @State private var mostrarVisualizaciones = true
    @State private var mostrarHistorial = false
    @State private var historial: [String] = []
    @State private var mostrarConfigUniverso = false
    @State private var tipoEntrada = "Numérico"
    
    private let operaciones = [
        "Unión", "Intersección", "Diferencia", "Complemento",
        "Ley de Morgan 1", "Ley de Morgan 2", "Doble Negación",
        "Conmutativa Unión", "Conmutativa Intersección",
        "Asociativa Unión", "Asociativa Intersección",
        "Idempotencia Unión", "Idempotencia Intersección",
        "Contradicción", "Distributiva Unión", "Distributiva Intersección"
    ]
    
    private let tiposEntrada = ["Numérico", "Alfabético"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView()
                    
                    if mostrarConfigUniverso {
                        configuracionUniversoView()
                    }
                    
                    tipoEntradaPickerView()
                    conjuntosInputView()
                    operacionPickerView()
                    actionButtonsView()
                    resultadosView()
                    
                    if mostrarVisualizaciones {
                        visualizacionesView()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Lógica de Conjuntos")
            .sheet(isPresented: $mostrarHistorial) {
                historialView()
            }
        }
    }
    
    // MARK: - Subviews
    
    private func headerView() -> some View {
        HStack {
            Button(action: { mostrarHistorial.toggle() }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .padding(8)
            }
            
            Spacer()
            
            Button(action: { mostrarConfigUniverso.toggle() }) {
                Image(systemName: "globe")
                    .font(.title2)
                    .padding(8)
            }
        }
        .padding(.horizontal)
    }
    
    private func configuracionUniversoView() -> some View {
        VStack {
            if tipoEntrada == "Numérico" {
                HStack {
                    Text("Universo Numérico:")
                    TextField("Ej. 1, 2, 3", text: $universoNumerico)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            } else {
                HStack {
                    Text("Universo Alfabético:")
                    TextField("Ej. a, b, c", text: $universoAlfabetico)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            Button("Aplicar") {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                calcularOperacion()
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func tipoEntradaPickerView() -> some View {
        Picker("Tipo de Conjunto", selection: $tipoEntrada) {
            ForEach(tiposEntrada, id: \.self) { tipo in
                Text(tipo).tag(tipo)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .onChange(of: tipoEntrada) { _ in calcularOperacion() }
    }
    
    private func conjuntosInputView() -> some View {
        Group {
            if tipoEntrada == "Numérico" {
                ForEach(0..<conjuntosNumericos.count, id: \.self) { index in
                    HStack {
                        TextField("Conjunto \(index+1)", text: $conjuntosNumericos[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: conjuntosNumericos[index]) { _ in
                                calcularOperacion()
                            }
                        
                        if conjuntosNumericos.count > 1 {
                            Button(action: {
                                conjuntosNumericos.remove(at: index)
                                calcularOperacion()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    conjuntosNumericos.append("")
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Agregar Conjunto")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            } else {
                ForEach(0..<conjuntosAlfabeticos.count, id: \.self) { index in
                    HStack {
                        TextField("Conjunto \(index+1)", text: $conjuntosAlfabeticos[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: conjuntosAlfabeticos[index]) { _ in
                                calcularOperacion()
                            }
                        
                        if conjuntosAlfabeticos.count > 1 {
                            Button(action: {
                                conjuntosAlfabeticos.remove(at: index)
                                calcularOperacion()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    conjuntosAlfabeticos.append("")
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Agregar Conjunto")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func operacionPickerView() -> some View {
        Menu {
            ForEach(operaciones, id: \.self) { op in
                Button(action: {
                    operacion = op
                    calcularOperacion()
                }) {
                    Text(op)
                }
            }
        } label: {
            HStack {
                Text(operacion)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private func actionButtonsView() -> some View {
        HStack(spacing: 15) {
            Button(action: calcularOperacion) {
                Text("Calcular")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: borrarCampos) {
                Text("Borrar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    private func resultadosView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resultados")
                .font(.headline)
                .padding(.bottom, 5)
            
            if tipoEntrada == "Numérico" {
                Text("Numérico: \(formatearResultado(resultadoNumerico))")
                    .padding(.bottom, 10)
                
                if operacion == "Intersección" && conjuntosNumericos.count >= 2 {
                    mostrarIntersecciones(conjuntos: conjuntosNumericos, resultado: resultadoNumerico)
                        .padding(.bottom, 10)
                }
                
                if operacion == "Contradicción" {
                    mostrarContradicciones(conjuntos: conjuntosNumericos, universo: universoNumerico)
                        .padding(.bottom, 10)
                }
            } else {
                Text("Alfabético: \(formatearResultado(resultadoAlfabetico))")
                    .padding(.bottom, 10)
                
                if operacion == "Intersección" && conjuntosAlfabeticos.count >= 2 {
                    mostrarIntersecciones(conjuntos: conjuntosAlfabeticos, resultado: resultadoAlfabetico)
                        .padding(.bottom, 10)
                }
                
                if operacion == "Contradicción" {
                    mostrarContradicciones(conjuntos: conjuntosAlfabeticos, universo: universoAlfabetico)
                        .padding(.bottom, 10)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 15)
    }
    
    @ViewBuilder
    private func mostrarIntersecciones(conjuntos: [String], resultado: Set<String>) -> some View {
        let sets = conjuntos.map { limpiarConjunto($0) }
        
        ForEach(0..<sets.count, id: \.self) { i in
            ForEach(i+1..<sets.count, id: \.self) { j in
                let interseccion = sets[i].intersection(sets[j])
                if !interseccion.isEmpty {
                    Text("C\(i+1) ∩ C\(j+1) = \(formatearResultado(interseccion))")
                } else {
                    Text("C\(i+1) ∩ C\(j+1) = ∅")
                        .foregroundColor(.gray)
                }
            }
        }
        
        if conjuntos.count > 2 {
            let interseccionTotal = sets.reduce(sets[0]) { $0.intersection($1) }
            Text("Intersección total = \(formatearResultado(interseccionTotal))")
                .bold()
                .foregroundColor(interseccionTotal.isEmpty ? .gray : .primary)
        }
    }
    
    @ViewBuilder
    private func mostrarContradicciones(conjuntos: [String], universo: String) -> some View {
        let sets = conjuntos.map { limpiarConjunto($0) }
        let universalSet = limpiarConjunto(universo)
        
        VStack(alignment: .leading) {
            ForEach(0..<sets.count, id: \.self) { i in
                let complemento = universalSet.subtracting(sets[i])
                let contradiccion = sets[i].intersection(complemento)
                Text("C\(i+1) ∩ ¬C\(i+1) = \(formatearResultado(contradiccion))")
                    .foregroundColor(contradiccion.isEmpty ? .gray : .red)
            }
        }
    }
    
    private func visualizacionesView() -> some View {
        VStack(spacing: 30) {
            if tipoEntrada == "Numérico" {
                TablaPertenenciaView(
                    conjuntos: conjuntosNumericos.map { limpiarConjunto($0) },
                    resultado: resultadoNumerico,
                    operacion: operacion,
                    universo: limpiarConjunto(universoNumerico)
                )
                .frame(height: 220)
                
                DiagramaVennView(
                    conjuntos: conjuntosNumericos.map { limpiarConjunto($0) },
                    resultado: resultadoNumerico,
                    operacion: operacion,
                    universo: limpiarConjunto(universoNumerico)
                )
                .frame(height: 350)
                .padding(.horizontal, 20)
                
            } else {
                TablaPertenenciaView(
                    conjuntos: conjuntosAlfabeticos.map { limpiarConjunto($0) },
                    resultado: resultadoAlfabetico,
                    operacion: operacion,
                    universo: limpiarConjunto(universoAlfabetico)
                )
                .frame(height: 220)
                
                DiagramaVennView(
                    conjuntos: conjuntosAlfabeticos.map { limpiarConjunto($0) },
                    resultado: resultadoAlfabetico,
                    operacion: operacion,
                    universo: limpiarConjunto(universoAlfabetico)
                )
                .frame(height: 350)
                .padding(.horizontal, 20)
            }
            
            EcuacionFormalView(
                operacion: operacion,
                conjuntos: tipoEntrada == "Numérico" ? conjuntosNumericos : conjuntosAlfabeticos
            )
            .frame(height: 120)
        }
        .padding(.vertical, 15)
        .padding(.horizontal)
    }
    
    private func historialView() -> some View {
        NavigationView {
            List {
                ForEach(historial.reversed(), id: \.self) { item in
                    Text(item)
                }
                .onDelete { indices in
                    let reversedIndices = indices.map { historial.count - 1 - $0 }
                    historial.remove(atOffsets: IndexSet(reversedIndices))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Borrar") {
                        historial.removeAll()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        mostrarHistorial = false
                    }
                }
            }
            .navigationTitle("Historial (\(historial.count))")
        }
    }
    
    // MARK: - Logic Functions
    
    private func calcularOperacion() {
        if tipoEntrada == "Numérico" {
            calcularOperacionNumerica()
        } else {
            calcularOperacionAlfabetica()
        }
    }
    
    private func calcularOperacionNumerica() {
        guard !conjuntosNumericos.isEmpty else {
            resultadoNumerico = []
            return
        }
        
        let sets = conjuntosNumericos.map { limpiarConjunto($0) }
        let universal = limpiarConjunto(universoNumerico)
        
        switch operacion {
        case "Unión":
            resultadoNumerico = sets.reduce(Set<String>()) { $0.union($1) }
        case "Intersección":
            resultadoNumerico = sets.reduce(sets[0]) { $0.intersection($1) }
        case "Diferencia":
            resultadoNumerico = sets.count >= 2 ? sets[0].subtracting(sets[1]) : Set<String>()
        case "Complemento":
            resultadoNumerico = universal.subtracting(sets.first ?? Set<String>())
            
        case "Ley de Morgan 1":
            if sets.count >= 2 {
                let union = sets[0].union(sets[1])
                resultadoNumerico = universal.subtracting(union)
            } else {
                resultadoNumerico = []
            }
            
        case "Ley de Morgan 2":
            if sets.count >= 2 {
                let interseccion = sets[0].intersection(sets[1])
                resultadoNumerico = universal.subtracting(interseccion)
            } else {
                resultadoNumerico = []
            }
            
        case "Doble Negación":
            if !sets.isEmpty {
                let complemento = universal.subtracting(sets[0])
                resultadoNumerico = universal.subtracting(complemento)
            } else {
                resultadoNumerico = []
            }
            
        case "Conmutativa Unión":
            if sets.count >= 2 {
                resultadoNumerico = sets[1].union(sets[0])
            } else {
                resultadoNumerico = sets.first ?? []
            }
            
        case "Conmutativa Intersección":
            if sets.count >= 2 {
                resultadoNumerico = sets[1].intersection(sets[0])
            } else {
                resultadoNumerico = sets.first ?? []
            }
            
        case "Asociativa Unión":
            if sets.count >= 3 {
                let ladoIzq = sets[0].union(sets[1]).union(sets[2])
                let ladoDer = sets[0].union(sets[1].union(sets[2]))
                resultadoNumerico = ladoIzq
            } else if sets.count >= 2 {
                resultadoNumerico = sets[0].union(sets[1])
            } else {
                resultadoNumerico = sets.first ?? []
            }
            
        case "Asociativa Intersección":
            if sets.count >= 3 {
                let ladoIzq = sets[0].intersection(sets[1]).intersection(sets[2])
                let ladoDer = sets[0].intersection(sets[1].intersection(sets[2]))
                resultadoNumerico = ladoIzq
            } else if sets.count >= 2 {
                resultadoNumerico = sets[0].intersection(sets[1])
            } else {
                resultadoNumerico = sets.first ?? []
            }
            
        case "Idempotencia Unión":
            if !sets.isEmpty {
                resultadoNumerico = sets[0].union(sets[0])
            } else {
                resultadoNumerico = []
            }
            
        case "Idempotencia Intersección":
            if !sets.isEmpty {
                resultadoNumerico = sets[0].intersection(sets[0])
            } else {
                resultadoNumerico = []
            }
            
        case "Contradicción":
            var contradicciones: Set<String> = []
            for set in sets {
                let complemento = universal.subtracting(set)
                contradicciones.formUnion(set.intersection(complemento))
            }
            resultadoNumerico = contradicciones
            
        case "Distributiva Unión":
            if sets.count >= 3 {
                let ladoIzq = sets[0].union(sets[1].intersection(sets[2]))
                let ladoDer = (sets[0].union(sets[1])).intersection(sets[0].union(sets[2]))
                resultadoNumerico = ladoIzq
            } else {
                resultadoNumerico = []
            }
            
        case "Distributiva Intersección":
            if sets.count >= 3 {
                let ladoIzq = sets[0].intersection(sets[1].union(sets[2]))
                let ladoDer = (sets[0].intersection(sets[1])).union(sets[0].intersection(sets[2]))
                resultadoNumerico = ladoIzq
            } else {
                resultadoNumerico = []
            }
            
        default:
            resultadoNumerico = []
        }
        
        let conjuntosStr = conjuntosNumericos.enumerated().map { "\($0+1)=\($1)" }.joined(separator: ", ")
        let entrada = "[Num] \(operacion): \(conjuntosStr) → \(formatearResultado(resultadoNumerico))"
        if !historial.contains(entrada) {
            historial.append(entrada)
        }
    }
    
    private func calcularOperacionAlfabetica() {
        guard !conjuntosAlfabeticos.isEmpty else {
            resultadoAlfabetico = []
            return
        }
        
        let sets = conjuntosAlfabeticos.map { limpiarConjunto($0) }
        let universal = limpiarConjunto(universoAlfabetico)
        
        switch operacion {
        case "Unión":
            resultadoAlfabetico = sets.reduce(Set<String>()) { $0.union($1) }
        case "Intersección":
            resultadoAlfabetico = sets.reduce(sets[0]) { $0.intersection($1) }
        case "Diferencia":
            resultadoAlfabetico = sets.count >= 2 ? sets[0].subtracting(sets[1]) : Set<String>()
        case "Complemento":
            resultadoAlfabetico = universal.subtracting(sets.first ?? Set<String>())
            
        case "Ley de Morgan 1":
            if sets.count >= 2 {
                let union = sets[0].union(sets[1])
                resultadoAlfabetico = universal.subtracting(union)
            } else {
                resultadoAlfabetico = []
            }
            
        case "Ley de Morgan 2":
            if sets.count >= 2 {
                let interseccion = sets[0].intersection(sets[1])
                resultadoAlfabetico = universal.subtracting(interseccion)
            } else {
                resultadoAlfabetico = []
            }
            
        case "Doble Negación":
            if !sets.isEmpty {
                let complemento = universal.subtracting(sets[0])
                resultadoAlfabetico = universal.subtracting(complemento)
            } else {
                resultadoAlfabetico = []
            }
            
        case "Conmutativa Unión":
            if sets.count >= 2 {
                resultadoAlfabetico = sets[1].union(sets[0])
            } else {
                resultadoAlfabetico = sets.first ?? []
            }
            
        case "Conmutativa Intersección":
            if sets.count >= 2 {
                resultadoAlfabetico = sets[1].intersection(sets[0])
            } else {
                resultadoAlfabetico = sets.first ?? []
            }
            
        case "Asociativa Unión":
            if sets.count >= 3 {
                let ladoIzq = sets[0].union(sets[1]).union(sets[2])
                let ladoDer = sets[0].union(sets[1].union(sets[2]))
                resultadoAlfabetico = ladoIzq
            } else if sets.count >= 2 {
                resultadoAlfabetico = sets[0].union(sets[1])
            } else {
                resultadoAlfabetico = sets.first ?? []
            }
            
        case "Asociativa Intersección":
            if sets.count >= 3 {
                let ladoIzq = sets[0].intersection(sets[1]).intersection(sets[2])
                let ladoDer = sets[0].intersection(sets[1].intersection(sets[2]))
                resultadoAlfabetico = ladoIzq
            } else if sets.count >= 2 {
                resultadoAlfabetico = sets[0].intersection(sets[1])
            } else {
                resultadoAlfabetico = sets.first ?? []
            }
            
        case "Idempotencia Unión":
            if !sets.isEmpty {
                resultadoAlfabetico = sets[0].union(sets[0])
            } else {
                resultadoAlfabetico = []
            }
            
        case "Idempotencia Intersección":
            if !sets.isEmpty {
                resultadoAlfabetico = sets[0].intersection(sets[0])
            } else {
                resultadoAlfabetico = []
            }
            
        case "Contradicción":
            var contradicciones: Set<String> = []
            for set in sets {
                let complemento = universal.subtracting(set)
                contradicciones.formUnion(set.intersection(complemento))
            }
            resultadoAlfabetico = contradicciones
            
        case "Distributiva Unión":
            if sets.count >= 3 {
                let ladoIzq = sets[0].union(sets[1].intersection(sets[2]))
                let ladoDer = (sets[0].union(sets[1])).intersection(sets[0].union(sets[2]))
                resultadoAlfabetico = ladoIzq
            } else {
                resultadoAlfabetico = []
            }
            
        case "Distributiva Intersección":
            if sets.count >= 3 {
                let ladoIzq = sets[0].intersection(sets[1].union(sets[2]))
                let ladoDer = (sets[0].intersection(sets[1])).union(sets[0].intersection(sets[2]))
                resultadoAlfabetico = ladoIzq
            } else {
                resultadoAlfabetico = []
            }
            
        default:
            resultadoAlfabetico = []
        }
        
        let conjuntosStr = conjuntosAlfabeticos.enumerated().map { "\($0+1)=\($1)" }.joined(separator: ", ")
        let entrada = "[Alf] \(operacion): \(conjuntosStr) → \(formatearResultado(resultadoAlfabetico))"
        if !historial.contains(entrada) {
            historial.append(entrada)
        }
    }
    
    private func borrarCampos() {
        if tipoEntrada == "Numérico" {
            conjuntosNumericos = ["", ""]
            resultadoNumerico = []
        } else {
            conjuntosAlfabeticos = ["", ""]
            resultadoAlfabetico = []
        }
        operacion = "Unión"
    }
    
    private func limpiarConjunto(_ texto: String) -> Set<String> {
        Set(texto.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty })
    }
    
    private func formatearResultado(_ conjunto: Set<String>) -> String {
        conjunto.isEmpty ? "∅" : "{\(conjunto.sorted().joined(separator: ", "))}"
    }
}

// MARK: - Auxiliary Views

struct TablaPertenenciaView: View {
    let conjuntos: [Set<String>]
    let resultado: Set<String>
    let operacion: String
    let universo: Set<String>
    
    var elementos: [String] {
        if operacion == "Complemento" {
            return Array(universo).sorted()
        }
        return Array(conjuntos.reduce(Set<String>(), { $0.union($1) })).sorted()
    }
    
    var body: some View {
        VStack {
            Text("Tabla de Pertenencia")
                .font(.headline)
                .padding(.bottom, 5)
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elemento").bold()
                        ForEach(elementos, id: \.self) { elemento in
                            Text(elemento)
                        }
                    }
                    .frame(width: 70)
                    
                    ForEach(0..<conjuntos.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("∈ \(index+1)").bold()
                            ForEach(elementos, id: \.self) { elemento in
                                Text(conjuntos[index].contains(elemento) ? "✓" : "✗")
                            }
                        }
                        .frame(width: 50)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resultado").bold()
                        ForEach(elementos, id: \.self) { elemento in
                            Text(resultado.contains(elemento) ? "✓" : "✗")
                        }
                    }
                    .frame(width: 70)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct DiagramaVennView: View {
    let conjuntos: [Set<String>]
    let resultado: Set<String>
    let operacion: String
    let universo: Set<String>
    
    private let maxCircles = 6
    private let circleSize: CGFloat = 120
    private let elementFontSize: CGFloat = 10
    private let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow]
    private let elementoSize: CGFloat = 20
    
    private var elementosAMostrar: [String] {
        let todosElementos = Array(universo)
        return todosElementos.count > 20 ? Array(todosElementos.prefix(20)) : todosElementos
    }
    
    private var mostrarAdvertencia: Bool {
        universo.count > 20
    }
    
    private var esTeorema: Bool {
        operacion.contains("Ley de Morgan") ||
        operacion.contains("Conmutativa") ||
        operacion.contains("Asociativa") ||
        operacion.contains("Idempotencia") ||
        operacion.contains("Distributiva") ||
        operacion.contains("Contradicción") ||
        operacion.contains("Doble Negación")
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Diagrama de Venn")
                .font(.headline)
                .padding(.bottom, 5)
            
            if mostrarAdvertencia {
                Text("Mostrando 20 de \(universo.count) elementos")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(width: circleSize * 2.2, height: circleSize * 2.2)
                    .background(Color.gray.opacity(0.08))
                
                if esTeorema {
                    diagramaParaTeoremas()
                } else {
                    ForEach(0..<min(conjuntos.count, maxCircles), id: \.self) { index in
                        Circle()
                            .stroke(colors[index % colors.count], lineWidth: 2.5)
                            .fill(colors[index % colors.count].opacity(0.15))
                            .frame(width: circleSize, height: circleSize)
                            .offset(offsetForCircle(index: index, total: min(conjuntos.count, maxCircles)))
                    }
                    
                    ForEach(elementosAMostrar, id: \.self) { elemento in
                        let enResultado = resultado.contains(elemento)
                        let enConjuntos = conjuntos.contains { $0.contains(elemento) }
                        
                        elementoView(elemento: elemento,
                                   destacado: enResultado,
                                   enConjunto: enConjuntos)
                            .offset(positionForElement(elemento: elemento,
                                  enResult: enResultado))
                    }
                    
                    ForEach(0..<min(conjuntos.count, maxCircles), id: \.self) { index in
                        Text(labelForSet(index: index))
                            .font(.system(size: elementFontSize + 2, weight: .bold))
                            .foregroundColor(colors[index % colors.count])
                            .offset(labelOffsetForSet(index: index,
                                                     total: min(conjuntos.count, maxCircles)))
                    }
                }
                
                if resultado.isEmpty && !esTeorema {
                    Text("∅")
                        .font(.system(size: elementFontSize * 1.8, weight: .bold))
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Circle().fill(Color.white))
                }
            }
            .frame(height: 300)
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(0..<conjuntos.count, id: \.self) { index in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 14, height: 14)
                            Text("Conjunto \(index + 1)")
                                .font(.caption)
                        }
                    }
                    
                    if !resultado.isEmpty {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 14, height: 14)
                            Text("Resultado")
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private func elementoView(elemento: String, destacado: Bool, enConjunto: Bool) -> some View {
        let tamano = enConjunto ? elementoSize : elementoSize * 0.8
        let colorFondo = destacado ? Color.red : (enConjunto ? Color.blue.opacity(0.7) : Color.gray.opacity(0.7))
        
        Text(elemento)
            .font(.system(size: elementFontSize, weight: .bold))
            .frame(width: tamano, height: tamano)
            .background(Circle().fill(colorFondo))
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .foregroundColor(.white)
    }
    
    private func positionForElement(elemento: String, enResult: Bool = false) -> CGSize {
        let setsContainingElement = conjuntos.enumerated().filter { $0.element.contains(elemento) }.map { $0.offset }
        
        if enResult {
            switch operacion {
            case "Unión":
                if setsContainingElement.count > 0 {
                    return positionInUnion(setsContainingElement: setsContainingElement)
                }
            case "Intersección":
                if setsContainingElement.count == conjuntos.count {
                    return positionInIntersection()
                } else {
                    return positionInUnion(setsContainingElement: setsContainingElement)
                }
            case "Diferencia":
                if setsContainingElement.count == 1 && setsContainingElement[0] == 0 {
                    return positionInDifference()
                }
            case "Complemento":
                return positionInComplement()
            default:
                break
            }
        }
        
        guard !setsContainingElement.isEmpty else {
            let angle = Double.random(in: 0..<Double.pi * 2)
            let distance = circleSize * 1.1
            return CGSize(
                width: CGFloat(cos(angle)) * distance,
                height: CGFloat(sin(angle)) * distance
            )
        }
        
        if setsContainingElement.count > 1 {
            let total = min(conjuntos.count, maxCircles)
            let angles = setsContainingElement.map { Double($0) * (2 * Double.pi / Double(total)) - Double.pi / 2 }
            
            let avgAngle = atan2(
                angles.map { sin($0) }.reduce(0, +) / Double(angles.count),
                angles.map { cos($0) }.reduce(0, +) / Double(angles.count))
            
            let distance = circleSize * 0.2
            
            return CGSize(
                width: CGFloat(cos(avgAngle)) * distance,
                height: CGFloat(sin(avgAngle)) * distance
            )
        } else {
            let index = setsContainingElement[0]
            let total = min(conjuntos.count, maxCircles)
            let angle = Double(index) * (2 * Double.pi / Double(total)) - Double.pi / 2
            
            let distance = circleSize * 0.6
            return CGSize(
                width: CGFloat(cos(angle)) * distance,
                height: CGFloat(sin(angle)) * distance
            )
        }
    }
    
    private func positionInUnion(setsContainingElement: [Int]) -> CGSize {
        let total = min(conjuntos.count, maxCircles)
        let angles = setsContainingElement.map { Double($0) * (2 * Double.pi / Double(total)) - Double.pi / 2 }
        
        let avgAngle = atan2(
            angles.map { sin($0) }.reduce(0, +) / Double(angles.count),
            angles.map { cos($0) }.reduce(0, +) / Double(angles.count))
        
        let distance = circleSize * 0.4
        
        return CGSize(
            width: CGFloat(cos(avgAngle)) * distance,
            height: CGFloat(sin(avgAngle)) * distance
        )
    }
    
    private func positionInIntersection() -> CGSize {
        return .zero
    }
    
    private func positionInDifference() -> CGSize {
        let total = min(conjuntos.count, maxCircles)
        let angle = -Double.pi / 2
        let distance = circleSize * 0.4
        
        return CGSize(
            width: CGFloat(cos(angle)) * distance,
            height: CGFloat(sin(angle)) * distance
        )
    }
    
    private func positionInComplement() -> CGSize {
        let angle = Double.random(in: 0..<Double.pi * 2)
        let distance = circleSize * 1.1
        
        return CGSize(
            width: CGFloat(cos(angle)) * distance,
            height: CGFloat(sin(angle)) * distance
        )
    }
    
    @ViewBuilder
    private func diagramaParaTeoremas() -> some View {
        switch operacion {
        case "Contradicción":
            let circleSize1 = circleSize * 0.9
            
            Circle()
                .stroke(colors[0], lineWidth: 2.5)
                .fill(colors[0].opacity(0.2))
                .frame(width: circleSize1, height: circleSize1)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red, lineWidth: 3)
                .frame(width: circleSize * 2.1, height: circleSize * 2.1)
                .background(Color.red.opacity(0.1))
                .blendMode(.destinationOut)
            
            if !resultado.isEmpty {
                ForEach(Array(resultado), id: \.self) { elemento in
                    elementoView(elemento: elemento, destacado: true, enConjunto: true)
                        .offset(positionForElementContradiccion(elemento: elemento, sets: conjuntos, universal: universo))
                }
            } else {
                Text("∅")
                    .font(.system(size: elementFontSize * 1.8, weight: .bold))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Circle().fill(Color.white))
            }
            
            Text("A")
                .font(.system(size: elementFontSize + 2, weight: .bold))
                .foregroundColor(colors[0])
                .offset(y: -circleSize1/2 - 20)
            
            Text("¬A")
                .font(.system(size: elementFontSize + 2, weight: .bold))
                .foregroundColor(.red)
                .offset(y: circleSize1/2 + 20)
            
        default:
            ForEach(0..<min(conjuntos.count, maxCircles), id: \.self) { index in
                Circle()
                    .stroke(colors[index % colors.count], lineWidth: 2.5)
                    .fill(colors[index % colors.count].opacity(0.2))
                    .frame(width: circleSize, height: circleSize)
                    .offset(offsetForCircle(index: index, total: min(conjuntos.count, maxCircles)))
            }
            
            if !resultado.isEmpty {
                ForEach(Array(resultado), id: \.self) { elemento in
                    elementoView(elemento: elemento, destacado: true, enConjunto: true)
                        .offset(positionForElement(elemento: elemento, enResult: true))
                }
            }
        }
    }
    
    private func positionForElementContradiccion(elemento: String, sets: [Set<String>], universal: Set<String>) -> CGSize {
        guard !sets.isEmpty else { return .zero }
        
        let setA = sets[0]
        let complementoA = universal.subtracting(setA)
        
        if setA.contains(elemento) && complementoA.contains(elemento) {
            return CGSize(width: 0, height: 0)
        } else if setA.contains(elemento) {
            return CGSize(width: -circleSize/4, height: 0)
        } else if complementoA.contains(elemento) {
            let angle = Double.random(in: 0..<Double.pi * 2)
            let distance = circleSize * 0.8
            return CGSize(
                width: CGFloat(cos(angle)) * distance,
                height: CGFloat(sin(angle)) * distance
            )
        }
        
        return .zero
    }
    
    private func offsetForCircle(index: Int, total: Int) -> CGSize {
        guard total > 1 else { return .zero }
        
        let radius = circleSize / 2
        let angle = Double(index) * (2 * Double.pi / Double(total)) - Double.pi / 2
        
        return CGSize(
            width: CGFloat(cos(angle)) * radius * 0.8,
            height: CGFloat(sin(angle)) * radius * 0.8
        )
    }
    
    private func labelForSet(index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return index < letters.count ? letters[index] : "C\(index+1)"
    }
    
    private func labelOffsetForSet(index: Int, total: Int) -> CGSize {
        guard total > 1 else {
            return CGSize(width: 0, height: -circleSize/2 - 20)
        }
        
        let radius = circleSize / 2 + 25
        let angle = Double(index) * (2 * Double.pi / Double(total)) - Double.pi / 2
        
        return CGSize(
            width: CGFloat(cos(angle)) * radius,
            height: CGFloat(sin(angle)) * radius
        )
    }
}

struct EcuacionFormalView: View {
    let operacion: String
    let conjuntos: [String]
    
    var body: some View {
        VStack {
            Text("Ecuación Formal")
                .font(.headline)
                .padding(.bottom, 5)
            
            Text(ecuacionTexto())
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
    
    func ecuacionTexto() -> String {
        switch operacion {
        case "Unión":
            if conjuntos.count >= 2 {
                return "A ∪ B = {x | x ∈ A ∨ x ∈ B} = \(conjuntos[0]) ∪ \(conjuntos[1])"
            } else {
                return "A ∪ B = {x | x ∈ A ∨ x ∈ B}"
            }
            
        case "Intersección":
            if conjuntos.count >= 2 {
                return "A ∩ B = {x | x ∈ A ∧ x ∈ B} = \(conjuntos[0]) ∩ \(conjuntos[1])"
            } else {
                return "A ∩ B = {x | x ∈ A ∧ x ∈ B}"
            }
            
        case "Diferencia":
            if conjuntos.count >= 2 {
                return "A ∖ B = {x | x ∈ A ∧ x ∉ B} = \(conjuntos[0]) ∖ \(conjuntos[1])"
            } else {
                return "A ∖ B = {x | x ∈ A ∧ x ∉ B}"
            }
            
        case "Complemento":
            if !conjuntos.isEmpty {
                return "A' = {x | x ∉ A ∧ x ∈ U} = \(conjuntos[0])'"
            } else {
                return "A' = {x | x ∉ A ∧ x ∈ U}"
            }
            
        case "Ley de Morgan 1":
            if conjuntos.count >= 2 {
                return "¬(A ∪ B) = ¬A ∩ ¬B = ¬(\(conjuntos[0]) ∪ \(conjuntos[1])) = ¬\(conjuntos[0]) ∩ ¬\(conjuntos[1])"
            } else {
                return "¬(A ∪ B) = ¬A ∩ ¬B"
            }
            
        case "Ley de Morgan 2":
            if conjuntos.count >= 2 {
                return "¬(A ∩ B) = ¬A ∪ ¬B = ¬(\(conjuntos[0]) ∩ \(conjuntos[1])) = ¬\(conjuntos[0]) ∪ ¬\(conjuntos[1])"
            } else {
                return "¬(A ∩ B) = ¬A ∪ ¬B"
            }
            
        case "Doble Negación":
            if !conjuntos.isEmpty {
                return "¬¬A = A = ¬¬\(conjuntos[0]) = \(conjuntos[0])"
            } else {
                return "¬¬A = A"
            }
            
        case "Conmutativa Unión":
            if conjuntos.count >= 2 {
                return "A ∪ B = B ∪ A = \(conjuntos[0]) ∪ \(conjuntos[1]) = \(conjuntos[1]) ∪ \(conjuntos[0])"
            } else {
                return "A ∪ B = B ∪ A"
            }
            
        case "Conmutativa Intersección":
            if conjuntos.count >= 2 {
                return "A ∩ B = B ∩ A = \(conjuntos[0]) ∩ \(conjuntos[1]) = \(conjuntos[1]) ∩ \(conjuntos[0])"
            } else {
                return "A ∩ B = B ∩ A"
            }
            
        case "Asociativa Unión":
            if conjuntos.count >= 3 {
                return "(A ∪ B) ∪ C = A ∪ (B ∪ C) = (\(conjuntos[0]) ∪ \(conjuntos[1])) ∪ \(conjuntos[2]) = \(conjuntos[0]) ∪ (\(conjuntos[1]) ∪ \(conjuntos[2]))"
            } else {
                return "(A ∪ B) ∪ C = A ∪ (B ∪ C)"
            }
            
        case "Asociativa Intersección":
            if conjuntos.count >= 3 {
                return "(A ∩ B) ∩ C = A ∩ (B ∩ C) = (\(conjuntos[0]) ∩ \(conjuntos[1])) ∩ \(conjuntos[2]) = \(conjuntos[0]) ∩ (\(conjuntos[1]) ∩ \(conjuntos[2]))"
            } else {
                return "(A ∩ B) ∩ C = A ∩ (B ∩ C)"
            }
            
        case "Idempotencia Unión":
            if !conjuntos.isEmpty {
                return "A ∪ A = A = \(conjuntos[0]) ∪ \(conjuntos[0]) = \(conjuntos[0])"
            } else {
                return "A ∪ A = A"
            }
            
        case "Idempotencia Intersección":
            if !conjuntos.isEmpty {
                return "A ∩ A = A = \(conjuntos[0]) ∩ \(conjuntos[0]) = \(conjuntos[0])"
            } else {
                return "A ∩ A = A"
            }
            
        case "Contradicción":
            if !conjuntos.isEmpty {
                return "A ∩ ¬A = ∅ = \(conjuntos[0]) ∩ ¬\(conjuntos[0]) = ∅"
            } else {
                return "A ∩ ¬A = ∅"
            }
            
        case "Distributiva Unión":
            if conjuntos.count >= 3 {
                return "A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C) = \(conjuntos[0]) ∪ (\(conjuntos[1]) ∩ \(conjuntos[2])) = (\(conjuntos[0]) ∪ \(conjuntos[1])) ∩ (\(conjuntos[0]) ∪ \(conjuntos[2]))"
            } else {
                return "A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C)"
            }
            
        case "Distributiva Intersección":
            if conjuntos.count >= 3 {
                return "A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) = \(conjuntos[0]) ∩ (\(conjuntos[1]) ∪ \(conjuntos[2])) = (\(conjuntos[0]) ∩ \(conjuntos[1])) ∪ (\(conjuntos[0]) ∩ \(conjuntos[2]))"
            } else {
                return "A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C)"
            }
            
        default:
            return operacion
        }
    }
}

// MARK: - Preview
struct LogicaConjuntosView_Previews: PreviewProvider {
    static var previews: some View {
        LogicaConjuntosView()
    }
}
