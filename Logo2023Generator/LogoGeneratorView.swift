import SwiftUI

struct DataShape: Shape {
    static let terminator = Data([UInt8(0x00)])

    var data: Data
    var numberOfSegments: Int {
        bitPattern.count / 4
    }
    
    private var bitPattern: String {
        (data + Self.terminator).map {
            let temp = String($0, radix: 2)
            return String(repeating: "0", count: 8 - temp.count) + temp
        }
        .reduce("") {
            $0 + $1
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let radiiStep = rect.width / Double(14.0)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radii: [CGFloat] = [7*radiiStep, 6*radiiStep, 5*radiiStep, 4*radiiStep, 3*radiiStep]
        let stepAngle = -360.0 / Double(numberOfSegments)
        
        for (index, segment) in bitPattern.enumerated() {
            guard index < numberOfSegments * 4 else { break }
            
            let bitIndex = index % 4
            let segmentIndex = index / 4
            
            if segment == "1" {
                let startAngle = Angle(degrees: stepAngle * Double(segmentIndex + 1) - 90 + stepAngle)
                let endAngle = Angle(degrees: stepAngle * Double(segmentIndex) - 90 + stepAngle)
                
                path.addArc(center: center,
                            radius: radii[bitIndex],
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false)
                
                path.addLine(to: CGPoint(x: center.x + radii[bitIndex + 1] * CGFloat(cos(endAngle.radians)),
                                         y: center.y + radii[bitIndex + 1] * CGFloat(sin(endAngle.radians))))
                
                path.addArc(center: center,
                            radius: radii[bitIndex + 1],
                            startAngle: endAngle,
                            endAngle: startAngle,
                            clockwise: true)
                
                path.closeSubpath()
            }
        }
        
        return path
    }
}

struct LogoGeneratorView: View {
    @State private var message: String = "正直すまんかった"
    
    var body: some View {
        VStack {
            Spacer()
            DataShape(data: Data(message.utf8))
                .fill(.white)
            
            TextField("Enter a character", text: $message)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
        }
        .background(.black)
    }
    
    private func getBitPattern(for message: String) -> String {
        return Data(message.utf8).map {
            let temp = String($0, radix: 2)
            return String(repeating: "0", count: 8 - temp.count) + temp
        }.reduce("") { $0 + $1 }
    }
}

#Preview {
    LogoGeneratorView()
}
