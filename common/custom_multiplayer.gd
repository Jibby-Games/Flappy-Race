#### This code was provided by LudiDorici on GitHub: https://github.com/LudiDorici/gd-custom-multiplayer

### This small demo demostrate how to use the new MultiplayerAPI class
### to run both server and client(s) in the same instance.
### This is very useful for testing and in cases where you want to
### always run a server even when playing locally (like good ol Quake III did)
### IMPORTANT: You need to replace all the get_tree().[network_stuff] (which
### will be deprected in 3.1, and removed in later releases) with:
### multiplayer.[network_stuff] (which internally calls get_tree() if no custom
### multiplayer is specified).

### This node will apply a custom Multliplayer API instance (or RPC manager
### if you like) to all its childern, and manage them as INDEPENDENT branches
### in regards to RPCs/RSETs purpose
extends Node


func _init():
	# First, we assign a new MultiplayerAPI to our this node
	custom_multiplayer = MultiplayerAPI.new()
	# Then we need to specify that this will be the root node for this custom
	# MultlpayerAPI, so that all path references will be relative to this one
	# and only its children will be affected by RPCs/RSETs
	custom_multiplayer.set_root_node(self)


# We want to listen to NOTIFICATION_ENTER_TREE to change the custom_multiplayer
# variable in all children as soon as we enter the tree.
# We don't this in the _ready() function because it will be called AFTER the
# _ready() function of the children is called, and they might register
# multiplayer related signals in it (more on this in _customize_children
# function)
func _notification(what):
	if what == NOTIFICATION_ENTER_TREE:
		# We also want to customize all nodes that will be added dinamically
		# later on.
		assert(get_tree().connect("node_added", self, "_on_add_node") == OK)
		_customize_children()
	elif what == NOTIFICATION_EXIT_TREE:
		# Don't forget to disconnect
		get_tree().disconnect("node_added", self, "_on_add_node")


# When the MultiplayerAPI is not managed directly by the SceneTree
# we MUST poll it
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return  # No network peer, nothing to poll
	# Poll the MultiplayerAPI so it fetches packets, emit signals, process RPCs
	custom_multiplayer.poll()


# Called every time a new node is added to the tree (dinamically added nodes)
func _on_add_node(node):
	# We want to make sure that the node is in our branch.
	var path = str(node.get_path())
	var mypath = str(get_path())
	if path.substr(0, mypath.length()) != mypath:
		return
	var rel = path.substr(mypath.length(), path.length())
	if rel.length() > 0 and not rel.begins_with("/"):
		# The added node is not in our branch (child or subchild).
		# Leave it alone
		return

	# The added node is our child, or child of our child,
	# or child of our child's child, and so on.
	# Let's apply to it our own custom multiplayer
	node.custom_multiplayer = custom_multiplayer


# This function customize all the child nodes added when the scene is instanced
func _customize_children():
	# Remember to mind the stack ;-)
	# We use a frontier to avoid recursion.
	var frontier = []
	for c in get_children():
		frontier.append(c)
	while not frontier.empty():
		var node = frontier.pop_front()
		frontier += node.get_children()
		# Same as in _on_add_node we customize the MultiplayerAPI of our child.
		node.custom_multiplayer = custom_multiplayer

### That's it, nothing more. Children that calls rpc/rset will use our custom
### MultiplayerAPI and not the global SceneTree one.
