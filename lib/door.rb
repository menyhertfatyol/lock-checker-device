require 'rpi_gpio'
require_relative './status_storage'

class Door
  class << self
    include StatusStorage

    def check_lock_state(pin_num: 11)
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup pin_num, as: :input, pull: :up

      state = if RPi::GPIO.high? pin_num
                'open'
              else
                'locked'
              end

      store_state(state)
    ensure
      RPi::GPIO.clean_up
    end
  end
end
