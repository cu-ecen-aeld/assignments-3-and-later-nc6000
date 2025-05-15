# Compiler and flags
COMPILER := $(CROSS_COMPILE)gcc
CFLAGS := -Wall -Wextra -O2

# Source and object files
SOURCES := writer.c
OBJECTS := writer.o

# Default target
all: writer

# Build the writer application
writer: $(OBJECTS)
	$(COMPILER) $(CFLAGS) -o writer writer.o

# Compile source files into object files
writer.o: writer.c
	$(COMPILER) $(CFLAGS) -c writer.c -o writer.o

# Clean target
clean:
	rm -f writer writer.o

.PHONY: all clean

