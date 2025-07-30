import SwiftUI

struct LogicaProposicionalView: View {
    @State private var proposicion: String = "(P ∧ Q) → R"
    @State private var resultado: String = "Ingrese una proposición"
    @State private var tipoProposicion: String = ""
    @State private var mostrarHistorial = false
    @State private var mostrarSimbolos = false
    @State private var historial: [String] = []
    
    let simbolos = ["∧", "∨", "→", "↔", "¬", "(", ")", "P", "Q", "R", "S"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { mostrarHistorial.toggle() }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Text("Lógica Proposicional")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: { mostrarSimbolos.toggle() }) {
                            Image(systemName: "function")
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Input field
                    TextField("Ej: (P ∧ Q) → R", text: $proposicion)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: proposicion) { _ in analizarProposicion() }
                    
                    // Symbol keyboard
                    if mostrarSimbolos {
                        symbolKeyboard
                    }
                    
                    // Results
                    if !tipoProposicion.isEmpty {
                        resultadoView
                    }
                    
                    // Buttons
                    HStack(spacing: 15) {
                        Button("Analizar", action: analizarProposicion)
                            .buttonStyle(ActionButtonStyle(color: .blue))
                        
                        Button("Limpiar", action: borrarCampos)
                            .buttonStyle(ActionButtonStyle(color: .red))
                    }
                    .padding(.horizontal)
                    
