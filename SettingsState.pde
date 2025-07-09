class SettingsState implements State {
    // settings for setting up the editor
    // -> number of groups to start with
    Button[] buttons;
    int numGroups;

    // keeps track of what's been clicked, similarly to the menu
    Button clickedButton;

    SettingsState() {
        // create buttons
        this.buttons = new Button[]{
            new Button(width * 11 / 15, height / 5, width / 15, height / 10, "+", () -> this.numGroups++),
            new Button(width * 11 / 15, height * 3 / 10, width / 15, height / 10, "-", () -> this.numGroups = max(1, this.numGroups - 1)),
            new Button(width / 5, height * 3 / 5, width * 3 / 5, height / 5, "Open editor", () -> this.openEditor())
        };

        // set default groups
        this.numGroups = 10;
    }

    void openEditor() {
        // setup and switch to the editor
        ((EditorState) fsm.getState("editor")).setup(this.numGroups);
        fsm.changeState("editor");
    }

    void handleEvent(Event event) {
        // handle user interactions
        switch (event.type) {
            case MOUSE_DOWN:
                this.handleMouseDown(event.data);
                break;
            case MOUSE_UP:
                this.handleMouseUp(event.data);
                break;
            case KEY_DOWN:
                this.handleKeyDown(event.data);
                break;
        }
    }

    void handleMouseDown(Object data) {
        // start looking at a click event -> track where the mouse starts
        PVector clickLocation = (PVector) data;
        this.clickedButton = this.getClickedButton(clickLocation);
    }

    void handleMouseUp(Object data) {
        // stop looking at a click event -> if the mouse started and ended on the same button, click it
        // this lets a user move away if they clicked the wrong option
        PVector endClickLocation = (PVector) data;
        Button endClickedButton = this.getClickedButton(endClickLocation);
        if (clickedButton != null && endClickedButton != null && clickedButton == endClickedButton) {
            clickedButton.handleClick();
        }
        this.clickedButton = null;
    }

    void handleKeyDown(Object data) {
        // handle shortcuts
        switch ((char) data) {
            case 27:
                key = 0;
                fsm.changeState("menu");
            case '\n':
                this.openEditor();
                break;
            case '-':
                this.numGroups = max(1, this.numGroups - 1);
                break;
            case '=': // '+' button when shift is not pressed
                this.numGroups++;
                break;
        }
    }

    Button getClickedButton(PVector location) {
        // check if the mouse was over a button, and if so return it
        for (Button button : this.buttons) {
            if (button.containsLocation(location)) {
                return button;
            }
        }
        return null;
    }

    void draw() {
        // draw every button
        background(0x4c);

        for (Button button : this.buttons) {
            fill(0x73);
            stroke(0xa9);
            button.draw();
        }

        if (this.clickedButton != null) {
            fill(0x63);
            stroke(0x99);
            this.clickedButton.draw();
        }

        // draw the current number of groups to make
        fill(0x73);
        stroke(0xa9);
        rect(width / 5, height / 5, width * 8 / 15, height / 5);
        textAlign(CENTER, CENTER);
        textSize(height / 15);
        fill(0x0);
        text("Groups to create: " + this.numGroups, width * 7 / 15, height * 3 / 10);
    }
}
