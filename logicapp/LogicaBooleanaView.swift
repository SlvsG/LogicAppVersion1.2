import SwiftUI

// MARK: - Modelos de Datos
struct LogicData {
    struct TruthTableRow: Identifiable {
        let id = UUID()
        let inputs: [String: Bool]
        let output: Bool
        let minterm: Int?
        let maxterm: Int?
    }
    
    struct MinimizedExpression: Identifiable {
        let id = UUID()
        let method: String
        let expression: String
        let steps: [String]
        let theoremUsed: String?
    }
    
    struct KarnaughMap {
        let variables: [String]
        let grid: [[Bool]]
        let groups: [KarnaughGroup]
        
        struct KarnaughGroup {
            let cells: [CellPosition]
            let isPrimeImplicant: Bool
            let term: String
            
            struct CellPosition {
                let row: Int
                let column: Int
            }
        }
    }
    
    struct LogicGate: Identifiable, Equatable {
        let id = UUID()
        let type: GateType
        let inputs: [Int]
        var position: CGPoint
        let label: String?
        
        enum GateType: String, CaseIterable {
            case and, or, not, nand, nor, xor, xnor, input, output
        }
        
        static func == (lhs: LogicGate, rhs: LogicGate) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    struct Circuit {
        let gates: [LogicGate]
        let connections: [(from: Int, to: Int)]
    }
}

// MARK: - Formas de Compuertas
struct ANDShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 15, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 15, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ORShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 15, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 15, y: rect.maxY),
            control: CGPoint(x: rect.minX - 10, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 15, y: rect.minY),
            control: CGPoint(x: rect.maxX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct NOTShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 15, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        path.addEllipse(in: CGRect(x: rect.maxX - 20, y: rect.midY - 7, width: 14, height: 14))
        return path
    }
}

struct NANDShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = ANDShape().path(in: rect)
        path.addEllipse(in: CGRect(x: rect.maxX - 20, y: rect.midY - 7, width: 14, height: 14))
        return path
    }
}

struct NORShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = ORShape().path(in: rect)
        path.addEllipse(in: CGRect(x: rect.maxX - 20, y: rect.midY - 7, width: 14, height: 14))
        return path
    }
}

struct XORShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = ORShape().path(in: rect)
        path.move(to: CGPoint(x: rect.minX + 5, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 5, y: rect.maxY),
            control: CGPoint(x: rect.minX - 15, y: rect.midY))
        return path
    }
}

struct XNORShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = XORShape().path(in: rect)
        path.addEllipse(in: CGRect(x: rect.maxX - 20, y: rect.midY - 7, width: 14, height: 14))
        return path
    }
}

// MARK: - Vista de Compuerta
struct GateShape: View {
    let type: LogicData.LogicGate.GateType
    let position: CGPoint
    let label: String?
    let isActive: Bool
    
    private var fillColor: Color {
        isActive ? activeColor.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    private var strokeColor: Color {
        isActive ? activeColor : Color.black
    }
    
    private var activeColor: Color {
        switch type {
        case .input: return .green
        case .output: return .red
        case .and, .nand: return .blue
        case .or, .nor: return .purple
        case .not: return .orange
        case .xor, .xnor: return .teal
        }
    }
    
    private var glowColor: Color {
        isActive ? activeColor.opacity(0.5) : .clear
    }
    
    @ViewBuilder
    private var gateView: some View {
        switch type {
        case .and:
            ANDShape()
                .fill(fillColor)
                .overlay(ANDShape().stroke(strokeColor, lineWidth: 2))
        case .or:
            ORShape()
                .fill(fillColor)
                .overlay(ORShape().stroke(strokeColor, lineWidth: 2))
        case .not:
            NOTShape()
                .fill(fillColor)
                .overlay(NOTShape().stroke(strokeColor, lineWidth: 2))
        case .nand:
            NANDShape()
                .fill(fillColor)
                .overlay(NANDShape().stroke(strokeColor, lineWidth: 2))
        case .nor:
            NORShape()
                .fill(fillColor)
                .overlay(NORShape().stroke(strokeColor, lineWidth: 2))
        case .xor:
            XORShape()
                .fill(fillColor)
                .overlay(XORShape().stroke(strokeColor, lineWidth: 2))
        case .xnor:
            XNORShape()
                .fill(fillColor)
                .overlay(XNORShape().stroke(strokeColor, lineWidth: 2))
        case .input, .output:
            Circle()
                .fill(fillColor)
                .overlay(Circle().stroke(strokeColor, lineWidth: 2))
        }
    }
    
    var body: some View {
        ZStack {
            gateView
                .frame(width: gateWidth, height: gateHeight)
                .shadow(color: glowColor, radius: 8)
            
            if type == .input || type == .output {
                Text(type == .input ? (label ?? "?") : "OUT")
                    .font(.system(size: type == .input ? 16 : 12, weight: .bold))
                    .foregroundColor(.black)
            }
            
            if type != .input && type != .output {
                Text(label ?? gateSymbol)
                    .font(.system(size: 12, weight: .bold))
                    .offset(y: gateHeight/2 + 15)
            }
            
            if type == .input {
                Circle()
                    .fill(isActive ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                    .offset(x: -25)
            } else if type == .output {
                Circle()
                    .fill(isActive ? Color.red : Color.gray)
                    .frame(width: 12, height: 12)
                    .offset(x: 25)
            }
        }
        .position(position)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isActive ? Color.yellow : Color.clear, lineWidth: 2)
                .frame(width: gateWidth + 10, height: gateHeight + 10)
        )
    }
    
    private var gateWidth: CGFloat {
        switch type {
        case .input, .output: return 40
        case .not: return 45
        case .and, .or: return 60
        case .nand, .nor, .xor, .xnor: return 70
        }
    }
    
    private var gateHeight: CGFloat {
        switch type {
        case .input, .output: return 40
        default: return 50
        }
    }
    
    private var gateSymbol: String {
        switch type {
        case .and: return "AND"
        case .or: return "OR"
        case .not: return "NOT"
        case .nand: return "NAND"
        case .nor: return "NOR"
        case .xor: return "XOR"
        case .xnor: return "XNOR"
        default: return ""
        }
    }
}

// MARK: - Vista del Circuito
struct CircuitView: View {
    let circuit: LogicData.Circuit?
    @Binding var inputValues: [Bool]
    @Binding var outputValue: Bool
    
