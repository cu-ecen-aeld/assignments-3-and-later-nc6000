# Default compiler is gcc (host compiler)
COMPILER ?= gcc

# If CROSS_COMPILE is set, use its gcc
ifdef CROSS_COMPILE
COMPILER := $(CROSS_COMPILE)gcc
endif

CFLAGS := -Wall -Wextra -O2

SOURCES := writer.c
OBJECTS := writer.o

all: writer

writer: $(OBJECTS)
	$(COMPILER) $(CFLAGS) -o writer writer.o

writer.o: writer.c
	$(COMPILER) $(CFLAGS) -c writer.c -o writer.o

clean:
	rm -f writer writer.o

.PHONY: all clean

