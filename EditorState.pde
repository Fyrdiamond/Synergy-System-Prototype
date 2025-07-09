import java.util.Collections;
import java.util.HashSet;
import java.io.Serializable;

enum FocusArea {
    // what textbox has been clicked
    // -> {group | member | connection} {title | description}
    G_TITLE,
    G_DESCRIPTION,
    M_TITLE,
    M_DESCRIPTION,
    C_TITLE,
    C_DESCRIPTION,
    NONE
}

enum FocusType {
    // what appears in the bottom
    GROUP,
    CONNECTION,
    MEMBER
}

class EditorState implements State {
    // buttons for each section
    Button[] groupButtons;
    Button[] memberButtons;
    Button[] connectionButtons;

    // tracking for what to interact with / draw to screen
    FocusArea focusArea;
    FocusType focusType;

    // storage of the important information
    ArrayList<Group> groups;
    ArrayList<Member> members;
    ArrayList<Connection> connections;

    // size of a group (the circles)
    float groupDrawingRadius;

    // whether the user is currently trying to make a new connection between members
    boolean creatingConnection;

    // the current things being viewed
    Member selectedMember;
    Connection selectedConnection;
    int membersPage;
    int connectionsPage;

    EditorState() {
        // set up to buttons
        this.loadButtons();

        // set the size of a group
        this.groupDrawingRadius = width / 80;
    }

    void loadButtons() {
        // loads all the buttons and the lambda expressions they call
        this.groupButtons = new Button[]{
            new Button(0, height * 2 / 3, width, height / 12, "", () -> this.focusArea = FocusArea.G_TITLE), // group -> title
            new Button(width / 4, height * 3 / 4, width / 2, height / 4, "", () -> this.focusArea = FocusArea.G_DESCRIPTION), // group -> description
            new Button(width * 3 / 4, height * 3 / 4, width / 4, height / 8, "Add Member", () -> this.addMemberToGroup()), // group -> create a new member
            new Button(width * 3 / 4, height * 7 / 8, width / 4, height / 8, "Sort Members", () -> this.sortMembers()) // group -> sort members
        };
        this.memberButtons = new Button[]{
            new Button(0, height * 2 / 3, width, height / 12, "", () -> this.focusArea = FocusArea.M_TITLE), // member -> title
            new Button(width / 4, height * 3 / 4, width / 2, height / 4, "", () -> this.focusArea = FocusArea.M_DESCRIPTION), // member -> description
            new Button(width * 3 / 4, height * 7 / 12, width / 8, height / 12, "↓", () -> this.membersPageDown()), // member -> next page
            new Button(width * 7 / 8, height * 7 / 12, width / 8, height / 12, "↑", () -> this.membersPageUp()), // member -> previous page
        };
        this.connectionButtons = new Button[]{
            new Button(0, height * 2 / 3, width, height / 12, "", () -> this.focusArea = FocusArea.C_TITLE), // connection -> title
            new Button(width / 4, height * 3 / 4, width / 2, height / 4, "", () -> this.focusArea = FocusArea.C_DESCRIPTION), // connection -> description
            new Button(0, height * 3 / 4, width / 4, height / 8, "Create Connection", () -> this.createConnection()), // connection -> create new connection
            new Button(0, height * 7 / 8, width / 4, height / 8, "Sort Connections", () -> this.sortConnections()), // connection -> sort all connections
            new Button(0, height * 7 / 12, width / 8, height / 12, "↓", () -> this.connectionsPageDown()), // connection -> next page
            new Button(width / 8, height * 7 / 12, width / 8, height / 12, "↑", () -> this.connectionsPageUp()) // connection -> previous page
        };
    }

    void setup(int nGroups) {
        // sets the variables being used in the program
        this.focusArea = FocusArea.NONE;
        this.focusType = FocusType.GROUP;
        this.groups = new ArrayList<Group>();
        this.members = new ArrayList<Member>();
        this.connections = new ArrayList<Connection>();

        this.creatingConnection = false;

        this.selectedMember = null;

        this.setupGroups(nGroups);
    }

