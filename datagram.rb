class Datagram

  ATTRS = [ :source_ip, :source_port,
            :dest_ip, :dest_port,
            :seq, :ack,
            :message ]

  attr_reader *ATTRS

  def initialize(params)
    ATTRS.each do |attr|
      instance_variable_set("@"+attr.to_s,params[attr])
    end
  end

  def self.parse(msg)
    params = msg.split('|')
    attrs = ATTRS.map.each_with_index{ |a, i| [a, params[i]] }.to_h
    new(attrs)
  end

  def serialize
    params = ATTRS.map { |attr| instance_variable_get("@#{attr}") }
    params.join("|")
  end

end
