#!/usr/bin/ruby -r openssl -rubygems

require 'ReqPath'
require 'Listener'

$APN_RESOURCES = './resources'

provider = APN::Provider.new()
listener = ClientListener.new(provider, 1337)
listener.listen_clients()
