import std.typecons : tuple, Tuple;


class Edge {
    private Node previous_node;
    private Node next_node;
    public double cost;

    this(Node previous_node, Node next_node, double cost = 0) {
        this.previous_node = previous_node;
        this.next_node = next_node;
        this.cost = cast(immutable)cost;
    }

    @property previousNode() {
        return this.previous_node;
    }

    @property nextNode() {
        return this.next_node;
    }
}


class Node {
    private Edge[] next_edges;
    private Edge[] previous_edges;
    private string value;
    private double cost;

    this(string value, ulong cost = 0) {
        this.value = cast(immutable)value;
        this.cost = cast(immutable)cost;
    }

    override string toString() {
        return this.value;
    }

    //TODO consider the scope
    void connectTo(Node node, double edge_cost = 0) {
        this.next_edges ~= new Edge(this, node, edge_cost);
    }

    //TODO consider the scope
    void connectFrom(Node node, double edge_cost = 0) {
        this.previous_edges ~= new Edge(node, this, edge_cost);
    }

    @property Edge[] previousEdges() {
        return this.previous_edges;
    }

    @property Edge[] nextEdges() {
        return this.next_edges;
    }

    override bool opEqual(Node node) {
        return &this == &node;
    }
}


//TODO consider the interface
void connect(ref Node source, ref Node destination, double cost = 0) {
    source.connectTo(destination, cost);
    destination.connectFrom(source, cost);
}


//TODO recursion with memorization
Tuple!(Node[], double) viterbi(Node source, Node target) {
    if(target == source) {
        debug {
            import std.stdio;
            writefln("target: %s at %x  source: %s at %x",
                     target, &target, source, &source);
        }
        return tuple([source], source.cost);
    }

    Node[] previous_path;
    Node shortest_previous_node;
    double max_cost = 0;

    foreach(previous_edge; target.previousEdges) {
        Node previous_node = previous_edge.previousNode;
        auto t = viterbi(source, previous_node);
        previous_path = t[0];
        double previous_cost = t[1];
        double cost = previous_cost + previous_edge.cost + target.cost;
        if(cost > max_cost) {
            max_cost = cost;
            shortest_previous_node = previous_node;
        }
    }

    return tuple(previous_path ~ target, max_cost);
}


unittest {
    Node BOS = new Node("BOS", 0); Node EOS = new Node("EOS", 0);
    Node A = new Node("A", 3), B = new Node("B", 1), C = new Node("C", 1);
    Node D = new Node("D", 4), E = new Node("E", 5), F = new Node("F", 3);

    connect(BOS, A, 2); connect(BOS, B, 4);
    connect(A, C, 5); connect(A, D, 1);
    connect(B, C, 3); connect(B, D, 2);
    connect(C, E, 1); connect(C, F, 1);
    connect(D, F, 3);
    connect(E, EOS, 3); connect(F, EOS, 4);

    auto t = viterbi(BOS, EOS);
    Node[] path = t[0];
    double cost = t[1];

    import std.stdio;
    foreach(node; path) {
        write(node, " ");
    }
    write("\n");
    writefln("cost: %f", cost);
}
