
int checkFaction(CBlob @this){

	int faction = 0;
	
	CBlob@[] shipais;
		
	getBlobsByName("ship_ai", shipais);
	
	for (u32 l = 0; l < shipais.length; l++)
	{
		
		CBlob @shipai = shipais[l];
		
		if(this.getTeamNum() == shipai.getTeamNum())
		faction = shipai.get_u8("faction");
		
	}
	
	return faction;

}