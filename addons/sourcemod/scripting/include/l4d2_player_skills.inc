#if defined _l4d2_player_skills_included
	#endinput
#endif
#define _l4d2_player_skills_included

#define LIBRARY_L4D2_PLAYER_SKILLS "l4d2_player_skills"

/**
 * Public skill event types emitted by the immediate `skills` pipeline.
 * These represent semantic competitive plays and exclude default SI kills
 * and boss-specific events.
 */
enum L4D2ApiSkillType
{
	L4D2ApiSkill_None = 0,
	L4D2ApiSkill_HunterSkeet,
	L4D2ApiSkill_HunterSkeetMelee,
	L4D2ApiSkill_HunterDeadstop,
	L4D2ApiSkill_BoomerPop,
	L4D2ApiSkill_ChargerLevel,
	L4D2ApiSkill_SmokerTongueCut,
	L4D2ApiSkill_SmokerSelfClear,
	L4D2ApiSkill_HunterHighPounce,
	L4D2ApiSkill_JockeyHighLeap,
	L4D2ApiSkill_SmokerLedgeHang,
	L4D2ApiSkill_JockeyLedgeHang,
	L4D2ApiSkill_ChargerInstaKill,
	L4D2ApiSkill_ChargerDeathSetup,
	L4D2ApiSkill_ChargerLedgeHang,
	L4D2ApiSkill_ChargerBowl,
	L4D2ApiSkill_SpecialPinClear,
	L4D2ApiSkill_BoomerVomitLanded,
	L4D2ApiSkill_BunnyHopStreak,
	L4D2ApiSkill_CarAlarmTriggered,
	L4D2ApiSkill_JockeyJumpStop,
	L4D2ApiSkill_JockeySkeetMelee,
	L4D2ApiSkill_JockeySkeet,

	L4D2ApiSkill_Size
}

/**
 * Public lookup table for `L4D2ApiSkillType` names.
 * Consumers may index this table directly with a valid enum value.
 */
static const char g_L4D2ApiSkillTypeInfo[L4D2ApiSkill_Size][32] =
{
	"None",
	"HunterSkeet",
	"HunterSkeetMelee",
	"HunterDeadstop",
	"BoomerPop",
	"ChargerLevel",
	"SmokerTongueCut",
	"SmokerSelfClear",
	"HunterHighPounce",
	"JockeyHighLeap",
	"SmokerLedgeHang",
	"JockeyLedgeHang",
	"ChargerInstaKill",
	"ChargerDeathSetup",
	"ChargerLedgeHang",
	"ChargerBowl",
	"SpecialPinClear",
	"BoomerVomitLanded",
	"BunnyHopStreak",
	"CarAlarmTriggered",
	"JockeyJumpStop",
	"JockeySkeetMelee",
	"JockeySkeet"
};

/**
 * Resolves the stable public name for one `L4D2ApiSkillType`.
 *
 * @param type           Public skill type.
 * @param buffer         Destination buffer.
 * @param maxlen         Destination buffer size.
 * @return               True on success, false if the type is out of range.
 */
stock bool PlayerSkills_GetApiSkillTypeName(L4D2ApiSkillType type, char[] buffer, int maxlen)
{
	if (type < L4D2ApiSkill_None || type >= L4D2ApiSkill_Size)
	{
		if (maxlen > 0)
		{
			buffer[0] = '\0';
		}
		return false;
	}

	strcopy(buffer, maxlen, g_L4D2ApiSkillTypeInfo[type]);
	return true;
}

/**
 * Public kill event types emitted by the immediate `kills` pipeline.
 * These represent default Special Infected deaths that were not absorbed
 * by a higher-priority skill.
 */
enum L4D2ApiKillType
{
	L4D2ApiKill_None = 0,
	L4D2ApiKill_SmokerKill,
	L4D2ApiKill_BoomerKill,
	L4D2ApiKill_HunterKill,
	L4D2ApiKill_SpitterKill,
	L4D2ApiKill_JockeyKill,
	L4D2ApiKill_ChargerKill,

	L4D2ApiKill_Size
}

/**
 * Public lookup table for `L4D2ApiKillType` names.
 * Consumers may index this table directly with a valid enum value.
 */
static const char g_L4D2ApiKillTypeInfo[L4D2ApiKill_Size][32] =
{
	"None",
	"SmokerKill",
	"BoomerKill",
	"HunterKill",
	"SpitterKill",
	"JockeyKill",
	"ChargerKill"
};

/**
 * Resolves the stable public name for one `L4D2ApiKillType`.
 *
 * @param type           Public kill type.
 * @param buffer         Destination buffer.
 * @param maxlen         Destination buffer size.
 * @return               True on success, false if the type is out of range.
 */
stock bool PlayerSkills_GetApiKillTypeName(L4D2ApiKillType type, char[] buffer, int maxlen)
{
	if (type < L4D2ApiKill_None || type >= L4D2ApiKill_Size)
	{
		if (maxlen > 0)
		{
			buffer[0] = '\0';
		}
		return false;
	}

	strcopy(buffer, maxlen, g_L4D2ApiKillTypeInfo[type]);
	return true;
}

