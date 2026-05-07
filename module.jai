/*

usage:

    arr: Circular_Array(int, 5);
    init(*arr);
    
    // push more than capacity, it wraps
    for 0..6 {
        push(*arr, it);
    }
    
    print("Items in circular array:\n");
    for *arr {
        print("  [%] = %\n", it_index, it);
    }

*/

#import "Basic";

Circular_Array :: struct($T: Type, $CAPACITY: int) {
    data: [CAPACITY]T;

    // these are indices
    head: int = 0; // where we currently are
    tail: int = 0; // where the start is

    count: int = 0;
    capacity :: CAPACITY;
}


carray_add :: (arr: *$A/Circular_Array, item: A.T) {
    arr.data[arr.head] = item;
    arr.head = (arr.head + 1) % A.CAPACITY;
    
    if arr.count == A.CAPACITY {
        arr.tail = (arr.tail + 1) % A.CAPACITY;
    } else {
        arr.count += 1;
    }
}

/*

[a, b, c, d] -> [b, c, d]

todo rename pop front?

*/
carray_pop :: (arr: *$A/Circular_Array) -> A.T, bool {
    if arr.count == 0 {
        return .{}, false;
    }
    
    item := arr.data[arr.tail];
    arr.tail = (arr.tail + 1) % A.CAPACITY;
    arr.count -= 1;
    
    return item, true;
}

carray_peek :: (arr: *$A/Circular_Array) -> A.T, bool {
    if arr.count == 0 {
        return .{}, false;
    }
    return arr.data[arr.tail], true;
}

// we do this by pointer to avoid the copy of the array.
carray_empty :: (arr: *$A/Circular_Array) -> bool {
    return arr.count == 0;
}

carray_full :: (arr: *$A/Circular_Array) -> bool {
    return arr.count == A.CAPACITY;
}

carray_reset :: (arr: *$A/Circular_Array) {
    arr.head = 0;
    arr.tail = 0;
    arr.count = 0;
}

carray_find :: (arr: *$A/Circular_Array, item: A.T, $compare: (A.T, A.T) -> bool = null) -> bool, int {
    #if compare {
        for arr if compare(it, item) return true, it_index;
    } else {
        for arr if it == item return true, it_index;
    }
    
    return false, -1;  // Not found.
}

for_expansion :: (arr: *$A/Circular_Array, body: Code, flags: For_Flags) #expand {
    `it_index := 0;
    index := arr.tail;
    
    while it_index < arr.count {
        `it := arr.data[index];
        #insert body;
        
        index = (index + 1) % A.CAPACITY;
        it_index += 1;
    }
}

// read-only, by value
operator [] :: (arr: $A/Circular_Array, index: int) -> A.T {
    assert(index >= 0 && index < arr.count);
    actual_index := (arr.tail + index) % A.CAPACITY;
    return arr.data[actual_index];
}

// read/write, by pointer 
operator [] :: (arr: *$A/Circular_Array, index: int) -> *A.T {
    assert(index >= 0 && index < arr.count);
    actual_index := (arr.tail + index) % A.CAPACITY;
    return *arr.data[actual_index];
}
