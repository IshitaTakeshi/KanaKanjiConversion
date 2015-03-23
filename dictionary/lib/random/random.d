module lib.random.random;  //FIXME the module name is too nested

import std.random : uniform;
import lib.exception : ValueError;

/**
Returns random numbers from [low, high).
The random numbers are uniformly distributed.

Parameters:
    low = The beginning of the range of the distribution.
    high = The end of the range of the distribution.
    size = The size of the array.
 */
T[] randomArray(T) (T low, T high, ulong size) {
    if(low >= high) {
        throw new ValueError("low >= high");
    }

    T array[] = new T[size];
    foreach(ref e; array) {
        e = uniform(low, high);
    }
    return array;
}


///
unittest {
    double low = -100.0;
    double high = 100.0;
    ulong size = 20;

    auto array = randomArray(low, high, size);
    assert(array.length == size);
    foreach(double e; array) {
        assert(low <= e && e < high);
    }
}


//Ensure it also works if the types of the arguments are long.
unittest {
    long low = -100;
    long high = 100;
    ulong size = 20;

    auto array = randomArray(low, high, size);
    assert(array.length == size);
    foreach(long e; array) {
        assert(low <= e && e < high);
    }
}


//An exception must be thrown if low == high
unittest {
    bool failed = false;
    try {
        auto array = randomArray(10, 10, 10);
    } catch(Error e) {
        failed = true;
    }
    //must fail
    assert(failed);
}


//An empty array must be returned when 0 specified to the size.
unittest {
    assert(randomArray(0, 10, 0) == []);
}
