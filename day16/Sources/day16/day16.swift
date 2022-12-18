import Foundation

@available(macOS 12.6, *)
public class Valve:CustomStringConvertible, Hashable{
    public static func == (lhs: Valve, rhs: Valve) -> Bool {
        lhs.name == rhs.name
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public let name:String
    public let rawLinks: [String];
    public let links: NSMutableArray = []
    public let pressure: Int
    
    init(name:String, pressure: Int, rawLinks: [String]) {
        self.name = name
        self.pressure = pressure
        self.rawLinks = rawLinks
    }
    
    private var ptr:String {
        return Unmanaged.passUnretained(self).toOpaque().debugDescription
    }
    public var description: String {
        return "\(name)(\(ptr)): p:\(pressure), links: \(links.map{($0 as! Valve).ptr}.joined(separator: ","))"
    }
}
@available(macOS 12.6, *)
public class Path:CustomStringConvertible, Hashable{
//    public let actions: String
    public let totalReleased: Int
    public let current:Valve
    public let elephantCurrent:Valve
//    public let timeSpent:Int
    public let opened:Set<Valve>
    public let visited:Set<Valve>
    public let elephantVisited:Set<Valve>
    
    public static func == (lhs: Path, rhs: Path) -> Bool {
        lhs.current == rhs.current &&
        lhs.elephantCurrent == rhs.elephantCurrent &&
        lhs.opened == rhs.opened &&
        lhs.totalReleased == rhs.totalReleased
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(current)
        hasher.combine(totalReleased)
        hasher.combine(opened)
        hasher.combine(elephantCurrent)
    }
    
    init(
//        actions: String,
        totalReleased: Int,
        current: Valve,
        elephantCurrent: Valve,
//        timeSpent: Int,
        opened: Set<Valve>,
        visited: Set<Valve>,
        elephantVisited:Set<Valve>
    ) {
//        self.actions = actions
        self.totalReleased = totalReleased
        self.current = current
//        self.timeSpent = timeSpent
        self.opened = opened
        self.visited = visited
        self.elephantCurrent = elephantCurrent
        self.elephantVisited = elephantVisited
    }
    
    public var description: String {
        return "Path. released: \(totalReleased)"
    }
    public func moveHuman(newCurrent:Valve)-> Path {
        var newSet = visited
        newSet.insert(newCurrent)
        return Path(
//            actions: "\(self.actions), \(timeSpent+1):move \(current.name)->\(newCurrent.name)",
            totalReleased: totalReleased,
            current: newCurrent,
            elephantCurrent: elephantCurrent,
//            timeSpent: timeSpent+1,
            opened: opened,
            visited:newSet,
            elephantVisited: elephantVisited
        )
    }
    public func openHuman(minute:Int)-> Path {
        var newSet = opened
        newSet.insert(current)
        return Path(
//            actions: "\(self.actions), \(timeSpent+1):open \(current.name)",
            totalReleased: totalReleased+current.pressure*(day16.totalTimeAvail-minute),
            current: current,
            elephantCurrent: elephantCurrent,
//            timeSpent: timeSpent+1,
            opened: newSet,
            visited: [],
            elephantVisited: elephantVisited
        )
    }
    
    public func moveElephant(newElephantCurrent:Valve)-> Path {
        var newSet = elephantVisited
        newSet.insert(newElephantCurrent)
        return Path(
//            actions: "\(self.actions), \(timeSpent+1):move \(current.name)->\(newCurrent.name)",
            totalReleased: totalReleased,
            current: current,
            elephantCurrent: newElephantCurrent,
//            timeSpent: timeSpent,
            opened: opened,
            visited:visited,
            elephantVisited: newSet
        )
    }
    public func openElephant(minute:Int)-> Path {
        var newSet = opened
        newSet.insert(elephantCurrent)
        return Path(
//            actions: "\(self.actions), \(timeSpent+1):open \(current.name)",
            totalReleased: totalReleased+elephantCurrent.pressure*(day16.totalTimeAvail-minute),
            current: current,
            elephantCurrent: elephantCurrent,
//            timeSpent: timeSpent,
            opened: newSet,
            visited: visited,
            elephantVisited: []
        )
    }
    public func humanActions(minute:Int)-> [Path] {
        var newPaths:[Path] = []
        if(current.pressure>0 && !opened.contains(current)){
            newPaths.append(openHuman(minute: minute))
        }
        for link in current.links{
            if(!visited.contains(link as! Valve)){
                newPaths.append(moveHuman(newCurrent: link as! Valve))
            }
        }
        return newPaths
    }
    public func elephantActions(minute:Int)-> [Path] {
        var newPaths:[Path] = []
        if(elephantCurrent.pressure>0 && !opened.contains(elephantCurrent)){
            newPaths.append(openElephant(minute: minute))
        }
        for link in elephantCurrent.links{
            if(!elephantVisited.contains(link as! Valve)){
                newPaths.append(moveElephant(newElephantCurrent: link as! Valve))
            }
        }
        return newPaths
    }
}

@available(macOS 12.6, *)
@main
public class day16 {
    public static let totalTimeAvail = 26;

