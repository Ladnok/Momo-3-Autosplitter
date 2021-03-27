state("Momodora3", "v1.06")
{

	double loadSave:	0x2D3054, 0x370, 0xE00;

	double screen:		0x189570, 0x274, 0x2EC, 0xC, 0x0, 0x8;

	double cutscene:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1118;

	double percentage:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1C30;

	double Haegok:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1CF8;

	double InGame:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1E38;
	double InGame2:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1F00;
}


state("Momodora3", "v1.11b")
{

	double loadSave:	0x18D4CC, 0x1E4,  0x104, 0x8, 0x104, 0x4,  0x128;

	double screen:		0x189570, 0x274, 0x2ec, 0xc, 0x0, 0x8;

	double cutscene:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1168;

	double percentage:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1C80;

	double Haegok:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1D48;

	double InGame:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1E88;
	double InGame2:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1F50;
}


startup
{

	settings.Add("zones", true, "Zones");

	settings.Add("shrine", true, "Ishlith Shrine", "zones");
	settings.Add("madryn", true, "Old Madryn", "zones");
	settings.Add("hideout", true, "Dim Hideout", "zones");
	settings.Add("garden", true, "Belltower Garden", "zones");
	settings.Add("distortion", true, "Distortion in Time", "zones");
	settings.Add("grave", true, "Artemisia's Grave", "zones");


	settings.Add("bosses", false, "Bosses");

	settings.Add("prim", true, "Prim", "bosses");
	settings.Add("fishgod", true, "Fishgod Peishe", "bosses");
	settings.Add("arabella", true, "Arabella Sisters", "bosses");
	settings.Add("bellkeeper", true, "Bellkeeper Poetelia", "bosses");
	settings.Add("bakrog", true, "Bakrog Demon", "bosses");
	settings.Add("haegok", true, "Haegok", "bosses");
	settings.Add("cashias", true, "Cashias", "bosses");


	settings.Add("hell", true, "Endsplit");
}


