#!/usr/bin/ruby
require 'rubygems'
require 'aws-sdk-core'
require 'pp'
require 'base64'
require 'gibberish'
require 'json'

region = 'us-east-1'
dynamo_table = 'SecurityDemo'
employee_id = '007'

if ARGV[0].nil?
  puts "Usage: kms-decrypt.rb MESSAGEID"
  exit 1
end

dynamodb = Aws::DynamoDB::Client.new(region:region)
contents = dynamodb.get_item(
	table_name: dynamo_table,
	key: {
		employeeID: employee_id,
		messageID: ARGV[0]
	}
).data.item

#contents = JSON.parse(IO.read(ARGV[0]))
kms = Aws::KMS::Client.new(region:region)
datakey =  Base64.strict_decode64(contents['datakey'])

cleartextkey = kms.decrypt(:ciphertext_blob => datakey,
  encryption_context: { 'KeyType' => 'Some descriptive text here' }
)

cipher = Gibberish::AES::CBC.new(cleartextkey.plaintext)
cleartext = cipher.decrypt(contents['ciphertext'])
puts cleartext
