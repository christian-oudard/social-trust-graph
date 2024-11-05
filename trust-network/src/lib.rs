use std::collections::HashMap;
use serde::{Serialize, Deserialize};

type Id = String;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", content = "acknowledged")]
enum TrustState {
    Trust(bool), // bool variable is whether the trust is acknowledged as mutual.
    Distrust,
}


#[derive(Debug, Clone, Serialize, Deserialize)]
struct TrustGraph {
    // The current state of trust relationships with labeled states
    graph: HashMap<Id, HashMap<Id, TrustState>>,
}

impl TrustGraph {
    fn new() -> Self {
        TrustGraph {
            graph: HashMap::new(),
        }
    }

    fn get(&self, from: &Id, to: &Id) -> Option<&TrustState> {
        self.graph.get(from)?.get(to)
    }

    fn trust(&mut self, from: &Id, to: &Id) {
        let trust_state = TrustState::Trust(false);
        self.graph.entry(from.clone()).or_default().insert(to.clone(), trust_state);
    }

    fn acknowledge(&mut self, from: &Id, to: &Id) {
        if let Some(entry) = self.graph.get_mut(from) {
            if let Some(trust_state) = entry.get_mut(to) {
                if let TrustState::Trust(acknowledged) = trust_state {
                    *acknowledged = true;
                }
            }
        }
    }
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add_trust_and_acknowledgment() {
        let mut graph = TrustGraph::new();
        let a = "A".to_string();
        let b = "B".to_string();

        graph.trust(&a, &b);
        assert_eq!(
            *graph.get(&a, &b).unwrap(),
            TrustState::Trust(false)
        );

        graph.acknowledge(&a, &b);
        assert_eq!(
            *graph.get(&a, &b).unwrap(),
            TrustState::Trust(true)
        );
    }
}
