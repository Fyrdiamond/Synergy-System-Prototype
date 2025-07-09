class MenuState implements State {
    // the starting state

    // keep track of what was clicked
    Button clickedButton;

    Button[] buttons;

    PVector mouseLocation;

    MenuState() {
        // create the buttons
        this.buttons = new Button[]{
            new Button(width * 1 / 3, height * 4 / 11, width * 1 / 3, height / 11, "New", () -> fsm.changeState("settings")),
            new Button(width * 1 / 3, height * 6 / 11, width * 1 / 3, height / 11, "Load", () -> fsm.changeState("load"))
        };
    }

    void handleEvent(Event event) {
        // handle events from the user
        switch (event.type) {
            case MOUSE_DOWN:
                this.handleMouseDown(event.data);
                break;
            case MOUSE_UP:
                this.handleMouseUp(event.data);
                break;
            case KEY_DOWN:
                this.handleKey(event.data);
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

    void handleKey(Object data) {
        // handle shortcuts
        switch ((char)data) {
            case 'n':
                fsm.changeState("settings");
                break;
            case 'l':
                fsm.changeState("load");
                break;
        }
    }

    Button getClickedButton(PVector location) {
        // figure out which button was clicked, if any
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
    }
}
