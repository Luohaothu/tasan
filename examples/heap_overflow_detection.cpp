#include <iostream>
#include <cstdlib>

int main() {
    // Allocate array of size 10
    int* array = new int[10];
    
    // Initialize array within bounds
    for (int i = 0; i < 10; ++i) {
        array[i] = i;
    }
    
    std::cout << "Array initialized with values 0-9" << std::endl;
    
    // This would cause a heap overflow error - comment out for normal operation
    // array[10] = 42;  // Buffer overflow here
    
    // This would cause a heap underflow error - comment out for normal operation
    // array[-1] = 42;  // Buffer underflow here
    
    // Proper cleanup
    delete[] array;
    
    std::cout << "Heap overflow detection example completed!" << std::endl;
    std::cout << "Uncomment the overflow/underflow lines to see ASan in action." << std::endl;
    
    return 0;
}