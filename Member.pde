class Member {
    // the title and description
    TextField title;
    TextField description;

    // the group it's contained within
    Group group;

    // a unique identifer for saving / loading
    int value;

    // a list of all connections it has
    ArrayList<Connection> connections;

    Member(Group group) {
        // create a new member
        this.title = new TextField();
        this.description = new TextField();
        this.group = group;

        this.connections = new ArrayList<Connection>();
    }

    Member(String t, String d, int v) {
        // create a member based on loaded data
        this.title = new TextField(t);
        this.description = new TextField(d);

        this.connections = new ArrayList<Connection>();
        this.value = v;
    }

    // -------------------------------------------------------------------------
    // text related methods
    void keyPressedTitle(char c) {
        this.title.keyPressed(c);
    }

    void keyDeletePressedTitle() {
        this.title.keyDeletePressed();
    }

    void keyPressedDescription(char c) {
        this.description.keyPressed(c);
    }

    void keyDeletePressedDescription() {
        this.description.keyDeletePressed();
    }
    // -------------------------------------------------------------------------

    void addConnection(Connection c) {
        // add a connection
        this.connections.add(c);
    }

    boolean isConnectedTo(Member other) {
        // check if the member is connected to a different one
        for (Connection conn : this.connections) {
            if (conn.connects(other)) {
                return true;
            }
        }
        return false;
    }
}
