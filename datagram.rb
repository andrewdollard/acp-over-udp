class Datagram

  attr_reader :source_ip, :source_port, :dest_ip, :dest_port,
              :seq, :ack, :message

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  # end
  #   params.keys.each do |key|
  #     # this.
  #   end
  #
  #   @source_ip = params[:source_ip]
  #   @source_port = params[:source_port]
  #   @dest_ip = params[:dest_ip]
  #   @dest_port = params[:dest_port]
  #   @seq = params[:seq]
  #   @ack = params[:ack]
  #   @message = params[:message]
  end

  def self.parse(msg)
    raw = msg.split('|')
    new({
      source_ip: raw[0],
      source_port: raw[1],
      dest_ip: raw[2],
      dest_port: raw[3],
      seq: raw[4],
      ack: raw[5],
      message: raw[6]
    })
  end

  def serialize
    [@source_ip,
     @source_port,
     @dest_ip,
     @dest_port,
     @seq,
     @ack,
     @message].join("|")
  end

end
