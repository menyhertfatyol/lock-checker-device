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

  def recreate_table(table_schema)
    delete_table_if_exists(table_schema[:table_name])
    dynamodb.create_table(table_schema)
    puts 'table is created!'
  rescue Aws::DynamoDB::Errors::ServiceError => error
    puts "Unable to create table: #{error.message}"
  end

  private

  def dynamodb
    Aws::DynamoDB::Client.new endpoint: ENV['STATUS_STORE_URL'],
                              region: 'eu-central-1',
                              access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                              secret_access_key: ENV['AWS_ACCESS_KEY']
  end

  def delete_table_if_exists(table_name)
    dynamodb.delete_table(table_name: table_name)
  rescue Aws::DynamoDB::Errors::ResourceNotFoundException
    puts "#{table_name} table does not exist, unalble to delete it"
  end
end