                    // Visualizations
                    visualizationsSection
                }
                .padding(.vertical)
            }
            .sheet(isPresented: $mostrarHistorial) {
                HistorialView(historial: $historial, mostrarHistorial: $mostrarHistorial)
            }
            .navigationTitle("Lógica Proposicional")
            .animation(.easeInOut, value: mostrarSimbolos)
        }
        .onAppear(perform: analizarProposicion)
    }
    
    // MARK: - Subviews
    private var symbolKeyboard: some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
        return LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(simbolos, id: \.self) { simbolo in
                Button(action: {
                    proposicion += simbolo
                    analizarProposicion()
                }) {
                    Text(simbolo)
                        .font(.title)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var resultadoView: some View {
        Text(tipoProposicionFormateada())
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                tipoProposicion.contains("Tautología") ? Color.green.opacity(0.2) :
                tipoProposicion.contains("Contradicción") ? Color.red.opacity(0.2) :
                Color.blue.opacity(0.2)
            )
            .cornerRadius(10)
            .padding(.horizontal)
    }
    
    private var visualizationsSection: some View {
        VStack(spacing: 30) {
            EnhancedTruthTableView(proposicion: proposicion, tipoProposicion: tipoProposicion)
                .frame(minHeight: 100, maxHeight: 400)
            
            EcuacionView(proposicion: proposicion, tipoProposicion: tipoProposicion)
                .frame(height: 80)
            
            TeoremaView(proposicion: proposicion, tipoProposicion: tipoProposicion)
                .frame(minHeight: 150)
        }
        .padding()
    }

    // MARK: - Logic Functions
    private func analizarProposicion() {
        guard !proposicion.isEmpty else {
            resultado = "Ingrese una proposición"
            tipoProposicion = ""
            return
        }
        
        let (esTautologia, esContradiccion) = verificarTautologiaContradiccion(proposicion)
        
        if esTautologia {
            tipoProposicion = "Tautología"
            resultado = "La proposición es siempre verdadera (1)"
        } else if esContradiccion {
            tipoProposicion = "Contradicción"
            resultado = "La proposición es siempre falsa (0)"
        } else {
            tipoProposicion = detectarTipoProposicion(proposicion)
            resultado = "Análisis: \(proposicion)\n\(explicacionTipoProposicion(tipoProposicion))"
        }
        
        guard !proposicion.isEmpty else { return }
        let entrada = "\(proposicion) → \(tipoProposicion)"
        if !historial.contains(entrada) {
            historial.append(entrada)
        }
    }
    
    private func detectarTipoProposicion(_ proposicion: String) -> String {
        let expr = proposicion.replacingOccurrences(of: " ", with: "")
        
        // Verificar primero si es una implicación
        if expr.contains("→") {
            if let (antecedente, _) = separarImplicacion(expr) {
                if antecedente.contains("(") || antecedente.contains("∧") || antecedente.contains("∨") {
                    return "Implicación Compuesta"
                }
                return "Implicación Simple"
            }
        }
        
        if expr.contains("¬") {
            if expr.contains("(") && expr.contains(")") {
                return "Negación Compuesta"
            } else {
                return "Negación Simple"
            }
        }
        
        if expr.contains("∧") {
            if expr.components(separatedBy: "∧").count > 1 {
                return "Conjunción Múltiple"
            }
            return "Conjunción"
        }
        
        if expr.contains("∨") {
            if expr.components(separatedBy: "∨").count > 1 {
                return "Disyunción Múltiple"
            }
            return "Disyunción"
        }
        
        if expr.contains("↔") {
            return "Equivalencia Lógica"
        }
        
        // Si es una sola variable
        if expr.count == 1 && expr.first?.isLetter == true {
            return "Variable Proposicional"
        }
        
        return "Proposición Compuesta"
    }
    
    private func verificarTautologiaContradiccion(_ proposicion: String) -> (Bool, Bool) {
        let variables = extraerVariables(proposicion)
        guard !variables.isEmpty else { return (false, false) }
        
        let combinaciones = generarCombinaciones(variables.count)
        var todosVerdaderos = true
        var todosFalsos = true
        
        for combinacion in combinaciones {
            let valores = Dictionary(uniqueKeysWithValues: zip(variables, combinacion))
            let resultado = evaluarProposicion(proposicion, con: valores)
            
            if !resultado { todosVerdaderos = false }
            if resultado { todosFalsos = false }
            
            if !todosVerdaderos && !todosFalsos { break }
        }
        
        return (todosVerdaderos, todosFalsos)
    }
    
    private func evaluarProposicion(_ expresion: String, con valores: [String: Bool]) -> Bool {
        var expr = expresion.replacingOccurrences(of: " ", with: "")
        
        // Reemplazar variables con valores
        for (variable, valor) in valores {
            expr = expr.replacingOccurrences(of: variable, with: valor ? "1" : "0")
        }
        
        // Función para evaluar una expresión sin paréntesis
        func evaluarExpresionSimple(_ exp: String) -> String {
            var exp = exp
            
            // Evaluar todas las negaciones primero
            while let range = exp.range(of: "¬[01()]|¬[∧∨→↔]", options: .regularExpression) {
                let nextChar = exp[exp.index(range.lowerBound, offsetBy: 1)]
                let negatedValue: String
                if nextChar == "1" {
                    negatedValue = "0"
                } else if nextChar == "0" {
                    negatedValue = "1"
                } else if nextChar == "(" {
                    // Manejar negación de paréntesis encontrando el cierre correspondiente
                    var balance = 1
                    var endIndex = exp.index(range.lowerBound, offsetBy: 2)
                    while balance != 0 && endIndex < exp.endIndex {
                        if exp[endIndex] == "(" {
                            balance += 1
                        } else if exp[endIndex] == ")" {
                            balance -= 1
                        }
                        endIndex = exp.index(endIndex, offsetBy: 1)
                    }
                    let subExpr = String(exp[exp.index(range.lowerBound, offsetBy: 1)..<endIndex])
                    let evaluated = evaluarExpresionSimple(subExpr)
                    negatedValue = evaluated == "1" ? "0" : "1"
                    exp.replaceSubrange(range.lowerBound..<endIndex, with: negatedValue)
                    continue
                } else {
                    // Si es un operador después de ¬, lo tratamos como ¬1 (caso especial)
                    negatedValue = "0"
                }
                exp.replaceSubrange(range, with: negatedValue)
            }
            
            // Evaluar paréntesis internos (por si quedan algunos)
            while let rango = exp.range(of: #"\([01∧∨→↔¬]+\)"#, options: .regularExpression) {
                let subExpr = String(exp[exp.index(rango.lowerBound, offsetBy: 1)..<exp.index(rango.upperBound, offsetBy: -1)])
                let resultado = evaluarExpresionSimple(subExpr)
                exp.replaceSubrange(rango, with: resultado)
            }
            
            // Evaluar conjunciones
            while let rango = exp.range(of: #"[01]∧[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let izquierda = partes[0] == "1"
                let derecha = partes[2] == "1"
                exp.replaceSubrange(rango, with: (izquierda && derecha) ? "1" : "0")
            }
            
            // Evaluar disyunciones
            while let rango = exp.range(of: #"[01]∨[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let izquierda = partes[0] == "1"
                let derecha = partes[2] == "1"
                exp.replaceSubrange(rango, with: (izquierda || derecha) ? "1" : "0")
            }
            
            // Evaluar implicaciones (→)
            while let rango = exp.range(of: #"[01]→[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let antecedente = partes[0] == "1"
                let consecuente = partes[2] == "1"
                // A → B es equivalente a ¬A ∨ B
                exp.replaceSubrange(rango, with: (!antecedente || consecuente) ? "1" : "0")
            }
            
            // Evaluar equivalencias (↔)
            while let rango = exp.range(of: #"[01]↔[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let izquierda = partes[0] == "1"
                let derecha = partes[2] == "1"
                exp.replaceSubrange(rango, with: (izquierda == derecha) ? "1" : "0")
            }
            
            return exp
        }
        
        // Primero evaluar todos los paréntesis anidados
        while let rango = encontrarParentesisMasInternos(expr) {
            let subExpr = String(expr[expr.index(rango.lowerBound, offsetBy: 1)..<expr.index(rango.upperBound, offsetBy: -1)])
            let resultado = evaluarExpresionSimple(subExpr)
            expr.replaceSubrange(rango, with: resultado)
        }
        
        // Evaluar la expresión completa sin paréntesis
        let resultadoFinal = evaluarExpresionSimple(expr)
        return resultadoFinal == "1"
    }
    
    private func encontrarParentesisMasInternos(_ expresion: String) -> Range<String.Index>? {
        var stack = [(index: String.Index, isOpen: Bool)]()
        var resultado: Range<String.Index>?
        
        for index in expresion.indices {
            let char = expresion[index]
            if char == "(" {
                stack.append((index: index, isOpen: true))
            } else if char == ")" {
                if let last = stack.last, last.isOpen {
                    let start = last.index
                    // Solo consideramos el par más interno (sin otros paréntesis dentro)
                    let contenido = expresion[expresion.index(after: start)..<index]
                    if !contenido.contains("(") {
                        resultado = start..<expresion.index(after: index)
                        break
                    }
                    stack.removeLast()
                }
            }
        }
        return resultado
    }
    
    private func extraerVariables(_ proposicion: String) -> [String] {
        Set(proposicion.filter { $0.isLetter && $0.isUppercase }.map { String($0) }).sorted()
    }
    
    private func generarCombinaciones(_ count: Int) -> [[Bool]] {
        guard count > 0 else { return [] }
        return (0..<(1 << count)).map { i in
            (0..<count).map { (i & (1 << $0)) != 0 }
        }
    }
    
    private func separarImplicacion(_ proposicion: String) -> (String, String)? {
        let expr = proposicion.replacingOccurrences(of: " ", with: "")
        guard let rango = expr.range(of: "→") else { return nil }
        
        let antecedente = String(expr[..<rango.lowerBound])
        let consecuente = String(expr[rango.upperBound...])
        
        return (antecedente, consecuente)
    }
    
    private func tipoProposicionFormateada() -> String {
        if tipoProposicion.contains("Tautología") { return "🔍 Es una Tautología (siempre 1)" }
        if tipoProposicion.contains("Contradicción") { return "🔍 Es una Contradicción (siempre 0)" }
        return "🔍 \(tipoProposicion)"
    }
    
    private func explicacionTipoProposicion(_ tipo: String) -> String {
        switch tipo {
        case "Implicación Simple", "Implicación Compuesta":
            return "Falsa solo cuando antecedente es verdadero y consecuente es falso"
        case "Conjunción": return "Verdadera solo cuando ambos operandos son verdaderos"
        case "Conjunción Múltiple": return "Verdadera solo cuando todas las partes son verdaderas"
        case "Disyunción": return "Falsa solo cuando ambos operandos son falsos"
        case "Disyunción Múltiple": return "Falsa solo cuando todas las partes son falsas"
        case "Equivalencia Lógica": return "Verdadera cuando ambos operandos tienen el mismo valor"
        case "Negación Simple": return "Invierte el valor (verdadero→falso, falso→verdadero)"
        case "Negación Compuesta": return "Niega una expresión compuesta"
        case "Ley de De Morgan (Conjunción)": return "¬(A ∧ B) ↔ (¬A ∨ ¬B)"
        case "Ley de De Morgan (Disyunción)": return "¬(A ∨ B) ↔ (¬A ∧ ¬B)"
        case "Ley Distributiva": return "A ∧ (B ∨ C) ↔ (A ∧ B) ∨ (A ∧ C) o A ∨ (B ∧ C) ↔ (A ∨ B) ∧ (A ∨ C)"
        case "Doble Negación": return "¬¬A ↔ A"
        case "Implicación como Disyunción": return "A → B ↔ ¬A ∨ B"
        case "Variable Proposicional": return "Variable atómica (P, Q, R...)"
        default: return "Proposición lógica compuesta"
        }
    }
    
    private func borrarCampos() {
        withAnimation {
            proposicion = ""
            resultado = "Ingrese una proposición"
            tipoProposicion = ""
        }
    }
}