    private func isGateActive(_ gate: LogicData.LogicGate) -> Bool {
        guard let circuit = circuit else { return false }
        
        if gate.type == .input {
            let inputGates = circuit.gates.filter { $0.type == .input }
            if let inputIndex = inputGates.firstIndex(of: gate) {
                return inputIndex < inputValues.count ? inputValues[inputIndex] : false
            }
            return false
        } else if gate.type == .output {
            return outputValue
        }
        
        guard let gateIndex = circuit.gates.firstIndex(of: gate) else {
            return false
        }
        
        let inputConnections = circuit.connections.filter { $0.to == gateIndex }
        var activeInputs = true
        
        for connection in inputConnections {
            let inputGate = circuit.gates[connection.from]
            if !isGateActive(inputGate) {
                activeInputs = false
                break
            }
        }
        
        return activeInputs && !inputConnections.isEmpty
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            if let circuit = circuit {
                ZStack {
                    // Dibujar conexiones primero (detrás de las compuertas)
                    ForEach(0..<circuit.connections.count, id: \.self) { index in
                        let connection = circuit.connections[index]
                        let fromGate = circuit.gates[connection.from]
                        let toGate = circuit.gates[connection.to]
                        
                        let isActive = isGateActive(fromGate)
                        
                        Path { path in
                            let startPoint = connectionStartPoint(from: fromGate)
                            let endPoint = connectionEndPoint(to: toGate)
                            
                            path.move(to: startPoint)
                            path.addLine(to: CGPoint(x: startPoint.x + 30, y: startPoint.y))
                            
                            let midY = (startPoint.y + endPoint.y) / 2
                            path.addLine(to: CGPoint(x: startPoint.x + 30, y: midY))
                            
                            path.addLine(to: CGPoint(x: endPoint.x - 30, y: midY))
                            path.addLine(to: CGPoint(x: endPoint.x - 30, y: endPoint.y))
                            path.addLine(to: endPoint)
                        }
                        .stroke(isActive ? Color.green : Color.gray, lineWidth: 2)
                        .animation(.easeInOut, value: isActive)
                        
                        // Dibujar puntos de conexión
                        let startPoint = connectionStartPoint(from: fromGate)
                        let endPoint = connectionEndPoint(to: toGate)
                        let midY = (startPoint.y + endPoint.y) / 2
                        
                        Circle()
                            .fill(isActive ? Color.green : Color.gray)
                            .frame(width: 6, height: 6)
                            .position(x: startPoint.x + 30, y: midY)
                        
                        Circle()
                            .fill(isActive ? Color.green : Color.gray)
                            .frame(width: 6, height: 6)
                            .position(x: endPoint.x - 30, y: midY)
                    }
                    
                    // Dibujar compuertas encima de las conexiones
                    ForEach(circuit.gates) { gate in
                        GateShape(
                            type: gate.type,
                            position: gate.position,
                            label: gate.label,
                            isActive: isGateActive(gate)
                        )
                        .zIndex(1)
                    }
                }
                .frame(width: 1200, height: 800)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            } else {
                Text("No se pudo generar el circuito")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
    
    private func connectionStartPoint(from gate: LogicData.LogicGate) -> CGPoint {
        switch gate.type {
        case .input: return CGPoint(x: gate.position.x + 20, y: gate.position.y)
        default: return CGPoint(x: gate.position.x + 35, y: gate.position.y)
        }
    }
    
    private func connectionEndPoint(to gate: LogicData.LogicGate) -> CGPoint {
        switch gate.type {
        case .output: return CGPoint(x: gate.position.x - 20, y: gate.position.y)
        default: return CGPoint(x: gate.position.x - 35, y: gate.position.y)
        }
    }
}

// MARK: - Analizador de Circuitos
class CircuitAnalyzer {
    let expression: String
    
    init(expression: String) {
        self.expression = expression
            .replacingOccurrences(of: "∧", with: "&")
            .replacingOccurrences(of: "∨", with: "|")
            .replacingOccurrences(of: "¬", with: "~")
            .replacingOccurrences(of: "⊕", with: "^")
            .replacingOccurrences(of: "⊼", with: "!&")
            .replacingOccurrences(of: "⊽", with: "!|")
    }
    
    func analyze() throws -> CircuitInfo {
        let tokens = try tokenize()
        let rpn = try shuntingYard(tokens: tokens)
        return try buildCircuit(from: rpn)
    }
    
    private func tokenize() throws -> [Token] {
        var tokens: [Token] = []
        var currentToken = ""
        
        for char in expression {
            if char.isWhitespace {
                if !currentToken.isEmpty {
                    tokens.append(createToken(from: currentToken))
                    currentToken = ""
                }
                continue
            }
            
            if isOp(char) || char == "(" || char == ")" || char == "⊼" || char == "⊽" {
                if !currentToken.isEmpty {
                    tokens.append(createToken(from: currentToken))
                    currentToken = ""
                }
                tokens.append(createToken(from: String(char)))
            } else {
                currentToken.append(char)
            }
        }
        
        if !currentToken.isEmpty {
            tokens.append(createToken(from: currentToken))
        }
        
        return tokens
    }
    
    private func createToken(from string: String) -> Token {
        if string == "&" || string == "∧" {
            return .op(.and)
        } else if string == "|" || string == "∨" {
            return .op(.or)
        } else if string == "~" || string == "¬" {
            return .op(.not)
        } else if string == "^" || string == "⊕" {
            return .op(.xor)
        } else if string == "!&" || string == "⊼" {
            return .op(.nand)
        } else if string == "!|" || string == "⊽" {
            return .op(.nor)
        } else if string == "(" {
            return .parenthesis(.open)
        } else if string == ")" {
            return .parenthesis(.close)
        } else {
            return .variable(string)
        }
    }
    
    private func isOp(_ char: Character) -> Bool {
        return char == "&" || char == "|" || char == "~" ||
               char == "∧" || char == "∨" || char == "¬" ||
               char == "^" || char == "⊕" || char == "⊼" || char == "⊽"
    }
    
    private func shuntingYard(tokens: [Token]) throws -> [Token] {
        var output: [Token] = []
        var operators: [Token] = []
        
        for token in tokens {
            switch token {
            case .variable:
                output.append(token)
            case .op(let op):
                while let lastOp = operators.last, case .op(let lastTokenOp) = lastOp,
                      lastTokenOp.precedence >= op.precedence {
                    output.append(operators.removeLast())
                }
                operators.append(token)
            case .parenthesis(.open):
                operators.append(token)
            case .parenthesis(.close):
                while let last = operators.last, last != .parenthesis(.open) {
                    output.append(operators.removeLast())
                }
                if operators.last == .parenthesis(.open) {
                    operators.removeLast()
                } else {
                    throw AnalysisError.mismatchedParentheses
                }
            }
        }
        
        while let last = operators.last {
            if case .parenthesis = last {
                throw AnalysisError.mismatchedParentheses
            }
            output.append(operators.removeLast())
        }
        
        return output
    }
    
    private func buildCircuit(from rpn: [Token]) throws -> CircuitInfo {
        var stack: [CircuitNode] = []
        var gates: [GateInfo] = []
        var nextGateId = 0
        
        for token in rpn {
            switch token {
            case .variable(let name):
                stack.append(.variable(name))
                
            case .op(let op):
                switch op {
                case .not:
                    guard let a = stack.popLast() else { throw AnalysisError.invalidExpression }
                    let gate = GateInfo(type: .not, inputs: [a], gateId: nextGateId)
                    gates.append(gate)
                    stack.append(.gate(nextGateId))
                    nextGateId += 1
                    
                case .and, .or, .xor, .nand, .nor:
                    guard let b = stack.popLast(), let a = stack.popLast() else {
                        throw AnalysisError.invalidExpression
                    }
                    let gateType: LogicData.LogicGate.GateType
                    switch op {
                    case .and: gateType = .and
                    case .or: gateType = .or
                    case .xor: gateType = .xor
                    case .nand: gateType = .nand
                    case .nor: gateType = .nor
                    default: gateType = .and
                    }
                    let gate = GateInfo(type: gateType, inputs: [a, b], gateId: nextGateId)
                    gates.append(gate)
                    stack.append(.gate(nextGateId))
                    nextGateId += 1
                }
                
            default:
                throw AnalysisError.invalidToken
            }
        }
        
        guard stack.count == 1, case .gate(let outputGateId) = stack.first else {
            throw AnalysisError.invalidExpression
        }
        
        return CircuitInfo(gates: gates, outputGateId: outputGateId)
    }
    
    enum Token: Equatable {
        case variable(String)
        case op(Operator)
        case parenthesis(Parenthesis)
        
        enum Operator {
            case and, or, not, xor, nand, nor
            
            var precedence: Int {
                switch self {
                case .not: return 4
                case .and, .nand: return 3
                case .or, .nor, .xor: return 2
                }
            }
        }
        
        enum Parenthesis {
            case open, close
        }
    }
    
    enum CircuitNode {
        case variable(String)
        case gate(Int)
    }
    
    struct GateInfo {
        let type: LogicData.LogicGate.GateType
        let inputs: [CircuitNode]
        let gateId: Int
    }
    
    struct CircuitInfo {
        let gates: [GateInfo]
        let outputGateId: Int
    }
    
    enum AnalysisError: Error, LocalizedError {
        case undefinedVariable(name: String)
        case mismatchedParentheses
        case invalidExpression
        case invalidToken
        
        var errorDescription: String? {
            switch self {
            case .undefinedVariable(let name):
                return "Variable no definida: \(name)"
            case .mismatchedParentheses:
                return "Paréntesis no coincidentes"
            case .invalidExpression:
                return "Expresión inválida"
            case .invalidToken:
                return "Token inválido en la expresión"
            }
        }
    }
}

// MARK: - Analizador de Expresiones Booleanas
class BooleanExpressionAnalyzer {
    let expression: String
    let variables: [String: Bool]
    
    init(expression: String, variables: [String: Bool]) {
        self.expression = expression
            .replacingOccurrences(of: "∧", with: "&")
            .replacingOccurrences(of: "∨", with: "|")
            .replacingOccurrences(of: "¬", with: "~")
            .replacingOccurrences(of: "⊕", with: "^")
            .replacingOccurrences(of: "⊼", with: "!&")
            .replacingOccurrences(of: "⊽", with: "!|")
        self.variables = variables
    }
    
    func evaluate() throws -> Bool {
        // Primero verifica si es una constante
        if expression == "1" { return true }
        if expression == "0" { return false }
        
        // Verifica variables individuales
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        if let value = variables[trimmed] {
            return value
        }
        
        // Si no es una variable simple, procede con el análisis
        let tokens = try tokenize()
        let rpn = try shuntingYard(tokens: tokens)
        return try evaluateRPN(tokens: rpn)
    }
    
    private func tokenize() throws -> [Token] {
        var tokens: [Token] = []
        var currentToken = ""
        
        for char in expression {
            if char.isWhitespace {
                if !currentToken.isEmpty {
                    tokens.append(createToken(from: currentToken))
                    currentToken = ""
                }
                continue
            }
            
            if isOp(char) || char == "(" || char == ")" || char == "⊼" || char == "⊽" {
                if !currentToken.isEmpty {
                    tokens.append(createToken(from: currentToken))
                    currentToken = ""
                }
                tokens.append(createToken(from: String(char)))
            } else {
                currentToken.append(char)
            }
        }
        
        if !currentToken.isEmpty {
            tokens.append(createToken(from: currentToken))
        }
        
        return tokens
    }
    
    private func createToken(from string: String) -> Token {
        if string == "&" || string == "∧" {
            return .op(.and)
        } else if string == "|" || string == "∨" {
            return .op(.or)
        } else if string == "~" || string == "¬" {
            return .op(.not)
        } else if string == "^" || string == "⊕" {
            return .op(.xor)
        } else if string == "!&" || string == "⊼" {
            return .op(.nand)
        } else if string == "!|" || string == "⊽" {
            return .op(.nor)
        } else if string == "(" {
            return .parenthesis(.open)
        } else if string == ")" {
            return .parenthesis(.close)
        } else {
            return .variable(string)
        }
    }
    
    private func isOp(_ char: Character) -> Bool {
        return char == "&" || char == "|" || char == "~" ||
               char == "∧" || char == "∨" || char == "¬" ||
               char == "^" || char == "⊕" || char == "⊼" || char == "⊽"
    }
    
    private func shuntingYard(tokens: [Token]) throws -> [Token] {
        var output: [Token] = []
        var operators: [Token] = []
        
        for token in tokens {
            switch token {
            case .variable:
                output.append(token)
            case .op(let op):
                while let lastOp = operators.last, case .op(let lastTokenOp) = lastOp,
                      lastTokenOp.precedence >= op.precedence {
                    output.append(operators.removeLast())
                }
                operators.append(token)
            case .parenthesis(.open):
                operators.append(token)
            case .parenthesis(.close):
                while let last = operators.last, last != .parenthesis(.open) {
                    output.append(operators.removeLast())
                }
                if operators.last == .parenthesis(.open) {
                    operators.removeLast()
                } else {
                    throw AnalysisError.mismatchedParentheses
                }
            }
        }
        
        while let last = operators.last {
            if case .parenthesis = last {
                throw AnalysisError.mismatchedParentheses
            }
            output.append(operators.removeLast())
        }
        
        return output
    }
    
    private func evaluateRPN(tokens: [Token]) throws -> Bool {
        var stack: [Bool] = []
        
        for token in tokens {
            switch token {
            case .variable(let name):
                guard let value = variables[name] else {
                    // Si la variable no está definida, asumir false
                    stack.append(false)
                    continue
                }
                stack.append(value)
            case .op(let op):
                switch op {
                case .not:
                    guard let a = stack.popLast() else { throw AnalysisError.invalidExpression }
                    stack.append(!a)
                case .and:
                    guard let b = stack.popLast(), let a = stack.popLast() else { throw AnalysisError.invalidExpression }
                    stack.append(a && b)
                case .or:
                    guard let b = stack.popLast(), let a = stack.popLast() else { throw AnalysisError.invalidExpression }
                    stack.append(a || b)
                case .xor:
                    guard let b = stack.popLast(), let a = stack.popLast() else { throw AnalysisError.invalidExpression }
                    stack.append(a != b)
                case .nand:
                    guard let b = stack.popLast(), let a = stack.popLast() else { throw AnalysisError.invalidExpression }
                    stack.append(!(a && b))
                case .nor:
                    guard let b = stack.popLast(), let a = stack.popLast() else { throw AnalysisError.invalidExpression }
                    stack.append(!(a || b))
                }
            default:
                throw AnalysisError.invalidToken
            }
        }
        
        guard stack.count == 1, let result = stack.first else {
            throw AnalysisError.invalidExpression
        }
        
        return result
    }
    
    enum Token: Equatable {
        case variable(String)
        case op(Operator)
        case parenthesis(Parenthesis)
        
        enum Operator {
            case and, or, not, xor, nand, nor
            
            var precedence: Int {
                switch self {
                case .not: return 4
                case .and, .nand: return 3
                case .or, .nor, .xor: return 2
                }
            }
        }
        
        enum Parenthesis {
            case open, close
        }
    }
    
    enum AnalysisError: Error, LocalizedError {
        case undefinedVariable(name: String)
        case mismatchedParentheses
        case invalidExpression
        case invalidToken
        
        var errorDescription: String? {
            switch self {
            case .undefinedVariable(let name):
                return "Variable no definida: \(name)"
            case .mismatchedParentheses:
                return "Paréntesis no coincidentes"
            case .invalidExpression:
                return "Expresión inválida"
            case .invalidToken:
                return "Token inválido en la expresión"
            }
        }
    }
}

// MARK: - Vista de Tabla de Verdad
struct TruthTableView: View {
    let rows: [LogicData.TruthTableRow]
    let minterms: [Int]
    let maxterms: [Int]
    let canonicalSOP: String
    let canonicalPOS: String
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 15) {
                if rows.isEmpty {
                    Text("Genera una tabla de verdad")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    truthTableSection
                    mintermsMaxtermsSection
                    canonicalFormsSection
                }
            }
            .padding()
        }
    }
    
    private var truthTableSection: some View {
        VStack(alignment: .leading) {
            Text("Tabla de Verdad")
                .font(.headline)
                .padding(.bottom, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(rows[0].inputs.keys.sorted(), id: \.self) { name in
                            Text(name)
                                .frame(width: 50, height: 40)
                                .background(Color.blue)
                                .foregroundColor(.white)
                        }
                        Text("Salida")
                            .frame(width: 60, height: 40)
                            .background(Color.green)
                            .foregroundColor(.white)
                    }
                    
                    ForEach(rows.indices, id: \.self) { index in
                        let row = rows[index]
                        HStack(spacing: 0) {
                            ForEach(row.inputs.keys.sorted(), id: \.self) { name in
                                Text(row.inputs[name]! ? "1" : "0")
                                    .frame(width: 50, height: 40)
                                    .background(Color.gray.opacity(0.1))
                            }
                            Text(row.output ? "1" : "0")
                                .frame(width: 60, height: 40)
                                .background(Color.green.opacity(0.2))
                        }
                    }
                }
            }
        }
    }
    
    private var mintermsMaxtermsSection: some View {
        VStack(alignment: .leading) {
            Text("Minitérminos & Maxitérminos")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Minitérminos (1):")
                        .foregroundColor(.orange)
                    Text(minterms.map { "m\($0)" }.joined(separator: ", "))
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Maxitérminos (0):")
                        .foregroundColor(.purple)
                    Text(maxterms.map { "M\($0)" }.joined(separator: ", "))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
        }
    }
    
    private var canonicalFormsSection: some View {
        VStack(alignment: .leading) {
            Text("Formas Canónicas")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Suma de Productos:")
                    .foregroundColor(.blue)
                Text(canonicalSOP)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Text("Producto de Sumas:")
                    .foregroundColor(.green)
                Text(canonicalPOS)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Vista de Minimización
struct MinimizationView: View {
    let expressions: [LogicData.MinimizedExpression]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if expressions.isEmpty {
                    Text("No hay resultados de minimización")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(expressions) { expr in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(expr.method)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                if let theorem = expr.theoremUsed {
                                    Spacer()
                                    Text(theorem)
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(5)
                                }
                            }
                            
                            Text(expr.expression)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            if !expr.steps.isEmpty {
                                DisclosureGroup("Mostrar pasos") {
                                    VStack(alignment: .leading, spacing: 5) {
                                        ForEach(expr.steps, id: \.self) { step in
                                            Text("• \(step)")
                                                .padding(.vertical, 2)
                                        }
                                    }
                                    .padding(.top, 5)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Vista de Mapa de Karnaugh
struct KarnaughMapView: View {
    let map: LogicData.KarnaughMap?
    
    var body: some View {
        ScrollView {
            if let map = map {
                VStack(alignment: .center, spacing: 10) {
                    Text("Mapa de Karnaugh")
                        .font(.headline)
                    
                    if map.variables.count == 5 {
                        Text("Mapa de 5 variables (mostrando primera capa)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    // Encabezados de columnas
                    HStack(spacing: 0) {
                        Text("")
                            .frame(width: 50)
                        
                        if map.variables.count == 2 {
                            Text("0").frame(width: 50)
                            Text("1").frame(width: 50)
                        } else if map.variables.count == 3 {
                            Text("00").frame(width: 50)
                            Text("01").frame(width: 50)
                            Text("11").frame(width: 50)
                            Text("10").frame(width: 50)
                        } else if map.variables.count >= 4 {
                            Text("00").frame(width: 50)
                            Text("01").frame(width: 50)
                            Text("11").frame(width: 50)
                            Text("10").frame(width: 50)
                        }
                    }
                    
                    // Filas del mapa
                    ForEach(0..<map.grid.count, id: \.self) { row in
                        HStack(spacing: 0) {
                            // Etiqueta de fila
                            if map.variables.count == 2 {
                                Text(row == 0 ? "0" : "1").frame(width: 50)
                            } else if map.variables.count == 3 {
                                Text(row == 0 ? "0" : "1").frame(width: 50)
                            } else if map.variables.count >= 4 {
                                let labels = ["00", "01", "11", "10"]
                                Text(labels[row]).frame(width: 50)
                            }
                            
                            // Celdas del mapa
                            ForEach(0..<map.grid[row].count, id: \.self) { column in
                                ZStack {
                                    Text(map.grid[row][column] ? "1" : "0")
                                        .frame(width: 50, height: 50)
                                        .background(map.grid[row][column] ? Color.green.opacity(0.3) : Color.red.opacity(0.1))
                                        .border(Color.gray, width: 0.5)
                                    
                                    if let group = map.groups.first(where: { $0.cells.contains(where: { $0.row == row && $0.column == column }) }) {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(group.isPrimeImplicant ? Color.blue : Color.orange, lineWidth: 2)
                                            .frame(width: 48, height: 48)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Leyenda de grupos
                    if !map.groups.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Grupos identificados:")
                                .font(.subheadline)
                                .padding(.top)
                            
                            ForEach(map.groups, id: \.term) { group in
                                HStack {
                                    Circle()
                                        .fill(group.isPrimeImplicant ? Color.blue : Color.orange)
                                        .frame(width: 10, height: 10)
                                    Text(group.term)
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Explicación de variables
                    if map.variables.count >= 3 {
                        VStack(alignment: .leading) {
                            Text("Codificación:")
                                .font(.subheadline)
                                .padding(.top)
                            
                            if map.variables.count == 3 {
                                Text("Filas: \(map.variables[0])")
                                Text("Columnas: \(map.variables[1]) y \(map.variables[2])")
                            } else if map.variables.count == 4 {
                                Text("Filas: \(map.variables[0]) y \(map.variables[1])")
                                Text("Columnas: \(map.variables[2]) y \(map.variables[3])")
                            } else if map.variables.count == 5 {
                                Text("Filas: \(map.variables[0]) y \(map.variables[1])")
                                Text("Columnas: \(map.variables[2]) y \(map.variables[3])")
                                Text("Capa: \(map.variables[4]) (0 = primera capa, 1 = segunda capa)")
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            } else {
                Text("El mapa de Karnaugh solo está disponible para 2 a 5 variables")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}

// MARK: - Vista Principal
struct BooleanLogicView: View {
    @State private var expression = "A⊼B"  // Ejemplo inicial con NAND
    @State private var variables: [String: Bool] = [:]
    @State private var truthTable: [LogicData.TruthTableRow] = []
    @State private var minimizedExpressions: [LogicData.MinimizedExpression] = []
    @State private var karnaughMap: LogicData.KarnaughMap?
    @State private var circuit: LogicData.Circuit?
    @State private var selectedTab = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCircuitSimulator = false
    @State private var showSymbolPalette = false
    @State private var minterms: [Int] = []
    @State private var maxterms: [Int] = []
    @State private var canonicalSOP = ""
    @State private var canonicalPOS = ""
    @State private var inputValues: [Bool] = []
    @State private var outputValue = false
    
    private let tabs = ["Tabla de Verdad", "Minimización", "Karnaugh", "Circuito"]
    private let maxVariables = 5
    private let paletteSymbols = ["A", "B", "C", "D", "E", "∧", "∨", "¬", "⊕", "⊼", "⊽", "(", ")", "[", "]", "{", "}"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                expressionInputView
                variablesPanel
                tabSelector
                tabContent
            }
            .navigationTitle("Lógica Booleana")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showCircuitSimulator.toggle() }) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 18))
                        }
                        
                        Button(action: { showSymbolPalette.toggle() }) {
                            Image(systemName: "function")
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showCircuitSimulator) {
                circuitSimulator
            }
            .sheet(isPresented: $showSymbolPalette) {
                symbolPaletteView
            }
            .onAppear {
                extractVariables()
                evaluate()
            }
            .onChange(of: expression) { _ in
                extractVariables()
                evaluate()
            }
        }
    }
    
    // MARK: - Componentes de UI
    private var expressionInputView: some View {
        HStack(spacing: 10) {
            Button(action: clearAll) {
                Image(systemName: "trash")
                    .padding(8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            TextField("Ej: A⊼B", text: $expression)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(.body, design: .monospaced))
                .keyboardType(.asciiCapable)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button(action: evaluate) {
                Image(systemName: "play.fill")
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    private var variablesPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(variables.keys.sorted(), id: \.self) { variable in
                    VStack {
                        Text(variable)
                            .font(.headline)
                        Toggle("", isOn: Binding(
                            get: { self.variables[variable] ?? false },
                            set: { self.variables[variable] = $0 }
                        ))
                        .labelsHidden()
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if variables.count < maxVariables {
                    Button(action: addVariable) {
                        Image(systemName: "plus")
                            .padding(8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var tabSelector: some View {
        Picker("", selection: $selectedTab) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Text(tabs[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case 0:
                TruthTableView(rows: truthTable, minterms: minterms, maxterms: maxterms, canonicalSOP: canonicalSOP, canonicalPOS: canonicalPOS)
            case 1:
                MinimizationView(expressions: minimizedExpressions)
            case 2:
                KarnaughMapView(map: karnaughMap)
            case 3:
                CircuitView(circuit: circuit, inputValues: $inputValues, outputValue: $outputValue)
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var symbolPaletteView: some View {
        VStack {
            Text("Símbolos Lógicos")
                .font(.headline)
                .padding()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(paletteSymbols, id: \.self) { symbol in
                    Button(action: {
                        self.expression += symbol
                    }) {
                        Text(symbol)
                            .font(.title)
                            .frame(width: 50, height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            
            Button("Cerrar") {
                showSymbolPalette = false
            }
            .padding()
        }
    }
    
    private var circuitSimulator: some View {
        VStack {
            if circuit != nil {
                CircuitView(circuit: circuit, inputValues: $inputValues, outputValue: $outputValue)
                    .padding()
                
                inputControls
                outputDisplay
            }
        }
        .navigationTitle("Simulador de Circuito")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cerrar") { showCircuitSimulator = false }
            }
        }
        .onAppear {
            setupInputs()
        }
    }
    
    private var inputControls: some View {
        VStack {
            if let circuit = circuit {
                ForEach(0..<inputValues.count, id: \.self) { index in
                    HStack {
                        Text("Entrada \(index + 1):")
                        Toggle(isOn: $inputValues[index]) {
                            Text(inputValues[index] ? "1" : "0")
                        }
                        .onChange(of: inputValues[index]) { _ in
                            simulateCircuit()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var outputDisplay: some View {
        HStack {
            Text("Salida:")
                .font(.headline)
            Text(outputValue ? "1" : "0")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(outputValue ? .green : .red)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
    
    // MARK: - Lógica de Negocio
    private func extractVariables() {
        let pattern = "[A-Za-z]"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        
        let matches = regex.matches(
            in: expression,
            range: NSRange(expression.startIndex..., in: expression))
        
        var newVariables: [String: Bool] = [:]
        for match in matches {
            if let range = Range(match.range, in: expression) {
                let variable = String(expression[range]).uppercased()
                newVariables[variable] = variables[variable] ?? false
            }
        }
        
        variables = newVariables
    }
    
    private func clearAll() {
        expression = ""
        variables = [:]
        truthTable = []
        minimizedExpressions = []
        karnaughMap = nil
        circuit = nil
        minterms = []
        maxterms = []
        canonicalSOP = ""
        canonicalPOS = ""
        inputValues = []
        outputValue = false
    }
    
    private func addVariable() {
        guard variables.count < maxVariables else { return }
        
        // Encuentra la próxima letra disponible
        let existingLetters = Set(variables.keys)
        for ascii in 65..<(65+26) { // A-Z
            let letter = String(UnicodeScalar(ascii)!)
            if !existingLetters.contains(letter) {
                variables[letter] = false
                evaluate()
                return
            }
        }
    }
    
    private func evaluate() {
        do {
            try generateTruthTable()
            try findMintermsMaxterms()
            try generateCanonicalForms()
            try minimizeExpressions()
            try generateKarnaughMap()
            try generateCircuit()
            showError = false
        } catch {
            // No mostramos errores para variables no definidas
            if !error.localizedDescription.contains("undefined") {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func generateTruthTable() throws {
        let variableNames = variables.keys.sorted()
        guard !variableNames.isEmpty else {
            throw NSError(domain: "No hay variables", code: 0, userInfo: [NSLocalizedDescriptionKey: "Se requiere al menos una variable"])
        }
        
        var table: [LogicData.TruthTableRow] = []
        let rowCount = Int(pow(2, Double(variableNames.count)))
        
        for i in 0..<rowCount {
            var inputs: [String: Bool] = [:]
            for (index, name) in variableNames.enumerated() {
                let bitPosition = variableNames.count - 1 - index
                inputs[name] = (i >> bitPosition) & 1 == 1
            }
            
            let analyzer = BooleanExpressionAnalyzer(expression: expression, variables: inputs)
            let output = try analyzer.evaluate()
            let minterm = output ? i : nil
            let maxterm = output ? nil : i
            table.append(LogicData.TruthTableRow(inputs: inputs, output: output, minterm: minterm, maxterm: maxterm))
        }
        
        truthTable = table
    }
    
    private func findMintermsMaxterms() throws {
        minterms = truthTable.indices.filter { truthTable[$0].output }
        maxterms = truthTable.indices.filter { !truthTable[$0].output }
    }
    
    private func generateCanonicalForms() throws {
        let variableNames = variables.keys.sorted()
        
        // Suma de Productos (minterms)
        var sopTerms: [String] = []
        for minterm in minterms {
            var term: [String] = []
            for (i, varName) in variableNames.enumerated() {
                let bitPosition = variableNames.count - 1 - i
                let isPositive = (minterm >> bitPosition) & 1 == 1
                term.append(isPositive ? varName : "¬\(varName)")
            }
            sopTerms.append(term.joined(separator: " ∧ "))
        }
        canonicalSOP = sopTerms.joined(separator: " ∨ ")
        
        // Producto de Sumas (maxterms)
        var posTerms: [String] = []
        for maxterm in maxterms {
            var term: [String] = []
            for (i, varName) in variableNames.enumerated() {
                let bitPosition = variableNames.count - 1 - i
                let isPositive = (maxterm >> bitPosition) & 1 == 1
                term.append(isPositive ? "¬\(varName)" : varName)
            }
            posTerms.append("(\(term.joined(separator: " ∨ ")))")
        }
        canonicalPOS = posTerms.joined(separator: " ∧ ")
    }
    
    private func minimizeExpressions() throws {
        var results: [LogicData.MinimizedExpression] = []
        let variableNames = variables.keys.sorted()
        
        // Formas canónicas
        results.append(LogicData.MinimizedExpression(
            method: "Suma de Productos (Canónica)",
            expression: canonicalSOP,
            steps: ["Minitérminos: \(minterms.map { String($0) }.joined(separator: ", "))"],
            theoremUsed: nil
        ))
        
        results.append(LogicData.MinimizedExpression(
            method: "Producto de Sumas (Canónica)",
            expression: canonicalPOS,
            steps: ["Maxitérminos: \(maxterms.map { String($0) }.joined(separator: ", "))"],
            theoremUsed: nil
        ))
        
        // Minimización básica basada en teoremas
        if expression.contains("∧") && expression.contains("∨") {
            // Teorema de absorción: A ∨ (A ∧ B) = A
            if let absorbed = applyAbsorptionTheorem(expression: expression) {
                results.append(LogicData.MinimizedExpression(
                    method: "Teorema de Absorción",
                    expression: absorbed,
                    steps: ["A ∨ (A ∧ B) = A"],
                    theoremUsed: "Absorción"
                ))
            }
            
            // Teorema de De Morgan
            if let demorgan = applyDeMorganTheorem(expression: expression) {
                results.append(LogicData.MinimizedExpression(
                    method: "Teorema de De Morgan",
                    expression: demorgan,
                    steps: ["¬(A ∧ B) = ¬A ∨ ¬B", "¬(A ∨ B) = ¬A ∧ ¬B"],
                    theoremUsed: "De Morgan"
                ))
            }
        }
        
        // Minimización con mapa de Karnaugh (si es posible)
        if variableNames.count <= 5 {
            if let minimizedKarnaugh = try minimizeWithKarnaugh() {
                results.append(minimizedKarnaugh)
            }
        }
        
        minimizedExpressions = results
    }
    
    private func applyAbsorptionTheorem(expression: String) -> String? {
        let patterns = [
            "([A-Z])\\s∨\\s\\(\\1\\s∧\\s([A-Z])\\)": "$1",
            "\\(([A-Z])\\s∧\\s([A-Z])\\)\\s∨\\s\\1": "$1"
        ]
        
        var result = expression
        var changed = false
        
        for (pattern, template) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(location: 0, length: result.utf16.count)
                let newResult = regex.stringByReplacingMatches(in: result, range: range, withTemplate: template)
                if newResult != result {
                    changed = true
                    result = newResult
                }
            }
        }
        
        return changed ? result : nil
    }
    
    private func applyDeMorganTheorem(expression: String) -> String? {
        var changed = false
        var result = expression
        
        // ¬(A ∧ B) → ¬A ∨ ¬B
        let pattern1 = "¬\\(([A-Z])\\s∧\\s([A-Z])\\)"
        if let regex1 = try? NSRegularExpression(pattern: pattern1) {
            let range = NSRange(location: 0, length: result.utf16.count)
            result = regex1.stringByReplacingMatches(in: result, range: range, withTemplate: "¬$1 ∨ ¬$2")
            changed = true
        }
        
        // ¬(A ∨ B) → ¬A ∧ ¬B
        let pattern2 = "¬\\(([A-Z])\\s∨\\s([A-Z])\\)"
        if let regex2 = try? NSRegularExpression(pattern: pattern2) {
            let range = NSRange(location: 0, length: result.utf16.count)
            result = regex2.stringByReplacingMatches(in: result, range: range, withTemplate: "¬$1 ∧ ¬$2")
            changed = true
        }
        
        return changed ? result : nil
    }
    
    private func minimizeWithKarnaugh() throws -> LogicData.MinimizedExpression? {
        guard let map = karnaughMap else { return nil }
        let variableNames = variables.keys.sorted()
        
        if variableNames.count == 2 {
            var groups: [String] = []
            
            if map.grid.flatMap({ $0 }).filter({ $0 }).count == 4 {
                return LogicData.MinimizedExpression(
                    method: "Mapa de Karnaugh",
                    expression: "1",
                    steps: ["Todos los unos están agrupados"],
                    theoremUsed: "Karnaugh"
                )
            }
            
            for row in 0..<map.grid.count {
                for column in 0..<map.grid[row].count-1 {
                    if map.grid[row][column] && map.grid[row][column+1] {
                        let term = row == 0 ? "¬\(variableNames[1])" : variableNames[1]
                        groups.append(term)
                    }
                }
            }
            
            for column in 0..<map.grid[0].count {
                for row in 0..<map.grid.count-1 {
                    if map.grid[row][column] && map.grid[row+1][column] {
                        let term = column == 0 ? "¬\(variableNames[0])" : variableNames[0]
                        groups.append(term)
                    }
                }
            }
            
            if !groups.isEmpty {
                return LogicData.MinimizedExpression(
                    method: "Mapa de Karnaugh",
                    expression: groups.joined(separator: " ∨ "),
                    steps: ["Grupos: \(groups.joined(separator: ", "))"],
                    theoremUsed: "Karnaugh"
                )
            }
        } else if variableNames.count == 3 || variableNames.count == 4 || variableNames.count == 5 {
            // Implementación básica para 3, 4 y 5 variables
            var groups: [String] = []
            
            for group in map.groups {
                groups.append(group.term)
            }
            
            if !groups.isEmpty {
                return LogicData.MinimizedExpression(
                    method: "Mapa de Karnaugh",
                    expression: groups.joined(separator: " ∨ "),
                    steps: ["Grupos identificados: \(groups.joined(separator: ", "))"],
                    theoremUsed: "Karnaugh"
                )
            }
        }
        
        return nil
    }
    
    private func generateKarnaughMap() throws {
        let variableNames = variables.keys.sorted()
        guard !variableNames.isEmpty else { return }
        
        if variableNames.count == 2 {
            let grid = [
                [truthTable[0].output, truthTable[1].output],
                [truthTable[2].output, truthTable[3].output]
            ]
            
            var groups: [LogicData.KarnaughMap.KarnaughGroup] = []
            
            if grid[0][0] && grid[0][1] {
                groups.append(LogicData.KarnaughMap.KarnaughGroup(
                    cells: [
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 0),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 1)
                    ],
                    isPrimeImplicant: true,
                    term: "¬\(variableNames[1])"
                ))
            }
            
            if grid[1][0] && grid[1][1] {
                groups.append(LogicData.KarnaughMap.KarnaughGroup(
                    cells: [
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 1, column: 0),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 1, column: 1)
                    ],
                    isPrimeImplicant: true,
                    term: variableNames[1]
                ))
            }
            
            karnaughMap = LogicData.KarnaughMap(variables: variableNames, grid: grid, groups: groups)
        } else if variableNames.count == 3 {
            // Mapa de Karnaugh para 3 variables (2x4)
            let grid = [
                [truthTable[0].output, truthTable[1].output, truthTable[3].output, truthTable[2].output],
                [truthTable[4].output, truthTable[5].output, truthTable[7].output, truthTable[6].output]
            ]
            
            var groups: [LogicData.KarnaughMap.KarnaughGroup] = []
            
            if grid[0][0] && grid[0][1] {
                groups.append(LogicData.KarnaughMap.KarnaughGroup(
                    cells: [
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 0),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 1)
                    ],
                    isPrimeImplicant: true,
                    term: "¬\(variableNames[0]) ∧ ¬\(variableNames[2])"
                ))
            }
            
            karnaughMap = LogicData.KarnaughMap(variables: variableNames, grid: grid, groups: groups)
        } else if variableNames.count == 4 {
            // Mapa de Karnaugh para 4 variables (4x4)
            let grid = [
                [truthTable[0].output, truthTable[1].output, truthTable[3].output, truthTable[2].output],
                [truthTable[4].output, truthTable[5].output, truthTable[7].output, truthTable[6].output],
                [truthTable[12].output, truthTable[13].output, truthTable[15].output, truthTable[14].output],
                [truthTable[8].output, truthTable[9].output, truthTable[11].output, truthTable[10].output]
            ]
            
            var groups: [LogicData.KarnaughMap.KarnaughGroup] = []
            
            if grid[0][0] && grid[0][1] && grid[1][0] && grid[1][1] {
                groups.append(LogicData.KarnaughMap.KarnaughGroup(
                    cells: [
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 0),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 1),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 1, column: 0),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 1, column: 1)
                    ],
                    isPrimeImplicant: true,
                    term: "¬\(variableNames[0]) ∧ ¬\(variableNames[1])"
                ))
            }
            
            karnaughMap = LogicData.KarnaughMap(variables: variableNames, grid: grid, groups: groups)
        } else if variableNames.count == 5 {
            // Mapa de Karnaugh para 5 variables (dos mapas de 4x4)
            let layer1 = [
                [truthTable[0].output, truthTable[1].output, truthTable[3].output, truthTable[2].output],
                [truthTable[4].output, truthTable[5].output, truthTable[7].output, truthTable[6].output],
                [truthTable[12].output, truthTable[13].output, truthTable[15].output, truthTable[14].output],
                [truthTable[8].output, truthTable[9].output, truthTable[11].output, truthTable[10].output]
            ]
            
            let layer2 = [
                [truthTable[16].output, truthTable[17].output, truthTable[19].output, truthTable[18].output],
                [truthTable[20].output, truthTable[21].output, truthTable[23].output, truthTable[22].output],
                [truthTable[28].output, truthTable[29].output, truthTable[31].output, truthTable[30].output],
                [truthTable[24].output, truthTable[25].output, truthTable[27].output, truthTable[26].output]
            ]
            
            // Para simplificar, mostramos solo la primera capa en la vista
            var groups: [LogicData.KarnaughMap.KarnaughGroup] = []
            
            // Identificar grupos en la primera capa
            if layer1[0][0] && layer1[0][1] && layer1[1][0] && layer1[1][1] {
                groups.append(LogicData.KarnaughMap.KarnaughGroup(
                    cells: [
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 0),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 1),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 1, column: 0),
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 1, column: 1)
                    ],
                    isPrimeImplicant: true,
                    term: "¬\(variableNames[0]) ∧ ¬\(variableNames[1]) (Capa 1)"
                ))
            }
            
            // Identificar grupos que cruzan capas (simplificado)
            if layer1[0][0] && layer2[0][0] {
                groups.append(LogicData.KarnaughMap.KarnaughGroup(
                    cells: [
                        LogicData.KarnaughMap.KarnaughGroup.CellPosition(row: 0, column: 0)
                    ],
                    isPrimeImplicant: false,
                    term: "¬\(variableNames[4]) ∧ ¬\(variableNames[0]) ∧ ¬\(variableNames[1])"
                ))
            }
            
            karnaughMap = LogicData.KarnaughMap(variables: variableNames, grid: layer1, groups: groups)
        }
    }
    
    private func generateCircuit() throws {
        let variableNames = variables.keys.sorted()
        var gates: [LogicData.LogicGate] = []
        var connections: [(from: Int, to: Int)] = []
        
        // Constantes para el diseño
        let inputSpacing: CGFloat = 80
        let verticalSpacing: CGFloat = 100
        let horizontalSpacing: CGFloat = 150
        let startX: CGFloat = 100
        let startY: CGFloat = 150
        
        // Crear compuertas de entrada en línea vertical a la izquierda
        for (index, name) in variableNames.enumerated() {
            gates.append(LogicData.LogicGate(
                type: .input,
                inputs: [],
                position: CGPoint(x: startX, y: startY + CGFloat(index) * inputSpacing),
                label: name
            ))
        }
        
        // Analizar expresión para crear circuito
        let analyzer = CircuitAnalyzer(expression: expression)
        let circuitInfo = try analyzer.analyze()
        
        // Organizar compuertas en niveles (columnas) basado en dependencias
        var gateLevels: [[Int]] = []
        var placedGates: Set<Int> = []
        var gateIdToIndex: [Int: Int] = [:]
        
        // Asignar cada compuerta a un nivel basado en sus dependencias
        for gateInfo in circuitInfo.gates {
            let gateIndex = gates.count
            gateIdToIndex[gateInfo.gateId] = gateIndex
            
            let gateType: LogicData.LogicGate.GateType = {
                switch gateInfo.type {
                case .and: return .and
                case .or: return .or
                case .not: return .not
                case .xor: return .xor
                case .nand: return .nand
                case .nor: return .nor
                default: return .and
                }
            }()
            
            gates.append(LogicData.LogicGate(
                type: gateType,
                inputs: [],
                position: CGPoint.zero, // La posición se establecerá más tarde
                label: nil
            ))
        }
        
        // Función para determinar nivel de compuerta
        func levelForGate(_ gateId: Int) -> Int {
            var maxLevel = 0
            let gateInfo = circuitInfo.gates.first(where: { $0.gateId == gateId })!
            
            for input in gateInfo.inputs {
                switch input {
                case .variable(_):
                    break // Las variables de entrada son nivel 0
                case .gate(let inputGateId):
                    maxLevel = max(maxLevel, levelForGate(inputGateId) + 1)
                }
            }
            return maxLevel
        }
        
        // Asignar niveles a todas las compuertas
        var maxLevel = 0
        for gateInfo in circuitInfo.gates {
            let level = levelForGate(gateInfo.gateId)
            maxLevel = max(maxLevel, level)
            
            while gateLevels.count <= level {
                gateLevels.append([])
            }
            gateLevels[level].append(gateInfo.gateId)
        }
        
        // Posicionar compuertas en columnas basado en sus niveles
        for (level, gateIds) in gateLevels.enumerated() {
            let x = startX + CGFloat(level + 1) * horizontalSpacing
            
            // Distribuir compuertas verticalmente en este nivel
            for (index, gateId) in gateIds.enumerated() {
                let y = startY + CGFloat(index) * verticalSpacing
                if let gateIndex = gateIdToIndex[gateId] {
                    gates[gateIndex].position = CGPoint(x: x, y: y)
                }
            }
        }
        
        // Crear conexiones
        for (i, gateInfo) in circuitInfo.gates.enumerated() {
            let gateIndex = gateIdToIndex[gateInfo.gateId]!
            
            for input in gateInfo.inputs {
                switch input {
                case .variable(let name):
                    if let inputIndex = variableNames.firstIndex(of: name) {
                        connections.append((from: inputIndex, to: gateIndex))
                    }
                case .gate(let inputGateId):
                    if let inputIndex = gateIdToIndex[inputGateId] {
                        connections.append((from: inputIndex, to: gateIndex))
                    }
                }
            }
        }
        
        // Posicionar compuerta de salida a la derecha del último nivel
        if let outputGateIndex = gateIdToIndex[circuitInfo.outputGateId] {
            let outputX = startX + CGFloat(maxLevel + 2) * horizontalSpacing
            let outputY = startY + CGFloat(gateLevels.last?.count ?? 0) * verticalSpacing / 2
            
            gates.append(LogicData.LogicGate(
                type: .output,
                inputs: [],
                position: CGPoint(x: outputX, y: outputY),
                label: "OUT"
            ))
            connections.append((from: outputGateIndex, to: gates.count - 1))
        }
        
        circuit = LogicData.Circuit(gates: gates, connections: connections)
        setupInputs()
    }
    
    private func setupInputs() {
        if let circuit = circuit {
            let inputGates = circuit.gates.filter { $0.type == .input }
            inputValues = Array(repeating: false, count: inputGates.count)
        }
    }
    
    private func simulateCircuit() {
        guard let circuit = circuit else { return }
        
        // Crear diccionario de valores de compuertas
        var gateValues: [Int: Bool] = [:]
        
        // Asignar valores de entrada
        for (index, gate) in circuit.gates.enumerated() {
            if gate.type == .input {
                let inputGates = circuit.gates.filter { $0.type == .input }
                if let inputIndex = inputGates.firstIndex(of: gate) {
                    gateValues[index] = inputIndex < inputValues.count ? inputValues[inputIndex] : false
                }
            }
        }
        
        // Evaluar compuertas en orden (esto está simplificado)
        for (index, gate) in circuit.gates.enumerated() {
            if gate.type != .input {
                var inputs: [Bool] = []
                for connection in circuit.connections {
                    if connection.to == index, let value = gateValues[connection.from] {
                        inputs.append(value)
                    }
                }
                
                switch gate.type {
                case .and:
                    gateValues[index] = inputs.allSatisfy { $0 }
                case .or:
                    gateValues[index] = inputs.contains(true)
                case .not:
                    gateValues[index] = !inputs[0]
                case .nand:
                    gateValues[index] = !inputs.allSatisfy { $0 }
                case .nor:
                    gateValues[index] = !inputs.contains(true)
                case .xor:
                    gateValues[index] = inputs.filter { $0 }.count % 2 == 1
                case .xnor:
                    gateValues[index] = inputs.filter { $0 }.count % 2 == 0
                case .output:
                    if let input = inputs.first {
                        outputValue = input
                    }
                case .input:
                    // Este caso ya fue manejado antes
                    break
                }
            }
        }
    }
}

// MARK: - Previews
struct BooleanLogicView_Previews: PreviewProvider {
    static var previews: some View {
        BooleanLogicView()
    }
}
