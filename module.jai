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

Circular_Array :: struct($T: Type, $CAPACITY: int) {
    data: [CAPACITY]T;
    head: int = 0;
    tail: int = 0;
    count: int = 0;
}


push :: (arr: *$A/Circular_Array, item: A.T) {
    arr.data[arr.head] = item;
    arr.head = (arr.head + 1) % A.CAPACITY;
    
    if arr.count == A.CAPACITY {
        arr.tail = (arr.tail + 1) % A.CAPACITY;
    } else {
        arr.count += 1;
    }
}

pop :: (arr: *$A/Circular_Array) -> A.T, bool {
    if arr.count == 0 {
        return .{}, false;
    }
    
    item := arr.data[arr.tail];
    arr.tail = (arr.tail + 1) % A.CAPACITY;
    arr.count -= 1;
    
    return item, true;
}

peek :: (arr: *$A/Circular_Array) -> A.T, bool {
    if arr.count == 0 {
        return .{}, false;
    }
    return arr.data[arr.tail], true;
}

is_empty :: (arr: *$A/Circular_Array) -> bool {
    return arr.count == 0;
}

is_full :: (arr: *$A/Circular_Array) -> bool {
    return arr.count == A.CAPACITY;
}

clear :: (arr: *$A/Circular_Array) {
    arr.head = 0;
    arr.tail = 0;
    arr.count = 0;
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

