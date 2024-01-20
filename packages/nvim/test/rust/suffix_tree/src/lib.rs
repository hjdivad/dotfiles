use log::{debug, info, log_enabled, Level::Debug};
use std::{borrow::Borrow, iter, str::FromStr};

extern crate pretty_env_logger;

/// Suffix Tree `T` for m-char string `S` ending in unique character `$`.
///
/// A rooted tree with exactly `m` leaves `1..m`
///
/// Such that:
///     * Root can have zero, one or more children
///     * Internal nodes have at least two children
///     * Edges labelled with non-empty substring of `S`
///     * No two edges from the same node have labels beginning with the same character
///
pub struct Tree<'a> {
    text: &'a str,
    nodes: Vec<Node>,
    edges: Vec<Edge>,

    root: NodeIndex,
}

#[derive(Debug, Clone, Copy)]
struct NodeIndex(usize);
#[derive(Debug, Clone, Copy)]
struct EdgeIndex(usize);

#[derive(Default)]
pub struct Node {
    children: Vec<EdgeIndex>,
}

struct NodeShortcuts {
    parent: Option<NodeIndex>,
    suffix_link: Option<NodeIndex>,
}

pub enum Edge {
    ToInternal(InternalEdge),
    ToLeaf(LeafEdge),
}

pub struct InternalEdge {
    // TODO: see if we can replace these with &'a str without increasing memory
    label_start_idx: usize,
    label_end_idx: usize,
    node: NodeIndex,
}
struct InternalEdgeBuild {
    label_start_idx: usize,
    label_end_idx: usize,
}

pub struct LeafEdge {
    // leaves always end at index e of phase e, and eventually at len(text)
    label_start_idx: usize,
    leaf_value: usize,
}

#[derive(Debug)]
pub enum SuffixTreeError {}

impl<'a> Tree<'a> {
    pub fn from_str(text: &'a str) -> Result<Self, SuffixTreeError> {
        Self::from_str_with_terminator(text, '$')
    }
}