    void setupGroups(int nGroups) {
        // create each group, including a value other things can reference it by -> for saving / loading
        for (int i = 0; i < nGroups; i++) {
            Group g = new Group();
            g.value = i + 1;
            this.groups.add(g);
        }
    }

    void sortMembers() {
        // sorts all members
        this.members = sort(this.members, (Object m1, Object m2) -> this.compareMembers((Member) m1, (Member) m2));
    }

    boolean compareMembers(Member m1, Member m2) {
        // returns whether m1 is strictly greater than m2 in some metric

        // if only one is connected to the currently selected member, return the other
        Member member = this.selectedMember;
        if (this.creatingConnection) {
            if (member.isConnectedTo(m1) ^ member.isConnectedTo(m2)) {
                return member.isConnectedTo(m2);
            }
        }
        // if only one is in the current group, return it
        Group group = this.groups.get(0);
        if (group.containsMember(m1) ^ group.containsMember(m2)) {
            return group.containsMember(m1);
        }
        // return whichever one has more connections
        return this.getConnectionsToMember(m1) > this.getConnectionsToMember(m2);
    }

    void updatePrimaryGroup(int groupIndex) {
        // rotate the groups
        Collections.rotate(this.groups, -groupIndex);

        // update the title and description seen
        this.groupButtons[0].text = this.groups.get(0).title.getCharsAsString();
        this.groupButtons[1].text = this.groups.get(0).description.getCharsAsString();

        // update the program's focus
        this.focusArea = FocusArea.NONE;
        this.focusType = FocusType.GROUP;
    }

    PVector getGroupCoordinates(int groupIndex) {
        // return the coordinates of a given group

        // get the center of the group viewing area
        int x = width / 2;
        int y = height / 3;

        // set how much groups can vary within it
        int xVariation = width / 5;
        int yVariation = height * 4 / 15;

        // calculate the group's position based on how far through the list of groups it is
        x += sin(TWO_PI * groupIndex / this.groups.size()) * xVariation;
        y += cos(TWO_PI * groupIndex / this.groups.size()) * yVariation;

        return new PVector(x, y);
    }

    boolean locationOverGroup(PVector location, int groupIndex) {
        // check if a group contains a coordinate pair
        PVector groupLocation = this.getGroupCoordinates(groupIndex);
        return PVector.sub(location, groupLocation).mag() < this.groupDrawingRadius;
    }

    void addMemberToGroup() {
        // add a new member to the current group

        // create the member using the current group
        Member member = new Member(this.groups.get(0));

        // set a value for other things to reference it by -> for saving / loading
        member.value = this.members.size();

        // add it to the editor's list of members
        this.members.add(member);

        // add it to the current group
        this.groups.get(0).addMember(member);

        // disable connection creation if it was enabled, so as to not accidentally create a connection
        this.creatingConnection = false;

        // select the newly created member
        this.selectMember(this.members.size() - 1);
    }

    int getConnectionsToMember(Member member) {
        // count how many connections a member has
        return member.connections.size();
    }

    int connectionsInGroup(Group group) {
        // count how many connections a group has
        // one per connection within a group
        // one for each other group it has one or more connections to

        int totalConnections = 0;

        // create sets of unique items so no duplicates are counted
        HashSet<Connection> uniqueConnections = new HashSet<Connection>();
        HashSet<Group> connectedGroups = new HashSet<Group>();

        for (Member member : group.members) {
            // add every connection within a member in the group
            for (Connection connection : member.connections) {
                uniqueConnections.add(connection);
            }
        }

        for (Connection connection : uniqueConnections) {
            // check each connection added:

            // if the connection is within the group, increase the total
            // if it isn't, add the group it connects to to the set of unique groups
            if (connection.m1.group == connection.m2.group) {
                totalConnections++;
            } else {
                connectedGroups.add(connection.m1.group);
                connectedGroups.add(connection.m2.group);
            }
        }

        for (Group g2 : connectedGroups) {
            // increment total for each group that isn't this one
            if (g2 != group) totalConnections++;
        }

        return totalConnections;
    }

