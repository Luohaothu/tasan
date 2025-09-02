#include <iostream>
#include <cstdlib>

int main() {
    // Allocate and initialize a variable
    int* ptr = new int;
    *ptr = 42;
    std::cout << "Value: " << *ptr << std::endl;
    
    // Free the memory
    delete ptr;
    std::cout << "Memory freed" << std::endl;
    
    // This would cause a use-after-free error - comment out for normal operation
    // std::cout << "Value after free: " << *ptr << std::endl;  // Use-after-free here
    
    std::cout << "Use-after-free detection example completed!" << std::endl;
    std::cout << "Uncomment the use-after-free line to see ASan in action." << std::endl;
    
    return 0;
}