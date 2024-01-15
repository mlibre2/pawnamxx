#include <amxmodx>

#define PLUGIN "Say Sound"
#define VERSION "2.2"
#define AUTHOR "mlibre"

new const sound_list[][] =
{
	"sound/music_1.wav",
	"sound/music_2.mp3",
	"sound/other/music_3.wav",
	"sound/music_4.wav"
}

new type_sound

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say", "set_sound")
	register_clcmd("say_team", "set_sound")
	
	for(new i; i < sizeof sound_list; i++)
	{
		chk_sound(i)
		
		if(type_sound > 0 && file_exists(sound_list[i]))
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
	new message[2]
	
	read_args(message, charsmax(message))
	
	if(message[0] && message[0] != '/')
	{
		play_sound(0)	//id=only you listen / 0=everyone listens "the sound list"
	}
}

stock chk_sound(wav_or_mp3)
{
	switch(sound_list[wav_or_mp3][strlen(sound_list[wav_or_mp3]) - 1]) 
	{
		case 'v': 
		{
			type_sound = 1
		}
		case '3': 
		{
			type_sound = 2
		}
		default: 
		{
			type_sound = 0
		}
	}
}

stock play_sound(id)
{
	new random_sound = random_num(0, charsmax(sound_list))
	
	chk_sound(random_sound)
	
	client_cmd(id ? id : 0, "%s ^"%s^"", type_sound == 1 ? "spk" : type_sound == 2 ? "mp3 play" : "echo ** invalid format", sound_list[random_sound])
}