    int maxConnectionsInGroup(Group group) {
        // get the maximum number of connections a group could currently have
        // given by (x^2 - x) / 2 + G - 1
        // x -> number of members a group has
        // G -> total number of groups
        return group.members.size() * (group.members.size() - 1) / 2 + this.groups.size() - 1;
    }

    void createConnection() {
        // set the connection creation flag
        // done because only one member can be selected at a time
        if (this.selectedMember != null) this.creatingConnection = true;
    }

    void sortConnections() {
        // sort all connections
        this.connections = sort(this.connections, (Object c1, Object c2) -> this.compareConnections((Connection) c1, (Connection) c2));
    }

    boolean compareConnections(Connection c1, Connection c2) {
        // returns whether c1 is strictly greater than c2 in some metric

        // if only one of them connects to the current member, return it
        Member m = this.selectedMember;
        if ((c1.m1 == m || c1.m2 == m) ^ (c2.m1 == m || c2.m2 == m)) {
            if (c1.m1 == m || c1.m2 == m) {
                return true;
            }
        }
        // return whichever comes first alphabetically
        return c1.title.getCharsAsString().compareTo(c2.title.getCharsAsString()) == 1;
    }

    void selectMember(int index) {
        // check whether the connection creation flag is set

        if (!this.creatingConnection) {
            // set the currently selected member
            this.selectedMember = this.members.get(index);

            // update what is being focused
            this.focusArea = FocusArea.M_TITLE;
            this.focusType = FocusType.MEMBER;

            // update the title and description text boxes
            this.memberButtons[0].text = this.selectedMember.title.getCharsAsString();
            this.memberButtons[1].text = this.selectedMember.description.getCharsAsString();
        } else {
            // attempt to create a new connection with the currently selected member

            // block self connections
            if (this.selectedMember == this.members.get(index)) return;

            // block duplicate connections
            for (Connection connection : this.connections) {
                if (connection.connects(this.selectedMember) && connection.connects(this.members.get(index))) {
                    this.creatingConnection = false;
                    return;
                }
            }

            // create the connection
            Connection connection = new Connection(this.selectedMember, this.members.get(index));

            // set a value for the connection -> for saving / loading
            connection.value = this.connections.size();

            // add the connection to the editor and each member it connects
            this.connections.add(connection);
            this.selectedMember.addConnection(connection);
            this.members.get(index).addConnection(connection);

            // stop attempting to create a new connection
            this.creatingConnection = false;

            // select the newly created connection
            this.selectConnection(this.connections.size() - 1);
        }
    }

    void selectConnection(int index) {
        // selects a connection
        this.selectedConnection = this.connections.get(index);

        // update the current focus
        this.focusArea = FocusArea.C_TITLE;
        this.focusType = FocusType.CONNECTION;

        // update the title and description being displayed
        this.connectionButtons[0].text = this.selectedConnection.title.getCharsAsString();
        this.connectionButtons[1].text = this.selectedConnection.description.getCharsAsString();
    }

    void membersPageUp() {
        // move up in the members list
        if (this.membersPage > 0)
            this.membersPage--;
        else
            this.membersPage = (this.members.size() - 1) / 6;
    }

    void membersPageDown() {
        // move down in the members list
        if ((this.members.size() - 1) / 6 > this.membersPage)
            this.membersPage++;
        else
            this.membersPage = 0;
    }

    void connectionsPageUp() {
        // move up in the connections list
        if (this.connectionsPage > 0)
            this.connectionsPage--;
        else
            this.connectionsPage = (this.connections.size() - 1) / 4;
    }

    void connectionsPageDown() {
        // move down in the connections list
        if ((this.connections.size() - 1) / 4 > this.connectionsPage)
            this.connectionsPage++;
        else
            this.connectionsPage = 0;
    }

