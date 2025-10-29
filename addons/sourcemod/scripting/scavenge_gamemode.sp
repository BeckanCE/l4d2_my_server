#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <colors>
#include <builtinvotes>
#include <left4dhooks>
#undef REQUIRE_PLUGIN
#include <confogl>
#include <readyup>
#define REQUIRE_PLUGIN

/*****************************************************************
			G L O B A L   V A R S
*****************************************************************/

#define PLUGIN_VERSION "1.2"
#define CONSOLE		   0

ConVar
	g_cvarDebug,
	g_cvarEnable,
	g_cvarPrintCvar,
	g_cvarCFGName,

	l4d_ready_cfg_name,
	survivor_limit,

	z_versus_hunter_limit,
	z_versus_boomer_limit,
	z_versus_smoker_limit,
	z_versus_jockey_limit,
	z_versus_charger_limit,
	z_versus_spitter_limit;

Handle
	g_hVote;

enum Mode
{
	mode_none = 0,
	mode_1v1  = 1,
	mode_2v2  = 2,
	mode_3v3  = 3,
	mode_4v4  = 4,

	mode_size = 5
}

stock const char sScavMode[mode_size][] = {
	"scav_none",
	"scav1v1",
	"scav2v2",
	"scav3v3",
	"scavogl"
};

stock const char sHunterMode[mode_size][] = {
	"scavh_none",
	"scavh1v1",
	"scavh2v2",
	"scavh3v3",
	"scavhunters"
};

stock const char sScavName[mode_size][] = {
	"scav_none",
	"1v1 ScavOgl",
	"2v2 ScavOgl",
	"3v3 ScavOgl",
	"ScavOgl"
};

stock const char sHunterName[mode_size][] = {
	"scavh_none",
	"1v1 ScavHunters",
	"2v2 ScavHunters",
	"2v2 ScavHunters",
	"ScavHunters"
};

enum struct GameMode
{
	Mode mode;
	bool ishunter;
	char name[32];
}

GameMode
	g_gmVote;

/*****************************************************************
			P L U G I N   I N F O
*****************************************************************/
public Plugin myinfo =
{
	name		= "Scavenge GameMode",
	author		= "lechuga",
	description = "Manages cvar related to the game mode and allows changing it",
	version		= PLUGIN_VERSION,
	url			= "https://github.com/AoC-Gamers/scavogl_rework"
};

/*****************************************************************
			F O R W A R D   P U B L I C S
*****************************************************************/
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!L4D_IsEngineLeft4Dead2())
		SetFailState("Plugin supports Left 4 dead 2 only!");

	return APLRes_Success;
}

public void OnLibraryAdded(const char[] sName)
{
	if (!StrEqual(sName, "readyup"))
		return;

	l4d_ready_cfg_name = FindConVar("l4d_ready_cfg_name");
}

