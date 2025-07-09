class Button {
    // a button class with listener

    // location & size
    int x;
    int y;
    int width;
    int height;

    // what it says
    String text;

    // the listener to notify when pressed
    transient ButtonCallback callback;

    Button(int x, int y, int width, int height, String text, ButtonCallback callback) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.text = text;
        this.callback = callback;
    }

    void handleClick() {
        // when clicked, call the listener
        this.callback.call();
    }

    boolean containsLocation(PVector location) {
        // check if a click is within its borders
        return (
            location.x > this.x
            && location.x < this.x + this.width
            && location.y > this.y
            && location.y < this.y + this.height
        );
    }

    void draw() {
        // draw the button

        // background first, then text
        strokeWeight(2);
        rect(this.x, this.y, this.width, this.height);

        textAlign(CENTER, CENTER);
        textSize(this.height / 3);
        fill(0x0);
        text(this.text.length() > 0 ? this.text : "<untitled>", this.x, this.y, this.width, this.height);
    }

    void drawSmallText() {
        // draw the button, but make the text size smaller -> for larger descriptive fields
        strokeWeight(2);
        rect(this.x, this.y, this.width, this.height);

        textAlign(CENTER, CENTER);
        textSize(this.height / 9); // /9 instead of /3
        fill(0x0);
        text(this.text.length() > 0 ? this.text : "<untitled>", this.x, this.y, this.width, this.height);
    }
}
