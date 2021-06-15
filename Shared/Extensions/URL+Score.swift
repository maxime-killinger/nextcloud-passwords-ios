import Foundation


extension URL {
    
    func score(searchUrl: URL, penalty: Double = 0.5) -> Double {
        if self == searchUrl {
            return 1.0
        }
        
        /// Prepare host names to avoid common matches
        guard var host = host,
              var searchHost = searchUrl.host else {
            return 0.0
        }
        var hostDomains = host.split(separator: ".")
        var searchHostDomains = searchHost.split(separator: ".")
        if hostDomains.first == "www" {
            hostDomains.removeFirst()
        }
        if searchHostDomains.first == "www" {
            searchHostDomains.removeFirst()
        }
        if hostDomains.last?.count ?? 0 > 4 {
            hostDomains.removeLast()
        }
        if searchHostDomains.last?.count ?? 0 > 4 {
            searchHostDomains.removeLast()
        }
        host = hostDomains.joined(separator: ".")
        searchHost = searchHostDomains.joined(separator: ".")
        
        /// Score host with the search's host and do the same in reverse to account for subdomains
        let hostScore = host.score(searchTerm: searchHost, penalty: penalty * 0.6)
        let reversedHostScore = searchHost.score(searchTerm: host, penalty: penalty * 0.6) * 0.85
        var score = max(hostScore, reversedHostScore)
        
        if searchUrl.relativeReference.isEmpty {
            /// Only scoring host with host, but they aren't equal
            score *= relativeReference.isEmpty
                ? 0.85
                : 0.8 /// The URL has a relative reference but the search URL hasn't
        }
        else {
            /// Reduce host score to account for the relative reference, if the search URL has one
            score *= 0.7
            let relativeReferenceScore = relativeReference.score(searchTerm: searchUrl.relativeReference, penalty: penalty * 1.5) * 0.2
            score += relativeReferenceScore
        }
        
        return score
    }
    
}
