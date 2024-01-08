#include <amxmodx>

#define PLUGIN "Say Sound"
#define VERSION "2.0"
#define AUTHOR "mlibre"

new const sound_list[][] =
{
	"sound/music_1.wav",
	"sound/music_2.mp3",
	"sound/other/music_3.wav",
	"sound/music_4.wav"
}

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say", "set_sound")
	register_clcmd("say_team", "set_sound")
	
	for(new i; i < sizeof sound_list; i++)
	{
		if(chk_sound(i) && file_exists(sound_list[i]))
		{
			precache_generic(sound_list[i])
		}
		else
		{
			log_amx("** could not be loaded ^"%s^"", sound_list[i])
		}
	}
}

public set_sound(id)
{
	new message[191]
    
	read_args(message, charsmax(message))
    
	remove_quotes(message)
    
	if( !message[0] || message[0] == '/' )
		return PLUGIN_HANDLED_MAIN
    
	play_sound(0)
	
	return PLUGIN_CONTINUE
}

new type_sound

stock chk_sound(wav_or_mp3)
{
	switch(sound_list[wav_or_mp3][strlen(sound_list[wav_or_mp3]) - 1]) 
	{
		case 'v': 
		{
			type_sound = 1
			
			return PLUGIN_HANDLED
		}
		case '3': 
		{
			type_sound = 2
			
			return PLUGIN_HANDLED
		}
		default: 
		{
			type_sound = 0
		}
	}
	
	return PLUGIN_CONTINUE
}

stock play_sound(id)
{
	new random_sound = random_num(0, charsmax(sound_list))
	
	chk_sound(random_sound)
	
	client_cmd(id ? id : 0, "%s ^"%s^"", type_sound == 1 ? "spk" : type_sound == 2 ? "mp3 play" : "echo ** invalid format", sound_list[random_sound])
}
