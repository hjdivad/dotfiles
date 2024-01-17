use std::{iter, str::FromStr};

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
    root: Node<'a>,
}

#[derive(Default)]
pub struct Node<'a> {
    children: Vec<Edge<'a>>,
    parent: Option<&'a Node<'a>>,
    suffix_link: Option<&'a Node<'a>>,
}

pub enum Edge<'a> {
    ToInternal(InternalEdge<'a>),
    ToLeaf(LeafEdge),
}

pub struct InternalEdge<'a> {
    // TODO: see if we can replace these with &'a str without increasing memory
    label_start_idx: usize,
    label_end_idx: usize,
    node: Node<'a>,
}

pub struct LeafEdge {
    // leaves always end at index e of phase e, and eventually at len(text)
    label_start_idx: usize,
    leaf_value: usize,
}

pub enum SuffixTreeError {}

impl<'a> FromStr for Tree<'a> {
    type Err = SuffixTreeError;

    fn from_str(text: &str) -> Result<Self, Self::Err> {
        // Pseudocode for Ukkonen's algorithm
        //  see https://www.geeksforgeeks.org/ukkonens-suffix-tree-construction-part-1/
        //
        // In phase i+1, T_{i+1} is built on top of T_i
        //
        // The true (non-implicit) suffix tree is added from T_m by adding $
        //
        // One extension for each of the i+1 suffixes of S[1..i+1]
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
        todo!()
    }
}

type DebugEdge<'a> = (&'a str, usize, usize, Option<usize>);
type DebugVec<'a> = Vec<DebugEdge<'a>>;
impl<'a> Tree<'a> {
    pub fn iter_edges(&self) -> Box<dyn Iterator<Item = &Edge<'a>> + '_> {
        self.root.iter_edges()
    }
    fn debug_vec(&self) -> DebugVec {
        self.debug_vec_from(&self.root)
    }

    fn debug_vec_from(&self, node: &'a Node) -> DebugVec {
        node.iter_edges()
            .map(|e| {
                let (start_idx, end_idx, maybe_leaf_value) = match e {
                    Edge::ToInternal(i_edge) => {
                        (i_edge.label_start_idx, i_edge.label_end_idx, None)
                    }
                    Edge::ToLeaf(l_edge) => (
                        l_edge.label_start_idx,
                        self.text.len()-1,
                        Some(l_edge.leaf_value),
                    ),
                };

                let label = self.debug_label(e);
                (label, start_idx, end_idx, maybe_leaf_value)
            })
            .collect()
    }

    fn new(text: &'a str) -> Self {
        Tree {
            text,
            root: Node::default(),
        }
    }

    fn debug_label(&self, edge: &Edge<'a>) -> &'a str {
        let (s, i): (usize, usize) = match edge {
            Edge::ToInternal(i_edge) => (i_edge.label_start_idx, i_edge.label_end_idx + 1),
            Edge::ToLeaf(l_edge) => (l_edge.label_start_idx, self.text.len()),
        };
        &self.text[s..i]
    }
}

impl<'a> Node<'a> {
    pub fn iter_edges(&self) -> Box<dyn Iterator<Item = &Edge<'a>> + '_> {
        let itr = self.children.iter().flat_map(|edge| match edge {
            Edge::ToLeaf(_) => {
                Box::new(iter::once(edge)) as Box<dyn Iterator<Item = &Edge<'a>> + '_>
            }
            Edge::ToInternal(i_edge) => {
                let itr = iter::once(edge);
                let subtree_itr = i_edge.node.iter_edges();
                Box::new(itr.chain(subtree_itr)) as Box<dyn Iterator<Item = &Edge<'a>> + '_>
            }
        });

        Box::new(itr)
    }

    fn add_leaf_edge(&mut self, leaf_edge: LeafEdge) {
        self.children.push(Edge::ToLeaf(leaf_edge));
    }

    fn add_internal_edge(&mut self, internal_edge: InternalEdge<'a>) {
        self.children.push(Edge::ToInternal(internal_edge));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

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

        tree.root.add_leaf_edge(LeafEdge {
            label_start_idx: 2,
            leaf_value: 2,
        });

        tree.root.add_leaf_edge(LeafEdge {
            label_start_idx: 5,
            leaf_value: 5,
        });

        let mut i_edge = InternalEdge {
            label_start_idx: 1,
            label_end_idx: 1,
            node: Node::default(),
        };
        i_edge.node.add_leaf_edge(LeafEdge {
            label_start_idx: 5,
            leaf_value: 4,
        });
        i_edge.node.add_leaf_edge(LeafEdge {
            label_start_idx: 2,
            leaf_value: 1,
        });
        tree.root.add_internal_edge(i_edge);

        let mut i_edge = InternalEdge {
            label_start_idx: 0,
            label_end_idx: 1,
            node: Node::default(),
        };
        i_edge.node.add_leaf_edge(LeafEdge {
            label_start_idx: 5,
            leaf_value: 3,
        });
        i_edge.node.add_leaf_edge(LeafEdge {
            label_start_idx: 2,
            leaf_value: 0,
        });
        tree.root.add_internal_edge(i_edge);

        tree
    }

    #[test]
    fn iter_edges() {
        let mut tree = Tree::new(TEST_STRING);
        tree.root.add_leaf_edge(LeafEdge {
            label_start_idx: 8,
            leaf_value: 8,
        });

        assert_eq!(
            tree.iter_edges()
                .map(|e| tree.debug_label(e))
                .collect::<Vec<&str>>(),
            vec!["cd"]
        );

        let tree = test_tree_xabxac();

        assert_eq!(
            tree.iter_edges()
                .map(|e| tree.debug_label(e))
                .collect::<Vec<&str>>(),
            vec!["bxac", "c", "a", "c", "bxac", "xa", "c", "bxac"]
        );
    }

    #[test]
    fn debug_vec() {
        let tree = test_tree_xabxac();

        assert_eq!(
            tree.debug_vec(),
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
    fn from_str() {
        // TODO: from_str xabxac
        // TODO: from_str TEST_STRING
        //
        // TODO: bench from_str big_strs
        // TODO: /usr/bin/time -hl from_str big_str
    }
}
