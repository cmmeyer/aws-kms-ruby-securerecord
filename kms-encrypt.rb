#!/usr/bin/ruby
require 'pp'
require 'rubygems'
require 'aws-sdk-core'
require 'base64'
require 'gibberish'
require 'json'
require_relative 'kms-masterkey'

region    = 'us-east-1'
key_alias = 'alias/SecurityDemoKey'
dyname_table = 'SecurityDemo'
employee_id = '007'
message_id  = '001'

if ARGV[0].nil?
  puts "Usage: encrypt.rb INPUTFILE"
  exit 1
end

#This uses the envelope-encryption model. The cleartext is not sent to AWS KMS, rather an encryption key is generated by KMS and stored alongside the ciphertext.
# keyid looks like 6d83e627-bf08-1111-9999-23b0a0df19b1
masterkey = MasterKey.new(key_alias)
keyid = masterkey.key_arn
validatorkey = IO.read(ARGV[0])

kms = Aws::KMS::Client.new(region:region)

#Encryption_context can be thought of as part of the key; it must match on both the encrypt and decrypt end.
resp = kms.generate_data_key(
  key_id: keyid,
  encryption_context: { 'KeyType' => 'Some descriptive text here' },
  key_spec: 'AES_256'
)
#cipher = Gibberish::AES.new(resp[:plaintext])
#outputhash = { 'ciphertext' => cipher.enc(validatorkey), 'datakey' => Base64.strict_encode64(resp.ciphertext_blob)}
#puts JSON.pretty_generate(outputhash)

cipher = Gibberish::AES::CBC.new(resp[:plaintext])
enc = cipher.encrypt("Some data")
outputhash = { 'employeeID' => employee_id, 'messageID' => message_id, 'ciphertext' => cipher.encrypt(validatorkey), 'datakey' => Base64.strict_encode64(resp.ciphertext_blob)}

#puts JSON.pretty_generate(outputhash)

dynamodb = Aws::DynamoDB::Client.new(region:region)
dynamodb.put_item(
	table_name: dyname_table,
	item:  outputhash
)