struct EnhancedTruthTableView: View {
    let proposicion: String
    let tipoProposicion: String
    
    private var variables: [String] {
        Set(proposicion.filter { $0.isLetter && $0.isUppercase }.map { String($0) }).sorted()
    }
    
    private var combinaciones: [[Bool]] {
        let count = variables.count
        guard count > 0 else { return [] }
        return (0..<(1 << count)).map { i in
            (0..<count).map { (i & (1 << $0)) != 0 }
        }
    }
    
    private func evaluar(_ expresion: String, con valores: [String: Bool]) -> Bool {
        var expr = expresion.replacingOccurrences(of: " ", with: "")
        
        // Reemplazar variables con valores
        for (variable, valor) in valores {
            expr = expr.replacingOccurrences(of: variable, with: valor ? "1" : "0")
        }
        
        // Función para evaluar una expresión sin paréntesis
        func evaluarExpresionSimple(_ exp: String) -> String {
            var exp = exp
            
            // Evaluar todas las negaciones primero
            while let range = exp.range(of: "¬[01]", options: .regularExpression) {
                let valor = exp[exp.index(range.lowerBound, offsetBy: 1)] == "1"
                exp.replaceSubrange(range, with: valor ? "0" : "1")
            }
            
            // Evaluar paréntesis internos
            while let rango = exp.range(of: #"\([01∧∨→↔¬]+\)"#, options: .regularExpression) {
                let subExpr = String(exp[exp.index(rango.lowerBound, offsetBy: 1)..<exp.index(rango.upperBound, offsetBy: -1)])
                let resultado = evaluarExpresionSimple(subExpr)
                exp.replaceSubrange(rango, with: resultado)
            }
            
            // Evaluar conjunciones
            while let rango = exp.range(of: #"[01]∧[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let izquierda = partes[0] == "1"
                let derecha = partes[2] == "1"
                exp.replaceSubrange(rango, with: (izquierda && derecha) ? "1" : "0")
            }
            
            // Evaluar disyunciones
            while let rango = exp.range(of: #"[01]∨[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let izquierda = partes[0] == "1"
                let derecha = partes[2] == "1"
                exp.replaceSubrange(rango, with: (izquierda || derecha) ? "1" : "0")
            }
            
            // Evaluar implicaciones (→)
            while let rango = exp.range(of: #"[01]→[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let antecedente = partes[0] == "1"
                let consecuente = partes[2] == "1"
                exp.replaceSubrange(rango, with: (!antecedente || consecuente) ? "1" : "0")
            }
            
            // Evaluar equivalencias (↔)
            while let rango = exp.range(of: #"[01]↔[01]"#, options: .regularExpression) {
                let partes = Array(exp[rango])
                let izquierda = partes[0] == "1"
                let derecha = partes[2] == "1"
                exp.replaceSubrange(rango, with: (izquierda == derecha) ? "1" : "0")
            }
            
            return exp
        }
        
        // Primero evaluar todos los paréntesis anidados
        while let rango = encontrarParentesisMasInternos(expr) {
            let subExpr = String(expr[expr.index(rango.lowerBound, offsetBy: 1)..<expr.index(rango.upperBound, offsetBy: -1)])
            let resultado = evaluarExpresionSimple(subExpr)
            expr.replaceSubrange(rango, with: resultado)
        }
        
        // Evaluar la expresión completa sin paréntesis
        let resultadoFinal = evaluarExpresionSimple(expr)
        return resultadoFinal == "1"
    }
    
