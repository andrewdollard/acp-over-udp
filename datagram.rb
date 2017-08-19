class Datagram

  ATTRS = [ :source_ip, :source_port,
            :dest_ip, :dest_port,
            :seq, :ack, :message, :chk ]

  attr_reader *ATTRS

  def initialize(params, valid = true)
    ATTRS.each do |attr|
      instance_variable_set("@"+attr.to_s,params[attr])
    end
    @valid = valid
  end

  def self.parse(chkd_msg)
    checkmatch = chkd_msg.match(/(.*)\|([0-9]*)$/)
    msg = checkmatch[1]
    chk = checkmatch[2]

    params = chkd_msg.split('|')
    attrs = {
      source_ip: params[0],
      source_port: params[1],
      dest_ip: params[2],
      dest_port: params[3],
      seq: params[4].to_i,
      ack: params[5].to_i,
      message: params[6] || '',
      chk: params[7]
    }
    new(attrs, checksum(msg) == chk)
  end

  def self.checksum(msg)
    msg.split(//)
       .map{ |c| c.unpack('C') }
       .flatten
       .inject(:+)
       .send(:^, (2**16 - 1))
       .to_s
  end

  def invalid?
    !@valid
  end

  def serialize
    params = (ATTRS - [:chk]).map { |attr| instance_variable_get("@#{attr}") }
    msg = params.join("|")
    msg + "|" + Datagram.checksum(msg)
  end

end
