CC=g++
ASMBIN=nasm
 
prog: func.o main.o
	$(CC) -std=c++11 -m64 -g -o prog main.o func.o
 
func.o: func.asm
	$(ASMBIN) -o func.o -f elf64  -g -l func.lst func.asm
 
main.o: main.cpp
	$(CC) -std=c++11 -m64 -c -g -O0 main.cpp
 
clean:
	rm -f *.o  
	rm -f prog
	rm -f func.lst
