#!/usr/bin/env ruby

require 'aws-sdk-dynamodb'
require 'dotenv/load'

module StatusStorage
  def store_state(state)
    dynamodb.put_item({
                        item: { 'door' => 'front_door',
                                'lock_state' => state,
                                'updated_at' => Time.now.to_s },
                        table_name: 'door_lock'
                      })
  end

  def read_state
    dynamodb.get_item table_name: 'door_lock', key: { 'door' => 'front_door' }
  end

  private

  def dynamodb
    Aws::DynamoDB::Client.new region: 'eu-central-1',
                              access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                              secret_access_key: ENV['AWS_ACCESS_KEY'],
                              endpoint: ENV['STATUS_STORE_URL']
  end
end
