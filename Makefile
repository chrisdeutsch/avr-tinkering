# General settings
MCU        = attiny45
F_CPU      = 1000000UL
TARGET     = main

# Programmer settings
PROGRAMMER_TYPE = avrisp
PROGRAMMER_PORT = /dev/ttyACM0
PROGRAMMER_BAUD = 19200

# Toolset paths
COMPILER_PREFIX = /home/chris/.arduino15/packages/arduino/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7/bin
CC              = $(COMPILER_PREFIX)/avr-gcc
CXX             = $(COMPILER_PREFIX)/avr-g++
OBJCOPY         = avr-objcopy
AVRDUDE         = avrdude

# Compiler flags
CXXFLAGS = -Os -Wall -Wextra -std=gnu++11 -DF_CPU=$(F_CPU) -mmcu=$(MCU)
LDFLAGS =

# Object files
OBJECTS = main.o

# Rules
.PHONY: all flash test clean

all: $(TARGET).hex

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(TARGET).elf: $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $@	$^

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

flash: $(TARGET).hex
	$(AVRDUDE) -P $(PROGRAMMER_PORT) -c $(PROGRAMMER_TYPE) -b $(PROGRAMMER_BAUD) \
	           -p $(MCU) -U flash:w:$<

test:
	$(AVRDUDE) -P $(PROGRAMMER_PORT) -c $(PROGRAMMER_TYPE) -b $(PROGRAMMER_BAUD) \
	           -p $(MCU) -v -n

clean:
	rm $(TARGET).hex $(TARGET).elf $(OBJECTS)
