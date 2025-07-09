class FiniteStateMachine {
    // the finite state machine tracking what state is active

    // it has a current state and a list of all states
    State currentState;
    HashMap<String, State> states;

    FiniteStateMachine() {
        // create each state
        this.currentState = new MenuState();
        this.states = new HashMap<String, State>();
        this.states.put("menu", this.currentState);
        this.states.put("editor", new EditorState());
        this.states.put("settings", new SettingsState());
        this.states.put("save", new SaveState());
        this.states.put("load", new LoadState());
    }

    State getState(String name) {
        // get a state by name
        return this.states.get(name);
    }

    void changeState(String name) {
        // go to a new state
        this.currentState = this.states.get(name);
    }

    void handleEvent(Event event) {
        // pass an event on to the current state
        this.currentState.handleEvent(event);
    }

    void draw() {
        // draw the current state
        this.currentState.draw();
    }
}
