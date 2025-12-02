#include <sourcemod>
#include <sdktools>
#include <pf2>

public Plugin myinfo =
{
    name = "Unlimited Engineer Metal During Setup (PF2)",
    author = "ChatGPT + Grok + SaintSoftware (please don't kill me)",
    description = "Gives Engineers infinite metal only during setup time.",
    version = "1.5",
};

bool g_bInSetup = false;
Handle g_hTimer = null;

public void OnPluginStart()
{
    HookEvent("teamplay_round_start", Event_RoundStart);
    HookEvent("teamplay_setup_finished", Event_SetupFinished);
}

public void OnMapEnd()
{
    g_bInSetup = false;
    if (g_hTimer != null)
    {
        KillTimer(g_hTimer);
        g_hTimer = null;
    }
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_bInSetup = true;

    if (g_hTimer != null)
    {
        KillTimer(g_hTimer);
        g_hTimer = null;
    }
    g_hTimer = CreateTimer(0.5, Timer_ApplyRules, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}

public Action Event_SetupFinished(Event event, const char[] name, bool dontBroadcast)
{
    g_bInSetup = false;
    return Plugin_Continue;
}

public Action Timer_ApplyRules(Handle timer)
{
    // ? THIS IS THE ONLY REAL CHANGE (2 lines)
    bool inWaiting = (GameRules_GetProp("m_bInWaitingForPlayers") != 0);
    bool inSetup   = (GameRules_GetProp("m_bInSetup") != 0);           // this property exists everywhere

    if (!inWaiting && !inSetup)
    {
        g_hTimer = null;
        return Plugin_Stop;
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i) || TF2_GetPlayerClass(i) != TFClass_Engineer)
            continue;

        SetEntProp(i, Prop_Send, "m_iAmmo", 200, 4, 3);
    }

    return Plugin_Continue;
}

bool IsValidClient(int client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client);
}