    void handleEvent(Event evt) {
        // handle an incoming event based on its type
        switch (evt.type) {
            case MOUSE_UP:
                this.handleMouseUp(evt.data);
                break;
            case KEY_DOWN:
                if ((char) evt.data == 27){ // 27: key code for ESC--separate handling because ESC will close Processing
                    this.handleEscapePress();
                } else {
                    this.handleKeyDown(evt.data);
                }
        }
    }

    void handleEscapePress() {
        // tell processing escape wasn't pressed
        key = 0;

        // go backwards a bit
        if (this.focusArea == FocusArea.NONE) {
            if (this.focusType == FocusType.GROUP) fsm.changeState("settings");
            else this.focusType = FocusType.GROUP;
        } else {
            this.focusArea = FocusArea.NONE;
        }
    }

    void handleKeyDown(Object c) {
        // handle a key press based on the current focus
        switch (this.focusArea) {
            // NONE is the only case that treats keys as shortcuts
            // all others treat keys as regular typing within a text box
            case NONE:
                switch ((char) c) {
                    case 'a':
                        this.updatePrimaryGroup(-1);
                        break;
                    case 'd':
                        this.updatePrimaryGroup(1);
                        break;
                    case 's':
                        this.save();
                        break;
                }
                break;
            case G_TITLE:
                if (key == 8) {
                    try {
                        this.groups.get(0).keyDeletePressedTitle();
                    } catch (Exception e) {}
                } else if (key == '\n') {
                    this.focusArea = FocusArea.NONE;
                } else {
                    this.groups.get(0).keyPressedTitle((char) c);
                }
                this.groupButtons[0].text = this.groups.get(0).title.getCharsAsString();
                break;
            case G_DESCRIPTION:
                if (key == 8) {
                    try {
                        this.groups.get(0).keyDeletePressedDescription();
                    } catch (Exception e) {}
                } else {
                    this.groups.get(0).keyPressedDescription((char) c);
                }
                this.groupButtons[1].text = this.groups.get(0).description.getCharsAsString();
                break;
            case M_TITLE:
                if (key == 8) {
                    try {
                        this.selectedMember.keyDeletePressedTitle();
                    } catch (Exception e) {}
                } else if (key == '\n') {
                    this.focusArea = FocusArea.NONE;
                } else {
                    this.selectedMember.keyPressedTitle((char) c);
                }
                this.memberButtons[0].text = this.selectedMember.title.getCharsAsString();
                break;
            case M_DESCRIPTION:
                if (key == 8) {
                    try {
                        this.selectedMember.keyDeletePressedDescription();
                    } catch (Exception e) {}
                } else {
                    this.selectedMember.keyPressedDescription((char) c);
                }
                this.memberButtons[1].text = this.selectedMember.description.getCharsAsString();
                break;
            case C_TITLE:
                if (key == 8) {
                    try {
                        this.selectedConnection.keyDeletePressedTitle();
                    } catch (Exception e) {}
                } else if (key == '\n') {
                    this.focusArea = FocusArea.NONE;
                } else {
                    this.selectedConnection.keyPressedTitle((char) c);
                }
                this.connectionButtons[0].text = this.selectedConnection.title.getCharsAsString();
                break;
            case C_DESCRIPTION:
                if (key == 8) {
                    try {
                        this.selectedConnection.keyDeletePressedDescription();
                    } catch (Exception e) {}
                } else {
                    this.selectedConnection.keyPressedDescription((char) c);
                }
                this.connectionButtons[1].text = this.selectedConnection.description.getCharsAsString();
                break;
        }
    }

