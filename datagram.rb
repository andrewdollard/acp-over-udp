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
    attrs = {
      source_ip: params[0],
      source_port: params[1],
      dest_ip: params[2],
      dest_port: params[3],
      seq: params[4].to_i,
      ack: params[5].to_i,
      message: params[6] || '',
    }
    new(attrs)
  end

  def serialize
    params = ATTRS.map { |attr| instance_variable_get("@#{attr}") }
    params.join("|")
  end

end