public void OnPluginStart()
{
	LoadTranslation("scavenge_gamemode.phrases");
	CreateConVar("sm_scavenge_gamemode_version", PLUGIN_VERSION, "Scavenge Rounds version", FCVAR_NOTIFY, true, 0.0);

	g_cvarDebug			   = CreateConVar("sm_scavenge_gamemode_debug", "0", "Enable debug", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarEnable		   = CreateConVar("sm_scavenge_gamemode_enable", "1", "Enable Scavenge Rounds", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarPrintCvar		   = CreateConVar("sm_scavenge_gamemode_printcvar", "0", "Print cvar changes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarCFGName		   = CreateConVar("sm_scavenge_gamemode_forcename", "1", "Force the convar l4d_ready_cfg_name according to the game mode.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	z_versus_hunter_limit  = FindConVar("z_versus_hunter_limit");
	z_versus_boomer_limit  = FindConVar("z_versus_boomer_limit");
	z_versus_smoker_limit  = FindConVar("z_versus_smoker_limit");
	z_versus_jockey_limit  = FindConVar("z_versus_jockey_limit");
	z_versus_charger_limit = FindConVar("z_versus_charger_limit");
	z_versus_spitter_limit = FindConVar("z_versus_spitter_limit");
	survivor_limit		   = FindConVar("survivor_limit");

	z_versus_hunter_limit.AddChangeHook(OnVersusLimitChange);
	z_versus_boomer_limit.AddChangeHook(OnVersusLimitChange);
	z_versus_smoker_limit.AddChangeHook(OnVersusLimitChange);
	z_versus_jockey_limit.AddChangeHook(OnVersusLimitChange);
	z_versus_charger_limit.AddChangeHook(OnVersusLimitChange);
	z_versus_spitter_limit.AddChangeHook(OnVersusLimitChange);

	RegConsoleCmd("sm_scavmode", ModeRequest);
	RegServerCmd("z_scavogl_infected_limit", InfectedLimit);
}

public void OnVersusLimitChange(ConVar Convar, const char[] sOldValue, const char[] sNewValue)
{
	if (!g_cvarEnable.BoolValue || !L4D2_IsScavengeMode() || !g_cvarPrintCvar.BoolValue)
		return;

	char sCvarName[32];
	Convar.GetName(sCvarName, sizeof(sCvarName));
	PrintDebug("[ScavOgl] Server CVar '%s' changed from '%s' to '%s'", sCvarName, sOldValue, sNewValue);
}

public Action ModeRequest(int iClient, int iArgs)
{
	if (!g_cvarEnable.BoolValue)
	{
		CReplyToCommand(iClient, "%t %t", "Tag", "Disabled");
		return Plugin_Handled;
	}

	if (!L4D2_IsScavengeMode())
	{
		CReplyToCommand(iClient, "%t %t", "Tag", "GameMode");
		return Plugin_Handled;
	}

	ModeMenu(iClient);
	return Plugin_Handled;
}

public Action InfectedLimit(int iArgs)
{
	if (!g_cvarEnable.BoolValue)
	{
		CReplyToCommand(CONSOLE, "%t %t", "Tag", "Disabled");
		return Plugin_Handled;
	}

	if (!L4D2_IsScavengeMode())
	{
		CReplyToCommand(CONSOLE, "%t %t", "Tag", "GameMode");
		return Plugin_Handled;
	}

	char sGamemode[32];
	GetCmdArg(1, sGamemode, sizeof(sGamemode));

	GameMode
		gmTarget;

	GetGamemode(gmTarget, sGamemode);

	if (gmTarget.mode == mode_none)
	{
		CReplyToCommand(CONSOLE, "%t %t z_scavogl_infected_limit <scav1v1|scav2v2|scav3v3|scavogl>", "Tag", "Usage");
		return Plugin_Handled;
	}

	ChangeGameMode(gmTarget.mode, gmTarget.ishunter, false);
	return Plugin_Handled;
}

public void OnPluginEnd()
{
	z_versus_hunter_limit.RestoreDefault();
	z_versus_boomer_limit.RestoreDefault();
	z_versus_smoker_limit.RestoreDefault();
	z_versus_jockey_limit.RestoreDefault();
	z_versus_charger_limit.RestoreDefault();
	z_versus_spitter_limit.RestoreDefault();

	if (g_cvarCFGName.BoolValue)
		l4d_ready_cfg_name.RestoreDefault();
}

/*****************************************************************
			P L U G I N   F U N C T I O N S
*****************************************************************/

/**
 * Check if the translation file exists
 *
 * @param translation	Translation name.
 * @noreturn
 */
stock void LoadTranslation(const char[] translation)
{
	char
		sPath[PLATFORM_MAX_PATH],
		sName[64];

	Format(sName, sizeof(sName), "translations/%s.txt", translation);
	BuildPath(Path_SM, sPath, sizeof(sPath), sName);
	if (!FileExists(sPath))
		SetFailState("Missing translation file %s.txt", translation);

	LoadTranslations(translation);
}

/**
 * Prints a debug message to the server console.
 *
 * @param sMessage The message to be printed.
 * @param ... Additional arguments to be formatted into the message.
 */
void PrintDebug(const char[] sMessage, any...)
{
	if (!g_cvarDebug.BoolValue)
		return;

	static char sFormat[512];
	VFormat(sFormat, sizeof(sFormat), sMessage, 2);

	PrintToServer("[Scavenge] %s", sFormat);
}

/**
 * Displays the mode menu to the specified client.
 *
 * @param iClient The client index.
 */
void ModeMenu(int iClient)
{
	GameMode
		gmCurrent,
		gmTarget;
	
	CurrentGameMode(gmCurrent);
	GetTergetMode(gmCurrent, gmTarget);

	if (gmCurrent.mode == mode_none)
	{
		CReplyToCommand(iClient, "%t %t", "Tag", "ModeNoSupported");
		return;
	}

	Menu hMenu = new Menu(MenuHandler, MENU_ACTIONS_ALL);
	hMenu.SetTitle("%t", "MenuTitle");
	hMenu.AddItem(gmTarget.name, gmTarget.name);

	hMenu.Display(iClient, 20);
}

public int MenuHandler(Menu menu, MenuAction action, int iParam, int iParam2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			int	 iClient = iParam;
			char sInfo[32];
			menu.GetItem(iParam2, sInfo, sizeof(sInfo));
			GameMode gm;

			GetGamemode(gm, sInfo);

			if (gm.mode == mode_none)
			{
				CPrintToChat(iClient, "%t %t", "Tag", "Error_InvalidMode");
				return 0;
			}

			if (CreateVote(iClient, gm) && !g_cvarDebug.BoolValue)
				FakeClientCommand(iParam, "Vote Yes");
		}
		case MenuAction_End: delete menu;
	}

	return 0;
}

/**
 * Creates a vote for the specified client and game mode.
 *
 * @param iClient The client index initiating the vote.
 * @param gm The game mode to be voted on.
 */
bool CreateVote(int iClient, GameMode gm)
{
	if (L4D_GetClientTeam(iClient) <= L4DTeam_Spectator)
	{
		CPrintToChat(iClient, "%t %t", "Tag", "VoteSpect");
		return false;
	}

	if (IsBuiltinVoteInProgress())
	{
		CPrintToChat(iClient, "%t %t", "Tag", "VoteInProgress");
		return false;
	}

	if (!IsInReady())
	{
		CPrintToChat(iClient, "%t %t", "Tag", "MatchInProgress");
		return false;
	}

	int iNumPlayers = 0;
	int[] iPlayers	= new int[MaxClients];

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || L4D_GetClientTeam(i) <= L4DTeam_Spectator)
			continue;

		iPlayers[iNumPlayers++] = i;
	}

	char sBuffer[64];
	Format(sBuffer, sizeof(sBuffer), "%t", "Question", gm.name);
	g_gmVote = gm;

	g_hVote	 = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
	SetBuiltinVoteArgument(g_hVote, sBuffer);
	SetBuiltinVoteInitiator(g_hVote, iClient);
	SetBuiltinVoteResultCallback(g_hVote, MatchVoteResultHandler);
	DisplayBuiltinVote(g_hVote, iPlayers, iNumPlayers, 20);

	PrintDebug("Vote created successfully for game mode %s by client %N", gm.name, iClient);
	return true;
}