    void handleMouseUp(Object data) {
        // handle a click based on what section it appeared in

        // cast the event's data to a PVector
        PVector location = (PVector) data;
        if (location.y < height * 2 / 3) { // 2/3 is the dividing line between the bottom section (current selection & commands for selecting)
            if (location.x < width / 4) { // 1/4 is the dividing line between the groups (center) and connections (left)
                this.handleLeftPress(location);
            } else if (location.x < width * 3 / 4) { // 3/4 is the dividing line between the groups (center) and members (right)
                this.handleCenterPress(location);
            } else {
                this.handleRightPress(location);
            }
        } else {
            this.handleBottomPress(location);
        }
    }

    void handleLeftPress(PVector location) {
        // a click in the connections area

        if (location.y > height / 12 && location.y < height * 7 / 12) {
            // if the click happens within the area showing what connections exist, select the clicked connection
            int index = (int) ((location.y * 8 / height) - 2.0/3.0) + connectionsPage * 4;
            if (this.connections.size() > index) this.selectConnection(index);
        } else {
            // if the click is below the area showing what connections exist, update what page is being viewed
            if (this.connectionButtons[4].containsLocation(location)) this.connectionButtons[4].handleClick();
            else if (this.connectionButtons[5].containsLocation(location)) this.connectionButtons[5].handleClick();
        }
    }

    void handleCenterPress(PVector location) {
        // a click in the groups area
        // constant time function to figure out what was clicked, with no preference given to any group

        // get a vector from the center to the click's location
        PVector diff = PVector.sub(location, new PVector(width / 2, height / 3));

        // create a new vector acting as the vector to compare to
        // angle between two vectors is limited, so we ensure the angle calculated will be increasing in the counterclockwise direction
        PVector base;
        if (diff.x > 0) {
            base = new PVector(0, 1); // down is 0, up to PI when up
        } else {
            base = new PVector(0, -1); // up is 0, up to PI when down
        }

        // angle: the angle between the click's location and our base vector, add PI if it's on the left side
        // then constrain the angle based on the number of groups
        float angle = (PVector.angleBetween(diff, base) + (diff.x <= 0 ? PI : 0)) * this.groups.size() / TWO_PI + 0.5;
        angle %= this.groups.size();
        int groupIndex = int(angle);

        // check if a group was clicked, either rotating to that group or deselecting whatever focus we had
        if (locationOverGroup(location, groupIndex)) {
            this.updatePrimaryGroup(groupIndex);
        } else {
            this.focusArea = FocusArea.NONE;
        }
    }

    void handleRightPress(PVector location) {
        // click in the members area
        if (location.y > height / 12 && location.y < height * 7 / 12) {
            // if the click happens within the area showing what members exist, select the clicked member
            int index = (int) (location.y * 12 / height) - 1 + membersPage * 6;
            if (this.members.size() > index) this.selectMember(index);
        } else {
            // if the click is below the area showing what members exist, update what page is being viewed
            if (this.memberButtons[2].containsLocation(location)) this.memberButtons[2].handleClick();
            else if (this.memberButtons[3].containsLocation(location)) this.memberButtons[3].handleClick();
        }
    }

    void handleBottomPress(PVector location) {
        // click in the bottom area:
        // - title/description of the current selection
        // - sorting to view important members/connections
        // - member/connection creation buttons

        // creation / sorting
        if (this.groupButtons[2].containsLocation(location))                this.groupButtons[2].handleClick();
        else if (this.groupButtons[3].containsLocation(location))           this.groupButtons[3].handleClick();
        else if (this.connectionButtons[2].containsLocation(location))      this.connectionButtons[2].handleClick();
        else if (this.connectionButtons[3].containsLocation(location))      this.connectionButtons[3].handleClick();
        else

        // title / description of current focus
        if (this.focusType == FocusType.GROUP) {
            if (this.groupButtons[0].containsLocation(location))            this.groupButtons[0].handleClick();
            else if (this.groupButtons[1].containsLocation(location))       this.groupButtons[1].handleClick();
        } else if (this.focusType == FocusType.MEMBER) {
            if (this.memberButtons[0].containsLocation(location))           this.memberButtons[0].handleClick();
            else if (this.memberButtons[1].containsLocation(location))      this.memberButtons[1].handleClick();
        } else {
            if (this.connectionButtons[0].containsLocation(location))       this.connectionButtons[0].handleClick();
            else if (this.connectionButtons[1].containsLocation(location))  this.connectionButtons[1].handleClick();
        }
    }

