require 'rpi_gpio'
require 'aws-sdk-dynamodb'
require 'dotenv/load'

class Door
  class << self
    def check_lock_state(pin_num: 11)
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup pin_num, as: :input, pull: :up

      if RPi::GPIO.high? pin_num
        state = 'open'
      else
        state = 'locked'
      end

      store_state(state)
    ensure
      RPi::GPIO.clean_up
    end

    private

    def store_state(state)
      dynamodb.put_item({
                          item: { 'door' => 'front_door',
                                  'lock_state' => "#{state}",
                                  'updated_at' => "#{Time.now}" },
                          table_name: 'door_lock'
                        })
    end

    def dynamodb
      Aws::DynamoDB::Client.new region: 'eu-central-1', access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                secret_access_key: ENV['AWS_ACCESS_KEY']
    end
  end
end