public void VoteActionHandler(Handle vote, BuiltinVoteAction action, int param1, int param2)
{
	PrintDebug("Vote action handler called with action %d", action);

	switch (action)
	{
		case BuiltinVoteAction_End:
		{
			delete vote;
			g_hVote			  = null;
			g_gmVote.mode	  = mode_none;
			g_gmVote.ishunter = false;
			PrintDebug("Vote ended");
		}
		case BuiltinVoteAction_Cancel:
		{
			DisplayBuiltinVoteFail(vote, view_as<BuiltinVoteFailReason>(param1));
			PrintDebug("Vote cancelled with reason %d", param1);
		}
	}
}

public void MatchVoteResultHandler(Handle vote, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	PrintDebug("Match vote result handler called with %d votes and %d clients", num_votes, num_clients);

	for (int i = 0; i < num_items; i++)
	{
		if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES)
		{
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] > (num_votes / 2))
			{
				PrintDebug("Vote passed, game mode changed to %s", g_gmVote.name);
				DisplayBuiltinVotePass2(vote, "VotePassed");

				ChangeGameMode(g_gmVote.mode, g_gmVote.ishunter);

				g_gmVote.mode	  = mode_none;
				g_gmVote.ishunter = false;
				return;
			}
		}
	}

	DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
	PrintDebug("Vote failed");
}


/**
 * Retrieves the game mode based on the provided game mode string.
 *
 * @param sGamemode    The string representing the game mode to be retrieved.
 * @return             A GameMode structure containing the game mode and whether it is a hunter mode.
 */
