extends Node

@export var websocket_url = "ws://localhost:9080"

var socket = WebSocketPeer.new()

func socket_send_text(text: String):
	socket.send_text(text)

func _ready():
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		print("connecting to %s..." % websocket_url)
		await get_tree().create_timer(2).timeout
		socket.send_text(JSON.stringify({"type": "new_connection", "id": 1}))
	else:
		print("failed to connect :(")
		set_process(false)

func _process(delta: float) -> void:
	
	socket.poll()
	
	var state = socket.get_ready_state()
	
	if (state == WebSocketPeer.STATE_OPEN):
		
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			if socket.was_string_packet():
				var packet_text = packet.get_string_from_utf8()
				print("< Got text data from server: %s" % packet_text)
				var packet_json = JSON.new()
				packet_json = JSON.parse_string(packet_text)
				var data: Dictionary = packet_json
				
				#=====================================================
				#pars json packet
				#=====================================================
				#print("JSON reçu : ", data)
				#print("Clés reçues : ", data.keys())
				if (data["type"] == "new_connection"):
					var new_player = load("res://scene/player/player.tscn")
					var player_ins : CharacterBody2D = new_player.instantiate()
					get_tree().current_scene.add_child(player_ins)
					player_ins.client_player = false
					player_ins.player_id = data["id"]
					socket.send_text(JSON.stringify({"type": "new_connection_response", "id": 2}))
				if (data["type"] == "new_connection_response"):
					var new_player = load("res://scene/player/player.tscn")
					var player_ins : CharacterBody2D = new_player.instantiate()
					get_tree().current_scene.add_child(player_ins)
					player_ins.client_player = false
					player_ins.player_id = data["id"]
				
			else:
				print("< Got binary data from server: %d bytes" % packet.size())
		
		
	elif (state == WebSocketPeer.STATE_CLOSING):
		pass
		
		
	elif (state == WebSocketPeer.STATE_CLOSED):
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false)
