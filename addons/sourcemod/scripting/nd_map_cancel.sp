#include <sourcemod>
#include <mapchooser>
#include <nd_stocks>
#include <nd_rounds>
#include <nd_mvote>
#include <nd_redstone>
#include <nd_maps>
#include <nd_stype>

ConVar cvarUsePlayerThresolds;
//ConVar cvarStockMapCount;

public void OnPluginStart()
{
	cvarUsePlayerThresolds	= CreateConVar("sm_mcancel_thresholds", "1", "Specifies wehter or not to cancel map cycling by player count");
	//cvarStockMapCount	= CreateConVar("sm_mcancel_stock", "23", "Sets the maximum number of players for stock maps");
	LoadTranslations("nd_map_management.phrases"); //load the plugin's translations	
	AutoExecConfig(true, "nd_mcancel");
}

public void OnClientPutInServer(int client)
{
	// Only check map thresholds if the round is started and the map voter isn't running
	if (cvarUsePlayerThresolds.BoolValue && CanStartMapVote())
		checkMapExcludes();
}

bool CanStartMapVote() {
	return ND_RoundStarted() && CanMapChooserStartVote();
}

void TriggerMapVote(char[] nextMap)
{
	if (CanStartMapVote())
	{	
		PrintToChatAll("\x05[xG] %t", "Retrigger Map Vote", nextMap);	
		ND_TriggerMapVote();
	}	
}

void checkMapExcludes()
{
	char nextMap[32];
	GetNextMap(nextMap, sizeof(nextMap));
	
	int clientCount = ND_GetClientCount();
	
	if (clientCount < 12)
	{
		if (	ND_GetServerTypeEx() != SERVER_TYPE_BETA &&
			StrEqual(nextMap, ND_StockMaps[ND_Gate], false))
		{
			TriggerMapVote(nextMap);
			return;
		}		
		
		else if (StrEqual(nextMap, ND_StockMaps[ND_Downtown], false) ||
			StrEqual(nextMap, ND_StockMaps[ND_Oilfield], false) ||
			StrEqual(nextMap, ND_CustomMaps[ND_Nuclear], false))
		{
			TriggerMapVote(nextMap);
			return;	
		}		
			
		if (clientCount < 8)
		{
			if (StrEqual(nextMap, ND_CustomMaps[ND_Rock], false))
			{
				TriggerMapVote(nextMap);
				return;					
			}				
		}
	}
	
	else if (clientCount >= 10)
	{
		if (StrEqual(nextMap, ND_CustomMaps[ND_Sandbrick], false))
		{
			TriggerMapVote(nextMap);
			return;
		}
		
		if (clientCount >= 18)
		{		
			if (	StrEqual(nextMap, ND_CustomMaps[ND_Mars], false) || 
				StrEqual(nextMap, ND_CustomMaps[ND_Corner], false))
			{
				TriggerMapVote(nextMap);
				return;
			}
			
			/*if (clientCount > cvarStockMapCount.IntValue && 
			     (StrEqual_PopularMap(nextMap) || StrEqual(nextMap, ND_StockMaps[ND_Silo], false)))
			{
				TriggerMapVote(nextMap);
				return;
			}*/
		}
	}
}

/*int ndsPopular[SP_MAP_SIZE] = {
	view_as<int>(ND_Hydro),
	view_as<int>(ND_Oasis),
	view_as<int>(ND_Coast),
	view_as<int>(ND_Silo),
	view_as<int>(ND_Metro)
}

bool StrEqual_PopularMap(char[] checkMap)
{
	for (int idx = 0; idx < SP_MAP_SIZE; idx++) {
		if (StrEqual(checkMap, ND_StockMaps[ndsPopular[idx]], false))
			return true;
	}
	
	return false;
}*/
