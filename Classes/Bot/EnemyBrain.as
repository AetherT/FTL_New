
void onTick(CBrain @this){

	CBlob @blob = this.getBlob();
	
	if(blob is null)return;
	
	bool left = false;
	bool right = false;
	bool up = false;
	bool down = false;
	
	Vec2f Dir = (this.getNextPathPosition()+Vec2f(XORRandom(8)-4,XORRandom(8)-4))-blob.getPosition();
	
	down = Dir.y > 0;
	up =  Dir.y < 0;
	right =  Dir.x > 0;
	left =  Dir.x < 0;
	
	if(this.getTarget() !is null)
	if(!getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getTarget().getPosition())){
		Dir = this.getTarget().getPosition()-blob.getPosition();
		
		down = Dir.y > 0 || XORRandom(3) == 0;
		up =  Dir.y < 0 || XORRandom(3) == 0;
		right =  Dir.x > 0 || XORRandom(3) == 0;
		left =  Dir.x < 0 || XORRandom(3) == 0;
		
		if(blob.getDistanceTo(this.getTarget()) < 24)Dir = Vec2f(0,0);
	}
	
	
	
	//if(getMap().rayCastSolidNoBlobs(blob.getPosition()+Vec2f(0,16), this.getNextPathPosition()))down = false;
	//if(getMap().rayCastSolidNoBlobs(blob.getPosition()+Vec2f(0,-16), this.getNextPathPosition()))up = false;
	//if(getMap().rayCastSolidNoBlobs(blob.getPosition()+Vec2f(16,0), this.getNextPathPosition()))right = false;
	//if(getMap().rayCastSolidNoBlobs(blob.getPosition()+Vec2f(-16,0), this.getNextPathPosition()))left = false;
	
	blob.setKeyPressed(key_down, down);
	blob.setKeyPressed(key_up, up);
	blob.setKeyPressed(key_right, right);
	blob.setKeyPressed(key_left, left);
	
	blob.setKeyPressed(key_action1, false);
	
	if(blob.getHealth() < blob.getInitialHealth()/2){
		if(goToMedbay(this, blob)) return;
	}
	
	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius(blob.getPosition(),32.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				if(b.getTeamNum() != blob.getTeamNum() && b.hasTag("flesh")){
					if(findEnemies(this,blob))return;
				}
			}
		}
	}

	if(findGunRoom(this,blob))return;
	
	if(findEnemies(this,blob))return;
	
	if(goRepair(this,blob))return;
	
	if(XORRandom(100) == 0)if(idleSomewhere(this,blob))return;
}

void goUp(CBrain @this, CBlob @blob){
	
	this.SetPathTo(blob.getPosition()-Vec2f(0,16),true);

}

bool goToMedbay(CBrain @this, CBlob @blob){
	
	CBlob@[] medbays;
		
	getBlobsByName("medbay", medbays);
	
	for (u32 l = 0; l < medbays.length; l++)
	{
		
		CBlob @medbay = medbays[l];
		
		if(medbay !is null)
		if(blob.getTeamNum() == medbay.getTeamNum()){
			this.SetPathTo(medbay.getPosition(),true);
			this.SetTarget(medbay);
			return true;
		}
	}
	return false;
}

bool goRepair(CBrain @this, CBlob @blob){
	
	CBlob@[] rooms;
		
	getBlobsByTag("room", rooms);
	
	for (u32 l = 0; l < rooms.length; l++)
	{
		
		CBlob @room = rooms[l];
		
		if(room !is null)
		if(blob.getTeamNum() == room.getTeamNum())
		if(room.get_u8("Damage") > 0 || room.get_u16("Grief") > 0){
			this.SetPathTo(room.getPosition(),true);
			this.SetTarget(room);
			if(blob.getDistanceTo(room) < 16)blob.setKeyPressed(key_action1, true);
			
			return true;
		}
	}
	return false;
}

bool findGunRoom(CBrain @this, CBlob @blob){
	
	CBlob@[] gunrooms;
		
	getBlobsByName("weapon_room", gunrooms);
	
	for (u32 l = 0; l < gunrooms.length; l++)
	{
		
		CBlob @gunroom = gunrooms[l];
		
		if(gunroom !is null)
		if(blob.getTeamNum() == gunroom.getTeamNum())
		if(!gunroom.hasAttached()){
			this.SetPathTo(gunroom.getPosition(),true);
			this.SetTarget(gunroom);
			
			if(blob.getDistanceTo(gunroom) < 8)
			gunroom.server_AttachTo(blob, "SHOOTER");
			
			return true;
		}
	}
	return false;
}

bool findEnemies(CBrain @this, CBlob @blob){
	
	CBlob@[] rooms;
		
	getBlobsByTag("room", rooms);
		
	for (u32 l = 0; l < rooms.length; l++)
	{
		CBlob @room = rooms[l];
		
		if(room !is null)
		if(blob.getTeamNum() == room.getTeamNum()){
			CBlob@[] blobsInRadius;
			if (getMap().getBlobsInRadius(blob.getPosition(), 32.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b !is null){
						if(b.getTeamNum() != blob.getTeamNum() && b.hasTag("flesh")){
							this.SetPathTo(b.getPosition(),true);
							this.SetTarget(room);
							if(getNet().isServer())blob.server_DetachFromAll();
							return true;
						}
					}
				}
			}
		}
	}
	
	return false;
}

bool idleSomewhere(CBrain @this, CBlob @blob){
	
	CBlob@[] rooms;
		
	getBlobsByTag("room", rooms);
		
	CBlob @room = rooms[XORRandom(rooms.length)];
	
	if(room !is null)
	if(blob.getTeamNum() == room.getTeamNum() && !room.hasTag("leaking")){
		this.SetPathTo(room.getPosition(),true);
		this.SetTarget(room);
		return true;
	}
	
	return false;
}