init
{

	refreshRate = 60;
	

	print("[LSS - Checksum] » init{} - starting checksum calculation");

	ProcessModuleWow64Safe module = modules.Single(x => String.Equals(x.ModuleName, "Momodora3.exe", StringComparison.OrdinalIgnoreCase));

	// initialising the cryptography factory (we're using SHA512 in this case. MD5 would work aswell but SHA's considered the better option for checksums)
	byte[] exe512HashBytes = new byte[0];

	using (var sha = System.Security.Cryptography.SHA512.Create())
	{
		using (var s = File.Open(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
		{
		exe512HashBytes = sha.ComputeHash(s); 
		} 
	}

	string exeHash = exe512HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b); // execute the exe512HashBytes function and storing the hash in the hexadecimal (uppercased) variant

	print("[LSS - Checksum] » init{} - read SHA512-Hash: " + exeHash); // printing our SHA512 checksum

	switch(exeHash) {
        	case "4FE144C295682E4D2F82E20EA388B3FFF9653C8AEC8A006E06ED20EC8E59AFFEDB86F75BEFD9FE09A9F47FCDEDF415FAEA723F78440C03F403A1F5159DF618E9":
            		print("Version 1.06");
			version = "v1.06";
           	 	break;

        	case "1BDC4C10D23F00300EBAFB519CC44C3F650829A17BC23977D3207A25BB6C97F02F1D8AB62EF890393DF5C1867BFA4C051245B50B5C949F61E149FF02DE630F0C":
            		print("Version 1.11b");
			version = "v1.11b";
           	 	break;

		default:
			vars.version = "v1.06";
            		break;
			
    	}

	//Variables

	// HashSet to hold splits already hit
	// It prevents Livesplit from splitting on the same split multiple times
	vars.Splits = new HashSet<string>();

	//Saves the last screen the player was at, because while loading its values is set to -1
	double last_screen = -1;

	vars.wait_rell_talk = 0;
}


isLoading
{

	return (timer.CurrentAttemptDuration.Seconds > 5 && current.screen == -1);
}


update
{

	if (old.screen != -1)
	{
		vars.last_screen = old.screen;
	}

	if (current.screen == 112 && old.percentage < current.percentage)
	{
		vars.wait_rell_talk = 1;
		return false;
	}


	// Clear any hit splits if timer stops
	if (timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.Splits.Clear();
	}
}


start
{

	return (old.loadSave == 0 && current.loadSave == 1);
}


reset
{

        return ((old.InGame == 1 && current.InGame == 0) || (old.InGame2 == 1 && current.InGame2 == 0));
}


split
{
	//Zone Splits
	if (vars.last_screen == 64 && current.screen == 57)
	{

		if (vars.Splits.Contains("Shrine"))
		{

			return false;
		}

		vars.Splits.Add("Shrine");
		return settings["shrine"];
	}


	if (vars.last_screen == 121 && current.screen == 67)
	{

		if (vars.Splits.Contains("Madryn"))
		{

			return false;
		}

		vars.Splits.Add("Madryn");
		return settings["madryn"];
	}


	if (vars.last_screen == 106 && current.screen == 79)
	{

		if (vars.Splits.Contains("Hideout"))
		{

			return false;
		}

		vars.Splits.Add("Hideout");
		return settings["hideout"];
	}


	if (vars.last_screen == 85 && current.screen == 114)
	{

		if (vars.Splits.Contains("Garden"))
		{

			return false;
		}

		vars.Splits.Add("Garden");
		return settings["garden"];
	}


	if (vars.last_screen == 100 && current.Haegok == 1)
	{

		if (current.screen == 47 || current.screen == 57 || current.screen == 67 || current.screen == 79 || current.screen == 114)
		{
			if (vars.Splits.Contains("Distortion"))
			{

				return false;
			}

			vars.Splits.Add("Distortion");
			return settings["distortion"];
		}
	}


	if (vars.last_screen == 116 && current.screen == 93)
	{

		if (vars.Splits.Contains("Grave"))
		{

			return false;
		}

		vars.Splits.Add("Grave");
		return settings["grave"];
	}


	//Boss Splits
	if (old.percentage != current.percentage && old.percentage < current.percentage)
	{

		if (current.screen == 64)
		{

			if (vars.Splits.Contains("Prim"))
			{

				return false;
			}

			vars.Splits.Add("Prim");
			return settings["prim"];
		}


		if (current.screen == 121)
		{

			if (vars.Splits.Contains("Fishgod"))
			{

				return false;
			}

			vars.Splits.Add("Fishgod");
			return settings["fishgod"];
		}


		if (current.screen == 106)
		{

			if (vars.Splits.Contains("Arabella"))
			{

				return false;
			}

			vars.Splits.Add("Arabella");
			return settings["arabella"];
		}


		if (current.screen == 86)
		{

			if (vars.Splits.Contains("Bellkeeper"))
			{

				return false;
			}

			vars.Splits.Add("Bellkeeper");
			return settings["bellkeeper"];
		}


		if (current.screen == 90)
		{

			if (vars.Splits.Contains("Bakrog"))
			{

				return false;
			}

			vars.Splits.Add("Bakrog");
			return settings["bakrog"];
		}


		if (current.screen == 99)
		{

			if (vars.Splits.Contains("Haegok"))
			{

				return false;
			}

			vars.Splits.Add("Haegok");
			return settings["haegok"];
		}


		if (current.screen == 105)
		{

			if (vars.Splits.Contains("Cashias"))
			{

				return false;
			}

			vars.Splits.Add("Cashias");
			return settings["cashias"];
		}
	}


	//Last Split
	if (vars.wait_rell_talk == 1 && old.cutscene == 0 && current.cutscene == 1)
	{

		vars.wait_rell_talk = 0;
		return settings["hell"];
	}
}
