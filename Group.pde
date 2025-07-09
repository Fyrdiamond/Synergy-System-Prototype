class Group {
    // a unique value used to identify it during saving / loading
    int value;

    // the title and description
    TextField title;
    TextField description;

    // a list of all members contained in the group
    ArrayList<Member> members;

    Group() {
        // create a new group
        this.members = new ArrayList<Member>();
        this.title = new TextField();
        this.description = new TextField();
    }

    Group(String t, String d, int v) {
        // create a group based on loaded data
        this.members = new ArrayList<Member>();
        this.title = new TextField(t);
        this.description = new TextField(d);
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

    void addMember(Member member) {
        // add a new member
        this.members.add(member);
    }

    boolean containsMember(Member member) {
        // check if a member exists
        return this.members.contains(member);
    }
}
