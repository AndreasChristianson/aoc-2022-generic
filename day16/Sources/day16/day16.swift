import Foundation

public class Valve: CustomStringConvertible{
    public var name:String = ""
    public var rawLinks: [String] = []
    public var links: [Valve] = []
    public var pressure: Int = 0
    public var description: String { return "Valve: \(name), links:\(links.map{$0.name})" }
}

@available(macOS 12.6, *)
@main
public class day16 {


    public var file: String = ""
    public var rawFile: String = ""
    public var valves: [String: Valve] = [:]
    init(file: String){
        self.file = file
    }
    
    public static func main() {
 
        var sol = day16(file: "test.txt")
        sol.readFile()
        print(sol.rawFile)
        sol.parseRaw()
        sol.linkValves()
        print(sol.valves)

    }
    
    private func linkValves( ) {
        for valve in self.valves.values {
            for text in valve.rawLinks {
                valve.links.append(self.valves[text]!)
                valves[valve.name] = valve
//                print(valves)
            }
        }
    }
    
    private func readFile( ) {
        self.rawFile =  try! String(contentsOfFile: self.file, encoding: String.Encoding.utf8)
    }
    
    private func parseRaw( ){
        let lines = rawFile.split(separator: "\n")

        self.valves = [:]
        let regex = try! NSRegularExpression(pattern: "Valve ([A-Z]{2}) has flow rate=(\\d+); tunnels? leads? to valves? (([A-Z]{2}(, )?)+)")

        for substring in lines {
            var valve = Valve()
            let line  = String(substring)
            let range = NSRange(
                line.startIndex..<line.endIndex,
                in: line
            )
            let matches = regex.matches(
                in: line,
                options: [],
                range: range
            )

            let  match = matches.first!
            
            valve.name = String(line[Range(match.range(at: 1), in: line)!])
            valve.pressure = Int(line[Range(match.range(at: 2), in: line)!])!
            let links = String(line[Range(match.range(at: 3), in: line)!])
            let linksAsArray  = links.split(separator: ",")
            valve.rawLinks = linksAsArray.map{ $0.trimmingCharacters(in: .whitespaces) }

            self.valves[valve.name] = valve

        }
    }
    
}