type DebugEdge<'a> = (&'a str, usize, usize, Option<usize>);
type DebugVec<'a> = Vec<DebugEdge<'a>>;
impl<'a> Tree<'a> {
    fn from_str_with_terminator(text: &'a str, term: char) -> Result<Self, SuffixTreeError> {
        // Pseudocode for Ukkonen's algorithm
        //  see https://www.geeksforgeeks.org/ukkonens-suffix-tree-construction-part-1/
        //
        // In phase i+1, T_{i+1} is built on top of T_i
        //
        // The true (non-implicit) suffix tree is added from T_m by adding $
        //
        // One extension for each of the i+1 suffixes of S
        // In extension 1 of phase i+1 string S[1..i+1] goes in the tree. S[1..i] will already be
        // present from previous phase i. We only need character S[i+1] if it's not already there.
        //
        // Construct tree T_1
        // For i from 1 to m-1 do
        //  begin {phase i + 1}
        //      For j from 1 to i + 1
        //          begin {extension j}
        //
        //          Find the end of the path from the root labelled S[j..i] in the current tree
        //          Extend that path by adding charater S[i+l] if it's not there already
        //      end
        //  end
        //
        //  Three extension rules:
        //
        //  1. If the path S[j..i] ends at leaf edge then S[i+] is added to the edge label.
        //  2. If the path S[j..i] ends at non-leaf edge and the next character is not s[i+1] then
        //     a new leaf edge with label s[i+1] and number j is created starting from S[i+1]. A
        //     new internal node will also be created if S[1..i] ends inside a non-leaf edge.
        //  3. If the path S[j..i] ends at non-leaf edge and next character is S[i+1] do nothing.
        //
        //
        //  Suffix Links:
        //
        //  For a node v with path xA, if some node s(v) has path A, then a pointer v -> s(v) is a
        //  suffix link.
        //
        //  In extension j of phase i, if a new node v with path xA is added then in extension j+1
        //  in the same phase i:
        //      * either the path A already ends at an internal node (or root if A is empty)
        //      * OR a new internal node at the end of A will be created
        //
        //  In extension j+1 of the same phase i, create a suffix link from the node created in the
        //  jth extension to node with path A.
        //
        //  In extension j of phase i+1 we must find path S[j..i]. Instead of traversing from root,
        //  we start from S[j..i] and traverse parent's suffix link to s(v).
        //
        //
        //  Trick 1 Skip/Count:
        //
        //  When walking down from s(v) to leaf, instead of matching path character by character,
        //  skip to the next node if `#edge.chars` is less than the length we need to travel.
        //
        //  Trick 2 Early Exit Phase:
        //
        //  When rule 3 applies in any extension of phase i, the phase can exit early.
        //
        //  Trick 3 Leaves:
        //
        //  In phase i, leaves (p,i), (q,i), (r,i), thn in phase i+1, these leaves are (p,i+1), (q,
        //  i+1), (r, i+1). So in any phase, leaf edges are (p, e) for phase e, which can be stored
        //  globally and incremented in constant time.
        //
        //
        //  Active Point:
        //
        //  The active point is the root, an internal node, or a point along an edge. It is the
        //  point where traversal begins in any extension.
        //
        //  For phase 1 extension 1, activePoint = root. For others, it is set by the previous
        //  extension. It is stored via activeNode, activeEdge, activeLength.
        //
        //  activeNode - Non-leaf node.
        //  activeEdge - For the next character being processed in the next phase.
        //  acdtiveLength - How long to traverse the path of activeEdge (from activeNode) to reach
        //  the active point. If activeNode is the activePoint, then activeLength == 0.
        //
        //  Active Point Changes:
        //
        //  - When rule 3 applies in phase i, ++activeLength.
        //  - When walking down, update activeNode and activeEdge during the walk.
        //  - When length == 0, activeEdge will update.
        //

        let mut tree = Tree::new(text);
        let mut active_point: (NodeIndex, Option<(EdgeIndex, usize)>) = (tree.root, None);

        let m = text.len();
        if log_enabled!(Debug) {
            let text_short = if m > 6 {
                format!("{}...", &text[0..6])
            } else {
                text.to_string()
            };
            debug!(r#""{}" -> SuffixTree"#, text_short);
        }
        for i in 0..m {
            // phase i
            // add character S[i] to T

            let character = text.chars().nth(i).unwrap();
            debug!("phase {} - '{}'", i, character);
            for j in 0..i + 1 {
                debug!("  extension {}", j);
                // extension j

                // find path P that ends S[j..i-1]
                // extend P with S[i]

                // TODO: remove all this logic
                // TODO: instead, active_point is only where traversal begins
                // the goal is to traverse S[j..i-1] and see where it ends
                active_point = match active_point {
                    (node, None) => {
                        debug!("    rule 2 - add leaf");
                        // S[j..i] ends at node; there is no next character, add a leaf node
                        let new_edge = tree.add_leaf_edge(
                            node,
                            LeafEdge {
                                label_start_idx: i,
                                leaf_value: j,
                            },
                        );

                        (node, Some((new_edge, 0)))
                    }
                    (node, Some((edge_index, _))) => match tree.edge_for(edge_index) {
                        Edge::ToInternal(_) => {
                            debug!("    TODO: (node, internal_edge, len)");
                            (node, None)
                        }
                        Edge::ToLeaf(_) => {
                            debug!("    TODO: (node, leaf_edge, len)");
                            (node, None)
                        }
                    },
                };
            }
        }

        // TODO: process string terminator `term`

        Ok(tree)
    }

    pub fn iter_edges(&self) -> Box<dyn Iterator<Item = &Edge> + '_> {
        self.iter_edges_from(self.root)
    }
    fn iter_edges_from(&self, node: NodeIndex) -> Box<dyn Iterator<Item = &Edge> + '_> {
        let node = &self.nodes[node.0];
        let itr = node.children.iter().flat_map(|edge| {
            let edge = &self.edges[edge.0];
            match edge {
                Edge::ToLeaf(_) => {
                    Box::new(iter::once(edge)) as Box<dyn Iterator<Item = &Edge> + '_>
                }
                Edge::ToInternal(i_edge) => {
                    let itr = iter::once(edge);
                    let subtree_itr = self.iter_edges_from(i_edge.node);
                    let itr = itr.chain(subtree_itr);
                    Box::new(itr) as Box<dyn Iterator<Item = &Edge> + '_>
                }
            }
        });

