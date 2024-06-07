gcc -c printf.cpp -o printfcpp.o
nasm -f win64 printf.asm -o printfasm.o
gcc -o printf.exe printfcpp.o printfasm.o -lgcc -l kernel32
