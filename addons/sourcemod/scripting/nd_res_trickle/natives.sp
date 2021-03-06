/* Forwards */
Handle OnResFrackStarted;

void InitForwards()
{
	OnResFrackStarted = CreateGlobalForward("ND_OnResFrackStarted", ET_Ignore, Param_Cell, Param_Float, Param_Cell, Param_Cell);	
}

void FireOnResFrackStartedForward(int resType, float delay, int interval, int amount)
{
	Action dummy;
	Call_StartForward(OnResFrackStarted);
	Call_PushCell(resType);
	Call_PushFloat(delay);
	Call_PushCell(interval);
	Call_PushCell(amount);
	Call_Finish(dummy);	
}

/* Natives */
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("ND_AddTertiaryResources", Native_AddTertRes);
	CreateNative("ND_SetTertiaryResources", Native_SetTertRes);
	CreateNative("ND_GetTertiaryResources", Native_GetTertRes);
	
	CreateNative("ND_AddSecondaryResources", Native_AddSecRes);
	CreateNative("ND_SetSecondaryResources", Native_SetSecRes);
	CreateNative("ND_GetSecondaryResources", Native_GetSecRes);
	
	CreateNative("ND_AddPrimaryResources", Native_AddPrimeRes);
	CreateNative("ND_SetPrimaryResources", Native_SetPrimeRes);
	CreateNative("ND_GetPrimaryResources", Native_GetPrimeRes);
	return APLRes_Success;	
}

public int Native_AddTertRes(Handle plugin, int numParams) 
{
	// Get the entity, team and amount to add
	int entity = GetNativeCell(1);
	int team = GetNativeCell(2);
	int amount = GetNativeCell(3);
	
	// Get the array index of the tertiary, if not found return false
	int arrIndex = Tertiary_FindArrayIndex(entity);	
	if (arrIndex == RESPOINT_NOT_FOUND)
		return false;
	
	// Get the tertiary struct
	ResPoint tert;
	structTertaries.GetArray(arrIndex, tert);
	
	// Add the resources to the tertiary and update the running total
	tert.AddRes(team, amount);
	ND_SetCurrentResources(tert.entIndex, tert.GetRes());
	
	// Update the tertiary ArrayList
	structTertaries.SetArray(arrIndex, tert);
	return true; // Return true for success
}

public int Native_SetTertRes(Handle plugin, int numParams) 
{
	// Get the entity, team and amount to add
	int entity = GetNativeCell(1);
	int team = GetNativeCell(2);
	int amount = GetNativeCell(3);
	
	// Get the array index of the tertiary, if not found return false
	int arrIndex = Tertiary_FindArrayIndex(entity);	
	if (arrIndex == RESPOINT_NOT_FOUND)
		return false;
	
	// Get the tertiary struct
	ResPoint tert;
	structTertaries.GetArray(arrIndex, tert);
	
	// Set the current resources and update the running total
	tert.SetRes(team, amount);
	ND_SetCurrentResources(tert.entIndex, tert.GetRes());
	
	// Update the tertiary ArrayList
	structTertaries.SetArray(arrIndex, tert);
	return true; // Return true for success
}

public int Native_GetTertRes(Handle plugin, int numParams) 
{
	// Get the entity, team and amount to add
	int entity = GetNativeCell(1);
	int team = GetNativeCell(2);
	
	// Get the array index of the tertiary, if not found return -1
	int arrIndex = Tertiary_FindArrayIndex(entity);	
	if (arrIndex == RESPOINT_NOT_FOUND)
		return -1;
	
	// Get the tertiary struct and return resources
	ResPoint tert;
	structTertaries.GetArray(arrIndex, tert);	
	return tert.GetResTeam(team);
}

public int Native_AddSecRes(Handle plugin, int numParams) 
{
	// Get the entity, team and amount to add
	int entity = GetNativeCell(1);
	int team = GetNativeCell(2);
	int amount = GetNativeCell(3);
	
	// Get the array index of the secondary, if not found return false
	int arrIndex = Secondary_FindArrayIndex(entity);	
	if (arrIndex == RESPOINT_NOT_FOUND)
		return false;
	
	// Get the secondary struct
	ResPoint sec;
	structSecondaries.GetArray(arrIndex, sec);
	
	// Add the resources to the secondary and update the running total
	sec.AddRes(team, amount);
	ND_SetCurrentResources(sec.entIndex, sec.GetRes());
	
	// Update the secondary ArrayList
	structSecondaries.SetArray(arrIndex, sec);
	return true; // Return true for success
}

public int Native_SetSecRes(Handle plugin, int numParams) 
{
	// Get the entity, team and amount to add
	int entity = GetNativeCell(1);
	int team = GetNativeCell(2);
	int amount = GetNativeCell(3);
	
	// Get the array index of the secondary, if not found return false
	int arrIndex = Secondary_FindArrayIndex(entity);	
	if (arrIndex == RESPOINT_NOT_FOUND)
		return false;
	
	// Get the secondary struct
	ResPoint sec;
	structSecondaries.GetArray(arrIndex, sec);
	
	// Set the current resources and update the running total
	sec.SetRes(team, amount);
	ND_SetCurrentResources(sec.entIndex, sec.GetRes());
	
	// Update the secondary ArrayList
	structSecondaries.SetArray(arrIndex, sec);
	return true; // Return true for success
}

public int Native_GetSecRes(Handle plugin, int numParams) 
{
	// Get the entity, team and amount to add
	int entity = GetNativeCell(1);
	int team = GetNativeCell(2);
	
	// Get the array index of the secondary, if not found return -1
	int arrIndex = Secondary_FindArrayIndex(entity);	
	if (arrIndex == RESPOINT_NOT_FOUND)
		return -1;
	
	// Get the secondary struct and return resources
	ResPoint sec;
	structSecondaries.GetArray(arrIndex, sec);	
	return sec.GetResTeam(team);
}

public int Native_AddPrimeRes(Handle plugin, int numParams) 
{
	// Get the team and amount to add
	int team = GetNativeCell(1);
	int amount = GetNativeCell(2);
	
	// Get the prime struct
	ResPoint prime;
	structPrimary.GetArray(0, prime);
	
	// Add the resources to prime and update the running total
	prime.AddRes(team, amount);
	ND_SetCurrentResources(prime.entIndex, prime.GetRes());
	
	// Update the prime ArrayList
	structPrimary.SetArray(0, prime);
	return true; // Return true for success
}

public int Native_SetPrimeRes(Handle plugin, int numParams) 
{
	// Get the entity, team and amount to add
	int team = GetNativeCell(1);
	int amount = GetNativeCell(2);
	
	// Get the prime struct
	ResPoint prime;
	structPrimary.GetArray(0, prime);
	
	// Set the current resources and update the running total
	prime.SetRes(team, amount);
	ND_SetCurrentResources(prime.entIndex, prime.GetRes());
	
	// Update the prime ArrayList
	structPrimary.SetArray(0, prime);
	return true; // Return true for success
}

public int Native_GetPrimeRes(Handle plugin, int numParams) 
{
	// Get the team for prime
	int team = GetNativeCell(1);
	
	// Get the prime struct
	ResPoint prime;
	structPrimary.GetArray(0, prime);

	// Return resources left for team on prime
	return prime.GetResTeam(team);
}