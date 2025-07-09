// sort an arraylist of generic objects, using merge sort
<T> ArrayList<T> sort(ArrayList<T> list, SortComparisonMethod comparisonMethod) {
    // fewer than 2 items and it must already be sorted
    int end = list.size();
    if (end < 2) {
        return list;
    }

    // split in two
    int start = 0;
    int mid = (end - start) / 2;
    ArrayList<T> l1 = new ArrayList<T>(mid);
    ArrayList<T> l2 = new ArrayList<T>(end - mid);

    Iterator<T> iter = list.iterator();

    for (int i = 0; i < mid; i++) {
        l1.add(iter.next());
    }

    for (int i = 0; i < end - mid; i++) {
        l2.add(iter.next());
    }

    // merge the halves after sorting them
    return merge(sort(l1, comparisonMethod), sort(l2, comparisonMethod), comparisonMethod);
}

<T> ArrayList<T> merge(ArrayList<T> l1, ArrayList<T> l2, SortComparisonMethod comparisonMethod) {
    // merge two sorted lists

    // get iterators for each
    Iterator<T> iter1 = l1.iterator();
    Iterator<T> iter2 = l2.iterator();

    // create a result arraylist
    ArrayList<T> result = new ArrayList<T>(l1.size() + l2.size());

    // set the currently viewed items
    T item1 = iter1.next();
    T item2 = iter2.next();

    // keep track of whether it has finished, and what side was last updated when finished
    boolean done = false;
    int last = 0;

    while (!done) {
        // add the 'larger' item to the front and advance its iterator
        if (comparisonMethod.isBigger(item2, item1)) {
            result.add(item2);
            if (iter2.hasNext()) item2 = iter2.next();
            else {
                done = true;
                last = 2;
            }
        } else {
            result.add(item1);
            if (iter1.hasNext()) item1 = iter1.next();
            else {
                done = true;
                last = 1;
            }
        }
    }

    done = false;

    // add the remaining items
    if (last == 2) {
        while (!done) {
            result.add(item1);
            if (iter1.hasNext()) item1 = iter1.next();
            else done = true;
        }
    } else {
        while (!done) {
            result.add(item2);
            if (iter2.hasNext()) item2 = iter2.next();
            else done = true;
        }
    }

    return result;
}
