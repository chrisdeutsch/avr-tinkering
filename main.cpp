#include <avr/io.h>
#include <util/delay.h>

// Bitwise ops
//
// Toggle
// Y ^= mask
// Set
// Y |= mask
// Unset
// Y &= ~mask

int main(void) {
  // Set B4 to output
  DDRB |= _BV(DDB4);

  // Set B3 to input
  DDRB &= ~_BV(DDB3);
  // Enable internal pullup register
  PORTB |= _BV(PORTB3);

  while (true){
    //const bool pb3_is_high = PINB & _BV(PINB3);
    if (bit_is_set(PINB, PINB3)) {
      PORTB |= _BV(PORTB4);
    } else {
      PORTB &= ~_BV(PORTB4);
    }

    _delay_ms(10);

    // // Toggle B4
    // PORTB ^= _BV(PORTB4);
    // _delay_ms(1000);
  }
}
