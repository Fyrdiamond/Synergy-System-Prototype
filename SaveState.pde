import java.io.*;

class SaveState implements State {
    // used to save the current editor state to a file with a given name
    Button button;
    TextField name;
    String fakeName;

    boolean buttonSelected;

    SaveState() {
        // set the fields
        this.buttonSelected = false;
        this.name = new TextField();
        this.randomiseFakeName();
    }

    void selectButton() {
        // select the button or save, giving the user a slight buffer
        if (this.buttonSelected) this.save();
        else this.buttonSelected = true;
    }

    void deselectButton() {
        // deselect the button or exit, giving the user a slight buffer
        if (this.buttonSelected) this.buttonSelected = false;
        else fsm.changeState("editor");
    }

    void save() {
        // convert the current state to a JSON object, store it as plaintext
        EditorState editor = (EditorState) fsm.getState("editor");

        JSONObject json = new JSONObject();

        // set up the groups
        JSONArray groupsArray = new JSONArray();
        for (Group group : editor.groups) {
            JSONObject groupJson = new JSONObject();
            groupJson.setString("title", group.title.getCharsAsString());
            groupJson.setString("description", group.description.getCharsAsString());
            groupJson.setInt("value", group.value);
            groupsArray.append(groupJson);
        }
        json.setJSONArray("groups", groupsArray);

        // set up the members
        JSONArray membersArray = new JSONArray();
        for (Member member : editor.members) {
            JSONObject memberJson = new JSONObject();
            memberJson.setString("title", member.title.getCharsAsString());
            memberJson.setString("description", member.description.getCharsAsString());
            memberJson.setInt("value", member.value);
            memberJson.setInt("groupValue", member.group.value);
            membersArray.append(memberJson);
        }
        json.setJSONArray("members", membersArray);

        // set up the connections
        JSONArray connectionsArray = new JSONArray();
        for (Connection connection : editor.connections) {
            JSONObject connectionJson = new JSONObject();
            connectionJson.setString("title", connection.title.getCharsAsString());
            connectionJson.setString("description", connection.description.getCharsAsString());
            connectionJson.setInt("m1", connection.m1.value);
            connectionJson.setInt("m2", connection.m2.value);
            connectionJson.setInt("value", connection.value);
            connectionsArray.append(connectionJson);
        }
        json.setJSONArray("connections", connectionsArray);

        // set up the basic variables
        json.setFloat("groupDrawingRadius", editor.groupDrawingRadius);
        json.setBoolean("creatingConnection", editor.creatingConnection);
        json.setInt("membersPage", editor.membersPage);
        json.setInt("connectionsPage", editor.connectionsPage);

        // if a member of connection are selected, add the value they hold; otherwise, -1 is used (unlikely to have that many objects)
        if (editor.selectedMember != null) {
            json.setInt("selectedMember", editor.selectedMember.value);
        } else {
            json.setInt("selectedMember", -1);
        }

        if (editor.selectedConnection != null) {
            json.setInt("selectedConnection", editor.selectedConnection.value);
        } else {
            json.setInt("selectedConnection", -1);
        }

        // wrap the writing in a try/catch
        try {
            PrintWriter writer = new PrintWriter(dataPath(this.name.getCharsAsString()));
            writer.println(json.toString());
            writer.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    void randomiseFakeName() {
        // create a random name
        this.fakeName = "save_" + (int)(Math.random() * 1000000000);
    }

    void handleEvent(Event evt) {
        // handle an event
        // -> if it's a click, check whether it hits the button
        // -> if it's a key press, check whether it's text or a shortcut
        if (evt.type == EventType.MOUSE_UP) {
            PVector location = (PVector) evt.data;
            if (
                location.x > width / 3
                && location.x < width * 2 / 3
                && location.y > height / 3
                && location.y < height * 2 / 3
            ) this.selectButton();
            else this.deselectButton();
        } else if (evt.type == EventType.KEY_DOWN) {
            char c = (char) evt.data;
            if (c == 27) { // ESC key -> Processing will quit if we don't tell it something else was pressed
                key = 0;
                this.deselectButton();
            } else if (c == '\n') {
                this.selectButton();
            } else if (c == 8) {
                try {
                    this.name.keyDeletePressed();
                } catch (Exception e) {
                    this.randomiseFakeName();
                }
            } else {
                this.name.keyPressed(c);
            }
        }
    }

    void draw() {
        // draw the current name (either user typed or random)
        background(0x4c);

        File file = new File(dataPath(this.name.getCharsAsString()));

        // if the file is in use, fill with red; otherwise green
        if (file.exists()) fill(0x42, 0x18, 0x18);
        else fill(0x18, 0x42, 0x18);

        // if the button is selected, highlight green; otherwise red
        if (this.buttonSelected) stroke(0x00, 0xff, 0x00);
        else stroke(0xff, 0x00, 0x00);

        // draw the button
        rect(width / 3, height / 3, width / 3, height / 3);
        fill(0xc3);
        String text;
        if (this.name.getLength() > 0) {
            text = this.name.getCharsAsString();
        } else {
            text = this.fakeName;
        }
        text(text, width / 3, height / 3, width / 3, height / 3);
    }
}