    private func encontrarParentesisMasInternos(_ expresion: String) -> Range<String.Index>? {
        var stack = [String.Index]()
        var resultado: Range<String.Index>?
        
        for index in expresion.indices {
            let char = expresion[index]
            if char == "(" {
                stack.append(index)
            } else if char == ")" {
                if let start = stack.popLast() {
                    // Solo consideramos el par más interno (sin otros paréntesis dentro)
                    let contenido = expresion[expresion.index(after: start)..<index]
                    if !contenido.contains("(") {
                        resultado = start..<expresion.index(after: index)
                        break
                    }
                }
            }
        }
        return resultado
    }
    
    var body: some View {
        VStack {
            Text("Tabla de Verdad")
                .font(.headline)
                .padding(.bottom, 5)
            
            if variables.isEmpty {
                Text("Ingrese una proposición válida")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView([.horizontal, .vertical]) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Encabezados
                        HStack(spacing: 0) {
                            ForEach(variables, id: \.self) { variable in
                                Text(variable)
                                    .frame(width: 40, height: 40)
                                    .padding(.horizontal, 4)
                                    .background(Color.blue.opacity(0.7))
                                    .foregroundColor(.white)
                                    .border(Color.white, width: 1)
                                    .fixedSize()
                            }
                            
                            Text(proposicion)
                                .frame(minWidth: CGFloat(max(150, proposicion.count * 10)))
                                .padding(.horizontal, 4)
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .border(Color.white, width: 1)
                        }
                        
                        // Filas
                        ForEach(0..<combinaciones.count, id: \.self) { i in
                            HStack(spacing: 0) {
                                let valores = Dictionary(uniqueKeysWithValues: zip(variables, combinaciones[i]))
                                
                                ForEach(variables, id: \.self) { variable in
                                    Text(valores[variable]! ? "1" : "0")
                                        .frame(width: 40, height: 40)
                                        .padding(.horizontal, 4)
                                        .background(i % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2))
                                        .border(Color.white, width: 1)
                                        .fixedSize()
                                }
                                
                                let valorFinal = evaluar(proposicion, con: valores)
                                Text(valorFinal ? "1" : "0")
                                    .frame(minWidth: CGFloat(max(150, proposicion.count * 10)))
                                    .padding(.horizontal, 4)
                                    .background(
                                        i % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.2)
                                    )
                                    .border(Color.white, width: 1)
                                    .fontWeight(.bold)
                                    .foregroundColor(
                                        tipoProposicion.contains("Tautología") ? .green :
                                        tipoProposicion.contains("Contradicción") ? .red :
                                        .primary
                                    )
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct EcuacionView: View {
    let proposicion: String
    let tipoProposicion: String
    
    var body: some View {
        VStack {
            Text("Representación Formal")
                .font(.headline)
            
            Text(ecuacionFormateada())
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    tipoProposicion.contains("Tautología") ? Color.green.opacity(0.1) :
                    tipoProposicion.contains("Contradicción") ? Color.red.opacity(0.1) :
                    Color.blue.opacity(0.1)
                )
                .cornerRadius(10)
        }
    }
    
    private func ecuacionFormateada() -> String {
        if tipoProposicion.contains("Tautología") {
            return "⊨ \(proposicion) (Tautología)"
        } else if tipoProposicion.contains("Contradicción") {
            return "⊨ ¬(\(proposicion)) (Contradicción)"
        } else if tipoProposicion.contains("Ley de De Morgan") {
            if proposicion.contains("∧") {
                let partes = proposicion.replacingOccurrences(of: "¬(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: " ∧ ")
                return "¬(\(partes[0]) ∧ \(partes[1])) ≡ (¬\(partes[0]) ∨ ¬\(partes[1]))"
            } else {
                let partes = proposicion.replacingOccurrences(of: "¬(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: " ∨ ")
                return "¬(\(partes[0]) ∨ \(partes[1])) ≡ (¬\(partes[0]) ∧ ¬\(partes[1]))"
            }
        } else if tipoProposicion.contains("Implicación") {
            if let partes = separarImplicacion(proposicion) {
                return "\(proposicion) ≡ ¬\(partes.0) ∨ \(partes.1)"
            }
        } else if tipoProposicion.contains("Doble Negación") {
            let variable = String(proposicion.dropFirst(2))
            return "¬¬\(variable) ≡ \(variable)"
        }
        return proposicion
    }
    
    private func separarImplicacion(_ proposicion: String) -> (String, String)? {
        let expr = proposicion.replacingOccurrences(of: " ", with: "")
        guard let rango = expr.range(of: "→") else { return nil }
        
        let antecedente = String(expr[..<rango.lowerBound])
        let consecuente = String(expr[rango.upperBound...])
        
        return (antecedente, consecuente)
    }
}

struct TeoremaView: View {
    let proposicion: String
    let tipoProposicion: String
    
    private struct PasoDemostracion: Identifiable {
        let id = UUID()
        let expresion: String
        let regla: String
    }
    
    private func generarDemostracion() -> [PasoDemostracion] {
        var pasos: [PasoDemostracion] = []
        let proposicionLimpia = proposicion.replacingOccurrences(of: " ", with: "")
        
        if tipoProposicion.contains("Tautología") {
            pasos.append(PasoDemostracion(expresion: proposicionLimpia, regla: "Tautología"))
            pasos.append(PasoDemostracion(expresion: "Verdadera para todas las interpretaciones", regla: "Definición"))
        } else if tipoProposicion.contains("Contradicción") {
            pasos.append(PasoDemostracion(expresion: proposicionLimpia, regla: "Contradicción"))
            pasos.append(PasoDemostracion(expresion: "Falsa para todas las interpretaciones", regla: "Definición"))
        } else if tipoProposicion.contains("Ley de De Morgan") {
            if proposicionLimpia.contains("∧") {
                let partes = proposicionLimpia.replacingOccurrences(of: "¬(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: "∧")
                pasos.append(PasoDemostracion(expresion: "¬(\(partes[0])∧\(partes[1]))", regla: "Original"))
                pasos.append(PasoDemostracion(expresion: "¬\(partes[0]) ∨ ¬\(partes[1])", regla: "De Morgan (Conjunción)"))
            } else {
                let partes = proposicionLimpia.replacingOccurrences(of: "¬(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: "∨")
                pasos.append(PasoDemostracion(expresion: "¬(\(partes[0])∨\(partes[1]))", regla: "Original"))
                pasos.append(PasoDemostracion(expresion: "¬\(partes[0]) ∧ ¬\(partes[1])", regla: "De Morgan (Disyunción)"))
            }
        } else if tipoProposicion.contains("Implicación") {
            if let partes = separarImplicacion(proposicionLimpia) {
                pasos.append(PasoDemostracion(expresion: "\(partes.0)→\(partes.1)", regla: "Original"))
                pasos.append(PasoDemostracion(expresion: "¬\(partes.0) ∨ \(partes.1)", regla: "Equivalencia Implicación"))
            }
        } else if tipoProposicion.contains("Doble Negación") {
            let variable = String(proposicionLimpia.dropFirst(2))
            pasos.append(PasoDemostracion(expresion: "¬¬\(variable)", regla: "Original"))
            pasos.append(PasoDemostracion(expresion: variable, regla: "Doble Negación"))
        } else if proposicionLimpia.contains("∧") {
            let partes = separarProposicion(proposicionLimpia, operador: "∧")
            pasos.append(PasoDemostracion(expresion: "\(partes.0)∧\(partes.1)", regla: "Original"))
            pasos.append(PasoDemostracion(expresion: "Verdadera solo si ambos son verdaderos", regla: "Def. Conjunción"))
        } else if proposicionLimpia.contains("∨") {
            let partes = separarProposicion(proposicionLimpia, operador: "∨")
            pasos.append(PasoDemostracion(expresion: "\(partes.0)∨\(partes.1)", regla: "Original"))
            pasos.append(PasoDemostracion(expresion: "Falsa solo si ambos son falsos", regla: "Def. Disyunción"))
        } else if proposicionLimpia.contains("¬") {
            let subExp = String(proposicionLimpia.dropFirst())
            pasos.append(PasoDemostracion(expresion: "¬\(subExp)", regla: "Original"))
            pasos.append(PasoDemostracion(expresion: "Invierte el valor de verdad", regla: "Def. Negación"))
        }
        
        if pasos.isEmpty {
            pasos.append(PasoDemostracion(expresion: proposicion, regla: "Proposición atómica"))
        }
        
        return pasos
    }
    
    private func separarProposicion(_ proposicion: String, operador: String) -> (String, String) {
        let partes = proposicion.components(separatedBy: operador)
        guard partes.count == 2 else { return ("", "") }
        return (partes[0], partes[1])
    }
    
    private func separarImplicacion(_ proposicion: String) -> (String, String)? {
        let partes = proposicion.components(separatedBy: "→")
        guard partes.count == 2 else { return nil }
        
        let antecedente = partes[0].hasPrefix("(") && partes[0].hasSuffix(")") ?
            String(partes[0].dropFirst().dropLast()) : partes[0]
        
        return (antecedente, partes[1])
    }
    
    var body: some View {
        VStack {
            Text("Teorema y Demostración")
                .font(.headline)
                .padding(.bottom, 5)
            
            if proposicion.isEmpty {
                Text("Ingrese una proposición para ver el teorema")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Teorema:")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text(teoremaParaProposicion())
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Demostración:")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            ForEach(generarDemostracion()) { paso in
                                VStack(alignment: .leading) {
                                    Text(paso.expresion)
                                        .font(.system(.body, design: .monospaced))
                                    Text("/\(paso.regla)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func teoremaParaProposicion() -> String {
        if tipoProposicion.contains("Tautología") {
            return "⊨ \(proposicion) (Tautología: siempre verdadera)"
        } else if tipoProposicion.contains("Contradicción") {
            return "⊨ ¬(\(proposicion)) (Contradicción: siempre falsa)"
        } else if tipoProposicion.contains("Ley de De Morgan") {
            if proposicion.contains("∧") {
                let partes = proposicion.replacingOccurrences(of: "¬(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: " ∧ ")
                return "¬(\(partes[0]) ∧ \(partes[1])) ≡ (¬\(partes[0]) ∨ ¬\(partes[1]))"
            } else {
                let partes = proposicion.replacingOccurrences(of: "¬(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .components(separatedBy: " ∨ ")
                return "¬(\(partes[0]) ∨ \(partes[1])) ≡ (¬\(partes[0]) ∧ ¬\(partes[1]))"
            }
        } else if tipoProposicion.contains("Implicación") {
            if let partes = separarImplicacion(proposicion) {
                return "\(proposicion) ≡ ¬\(partes.0) ∨ \(partes.1)"
            }
        } else if tipoProposicion.contains("Doble Negación") {
            let variable = String(proposicion.dropFirst(2))
            return "¬¬\(variable) ≡ \(variable)"
        }
        return proposicion
    }
}

struct HistorialView: View {
    @Binding var historial: [String]
    @Binding var mostrarHistorial: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historial.reversed(), id: \.self) { item in
                    Text(item)
                }
                .onDelete { indices in
                    historial.remove(atOffsets: indices)
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
            .navigationTitle("Historial")
        }
    }
}

struct ActionButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct LogicaProposicionalView_Previews: PreviewProvider {
    static var previews: some View {
        LogicaProposicionalView()
    }
}
