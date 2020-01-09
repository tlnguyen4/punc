int main (void) {
    int fib = 0;
    int n = 5; // load from mem
    int a = 1; // load from mem
    int b = 1; // load from mem

    while (n > 0) {
        int c = a + b;
        a = b;
        b = c;

        if (c ^ 1 - 1 == 0) { 
            n = n - 1;
        }
    }

    fib = b;
}