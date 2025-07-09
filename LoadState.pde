import java.io.*;

class LoadState implements State {
    // used to select a file and load the editor's state when it was saved to that file

    // which file is being looked at
    int selectedPageIndex;
    int selectedItemIndex;
    int totalPages;
    int totalItems;

    // number of columns being viewed; 1 works best for most purposes, as file names end up quite long
    int cols;

    LoadState() {
        cols = 1;
    }

    void load(String name) {
        // load a file by its name

        // create a new editor
        EditorState editor = new EditorState();

        // setup what can't be loaded from the file
        editor.loadButtons();

        // wrap everything in a try/catch so the program can continue running if problems arise
        try {
            // get the path to the file in the Processing sketch
            String filePath = dataPath(name);

            // get the content of the file -> JSON object
            String fileContent = join(loadStrings(filePath), "\n");

            // load the JSON
            JSONObject json = parseJSONObject(fileContent);

            // get the major groups
            JSONArray groupsArray = json.getJSONArray("groups");

            // setup remaining parts of the editor based on the number of groups to be loaded
            editor.setup(groupsArray.size());

            // add each group to the editor
            for (int i = 0; i < groupsArray.size(); i++) {
                JSONObject groupJson = groupsArray.getJSONObject(i);
                Group group = new Group(groupJson.getString("title"), groupJson.getString("description"), groupJson.getInt("value"));
                editor.groups.set(i, group);
            }

            // get every member
            JSONArray membersArray = json.getJSONArray("members");

            // load every member into the program
            for (int i = 0; i < membersArray.size(); i++) {
                JSONObject memberJson = membersArray.getJSONObject(i);
                Member member = new Member(memberJson.getString("title"), memberJson.getString("description"), memberJson.getInt("value"));

                // figure out which group to add it to
                int groupValue = memberJson.getInt("groupValue");
                for (Group group : editor.groups) {
                    if (group.value == groupValue) {
                        member.group = group;
                        break;
                    }
                }
                editor.members.add(member);
            }

            // get every connection
            JSONArray connectionsArray = json.getJSONArray("connections");

            // load every connection into the program
            for (int i = 0; i < connectionsArray.size(); i++) {
                JSONObject connectionJson = connectionsArray.getJSONObject(i);

                // figure out which members it connects
                int m1Value = connectionJson.getInt("m1");
                int m2Value = connectionJson.getInt("m2");
                int value = connectionJson.getInt("value");
                Member m1 = null, m2 = null;
                for (Member member : editor.members) {
                    if (member.value == m1Value) {
                        m1 = member;
                    }
                    if (member.value == m2Value) {
                        m2 = member;
                    }
                }
                if (m1 != null && m2 != null) {
                    // create the connection if it actually exists
                    Connection connection = new Connection(connectionJson.getString("title"), connectionJson.getString("description"), m1, m2, value);
                    editor.connections.add(connection);
                }
            }

            // load basic variables
            editor.groupDrawingRadius = json.getFloat("groupDrawingRadius");
            editor.creatingConnection = json.getBoolean("creatingConnection");
            editor.membersPage = json.getInt("membersPage");
            editor.connectionsPage = json.getInt("connectionsPage");

            // figure out which member is selected
            int selectedMemberValue = json.getInt("selectedMember");
            editor.selectedMember = null;
            for (Member member : editor.members) {
                if (member.value == selectedMemberValue) {
                    editor.selectedMember = member;
                    break;
                }
            }

            // figure out which connection is selected
            int selectedConnectionValue = json.getInt("selectedConnection");
            editor.selectedConnection = null;
            for (Connection connection : editor.connections) {
                if (connection.value == selectedConnectionValue) {
                    editor.selectedConnection = connection;
                    break;
                }
            }

            // add the new state to the finite state machine and switch to it
            fsm.states.put("editor", editor);
            fsm.changeState("editor");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    String getSelectedFile() {
        // figure out the name of the file currently selected
        String[] files = listPaths(dataPath(""));
        int rows = 7;
        int itemsPerPage = cols * rows;
        int startIndex = selectedPageIndex * itemsPerPage;
        int index = startIndex + selectedItemIndex;

        if (index < files.length) {
            return files[index];
        } else {
            return null;
        }
    }

    void handleEvent(Event evt) {
        // handle shortcuts being used
        if (evt.type == EventType.KEY_DOWN) {
            char c = (char) evt.data;
            switch (c) {
                // move
                case 'a':
                    selectedPageIndex = (selectedPageIndex - 1 + totalPages) % totalPages;
                    break;
                case 'd':
                    selectedPageIndex = (selectedPageIndex + 1) % totalPages;
                    break;
                case 'w':
                    selectedItemIndex = (selectedItemIndex - 1 + totalItems) % totalItems;
                    break;
                case 's':
                    selectedItemIndex = (selectedItemIndex + 1) % totalItems;
                    break;
                // select
                case '\n':
                    println("load");
                    String selectedFile = getSelectedFile();
                    if (selectedFile != null) {
                        this.load(selectedFile);
                    }
                    break;
                // return
                case 27:
                    key = 0;
                    fsm.changeState("menu");
            }
        }
    }

    void draw() {
        // draw all the filenames
        background(0x4c);

        // get the list of files and where to start
        String[] files = listPaths(dataPath(""));
        int rows = 7;
        int itemsPerPage = cols * rows;
        int startIndex = selectedPageIndex * itemsPerPage;
        int index = startIndex;

        // get the size of each item
        int cellWidth = width / cols;
        int cellHeight = height / rows;

        for (int y = 0; y < rows; y++) {
            for (int x = 0; x < cols; x++) {
                if (index < files.length) {
                    // draw the file at the current index, if it exists
                    String fileName = files[index];
                    int posX = x * cellWidth;
                    int posY = y * cellHeight;

                    if (index == startIndex + selectedItemIndex) {
                        fill(200, 200, 255);
                    } else {
                        fill(255);
                    }
                    rect(posX, posY, cellWidth, cellHeight);
                    fill(0);
                    textAlign(CENTER, CENTER);
                    text(fileName, posX + cellWidth / 2, posY + cellHeight / 2);
                    index++;
                }
            }
        }
    }
}
