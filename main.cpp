#include <stddef.h>
#include <avr/io.h>
#include <util/delay.h>


inline void setup_gpio(void) {
  // Set B0 to output
  DDRB |= _BV(DDB0);

  // Set B1 and B2 to inputs with internal pullup resistor
  DDRB &= ~_BV(DDB1);
  PORTB |= _BV(PORTB1);

  DDRB &= ~_BV(DDB2);
  PORTB |= _BV(PORTB2);

  // Delay for safety
  _delay_ms(1);
}

inline bool get_trigger() {
  return !bit_is_set(PINB, PINB1);
}

inline bool get_sensor() {
  return !bit_is_set(PINB, PINB2);
}

inline void set_output() {
  PORTB |= _BV(PORTB0);
}

inline void unset_output() {
  PORTB &= ~_BV(PORTB0);
}

inline void toggle_output() {
  PORTB ^= _BV(PORTB0);
}

enum class State {
  ready,
  firing,
  stopped,
  waiting,
};

enum class Event {
  null,
  trigger_pulled,
  trigger_released,
  sensor_activated,
  sensor_deactivated,
};

// Transition functions
State transition_from_ready(Event event) {
  if (event == Event::trigger_pulled) {
    set_output();
    return State::firing;
  }
  return State::ready;
}

State transition_from_firing(Event event) {
  if (event == Event::sensor_activated) {
    unset_output();
    return State::stopped;
  } else if (event == Event::trigger_released) {
    set_output();
    return State::waiting;
  }
  return State::firing;
}

State transition_from_stopped(Event event) {
  if (event == Event::trigger_released) {
    unset_output();
    return State::ready;
  }
  return State::stopped;
}

State transition_from_waiting(Event event) {
  if (event == Event::sensor_activated) {
    unset_output();
    return State::ready;
  }
  return State::waiting;
}

int main(void) {
  setup_gpio();

  // Main loop
  Event events[2] = { Event::null, Event::null };

  // Trigger inputs
  bool last_trigger_state = get_trigger();

  // Sensor inputs
  bool last_sensor_state = get_sensor();

  // State machine
  State current_state = State::ready;

  while (true){
    // Check events
    const auto trigger = get_trigger();
    const auto sensor = get_sensor();

    if (trigger != last_trigger_state) {
      last_trigger_state = trigger;

      if (trigger) {
        events[0] = Event::trigger_pulled;
      } else {
        events[0] = Event::trigger_released;
      }
    }

    if (sensor != last_sensor_state) {
      last_sensor_state = sensor;

      if (sensor) {
        events[1] = Event::sensor_activated;
      } else {
        events[1] = Event::sensor_deactivated;
      }
    }

    // Process events
    for (size_t i = 0; i < 2; i++) {
      if (events[i] == Event::null) { continue; }

      switch (current_state) {
      case State::ready:
        current_state = transition_from_ready(events[i]);
        break;

      case State::firing:
        current_state = transition_from_firing(events[i]);
        break;

      case State::stopped:
        current_state = transition_from_stopped(events[i]);
        break;

      case State::waiting:
        current_state = transition_from_waiting(events[i]);
        break;
      }

      events[i] = Event::null;
    }

    _delay_ms(1);
  }
}
