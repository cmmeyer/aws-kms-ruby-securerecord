require 'sinatra/base'
require 'json'
require 'aws-sdk-core'
require 'base64'
require 'gibberish'
require_relative 'kms-masterkey'

# Initialization code here such as creating KMS keys or discovering CloudFormation resources.

# Initialize the AWS SDK Clients, these objects can later be used to make queries.
ec2_client = Aws::EC2::Client.new(region: 'us-east-1')
ddb_client = Aws::DynamoDB::Client.new(region: 'us-east-1')
$kms_client = Aws::KMS::Client.new(region: 'us-east-1')

class KMSLab < Sinatra::Base
    
	# Serve a static file as the root of the website.
	# By convention, static assets are stored in /public of the Siantra directory.
	get '/' do
		File.read(File.join('public', 'index.html'))
    end

	get '/kms/master-keys/:key_alias' do | key_alias |
		content_type :json
		masterkey = MasterKey.new(key_alias)
		masterkey.to_json
	end
	
	post '/kms/master-keys/:key_alias/generate-data-key' do | key_alias |
		content_type :json
		masterkey = MasterKey.new(key_alias)

		# Use JSON payload as the context string for the data key
		# Context can be thought of as part of the key; 
		# it must match on both the encrypt and decrypt end.
		context = JSON.parse(request.body.read)

		kms_client_resp = $kms_client.generate_data_key(
			key_id: masterkey.key_id,
			encryption_context: context,
			key_spec: 'AES_256'
		)

		{
			'ciphertext_blob' => Base64.strict_encode64(kms_client_resp.ciphertext_blob),
			'plaintext' => Base64.strict_encode64(kms_client_resp.plaintext),
			'key_id' => kms_client_resp.key_id.force_encoding('UTF-8')
		}.to_json	
	end

	post '/kms/decrypt' do
		content_type :json
		
		# Get the JSON payload of the request
		request_payload = JSON.parse(request.body.read)

		{}.to_json	
	end	
	
	post '/client/encrypt' do
		content_type :json
		
		# Get the JSON payload of the request
		# Expects 'key' to contain base64 encoded plaintext key 
		# Expects 'data' to contain unencoded data block
		request_payload = JSON.parse(request.body.read)
		plaintext = Base64.strict_decode64(request_payload['key'])
		cipher = Gibberish::AES::CBC.new(plaintext)
		encrypted_data = cipher.encrypt(request_payload['data'])

		# Return encrypted string as 'data'		
		{
			'data' => encrypted_data
		}.to_json	
	end

	post '/client/decrypt' do
		content_type :json
		
		# Get the JSON payload of the request
		# Expects 'key' to contain base64 encoded plaintext key 
		# Expects 'data' to contain encoded data block
		request_payload = JSON.parse(request.body.read)
		plaintext = Base64.strict_decode64(request_payload['key'])
		cipher = Gibberish::AES::CBC.new(plaintext)
		decrypted_data = cipher.decrypt(request_payload['data'])
		
		# Return encrypted string as 'data'		
		{
			'data' => decrypted_data
		}.to_json	
	end

	get '/dynamo-db/records/:record_id' do
		content_type :json
		{}.to_json
	end

	put '/dynamo-db/records/:record_id' do
		content_type :json
		{}.to_json
	end	
	
	post '/dynamo-db/records' do
		content_type :json
		{}.to_json
	end	
	
	# Still need to think this one through, the following is subject to change.
	get '/context-service/:record_id' do
		content_type :json
		{}.to_json
	end
end

Thread.new do
  # Background execution code such as listening to SQS.
end