void GetGamemode(GameMode gm, const char[] sGamemode)
{
	gm.mode		= mode_none;
	for (Mode i = mode_none; i <= mode_4v4; i++)
	{

		if (StrEqual(sScavMode[i], sGamemode) || StrEqual(sScavName[i], sGamemode))
		{
			gm.ishunter = false;
			gm.mode		= i;
			strcopy(gm.name, sizeof(gm.name), sGamemode);
			break;
		}
		else if (StrEqual(sHunterMode[i], sGamemode) || StrEqual(sHunterName[i], sGamemode))
		{
			gm.ishunter = true;
			gm.mode		= i;
			strcopy(gm.name, sizeof(gm.name), sGamemode);
			break;
		}
	}
}

/**
 * Changes the configuration name based on the given game mode.
 *
 * @param gm The game mode structure containing information about the current game mode.
 *
 * This function retrieves the current configuration name, modifies it based on whether the game mode
 * involves a hunter or not, and then sets the new configuration name. It also prints the new configuration
 * name for debugging purposes.
 */
void ChangeCFGName(GameMode gm)
{
	char
		sConfigName[32];
	
	l4d_ready_cfg_name.GetString(sConfigName, sizeof(sConfigName));

	if (gm.ishunter)
		ReplaceString(sConfigName, sizeof(sConfigName), sScavName[gm.mode], sHunterName[gm.mode], false);
	else
		ReplaceString(sConfigName, sizeof(sConfigName), sHunterName[gm.mode], sScavName[gm.mode], false);

	PrintDebug("New CFG Name: %s", sConfigName);
	l4d_ready_cfg_name.SetString(sConfigName);
}

/**
 * Changes the game mode and sets the appropriate limits for each mode.
 *
 * @param mode        The game mode to switch to.
 * @param bIshunter   Boolean indicating if the mode is for hunters.
 * @param bAnnounce   Optional boolean to announce the mode change to all players (default is true).
 *
 * The function sets the game mode and adjusts the limits for various infected types based on the mode and whether it is for hunters.
 * It also announces the mode change to all players if bAnnounce is true.
 *
 * Modes:
 * - mode_1v1: Sets limits for 1v1 mode.
 * - mode_2v2: Sets limits for 2v2 mode.
 * - mode_3v3: Sets limits for 3v3 mode.
 * - mode_4v4: Sets limits for 4v4 mode.
 *
 * For each mode, the limits for different infected types (hunter, jockey, charger, smoker, boomer, spitter) are set based on whether the mode is for hunters or not.
 */
