require 'reel'
require 'lib/testier'
require 'websocket_parser'
require 'json'
require 'symboltable'

class Socketeer
  
  include Celluloid
  
  def initialize(socket, neighbors)
    @remote_ip = socket.remote_ip
    @testier = Testier.new
    @neighbors = neighbors
    @socket = socket
    @neighbors[@remote_ip] = @socket
    @socket.on_close do |a,m|
      @socket.close
    end
    @socket.on_message do |m|
      @socket.cancel_timer!
      process(m)
      @socket.read_every(1)
    end
    @socket.on_ping do |payload|
      @socket.write ::WebSocket::Message.pong(payload).to_data
    end
    @socket.read_every(1)
  end
  
  def process(message)
    command = SymbolTable.new(JSON.load(message))
    case command.work.to_sym
    when :linear
      send_off @testier.linear(command.pages)
    when :parallel
      send_off @testier.parallel(command.pages)
    when :pool
      send_off @testier.pooly(5, command.pages)
    end
  end
  
  def send_off(results)
    highest=results.sort_by {|letter, ct| ct}.last
    text = "#{@remote_ip} had a high of #{highest}<br/>"
    @neighbors.keys.each {|socket_key| @neighbors[socket_key].write text}
  end
  
end


class Reeler < Reel::Server
  
  MY_IP="172.16.0.235"
  MY_PORT=3100
  
  
  def initialize
    puts "Starting server at #{MY_IP}:#{MY_PORT}"
    @sockets = {}
    super(MY_IP, MY_PORT, &method(:on_connection))
  end
  
  def on_connection(connection)
    while request = connection.request
      if !request.websocket?
        handle_homepage connection, request
        return
      else
        connection.detach
        handle_socket request.websocket
        return
      end
    end
  end
  
  def handle_homepage(connection, request)
    if request.url == "/"
      connection.respond :ok, ::IO.read("public/index.html").split("|host|").join("#{MY_IP}:#{MY_PORT}")
    else
      puts "BAD PAGE"
      connection.respond :not_found, "No Mr Peter... No... try /"
    end
  end
  
  def handle_socket(socket)
    i = Socketeer.new(socket, @sockets)
    @sockets.delete(socket.remote_ip) if @sockets.keys.include?(socket.remote_ip)
    @sockets[socket.remote_ip] = socket
  end
  
end

Reeler.supervise_as :reelerer

sleep