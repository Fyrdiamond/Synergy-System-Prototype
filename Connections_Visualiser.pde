FiniteStateMachine fsm;

void settings() {
    // 4:3 aspect ratio, fitting up to 80% of the width or height, whichever is smaller
    int sizeFactor = (int) min(displayWidth / 5, displayHeight * 4 / 15);
    size(4 * sizeFactor, 3 * sizeFactor);
}

void setup() {
    // finite state machine to track the program's current state
    fsm = new FiniteStateMachine();
}

void draw() {
    // have the finite state machine tell the current state to draw
    fsm.draw();
}

// -----------------------------------------------------------------------------
// send all events to the finite state machine, which sends them to the proper state
void keyPressed() {
    if (!(key == CODED)) {
        fsm.handleEvent(new Event(EventType.KEY_DOWN, key));
    }
}

void mousePressed() {
    fsm.handleEvent(new Event(EventType.MOUSE_DOWN, new PVector(mouseX, mouseY)));
}

void mouseReleased() {
    fsm.handleEvent(new Event(EventType.MOUSE_UP, new PVector(mouseX, mouseY)));
}
// -----------------------------------------------------------------------------
