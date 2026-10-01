/*

description:
    fixed size array that lets you add and remove elements easily.

motivation: 

    Most of the time you just use fixed size arrays for fixed data, eg vertices of a cube.

    Other times you want to use a fixed size array to enforce an upperbound on something rather
    than the data be fixed. When you're in this case it usually means that you'll want to append 
    and remove elements, in trying to build a datastructure that supports this, you usually end up here.

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

    index_of_next_added: int = 0; // people call this "head"
    index_of_oldest: int = 0; // people call this "tail"

    count: int = 0;
    capacity :: CAPACITY;
}


carray_add :: (arr: *$A/Circular_Array, item: A.T) {
    arr.data[arr.index_of_next_added] = item;
    arr.index_of_next_added = (arr.index_of_next_added + 1) % A.CAPACITY;
    
    if arr.count == A.CAPACITY {
        // if we were at capacity then the first assignment clobbers out the 
        // oldest element, thus we have to update.
        arr.index_of_oldest = (arr.index_of_oldest + 1) % A.CAPACITY;
    } else {
        arr.count += 1;
    }
}

/*

[a, b, c, d] -> [_, b, c, d]

pops the oldest element in the carray

*/
carray_pop :: (arr: *$A/Circular_Array) -> A.T, bool {
    if arr.count == 0 {
        return .{}, false;
    }
    
    item := arr.data[arr.index_of_oldest];
    arr.index_of_oldest = (arr.index_of_oldest + 1) % A.CAPACITY;
    arr.count -= 1;
    
    return item, true;
}

carray_peek :: (arr: *$A/Circular_Array) -> A.T, bool {
    if arr.count == 0 {
        return .{}, false;
    }
    return arr.data[arr.index_of_oldest], true;
}

// we do this by pointer to avoid the copy of the array.
carray_empty :: (arr: *$A/Circular_Array) -> bool {
    return arr.count == 0;
}

carray_full :: (arr: *$A/Circular_Array) -> bool {
    return arr.count == A.CAPACITY;
}

carray_reset :: (arr: *$A/Circular_Array) {
    arr.index_of_next_added = 0;
    arr.index_of_oldest = 0;
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
    index := arr.index_of_oldest;
    
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
    actual_index := (arr.index_of_oldest + index) % A.CAPACITY;
    return arr.data[actual_index];
}

// read/write, by pointer 
operator [] :: (arr: *$A/Circular_Array, index: int) -> *A.T {
    assert(index >= 0 && index < arr.count);
    actual_index := (arr.index_of_oldest + index) % A.CAPACITY;
    return *arr.data[actual_index];
}
