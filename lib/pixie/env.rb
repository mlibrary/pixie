class Pixie::Env
  attr_reader :you, :me, :pixiemaster, :puppetmaster, :subnet

  def initialize(you,me)
    @you = Pixie::Server.new(you)
    @me = Pixie::Server.new(me)
    @subnet = Pixie::Subnets.search(@you.ip)

    pixiemaster = @subnet['pixiemaster']
    pupetmaster = @subnet['puppetmaster']

    if pixiemaster
      @pixiemaster = Pixie::Server.new(pixiemaster)
    else
      @pixiemaster = @me
    end
    if puppetmaster
      @puppetmaster = Pixie::Server.new(puppetmaster)
    else
      @puppetmaster = @pixiemaster
    end
  end

  def to_hash
    {
      sw_version: "#{Pixie.name} v#{Pixie.version}",
      schema_version: Pixie.schema_version,
      you: @you.to_hash,
      me: @me.to_hash,
      pixiemaster: @pixiemaster.to_hash,
      puppetmaster: @puppetmaster.to_hash,
      subnet: @subnet.to_hash 
    }
  end

  def to_json
    self.to_hash.to_json
  end
  
end