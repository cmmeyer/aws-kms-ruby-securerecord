#!/usr/bin/ruby
require 'rubygems'
require 'aws-sdk-core'

class MasterKey
	attr_reader :key_id
	def initialize(key_alias,region = 'us-east-1')
		if key_alias.nil?
			raise Aws::KMS::Errors::NotFoundException
		end
		@key_alias = 'alias/' + key_alias 		
		@region = region
		kms = Aws::KMS::Client.new(region:@region)
		@masterkey = kms.describe_key(
			key_id: @key_alias,
		)
		@key_id = @masterkey[:key_metadata][:key_id]
	rescue Aws::KMS::Errors::NotFoundException
		@masterkey = kms.create_key()
		resp = kms.create_alias(
		  alias_name: @key_alias,
		  target_key_id: @masterkey[:key_metadata][:key_id],
		)
	  @key_id = @masterkey[:key_metadata][:key_id]
	rescue Exception => e
	  puts e.message
	  puts e.backtrace.inspect
	end

	def show_key
		puts @key_id
	end

	def to_json
		{
			'key_id' => @masterkey[:key_metadata][:key_id],
			'arn' => @masterkey[:key_metadata][:arn],
			'creation_date' => @masterkey[:key_metadata][:creation_date],
			'enabled' => @masterkey[:key_metadata][:enabled],
			'description' => @masterkey[:key_metadata][:description]
		}.to_json
	end
end
