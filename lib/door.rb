require 'pigpio'
require_relative './status_storage'

class Door
  class << self
    include Pigpio::Constant
    include StatusStorage

    def check_lock_state(broadcom_pin_num: 17)
      lock = pigpio(broadcom_pin_num)

      state = if lock.read == 1
                'open'
              else
                'locked'
              end

      store_state(state)
    end

    private

    def pigpio(broadcom_pin_num)
      pi = Pigpio.new
      exit(-1) unless pi.connect

      pin = pi.gpio(broadcom_pin_num)
      pin.pud = PI_PUD_UP
      pin.mode = PI_INPUT
      pin
    end
  end
end
