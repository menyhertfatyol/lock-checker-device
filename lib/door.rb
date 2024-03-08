require 'pigpio'
require_relative './status_storage'

class Door
  class << self
    include Pigpio::Constant
    include StatusStorage

    def check_lock_state(broadcom_pin_num: 17)
      pi = Pigpio.new
      exit(-1) unless pi.connect

      lock = pi.gpio(broadcom_pin_num)
      lock.pud = PI_PUD_UP
      lock.mode = PI_INPUT

      state = if lock.read == 1
                'open'
              else
                'locked'
              end

      store_state(state)
    end
  end
end
