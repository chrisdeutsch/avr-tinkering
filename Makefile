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
OBJCOPY         = $(COMPILER_PREFIX)/avr-objcopy
AVRDUDE         = avrdude
AVRSIZE         = $(COMPILER_PREFIX)/avr-size

# Compiler flags
CXXFLAGS = -Os -Wall -Wextra -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections \
	   -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto \
           -DF_CPU=$(F_CPU) -mmcu=$(MCU)
LDFLAGS = -Wall -Wextra -Os -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=$(MCU)

# Object files
OBJECTS = main.o

# Rules
.PHONY: all flash size test clean

all: $(TARGET).hex

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(TARGET).elf: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@	$^

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(TARGET).eep: $(TARGET).elf
	$(OBJCOPY) -O ihex -j .eeprom \
                   --set-section-flags=.eeprom=alloc,load \
                   --no-change-warnings --change-section-lma .eeprom=0 \
                   $< $@

flash: $(TARGET).hex
	$(AVRDUDE) -P $(PROGRAMMER_PORT) -c $(PROGRAMMER_TYPE) -b $(PROGRAMMER_BAUD) \
	           -p $(MCU) -U flash:w:$<

size: $(TARGET).elf
	$(AVRSIZE) -C --mcu=$(MCU) $(TARGET).elf

test:
	$(AVRDUDE) -P $(PROGRAMMER_PORT) -c $(PROGRAMMER_TYPE) -b $(PROGRAMMER_BAUD) \
	           -p $(MCU) -v -n

clean:
	rm $(TARGET).hex $(TARGET).elf $(OBJECTS)