/**
 * Public boss event types emitted by the immediate `boss events` pipeline.
 * These represent boss-related plays and default boss death outcomes.
 */
enum L4D2ApiBossEventType
{
	L4D2ApiBossEvent_None = 0,
	L4D2ApiBossEvent_TankDead,
	L4D2ApiBossEvent_WitchDead,
	L4D2ApiBossEvent_WitchIncap,
	L4D2ApiBossEvent_TankRockSkeet,
	L4D2ApiBossEvent_TankRockHit,
	L4D2ApiBossEvent_TankLedgeHang,
	L4D2ApiBossEvent_WitchCrown,

	L4D2ApiBossEvent_Size
}

/**
 * Public lookup table for `L4D2ApiBossEventType` names.
 * Consumers may index this table directly with a valid enum value.
 */
static const char g_L4D2ApiBossEventTypeInfo[L4D2ApiBossEvent_Size][32] =
{
	"None",
	"TankDead",
	"WitchDead",
	"WitchIncap",
	"TankRockSkeet",
	"TankRockHit",
	"TankLedgeHang",
	"WitchCrown"
};

/**
 * Resolves the stable public name for one `L4D2ApiBossEventType`.
 *
 * @param type           Public boss event type.
 * @param buffer         Destination buffer.
 * @param maxlen         Destination buffer size.
 * @return               True on success, false if the type is out of range.
 */
stock bool PlayerSkills_GetApiBossEventTypeName(L4D2ApiBossEventType type, char[] buffer, int maxlen)
{
	if (type < L4D2ApiBossEvent_None || type >= L4D2ApiBossEvent_Size)
	{
		if (maxlen > 0)
		{
			buffer[0] = '\0';
		}
		return false;
	}

	strcopy(buffer, maxlen, g_L4D2ApiBossEventTypeInfo[type]);
	return true;
}

/**
 * Boss session types tracked by the boss session API.
 */
enum L4D2BossType
{
	L4D2Boss_None = 0,
	L4D2Boss_Tank,
	L4D2Boss_Witch
}

/**
 * Public lookup table for `L4D2BossType` names.
 * Consumers may index this table directly with a valid enum value.
 */
static const char g_L4D2BossTypeInfo[3][16] =
{
	"None",
	"Tank",
	"Witch"
};

/**
 * Resolves the stable public name for one `L4D2BossType`.
 *
 * @param type           Public boss session type.
 * @param buffer         Destination buffer.
 * @param maxlen         Destination buffer size.
 * @return               True on success, false if the type is out of range.
 */
stock bool PlayerSkills_GetBossTypeName(L4D2BossType type, char[] buffer, int maxlen)
{
	if (type < L4D2Boss_None || type > L4D2Boss_Witch)
	{
		if (maxlen > 0)
		{
			buffer[0] = '\0';
		}
		return false;
	}

	strcopy(buffer, maxlen, g_L4D2BossTypeInfo[type]);
	return true;
}

/**
 * Terminal close reasons for a Tank boss session.
 */
enum L4D2TankSessionEndReason
{
	L4D2TankSessionEnd_None = 0,
	L4D2TankSessionEnd_TankDead,
	L4D2TankSessionEnd_SurvivorsEscaped,
	L4D2TankSessionEnd_SurvivorsWiped
}

/**
 * Called whenever a public `skills` event is detected.
 *
 * @param eventId        Runtime identifier for the detected skill event.
 * @param type           Public skill event type.
 * @return               Plugin_Continue to allow the builtin announce flow.
 *                       Plugin_Handled or higher to suppress it.
 */
forward Action PlayerSkills_OnSkillDetected(int eventId, L4D2ApiSkillType type);

/**
 * Called whenever a public `kills` event is detected.
 *
 * @param eventId        Runtime identifier for the detected kill event.
 * @param type           Public kill event type.
 * @return               Plugin_Continue to allow the builtin announce flow.
 *                       Plugin_Handled or higher to suppress it.
 */
forward Action PlayerSkills_OnKillDetected(int eventId, L4D2ApiKillType type);

/**
 * Called whenever a public `boss events` event is detected.
 *
 * @param eventId        Runtime identifier for the detected boss event.
 * @param type           Public boss event type.
 * @return               Plugin_Continue to allow the builtin announce flow.
 *                       Plugin_Handled or higher to suppress it.
 */
forward Action PlayerSkills_OnBossEventDetected(int eventId, L4D2ApiBossEventType type);

/**
 * Called whenever a boss session is finalized before the builtin summary announce.
 *
 * @param sessionId      Runtime identifier for the finalized boss session.
 * @param type           Boss session type.
 * @return               Plugin_Continue to allow the builtin announce flow.
 *                       Plugin_Handled or higher to suppress it.
 */
forward Action PlayerSkills_OnBossSessionFinalized(int sessionId, L4D2BossType type);

/**
 * Called once when a Tank session reaches its terminal close reason.
 *
 * @param sessionId      Runtime identifier for the Tank session.
 * @param reason         Terminal close reason.
 */