void ChangeGameMode(Mode mode, bool bIshunter, bool bAnnounce = true)
{
	GameMode gm;
	gm.mode		= mode;
	gm.ishunter = bIshunter;

	if (g_cvarCFGName.BoolValue)
		ChangeCFGName(gm);

	if (bAnnounce)
		CPrintToChatAll("%t %t", "Tag", "ChangeMode", gm.ishunter ? sHunterName[gm.mode] : sScavName[gm.mode]);

	switch (gm.mode)
	{
		case mode_1v1:
		{
			PrintDebug("Setting limits for mode_1v1");
			if (gm.ishunter)
			{
				z_versus_jockey_limit.SetInt(0);
				PrintDebug("Set z_versus_jockey_limit to 0");
			}
			else
			{
				z_versus_jockey_limit.SetInt(1);
				PrintDebug("Set z_versus_jockey_limit to 1");
			}

			z_versus_charger_limit.SetInt(0);
			z_versus_smoker_limit.SetInt(0);
			z_versus_boomer_limit.SetInt(0);
			z_versus_spitter_limit.SetInt(0);
			PrintDebug("Set other limits to 0");
		}
		case mode_2v2:
		{
			PrintDebug("Setting limits for mode_2v2");
			if (gm.ishunter)
			{
				z_versus_hunter_limit.SetInt(2);
				z_versus_jockey_limit.SetInt(0);
				z_versus_charger_limit.SetInt(0);
				PrintDebug("Set z_versus_hunter_limit to 2, z_versus_jockey_limit and z_versus_charger_limit to 0");
			}
			else
			{
				z_versus_hunter_limit.SetInt(1);
				z_versus_jockey_limit.SetInt(1);
				z_versus_charger_limit.SetInt(1);
				PrintDebug("Set z_versus_hunter_limit, z_versus_jockey_limit, and z_versus_charger_limit to 1");
			}

			z_versus_smoker_limit.SetInt(0);
			z_versus_boomer_limit.SetInt(0);
			z_versus_spitter_limit.SetInt(0);
			PrintDebug("Set other limits to 0");
		}
		case mode_3v3:
		{
			PrintDebug("Setting limits for mode_3v3");
			if (gm.ishunter)
			{
				z_versus_hunter_limit.SetInt(3);
				z_versus_smoker_limit.SetInt(0);
				z_versus_jockey_limit.SetInt(0);
				z_versus_charger_limit.SetInt(0);
				PrintDebug("Set z_versus_hunter_limit to 3, z_versus_smoker_limit, z_versus_jockey_limit, and z_versus_charger_limit to 0");
			}
			else
			{
				z_versus_hunter_limit.SetInt(1);
				z_versus_smoker_limit.SetInt(1);
				z_versus_jockey_limit.SetInt(1);
				z_versus_charger_limit.SetInt(1);
				PrintDebug("Set z_versus_hunter_limit, z_versus_smoker_limit, z_versus_jockey_limit, and z_versus_charger_limit to 1");
			}

			z_versus_boomer_limit.SetInt(0);
			z_versus_spitter_limit.SetInt(0);
			PrintDebug("Set z_versus_boomer_limit and z_versus_spitter_limit to 0");
		}
		case mode_4v4:
		{
			PrintDebug("Setting limits for mode_4v4");
			if (gm.ishunter)
			{
				z_versus_hunter_limit.SetInt(4);
				z_versus_boomer_limit.SetInt(0);
				z_versus_smoker_limit.SetInt(0);
				z_versus_jockey_limit.SetInt(0);
				z_versus_charger_limit.SetInt(0);
				z_versus_spitter_limit.SetInt(0);
				PrintDebug("Set z_versus_hunter_limit to 4, other limits to 0");
			}
			else
			{
				z_versus_hunter_limit.SetInt(1);
				z_versus_boomer_limit.SetInt(1);
				z_versus_smoker_limit.SetInt(1);
				z_versus_jockey_limit.SetInt(1);
				z_versus_charger_limit.SetInt(1);
				z_versus_spitter_limit.SetInt(1);
				PrintDebug("Set all limits to 1");
			}
		}
	}
}


/**
 * Sets the current game mode based on the configuration name.
 *
 * @param gm        The GameMode object to be updated.
 *
 * The function retrieves the configuration name and checks if it contains
 * specific substrings to determine the game mode and whether it is a hunter mode.
 * It updates the GameMode object with the appropriate values.
 */
void CurrentGameMode(GameMode gm)
{
	char
		sConfigName[32];

	gm.mode = view_as<Mode>(survivor_limit.IntValue);

	l4d_ready_cfg_name.GetString(sConfigName, sizeof(sConfigName));

	if (StrContains(sConfigName, sScavName[gm.mode], false) != -1)
	{
		gm.ishunter = false;
		strcopy(gm.name, sizeof(gm.name), sScavName[gm.mode]);
	}
	else if (StrContains(sConfigName, sHunterName[gm.mode], false) != -1)
	{
		gm.ishunter = true;
		strcopy(gm.name, sizeof(gm.name), sHunterName[gm.mode]);
	}
	else
	{
		gm.ishunter = false;
		gm.mode		= mode_none;
		strcopy(gm.name, sizeof(gm.name), sScavName[mode_none]);
	}
}

/**
 * Copies the current game mode to the target game mode and toggles the hunter status.
 *
 * @param gmCurrent The current game mode.
 * @param gmTarget The target game mode to be modified.
 */
void GetTergetMode(GameMode gmCurrent, GameMode gmTarget)
{
	gmTarget.mode = gmCurrent.mode;
	gmTarget.ishunter = !gmCurrent.ishunter;

	strcopy(gmTarget.name, sizeof(gmTarget.name), gmTarget.ishunter ? sHunterName[gmTarget.mode] : sScavName[gmTarget.mode]);
}