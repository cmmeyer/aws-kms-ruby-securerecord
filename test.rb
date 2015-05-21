#!/usr/bin/ruby
require_relative 'kms-securemessage'

mymessage = SecureMessage.new()
mymessage.encrypt('The rain in spain falls mainly on the plain')
puts mymessage.id

myothermessage = SecureMessage.new('foo')
myothermessage.encrypt('This is pretty secret')
puts myothermessage.id