require 'set'

module Pixie::Subnets
  @@subnets = YAML.load_file('config/subnets.yml')
  # 0.0.0.0/0 represents generic "everything" supernet
  @@default = @@subnets.delete('0.0.0.0/0') || {}
  @@subnets.each_key do |subnet|
    @@subnets[subnet] = @@default.merge(@@subnets[subnet])
    @@subnets[subnet][:subnet] = subnet
    subnet_ipaddr    = IPAddr.new(subnet)
    subnet_ipaddress = IPAddress(subnet)
    @@subnets[subnet][:base_addr] = subnet_ipaddr
    @@subnets[subnet][:mask]      = subnet_ipaddress.netmask
    @@subnets[subnet][:mask_cidr] = subnet_ipaddress.prefix
    @@subnets[subnet][:broadcast] = subnet_ipaddress.broadcast.to_s
    @@subnets[subnet][:gateway]   = @@subnets[subnet]['gateway'] # fix for clumsy yaml loading
    @@subnets[subnet][:gateway] ||= subnet_ipaddress.first.to_s
    if(@@subnets[subnet]['nameservers'])
      @@subnets[subnet][:nameserver_string] = @@subnets[subnet]['nameservers'].join(' ')
    elsif(@@subnets[subnet]['nameserver'])
      @@subnets[subnet][:nameserver_string] = @@subnets[subnet]['nameserver']
    end
    @@subnets[subnet]['pixiemaster'] = Pixie::Server.new(@@subnets[subnet]['pixiemaster'])
    @@subnets[subnet]['puppetmaster'] = Pixie::Server.new(@@subnets[subnet]['puppetmaster'])
  end

  def self.get
    @@subnets
  end

  def self.get_each_value_of(key)
    items = Set.new

    Pixie::Subnets.get.each_value do |sn|
      item = sn[key]
      items.add item if item
    end

    return items.to_a
  end

  def self.search(ip_obj)
    found = nil

    @@subnets.each_value do |subnet|
      if subnet[:base_addr].include?(ip_obj)
        found = subnet
        break
      end
    end

    found || @@default
  end
end
