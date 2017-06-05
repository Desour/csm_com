## This mod gives server- and client-mods the possibility to communicate.

### It should be installed on server and client.


## Added functions are:
### For client:
- `csm_com.register_on_receive(func(msg))`
If function returns `true`, remaining functions are not called.
- `csm_com.send(msg)`
- `csm_com.server_has()`
returns `true` if server has this mod installed
### For server:
- `csm_com.register_on_receive(func(player_name, msg))`
same as above
- `csm_com.send(player_name, msg)`
- `csm_com.player_has(player_name)`
returns `true` if player has this mod installed
