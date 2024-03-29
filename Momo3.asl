state("Momodora3", "v1.06") {

	double loadSave:	0x2D3054, 0x370, 0xE00;

	double screen:		0x1890F0, 0x7C, 0x10, 0xC, 0xF78;

	double cutscene:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1118;

	double percentage:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1C30;

	double Haegok:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1CF8;

	double InGame:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1E38;
	double InGame2:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1F00;
}

state("Momodora3", "v1.11b") {

	double loadSave:	0x18D4CC, 0x1E4,  0x104, 0x8, 0x104, 0x4,  0x128;

	double screen:		0x189570, 0x274, 0x2ec, 0xc, 0x0, 0x8;

	double cutscene:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1168;

	double percentage:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1C80;

	double Haegok:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1D48;

	double InGame:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1E88;
	double InGame2:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1F50;
}

state("Momodora3", "v1.12") {

	double loadSave:	0x18D4CC, 0x1E4,  0x104, 0x8, 0x104, 0x4,  0xE0;

	double screen:		0x189570, 0x274, 0x2ec, 0xc, 0x0, 0x8;

	double cutscene:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1168;

	double percentage:	0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1C80;

	double Haegok:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1D48;

	double InGame:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1E38;
	double InGame2:		0x189EDC, 0x4, 0xB4, 0x4, 0xC, 0x1F50;
}

startup {

	settings.Add("zones", true, "Zones");
		settings.Add("shrine", true, "Ishlith Shrine", "zones");
		settings.Add("madryn", true, "Old Madryn", "zones");
		settings.Add("hideout", true, "Dim Hideout", "zones");
		settings.Add("garden", true, "Belltower Garden", "zones");
		settings.Add("distortion", true, "Distortion in Time", "zones");
		settings.Add("grave", true, "Artemisia's Grave", "zones");

	settings.Add("bosses", false, "Bosses");
		settings.Add("prim", false, "Prim", "bosses");
		settings.Add("fishgod", false, "Fishgod Peishe", "bosses");
		settings.Add("arabella", false, "Arabella Sisters", "bosses");
		settings.Add("bellkeeper", false, "Bellkeeper Poetelia", "bosses");
		settings.Add("bakrog", false, "Bakrog Demon", "bosses");
		settings.Add("haegok", false, "Haegok", "bosses");
		settings.Add("cashias", false, "Cashias", "bosses");

	settings.Add("hell", true, "Endsplit");
}

init {

	ProcessModuleWow64Safe module = modules.Single(x => String.Equals(x.ModuleName, "Momodora3.exe", StringComparison.OrdinalIgnoreCase));

	// initialising the cryptography factory (we're using SHA512 in this case. MD5 would work aswell but SHA's considered the better option for checksums)
	byte[] exe512HashBytes = new byte[0];

	using (var sha = System.Security.Cryptography.SHA512.Create())
		using (var s = File.Open(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			exe512HashBytes = sha.ComputeHash(s);

	string exeHash = exe512HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b); // execute the exe512HashBytes function and storing the hash in the hexadecimal (uppercased) variant

	switch(exeHash) {
		case "4FE144C295682E4D2F82E20EA388B3FFF9653C8AEC8A006E06ED20EC8E59AFFEDB86F75BEFD9FE09A9F47FCDEDF415FAEA723F78440C03F403A1F5159DF618E9":
			version = "v1.06";
			break;

		case "1BDC4C10D23F00300EBAFB519CC44C3F650829A17BC23977D3207A25BB6C97F02F1D8AB62EF890393DF5C1867BFA4C051245B50B5C949F61E149FF02DE630F0C":
			version = "v1.11b";
			break;

		case "71131855F183BC42AC6E028AEB6D8E76D192AF68E448F9944004853606B0D74DA9E00E690B7DDD31E2D3287B9CD4C160A9FEEB5266D5E6608FFA698F5C55B65C":
			version = "v1.12";
			break;

		default:
			vars.version = "version not supported";
			break;
    }

	// HashSet to hold splits already hit
	vars.Splits = new HashSet<string>();

	// Saves the last screen the player was at, because while loading its values is set to -1
	vars.last_screen = -1;

	vars.wait_rell_talk = 0;

	// Lambda function cause I can
	Func<int, int, List<int>> toList = (x, y) => new List<int> {x, y};

	//Dictionary to bind zone transitions to their respective starting and end room number
	vars.Zones = new Dictionary<string, List<int>> { {"shrine", toList(57, 64)}, {"madryn", toList(67,  121)}, {"hideout", toList(79, 106)}, {"garden", toList(114, 85)}, {"grave", toList(93, 116)} };

	//Dictionary to bind boss fights to their respective room number
	vars.Bosses = new Dictionary<string, int> { {"prim", 64}, {"fishgod", 121}, {"arabella", 106}, {"bellkeeper", 86}, {"bakrog", 90}, {"haegok", 99}, {"cashias", 105} };
}

isLoading {

	return (timer.CurrentAttemptDuration.Seconds > 5 && current.screen == -1);
}

update {

	// Update last_screen when we are not in a screen transition
	if (old.screen != -1)
		vars.last_screen = old.screen;

	// After killing Rell wait for the player to talk to them, return false to avoid false split
	if (current.screen == 112 && old.percentage < current.percentage) {
		vars.wait_rell_talk = 1;
		return false;
	}

	// Clear any hit splits and reset wait_reel_talk if timer stops
	if (timer.CurrentPhase == TimerPhase.NotRunning) {
		vars.Splits.Clear();
		vars.wait_rell_talk = 0;
	}
}

start {

	return (old.loadSave == 0 && current.loadSave == 1);
}

reset {

    return ((old.InGame == 1 && current.InGame == 0) || (old.InGame2 == 1 && current.InGame2 == 0));
}

split {

	// Zone Splits
	if (old.screen != current.screen) {
		foreach (var zone in vars.Zones) {
			if (current.screen == zone.Value[0] && vars.last_screen == zone.Value[1]) {
				if (vars.Splits.Contains(zone.Key))
					return false;

				vars.Splits.Add(zone.Key);
				return settings[zone.Key];
			}
		}

		if (vars.last_screen == 100 && current.Haegok == 1) {
			if (current.screen == 47 || current.screen == 57 || current.screen == 67 || current.screen == 79 || current.screen == 114) {
				if (vars.Splits.Contains("distortion"))
					return false;

				vars.Splits.Add("distortion");
				return settings["distortion"];
			}
		}
	}

	// Boss Splits
	if (old.percentage < current.percentage) {
		foreach (var boss in vars.Bosses) {
			if (current.screen == boss.Value) {
				if (vars.Splits.Contains(boss.Key))
					return false;

				vars.Splits.Add(boss.Key);
				return settings[boss.Key];
			}
		}
	}

	// Last Split
	if (vars.wait_rell_talk == 1 && old.cutscene == 0 && current.cutscene == 1) {
		if (vars.Splits.Contains("hell"))
			return false;

		vars.Splits.Add("hell");
		return settings["hell"];
	}
}