    void draw() {
        // draw everything
        background(0x4c);

        this.drawSeparators();

        this.drawCenter();

        this.drawBottom();

        this.drawLeft();

        this.drawRight();
    }

    void drawSeparators() {
        // dividing lines between each section
        fill(0x73);
        stroke(0xa9);
        line(width / 4, 0, width / 4, height * 2 / 3);
        line(width * 3 / 4, 0, width * 3 / 4, height * 2 / 3);
        line(0, height * 2 / 3, width, height * 2 / 3);
    }

    void drawCenter() {
        // area with the groups
        int numGroups = this.groups.size();

        // if focused on the group, colour it blue; otherwise, black
        if (this.focusType == FocusType.GROUP) fill(0x00, 0x00, 0xff);
        else fill(0x0);

        // draw each group
        for (int i = 0; i < numGroups; i++) {
            // get the group's location
            PVector location = this.getGroupCoordinates(i);

            // get the maximum and minimum number of connections
            int maxVal = this.maxConnectionsInGroup(this.groups.get(i));
            if (maxVal > 0) {
                int curVal = this.connectionsInGroup(this.groups.get(i));

                // colour it according to how connected it is
                stroke(
                    min(0xff * ((maxVal - curVal) * 2) / (maxVal), 0xff),
                    min(0xff * (curVal * 2) / (maxVal), 0xff),
                    0x0
                );
            } else {
                // if it can't have connections, just colour it red
                stroke(0xff, 0x00, 0x00);
            }

            // draw a circle, with the group's value in the center
            circle(location.x, location.y, this.groupDrawingRadius * 2);
            fill(0xff);
            textSize(this.groupDrawingRadius);
            text(this.groups.get(i).value, location.x, location.y);
            fill(0x00);
        }
    }

    void drawBottom() {
        // draw the buttons for sorting and creation of members / connections
        stroke(0xa9);
        fill(0x73);
        this.groupButtons[2].draw();
        fill(0x73);
        this.groupButtons[3].draw();
        fill(0x73);
        this.connectionButtons[2].draw();
        fill(0x73);
        this.connectionButtons[3].draw();

        // draw the text of whatever is currently in focus
        if (this.focusType == FocusType.GROUP) {
            stroke(0xa9);
            fill(0x73);
            if (this.focusArea == FocusArea.G_TITLE) {
                fill(0xff, 0x73, 0x73);
            }
            this.groupButtons[0].draw();
            fill(0x73);
            if (this.focusArea == FocusArea.G_DESCRIPTION) {
                fill(0xff, 0x73, 0x73);
            }
            this.groupButtons[1].drawSmallText();
        } else if (this.focusType == FocusType.MEMBER) {
            stroke(0xa9);
            fill(0x73);
            if (this.focusArea == FocusArea.M_TITLE) {
                fill(0xff, 0x73, 0x73);
            }
            this.memberButtons[0].draw();
            fill(0x73);
            if (this.focusArea == FocusArea.M_DESCRIPTION) {
                fill(0xff, 0x73, 0x73);
            }
            this.memberButtons[1].drawSmallText();
        } else {
            stroke(0xa9);
            fill(0x73);
            if (this.focusArea == FocusArea.C_TITLE) {
                fill(0xff, 0x73, 0x73);
            }
            this.connectionButtons[0].draw();
            fill(0x73);
            if (this.focusArea == FocusArea.C_DESCRIPTION) {
                fill(0xff, 0x73, 0x73);
            }
            this.connectionButtons[1].drawSmallText();
        }
    }

