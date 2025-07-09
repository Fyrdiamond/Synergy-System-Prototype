class Event {
    // an event object passed through the fsm to a state
    EventType type; // identifies what kind of thing the user did
    Object data; // identifies what exact thing the user did
    Event(EventType type, Object data) {
        this.type = type;
        this.data = data;
    }
}
