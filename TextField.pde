import java.util.LinkedList;
import java.util.Iterator;

class TextField {
    // used to make text boxes that can be typed in -> both adding and removing characters, in regular constant time

    // use a linked list for easy traversal and tracking of each end
    private LinkedList<Character> value;
    private int length;

    TextField() {
        // create a new textfield
        this.value = new LinkedList<Character>();
    }

    TextField(String s) {
        // create a textfield from loaded data
        this.value = new LinkedList<Character>();
        char[] chars = s.toCharArray();
        for (int i = chars.length - 1; i >= 0; i--) {
            char c = chars[i];
            this.value.add(c);
        }
        this.length = s.length();
    }

    void keyPressed(char key) {
        // add a value to the end
        this.value.push(key);
        this.length++;
    }

    void keyDeletePressed() {
        // remove a value from the end
        this.value.pop();
        this.length--;
    }

    char[] getChars() {
        // return as a char*
        char[] result = new char[this.length];
        Iterator<Character> iter = this.value.descendingIterator();
        for (int i = 0; i < this.length; i++) {
            result[i] = (char) iter.next();
        }
        return result;
    }

    String getCharsAsString() {
        // return as a string
        return new String(this.getChars());
    }

    int getLength() {
        // return the current length
        return this.length;
    }
}
