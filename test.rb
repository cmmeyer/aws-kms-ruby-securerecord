#!/usr/bin/ruby
require_relative 'kms-securerecord'

myrecord = SecureRecord.new()
myrecord.store('The rain in spain falls mainly on the plain')
puts myrecord.id

myotherrecord = SecureRecord.new('foo')
myotherrecord.store('This is pretty secret')
puts myotherrecord.id