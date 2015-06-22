class Pixie::Server
  attr_reader :fqdn, :hostname, :domain

  def initialize(id)
    ip = Resolv.getaddress id
    begin
      # id can be ip or (resolvable) domain name
      @fqdn = Resolv.getname ip
      match = /^(?<hostname>[^\.]+)((\.)(?<domain>[^\.].*(?<!\.)))?(\.)?$/.match(@fqdn)
      @hostname = match[:hostname]
      @domain = match[:domain]
    rescue Resolv::ResolvError
      # We'll be missing some vars, won't matter for some templates...
    end
    @ip = IPAddr.new(ip)
  end

  def to_hash
    {:ip => @ip.to_s,
     :fqdn     => @fqdn,
     :hostname => @hostname,
     :domain   => @domain}
  end

  def ip
    @ip.to_s
  end

  def to_json
    return self.to_hash.to_json
  end
end