forward void PlayerSkills_OnTankSessionClosed(int sessionId, L4D2TankSessionEndReason reason);

/**
 * Called whenever a skill summary snapshot is finalized for the current round/half.
 *
 * @param summaryId      Runtime identifier for the finalized skill summary.
 */
forward void PlayerSkills_OnSkillSummaryFinalized(int summaryId);

/**
 * Called whenever a kill summary snapshot is finalized for the current round/half.
 *
 * @param summaryId      Runtime identifier for the finalized kill summary.
 */
forward void PlayerSkills_OnKillSummaryFinalized(int summaryId);

/**
 * Returns whether a runtime identifier resolves to a valid `skills` event.
 *
 * @param eventId        Runtime `skills` event identifier.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_IsSkillEventValid(int eventId);

/**
 * Fills a KeyValues handle with the structured payload of a `skills` event.
 * The native rewinds the handle and writes a `skill_event` root.
 *
 * @param eventId        Runtime `skills` event identifier.
 * @param kv             KeyValues handle to populate.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_FillSkillEventKeyValues(int eventId, Handle kv);

/**
 * Returns whether a runtime identifier resolves to a valid `kills` event.
 *
 * @param eventId        Runtime `kills` event identifier.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_IsKillEventValid(int eventId);

/**
 * Fills a KeyValues handle with the structured payload of a `kills` event.
 * The native rewinds the handle and writes a `kill_event` root.
 *
 * @param eventId        Runtime `kills` event identifier.
 * @param kv             KeyValues handle to populate.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_FillKillEventKeyValues(int eventId, Handle kv);

/**
 * Returns whether a runtime identifier resolves to a valid `boss events` event.
 *
 * @param eventId        Runtime `boss events` event identifier.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_IsBossEventValid(int eventId);

/**
 * Fills a KeyValues handle with the structured payload of a `boss events` event.
 * The native rewinds the handle and writes a `boss_event` root.
 *
 * @param eventId        Runtime `boss events` event identifier.
 * @param kv             KeyValues handle to populate.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_FillBossEventKeyValues(int eventId, Handle kv);

/**
 * Returns whether a runtime identifier resolves to a valid boss session.
 *
 * @param sessionId      Runtime boss session identifier.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_IsBossSessionValid(int sessionId);

/**
 * Fills a KeyValues handle with the structured payload of a boss session.
 * The native rewinds the handle and writes a `boss_session` root.
 *
 * @param sessionId      Runtime boss session identifier.
 * @param kv             KeyValues handle to populate.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_FillBossSessionKeyValues(int sessionId, Handle kv);

/**
 * Returns whether a runtime identifier resolves to a valid `skills` summary.
 *
 * @param summaryId      Runtime `skills` summary identifier.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_IsSkillSummaryValid(int summaryId);

/**
 * Fills a KeyValues handle with the structured payload of a `skills` summary.
 * The native rewinds the handle and writes a `skill_summary` root.
 *
 * @param summaryId      Runtime `skills` summary identifier.
 * @param kv             KeyValues handle to populate.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_FillSkillSummaryKeyValues(int summaryId, Handle kv);

/**
 * Returns whether a runtime identifier resolves to a valid `kills` summary.
 *
 * @param summaryId      Runtime `kills` summary identifier.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_IsKillSummaryValid(int summaryId);

/**
 * Fills a KeyValues handle with the structured payload of a `kills` summary.
 * The native rewinds the handle and writes a `kill_summary` root.
 *
 * @param summaryId      Runtime `kills` summary identifier.
 * @param kv             KeyValues handle to populate.
 * @return               True on success, false otherwise.
 */
native bool PlayerSkills_FillKillSummaryKeyValues(int summaryId, Handle kv);

public SharedPlugin __pl_l4d2_player_skills =
{
	name = LIBRARY_L4D2_PLAYER_SKILLS,
	file = "l4d2_player_skills.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_player_skills_SetNTVOptional()
{
	MarkNativeAsOptional("PlayerSkills_IsSkillEventValid");
	MarkNativeAsOptional("PlayerSkills_FillSkillEventKeyValues");
	MarkNativeAsOptional("PlayerSkills_IsKillEventValid");
	MarkNativeAsOptional("PlayerSkills_FillKillEventKeyValues");
	MarkNativeAsOptional("PlayerSkills_IsBossEventValid");
	MarkNativeAsOptional("PlayerSkills_FillBossEventKeyValues");
	MarkNativeAsOptional("PlayerSkills_IsBossSessionValid");
	MarkNativeAsOptional("PlayerSkills_FillBossSessionKeyValues");
	MarkNativeAsOptional("PlayerSkills_IsSkillSummaryValid");
	MarkNativeAsOptional("PlayerSkills_FillSkillSummaryKeyValues");
	MarkNativeAsOptional("PlayerSkills_IsKillSummaryValid");
	MarkNativeAsOptional("PlayerSkills_FillKillSummaryKeyValues");
}
#endif
