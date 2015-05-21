#!/usr/bin/ruby
require 'rubygems'
require 'aws-sdk-core'

class MasterKey
	attr_reader :key_arn
	def initialize(key_alias,region = 'us-east-1')
		if key_alias.nil?
			raise Aws::KMS::Errors::NotFoundException
		end
		@key_alias = key_alias 
		@region = region
		kms = Aws::KMS::Client.new(region:@region)
	  masterkey = kms.describe_key(
	    key_id: @key_alias,
	  )
	  @key_arn = masterkey[:key_metadata][:key_id]
	rescue Aws::KMS::Errors::NotFoundException
		masterkey = kms.create_key()
		resp = kms.create_alias(
		  alias_name: @key_alias,
		  target_key_id: masterkey[:key_metadata][:key_id],
		)
	  @key_arn = masterkey[:key_metadata][:key_id]
	rescue Exception => e
	  puts e.message
	  puts e.backtrace.inspect
	end

	def show_key
		puts @key_arn
	end
end
