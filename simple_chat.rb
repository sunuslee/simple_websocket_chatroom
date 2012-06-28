require File.expand_path('../lib/em-websocket', __FILE__)

$wss = {}

# waiting[user_A] = [user_B1, user_B2, ...]
# means user_B is waiting for user_A to getting online.
# so when a user(user_A) gets online, looks up for all the values that has key 'user_B'
$waiting = {} 
def send_notification(notification_type, user)
    if notification_type == 'login'
        if $waiting.has_key?(user) == true
            user_bs = $waiting[user]
            user_bs.each do |u|
                $wss[u].send("NOTIFY: #{user} is ONLINE now")
                $wss[user].send("NOTIFY: #{u} is waiting for you now")
            end
        end
    end
end

def message_handler(ws, msg)
    puts 'get msg', msg
    from, to = msg.split('|:')[0].split('|')[0..1]
    message  = msg.split('|:')[1]

    # create and save a websocket object.
    if $wss.has_key?(from) == false
        puts 'get from:', from, ws
        $wss[from] = ws
    end

    if to == 'sunussys' and message == 'login'
        send_notification(message, from)
    end
    message  = from + ":\n" + message

    if $wss.has_key?(to) == true
        puts 'get to', to, ws
        $wss[to].send(message)
    # don't send any message related to user 'sunussys'
    elsif to != 'sunussys'
        ws.send("NOTIFY: #{to} is currently offline")
        puts "NOTIFY: #{to} is currently offline"
        ($waiting[to] ||= []) << from
    end
end

def user_disconnect(ws)
    if $wss.has_value?(ws)
        puts $wss.key(ws) + ' is offline now'
        $wss.delete($wss.key(ws))
    end
end

EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen    { ws.send "Hello Client!" }
    ws.onmessage do |msg|
        begin
            message_handler(ws, msg)
        rescue
        end
    end
    ws.onclose   { user_disconnect(ws) }
    ws.onerror   { |e| puts "Error: #{e.message}" }
end
