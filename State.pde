interface State {
    // what every state in the finite state machine must include
    void handleEvent(Event evt);
    void draw();
}
