#include <sourcemod>
#include <sdktools>
#include <nd_stocks>
#include <nd_structures>
#include <nd_rounds>

public Plugin myinfo =
{
	name = "[ND] Dynamic Starting Locations",
	author = "Xander",
	description = "Randomize starting locations based on pre-defined coordinates written to a key-value structure.",
	version = "dummy",
   	url = "https://github.com/stickz/Redstone"
};

#define UPDATE_URL  "https://github.com/stickz/Redstone/raw/build/updater/nd_dynamic_start_locations/nd_dynamic_start_locations.txt"
#include "updater/standard.sp"

ConVar cvar_kv_path;
char gs_kv_mapname[64];

public void OnPluginStart()
{
	cvar_kv_path = CreateConVar("nd_dyn_kv_path", "addons/sourcemod/data/dynamic-start-keyvalues.txt", "Define the path to the dynamic start key values file relative to SourceMod's working directory.");
	
	AddUpdaterLibrary(); //auto-updater
}

public void OnMapStart()
{
	char map_name[64];	
	GetCurrentMap(map_name, sizeof(map_name))
	
	// the string formating is to not confuse versions if map revisions are required.
	if ( StrContains(map_name, "downtown_dyn", false) != -1 )
		Format(gs_kv_mapname, sizeof(gs_kv_mapname), "downtown_dyn");
		
	else
		Format(gs_kv_mapname, sizeof(gs_kv_mapname), "-NULL-");
}

public void ND_OnRoundStarted()
{
	char kv_path[256];
	GetConVarString(cvar_kv_path, kv_path, sizeof(kv_path));
	
	KeyValues kv = new KeyValues("DynamicStartLocations");
	
	if (!FileToKeyValues(kv, kv_path))
	{
		LogError("Failed to load key-values file.");
		CloseHandle(kv);
		return;
	}
	
	if (!KvJumpToKey(kv, gs_kv_mapname, false))
	{
		CloseHandle(kv);
		return; //If the map isn't known, do nothing.
	}
	
	if (!KvGotoFirstSubKey(kv, true))
	{
		CloseHandle(kv);
		LogError("Key-value traversal error.");
		return;
	}
	//else, we're in the map's section, looking at the first start location key section
	
	int num_start_locations = 0;
	int CT_start;
	int EMP_start;
	char sz_start_locations[2][2];
	
	//count the number of start locations on the map
	do
	{
		num_start_locations += 1;
	} while (KvGotoNextKey(kv, false))
	
	KvGoBack(kv);
	
	if (num_start_locations < 2)
	{
		CloseHandle(kv);
		LogError("Less than 2 start locations or key-vaule traversal error.");
		return;
	}
	
	CT_start = GetRandomInt(1, num_start_locations);
	EMP_start = GetRandomInt(1, num_start_locations);
	
	//loop forever until the start locations are not the same
	//this assumes the start locations under the map's hierarchy are single char numbers starting from `1`.
	while (EMP_start == CT_start) {
		EMP_start = GetRandomInt(1, num_start_locations);
	}
	
	IntToString(CT_start, sz_start_locations[TEAM_CONSORT - TEAM_CONSORT], 2);
	IntToString(EMP_start, sz_start_locations[TEAM_EMPIRE - TEAM_CONSORT], 2);
	
	float origin[3];
	float angles[3];
	char entity_class[64];
	int entity;
	int entity_first_gate = -1;
	
	for (int team = TEAM_CONSORT; team <= TEAM_EMPIRE; team++)
	{
		if (KvJumpToKey(kv, sz_start_locations[team - TEAM_CONSORT], false) && KvGotoFirstSubKey(kv, true))
		{
			do
			{
				KvGetSectionName(kv, entity_class, sizeof(entity_class));
				KvGetVector(kv, "origin", origin);
				KvGetVector(kv, "angles", angles);
				
				if (StrEqual(entity_class, STRUCT_TRANSPORT))
				{
					entity = LookupEntity(entity_class, team, entity_first_gate);
					entity_first_gate = entity; //since there are 2 tgates per team, we must track the one we've already teleported.
				}
				else if (StrEqual(entity_class, "point_viewcontrol"))
					entity = LookupCameraEntity(team, -1);
				else
					entity = LookupEntity(entity_class, team, -1);
				
				if (entity > -1)
					TeleportEntity(entity, origin, angles, NULL_VECTOR);

				else
					LogError("Could not find entity: %s", entity_class);

				
			} while(KvGotoNextKey(kv, false))
		}
		else
		{
			CloseHandle(kv);
			LogError("Key-value traversal error.");
			return;
		}
		
		KvGoBack(kv); KvGoBack(kv);
		entity_first_gate = -1;
	}
	CloseHandle(kv);
	LogMessage("Randomized starting locations.");
}

//Recursivly lookup entities by classname until we find one on the matching team
public int LookupEntity(const char[] classname, int team, int start_point)
{
	int entity = FindEntityByClassname(start_point, classname);
	
	if (entity > -1) {
		return 	team == GetEntProp(entity, Prop_Send, "m_iTeamNum") 
			? entity : LookupEntity(classname, team, entity);
	}
	
	return -1;
}

public int LookupCameraEntity(int team, int start_point)
{
	int entity = FindEntityByClassname(start_point, "point_viewcontrol");
	char entity_name[64];

	if (entity > -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entity_name, sizeof(entity_name));		
		return FoundTeamCamera(team, entity_name) ? entity : LookupCameraEntity(team, entity);
	}
	
	return -1;
}

bool FoundTeamCamera(int team, const char[] entity_name)
{
	return (team == TEAM_CONSORT && StrEqual(entity_name, "wincam_consortium"))
	    || (team == TEAM_EMPIRE && StrEqual(entity_name, "wincam_empire"));
}