    void drawLeft() {
        // draw the connections area
        if (this.selectedConnection != null) {
            // if a connection is selected, draw its name, but not what it connects
            fill(0x73);
            stroke(0xa9);
            rect(0, 0, width / 4, height / 12);

            fill(0x0);
            String title;
            if (this.selectedConnection.title.getLength() > 0) {
                title = selectedConnection.title.getCharsAsString();
            } else {
                title = "<untitled>";
            }
            textSize(height / 36);
            text(title, 0, 0, width / 4, height / 12);
        } else {
            // if nothing is selected, draw a black box
            fill(0x0);
            stroke(0xa9);
            rect(0, 0, width / 4, height / 12);
        }

        for (int i = 0; i < min(4, this.connections.size() - this.connectionsPage * 4); i++) {
            // draw up to 4 of the currently visible connections
            this.drawConnection(this.connections.get(i + this.connectionsPage * 4), i + 1);
        }

        // draw the page up and down buttons
        stroke(0xa9);
        fill(0x73);
        this.connectionButtons[4].draw();
        fill(0x73);
        this.connectionButtons[5].draw();
    }

    void drawConnection(Connection connection, int baseLocation) {
        // draw a connection, including its name and the names of each thing it connects

        // get the location to draw in
        float location = baseLocation - 1 / 3.0;
        float memberLocation = baseLocation + 1 / 3.0;

        // draw the connection
        fill(0x73);
        stroke(0xa9);
        rect(0, height * location / 8, width / 4, height / 12);

        // fill the connection's name
        fill(0x0);
        String title;
        if (connection.title.getLength() > 0) {
            title = connection.title.getCharsAsString();
        } else {
            title = "<untitled>";
        }
        textSize(height / 36);
        text(title, 0, height * location / 8, width / 4, height / 12);

        // draw the boxes for what it connects
        fill(0x73);
        stroke(0xa9);
        rect(0, height * memberLocation / 8, width / 8, height / 24);
        rect(width / 8, height * memberLocation / 8, width / 8, height / 24);

        // make the text smaller
        textSize(height / 72);

        // draw the names of each member connected
        fill(0x0);
        String member1Title;
        if (connection.m1.title.getLength() > 0) {
            member1Title = connection.m1.title.getCharsAsString();
        } else {
            member1Title = "<untitled>";
        }
        text(member1Title, 0, height * memberLocation / 8, width / 8, height / 24);

        String member2Title;
        if (connection.m2.title.getLength() > 0) {
            member2Title = connection.m2.title.getCharsAsString();
        } else {
            member2Title = "<untitled>";
        }
        text(member2Title, width / 8, height * memberLocation / 8, width / 8, height / 24);
    }

    void drawRight() {
        // draw the members area
        if (this.selectedMember != null) {
            // if a member is selected, draw it
            this.drawMember(this.selectedMember, 0);
        } else {
            // if no member is selected, draw a black box
            fill(0x0);
            stroke(0xa9);
            rect(width * 3 / 4, 0, width / 4, height / 12);
        }

        // draw up to 6 of the currently visible members
        for (int i = 0; i < min(6, this.members.size() - this.membersPage * 6); i++) {
            this.drawMember(this.members.get(i + this.membersPage * 6), i + 1);
        }

        // draw the page up and down buttons
        stroke(0xa9);
        fill(0x73);
        this.memberButtons[2].draw();
        fill(0x73);
        this.memberButtons[3].draw();
    }

    void drawMember(Member member, int location) {
        // draw a member

        // start with the box behind it
        fill(0x73);
        stroke(0xa9);
        rect(width * 3 / 4, height * location / 12, width / 4, height / 12);

        // draw the title
        fill(0x0);
        String title;
        if (member.title.getLength() > 0) {
            title = member.title.getCharsAsString();
        } else {
            title = "<untitled>";
        }
        textSize(height / 36);
        text(title, width * 3 / 4, height * location / 12, width / 4, height / 12);
    }

    void save() {
        // tell the program to save its data
        fsm.changeState("save");
    }
}
