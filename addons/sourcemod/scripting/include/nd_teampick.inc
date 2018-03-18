#if defined _nd_teampick_included
  #endinput
#endif
#define _nd_teampick_included

native bool ND_PickedTeamsThisMap();
#define ND_PTTM_AVAILABLE() (GetFeatureStatus(FeatureType_Native, "ND_PickedTeamsThisMap") == FeatureStatus_Available)

stock bool ND_TeamsPickedThisMap() {
	return ND_PTTM_AVAILABLE() && ND_PickedTeamsThisMap();
}