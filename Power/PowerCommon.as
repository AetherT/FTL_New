
void collectRooms(CBlob@[] @rooms){
	getBlobsByName("shield_generator", rooms);	
	getBlobsByName("medbay", rooms);
	getBlobsByName("engine_room", rooms);	
	getBlobsByName("oxygen_generator", rooms);
	getBlobsByName("cloning_bay", rooms);
	getBlobsByName("weapon_room", rooms);
    //getBlobsByName("scrap_miner",rooms);
}