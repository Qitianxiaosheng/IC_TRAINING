CC = cc
LD = cc
SRCS = $(wildcard *.cpp)
OBJS = $(patsubst %cpp, %o, $(SRCS))
INCLUDE = -I./include
LIB = -L./libs -ltomcrypt

CFLAGS = -Wall -O2

TARGET = LibtomDemo

all: $(TARGET)
$(TARGET): $(OBJS)
	$(LD) -o $@ $^ $(LIB)

%.o:%.cpp
	$(CC) -c $^ $(INCLUDE) $(CFLAGS) 

clean:
	rm -f $(OBJS) $(TARGET)


@PHONY:all clean