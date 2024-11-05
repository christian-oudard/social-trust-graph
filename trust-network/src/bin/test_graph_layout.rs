use petgraph::stable_graph::StableUnGraph;
// use petgraph::data::FromElements;
use petgraph::dot::{Config, Dot};

/// A relationship between two people.
#[derive(Debug, Copy, Clone)]
enum Rel {
    Trust,
    Distrust,
}
const T: Rel = Rel::Trust;
const D: Rel = Rel::Distrust;

const TEST_EDGES: &[(u32, u32, Rel)] = &[
    (1, 2, T),
    (1, 4, T),
    (2, 3, T),
    (2, 10, T),
    (3, 12, D),
    (3, 14, T),
    (4, 5, T),
    (4, 6, T),
    (4, 7, T),
    (5, 6, T),
    (5, 7, T),
    (5, 8, T),
    (6, 7, T),
    (6, 9, T),
    (7, 8, T),
    (7, 9, T),
    (9, 10, T),
    (9, 16, D),
    (10, 11, T),
    (10, 12, D),
    (11, 13, T),
    (12, 13, T),
    (12, 14, T),
    (13, 14, T),
    (13, 15, T),
    (13, 16, T),
    (14, 15, T),
    (14, 27, T),
    (14, 29, D),
    (15, 16, T),
    (15, 26, T),
    (15, 27, T),
    (15, 35, T),
    (16, 17, D),
    (17, 18, T),
    (17, 23, T),
    (17, 25, T),
    (18, 19, T),
    (18, 20, T),
    (18, 21, T),
    (18, 22, T),
    (18, 23, T),
    (19, 20, T),
    (19, 21, T),
    (19, 22, T),
    (19, 23, T),
    (20, 21, T),
    (20, 22, T),
    (20, 23, T),
    (21, 22, T),
    (21, 23, T),
    (21, 24, D),
    (22, 23, T),
    (22, 25, T),
    (24, 27, T),
    (24, 32, T),
    (25, 26, T),
    (26, 27, T),
    (26, 34, T),
    (27, 28, T),
    (28, 29, T),
    (28, 30, T),
    (28, 31, T),
    (28, 32, T),
    (28, 33, T),
    (28, 34, T),
    (29, 30, T),
    (29, 31, T),
    (29, 32, T),
    (29, 33, T),
    (29, 34, T),
    (30, 31, T),
    (30, 32, T),
    (30, 33, T),
    (30, 34, T),
    (31, 32, T),
    (31, 33, T),
    (31, 34, T),
    (32, 33, T),
    (32, 34, T),
    (33, 34, T),
];

fn main() {
    let g = StableUnGraph::<(), Rel>::from_edges(TEST_EDGES);

    // Check for doubled edges.
    for i in g.node_indices() {
        let mut neighbors = g.neighbors(i).collect::<Vec<_>>();
        neighbors.sort();
        let pairs = neighbors.iter().zip(neighbors.iter().skip(1));
        for (a, b) in pairs {
            if a == b {
                panic!("Doubled edge: {:?}--{:?}", i.index(), a.index());
            }
        }
    }

    let dot = Dot::with_attr_getters(
        &g,
        &[Config::NodeNoLabel, Config::EdgeNoLabel],
        &|_g, e| {
            match *e.weight() {
                Rel::Trust => "style=solid".to_string(),
                Rel::Distrust => "style=dashed".to_string(),
            }
        },
        &|g, (i, _)| {
            let degree = g.neighbors(i).count();
            format!("label=\"#{} ({})\", ", i.index(), degree)
        },
    );
    println!("{:?}", dot);
}
