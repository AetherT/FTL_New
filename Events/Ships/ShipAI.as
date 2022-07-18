
void onInit(CBlob @this){

	this.set_u8("faction", 1);
	//Factions:
	//0 - player
	//1 - enemy
	//To be expanded obviously

	
	
	print("Ship AI created. Team:"+this.getTeamNum()+" Faction:"+this.get_u8("faction"));
}