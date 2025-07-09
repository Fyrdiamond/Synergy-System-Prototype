class Connection {
    // the members it connects
    Member m1;
    Member m2;

    // the title and description
    TextField title;
    TextField description;

    // a unique value to identify it during saving and loading
    int value;

    Connection(Member m1, Member m2) {
        // create a brand new connection
        this.m1 = m1;
        this.m2 = m2;
        this.title = new TextField();
        this.description = new TextField();
    }

    Connection(String t, String d, Member m1, Member m2, int value) {
        // create a connection based on loaded data
        this.m1 = m1;
        this.m2 = m2;
        this.title = new TextField(t);
        this.description = new TextField(d);
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

    boolean connects(Member test) {
        // whether it connects to a member
        return test == m1 || test == m2;
    }
}