    public var file: String = ""
    public var rawFile: String = ""
    public var valves: NSMutableDictionary = [:]
    public var valvesWithPressure = 0
    public var start: Valve?
    public var bestPath :Path?
    init(file: String){
        self.file = file
    }
    
    public static func main() {
        let sol = day16(file: "input.txt")
        sol.readFile()
        print(sol.rawFile)
        sol.parseRaw()
        sol.enhanceValves()
        print(sol.valves)
        print("start: \(sol.start!)")
        sol.iterate()
        print(sol.bestPath?.totalReleased)
        
    }
    
    private func iterate() {
        var paths : Set<Path> = [Path(
//            actions: "",
            totalReleased: 0,
            current: start!,
            elephantCurrent: start!,
//            timeSpent: 0,
            opened: [],
            visited: [],
            elephantVisited: []
        )]
        for minute in 1...day16.totalTimeAvail {
            print("begin minute \(minute) (\(bestPath?.totalReleased ?? 0))")
            paths = Set<Path>(
                paths
                    .flatMap({ path in path.humanActions(minute: minute)})
                    .flatMap({ path in path.elephantActions(minute: minute)})
            .map({ path in
                if(path.totalReleased>bestPath?.totalReleased ?? 0){
                    bestPath = path
                }
                return path
            })
            )
            .filter({ path in
                return path.opened.count < valvesWithPressure && (minute < 10 || path.totalReleased > (bestPath?.totalReleased ?? 0) * 7 / 8 )
            })
            
        }
    }
    /*
     no trim
     begin minute 6 (735)
     begin minute 7 (953)
     begin minute 8 (1065)
     begin minute 9 (1509)
     begin minute 10 (1684)
     begin minute 11 (1726)
     begin minute 12 (1895)
     begin minute 13 (2185)
     
     50%
     begin minute 6 (735)
     begin minute 7 (953)
     begin minute 8 (1065)
     begin minute 9 (1509)
     begin minute 10 (1684)
     begin minute 11 (1726)
     begin minute 12 (1895)
     begin minute 13 (2185)
     begin minute 14 (2285)
     begin minute 15 (2351)
     begin minute 16 (2394)
     2405
     
     75%
     begin minute 10 (1684)
     begin minute 11 (1726)
     begin minute 12 (1895)
     begin minute 13 (2185)
     begin minute 14 (2285)
     begin minute 15 (2351)
     begin minute 16 (2394)
     begin minute 17 (2405)
     begin minute 18 (2468)
     begin minute 19 (2498)
     begin minute 20 (2498)
     begin minute 21 (2552)
     begin minute 22 (2568)
     begin minute 23 (2568)
     begin minute 24 (2585)
     
     7/8
     */
    private func enhanceValves( ) {
        for kv in self.valves {
            let valve = kv.value as! Valve
            if(valve.name == "AA"){
                start = valve
            }
            for text in valve.rawLinks {
                valve.links.add(self.valves[text]!)
                valves[valve.name] = valve
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
            
            let name = String(line[Range(match.range(at: 1), in: line)!])
            let pressure = Int(line[Range(match.range(at: 2), in: line)!])!
            let links = String(line[Range(match.range(at: 3), in: line)!])
            let linksAsArray  = links.split(separator: ",")
            let rawLinks = linksAsArray.map{ $0.trimmingCharacters(in: .whitespaces) }
            let valve = Valve(name: name, pressure: pressure, rawLinks: rawLinks)

            if(pressure>0){
                valvesWithPressure+=1
            }
            self.valves[valve.name] = valve

        }
    }
    
}