        Box::new(itr)
    }

    fn _debug_vec(&self) -> DebugVec {
        self._debug_vec_from(self.root)
    }

    fn _debug_vec_from(&self, node: NodeIndex) -> DebugVec {
        self.iter_edges_from(node)
            .map(|e| {
                let (start_idx, end_idx, maybe_leaf_value) = match e {
                    Edge::ToInternal(i_edge) => {
                        (i_edge.label_start_idx, i_edge.label_end_idx, None)
                    }
                    Edge::ToLeaf(l_edge) => (
                        l_edge.label_start_idx,
                        self.text.len() - 1,
                        Some(l_edge.leaf_value),
                    ),
                };

                let label = self._debug_label(e);
                (label, start_idx, end_idx, maybe_leaf_value)
            })
            .collect()
    }

    fn new(text: &'a str) -> Self {
        Tree {
            text,
            nodes: vec![Node::default()],
            edges: Vec::new(),
            root: NodeIndex(0),
        }
    }

    fn _debug_label(&self, edge: &Edge) -> &'a str {
        let (s, i): (usize, usize) = match edge {
            Edge::ToInternal(i_edge) => (i_edge.label_start_idx, i_edge.label_end_idx + 1),
            Edge::ToLeaf(l_edge) => (l_edge.label_start_idx, self.text.len()),
        };
        &self.text[s..i]
    }

    fn node_index_for(&self, edge: EdgeIndex) -> NodeIndex {
        if let Edge::ToInternal(edge) = &self.edges[edge.0] {
            edge.node
        } else {
            panic!("edge index {:?} is a leaf edge, not an internal edge", edge);
        }
    }

    fn edge_for(&self, edge: EdgeIndex) -> &Edge {
        self.edges[edge.0].borrow()
    }

    fn add_edge(&mut self, node: NodeIndex, edge: Edge) -> EdgeIndex {
        let node = &mut self.nodes[node.0];

        self.edges.push(edge);

        let edge = EdgeIndex(self.edges.len() - 1);
        node.children.push(edge);
        edge
    }

    fn add_leaf_edge(&mut self, node: NodeIndex, edge: LeafEdge) -> EdgeIndex {
        self.add_edge(node, Edge::ToLeaf(edge))
    }

    fn add_internal_edge(&mut self, parent_node: NodeIndex, edge: InternalEdgeBuild) -> EdgeIndex {
        self.nodes.push(Node::default());
        let node = NodeIndex(self.nodes.len() - 1);
        let InternalEdgeBuild {
            label_start_idx,
            label_end_idx,
        } = edge;
        let edge = Edge::ToInternal(InternalEdge {
            node,
            label_start_idx,
            label_end_idx,
        });
        self.add_edge(parent_node, edge)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use pretty_env_logger::env_logger;
    use pretty_env_logger::env_logger::Env;

    fn setup_logging() {
        env_logger::Builder::from_env(Env::default().default_filter_or("trace"))
            .is_test(true)
            .init();
    }

    //                         0123456789
    const TEST_STRING: &str = "abcabxabcd";

    /// Returns a suffix tree for
    ///
    /// "xabxac"
    ///  012345
    ///
    /// See figure 1 at https://www.geeksforgeeks.org/ukkonens-suffix-tree-construction-part-1/
    fn test_tree_xabxac() -> Tree<'static> {
        //          012345
        let test = "xabxac";
        let mut tree = Tree::new(test);

        tree.add_leaf_edge(
            tree.root,
            LeafEdge {
                label_start_idx: 2,
                leaf_value: 2,
            },
        );

        tree.add_leaf_edge(
            tree.root,
            LeafEdge {
                label_start_idx: 5,
                leaf_value: 5,
            },
        );

        let i_edge = tree.add_internal_edge(
            tree.root,
            InternalEdgeBuild {
                label_start_idx: 1,
                label_end_idx: 1,
            },
        );
        let node = tree.node_index_for(i_edge);
        tree.add_leaf_edge(
            node,
            LeafEdge {
                label_start_idx: 5,
                leaf_value: 4,
            },
        );
        tree.add_leaf_edge(
            node,
            LeafEdge {
                label_start_idx: 2,
                leaf_value: 1,
            },
        );

        let i_edge = tree.add_internal_edge(
            tree.root,
            InternalEdgeBuild {
                label_start_idx: 0,
                label_end_idx: 1,
            },
        );
        let node = tree.node_index_for(i_edge);
        tree.add_leaf_edge(
            node,
            LeafEdge {
                label_start_idx: 5,
                leaf_value: 3,
            },
        );
        tree.add_leaf_edge(
            node,
            LeafEdge {
                label_start_idx: 2,
                leaf_value: 0,
            },
        );

        tree
    }

    #[test]
    fn iter_edges() {
        let mut tree = Tree::new(TEST_STRING);
        tree.add_leaf_edge(
            tree.root,
            LeafEdge {
                label_start_idx: 8,
                leaf_value: 8,
            },
        );

        assert_eq!(
            tree.iter_edges()
                .map(|e| tree._debug_label(e))
                .collect::<Vec<&str>>(),
            vec!["cd"]
        );

        let tree = test_tree_xabxac();

        assert_eq!(
            tree.iter_edges()
                .map(|e| tree._debug_label(e))
                .collect::<Vec<&str>>(),
            vec!["bxac", "c", "a", "c", "bxac", "xa", "c", "bxac"]
        );
    }

    #[test]
    fn debug_vec() {
        let tree = test_tree_xabxac();

        assert_eq!(
            tree._debug_vec(),
            vec![
                ("bxac", 2, 5, Some(2)),
                ("c", 5, 5, Some(5)),
                ("a", 1, 1, None),
                ("c", 5, 5, Some(4)),
                ("bxac", 2, 5, Some(1)),
                ("xa", 0, 1, None),
                ("c", 5, 5, Some(3)),
                ("bxac", 2, 5, Some(0)),
            ]
        );
    }

    #[test]
    fn from_str_a() {
        let tree = Tree::from_str("a").unwrap();

        assert_eq!(tree._debug_vec(), vec![("a", 0, 0, Some(0)),]);
    }

    #[test]
    fn from_str_ab() {
        setup_logging();
        let tree = Tree::from_str("ab").unwrap();

        assert_eq!(
            tree._debug_vec(),
            vec![("ab", 0, 1, Some(0)), ("b", 1, 1, Some(1))]
        );
    }

    #[test]
    // TODO: impl
    #[ignore]
    fn from_str() {
        let tree = Tree::from_str("xabxac").unwrap();

        assert_eq!(
            tree._debug_vec(),
            vec![
                ("bxac", 2, 5, Some(2)),
                ("c", 5, 5, Some(5)),
                ("a", 1, 1, None),
                ("c", 5, 5, Some(4)),
                ("bxac", 2, 5, Some(1)),
                ("xa", 0, 1, None),
                ("c", 5, 5, Some(3)),
                ("bxac", 2, 5, Some(0)),
            ]
        );
        // TODO: from_str xabxac
        // TODO: from_str TEST_STRING
        //
        // TODO: bench from_str big_strs
        // TODO: /usr/bin/time -hl from_str big_str
    }
}
