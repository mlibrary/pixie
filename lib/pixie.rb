require 'ipaddress'
require 'yaml'
require 'ipaddr'
require 'json'

module Pixie
  def self.name
    'Pixie'
  end
  def self.version
    '0.1'
  end
  def self.schema_version
    '0.1'
  end
end

require_relative 'pixie/env'
require_relative 'pixie/inventory'
require_relative 'pixie/puppetdb'
require_relative 'pixie/server'
require_relative 'pixie/subnets'