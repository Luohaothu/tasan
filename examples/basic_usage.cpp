#include <iostream>
#include <cstdlib>

int main() {
    // Basic heap allocation
    int* array = new int[10];
    
    // Initialize array
    for (int i = 0; i < 10; ++i) {
        array[i] = i;
    }
    
    // Use the array
    std::cout << "Array values: ";
    for (int i = 0; i < 10; ++i) {
        std::cout << array[i] << " ";
    }
    std::cout << std::endl;
    
    // Properly deallocate
    delete[] array;
    
    std::cout << "Basic ASan example completed successfully!" << std::endl;
    return 0;
}