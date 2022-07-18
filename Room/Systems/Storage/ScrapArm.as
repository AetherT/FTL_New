
Vec2f armConnectionPos = Vec2f(0,-4);

void onInit(CBlob @ this){
	this.set_Vec2f("hand_pos",Vec2f(64,0));
	
	this.set_Vec2f("goal",Vec2f(128,0));
	
	this.Tag("storage");
}


void onTick(CBlob @ this)
{
	bool foundPull = false;
	
	CBlob@[] scraps;
		
	getBlobsByName("mat_scrap", scraps);
	getBlobsByName("weapon", scraps);
	
	for (u32 l = 0; l < scraps.length; l++)
	{
		
		CBlob @scrap = scraps[l];
		
		if(scrap !is null){
			if(scrap.hasTag("pulling"+this.getNetworkID()) && !scrap.isAttached() && !scrap.isInInventory() && scrap.getPosition().x > this.getPosition().x && !getMap().rayCastSolid(scrap.getPosition(), this.getPosition()+this.get_Vec2f("hand_pos"))){
				Vec2f dir = (this.getPosition()+this.get_Vec2f("hand_pos"))-scrap.getPosition();
				dir.Normalize();
				scrap.setVelocity(dir*0.06f+scrap.getVelocity());
				//scrap.getShape().getConsts().mapCollisions = false;
				foundPull = true;
				
				Vec2f startTractor = this.getPosition()+this.get_Vec2f("hand_pos");
				Vec2f endTractor = scrap.getPosition();
				f32 distance = Maths::Sqrt(Maths::Pow(endTractor.x-startTractor.x, 2)+Maths::Pow(endTractor.y-startTractor.y, 2));
				
				if((getGameTime()+this.getNetworkID()) % 30 < 15)
				for(float k = 15.0f; k < distance; k += 1){
					Vec2f direction = scrap.getPosition()-(this.getPosition()+this.get_Vec2f("hand_pos"));
					direction.Normalize();
					if(XORRandom(60)==1)ParticleAnimated("TractorBeam.png", this.getPosition()+this.get_Vec2f("hand_pos")+direction*k+Vec2f(XORRandom(5)-2,XORRandom(5)-2), -direction, -direction.getAngle()+90, 0.3f, 2, 0, true);
				}
				
				//if(XORRandom(100) == 0)scrap.Untag("pulling"+this.getNetworkID());
				
				break;
			} else {
				//scrap.getShape().getConsts().mapCollisions = true;
				scrap.Untag("pulling"+this.getNetworkID());
				if(getNet().isServer())scrap.Sync("pulling"+this.getNetworkID(),true);
			}
		}
	}
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition()+this.get_Vec2f("hand_pos"), 8.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b !is null){
				if(b.getName() == "mat_scrap"){
					if(getNet().isServer())this.server_PutInInventory(b);
					b.Untag("pulling"+this.getNetworkID());
					if(getNet().isServer())b.Sync("pulling"+this.getNetworkID(),true);
				}
			}
		}
	}
	
	if(scraps.length > 0)
	if(getNet().isServer())
	if(!foundPull){
		int num = XORRandom(scraps.length);
		if(scraps[num] !is null)if(scraps[num].getPosition().x > this.getPosition().x && !getMap().rayCastSolid(scraps[num].getPosition(), this.getPosition()+this.get_Vec2f("hand_pos"))){
			scraps[num].Tag("pulling"+this.getNetworkID());
			scraps[num].Sync("pulling"+this.getNetworkID(),true);
		}
	}
	
	if(XORRandom(30) == 0 && getNet().isServer()){
		this.set_Vec2f("goal",Vec2f(32+XORRandom(96),24-XORRandom(24+64)));
		this.Sync("goal",true);
	}
	
	Vec2f dir = this.get_Vec2f("goal")-this.get_Vec2f("hand_pos");
	dir.Normalize();
	this.set_Vec2f("hand_pos",this.get_Vec2f("hand_pos")+dir);
}


void onInit(CSprite @ this){
	CSpriteLayer@ armsocket = this.addSpriteLayer("armsocket", "ScrapArmSocket.png", 12, 12);
	
	if (armsocket !is null)
	{
		Animation@ anim = armsocket.addAnimation("default", 0, false);
		anim.AddFrame(0);
		armsocket.SetAnimation(anim);
		armsocket.SetRelativeZ(-1.0f);
		armsocket.SetLighting(false);
	}
	
	CSpriteLayer@ hand = this.addSpriteLayer("hand", "ScrapArmClaw.png", 12, 12);
	
	if (hand !is null)
	{
		Animation@ anim = hand.addAnimation("default", 0, false);
		anim.AddFrame(0);
		hand.SetAnimation(anim);
		hand.SetRelativeZ(-1.0f);
		hand.SetLighting(false);
	}
	
	CSpriteLayer@ connector = this.addSpriteLayer("link", "ScrapArmPole.png", 12, 12);
	
	if(connector !is null)
	{
		Animation@ anim = connector.addAnimation("default", 0, false);
		anim.AddFrame(0);
		connector.SetRelativeZ(-2.0f);
		connector.SetOffset(Vec2f(0.0f, 0.0f));
		connector.SetLighting(false);
	}
	
	CSpriteLayer@ connector2 = this.addSpriteLayer("link2", "ScrapArmPole.png", 12, 12);
	
	if(connector2 !is null)
	{
		Animation@ anim = connector2.addAnimation("default", 0, false);
		anim.AddFrame(0);
		connector2.SetRelativeZ(-2.0f);
		connector2.SetOffset(Vec2f(0.0f, 0.0f));
		connector2.SetLighting(false);
	}
}

void onTick(CSprite @ this)
{
	CBlob @blob = this.getBlob();
	
	if(blob is null)return;
	
	Vec2f ElbowPos = Vec2f(blob.get_Vec2f("hand_pos").x/2,96-(blob.get_Vec2f("hand_pos").x/2));
	
	CSpriteLayer @ armsocket = this.getSpriteLayer("armsocket");
	
	if(armsocket !is null){
		armsocket.ResetTransform();
		armsocket.SetOffset(Vec2f(-ElbowPos.x,-ElbowPos.y));
	}
	
	CSpriteLayer @ hand = this.getSpriteLayer("hand");
	
	if(hand !is null){
		hand.ResetTransform();
		hand.SetOffset(Vec2f(-blob.get_Vec2f("hand_pos").x,blob.get_Vec2f("hand_pos").y));
	}
	
	
	CSpriteLayer@ connector = this.getSpriteLayer("link");
				
	if (connector !is null)
	{
		f32 maxDistance = 400;
			
		Vec2f hitPos;
		f32 length;
		bool flip = this.isFacingLeft();
		Vec2f startPos = Vec2f(armConnectionPos.x,armConnectionPos.y);
		Vec2f endPos = Vec2f(-ElbowPos.x,ElbowPos.y)+armConnectionPos*2;
		f32 angle =	UpdateAngle(startPos,endPos);
		Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);

		length = (endPos - startPos).Length();
	
		connector.SetOffset(armConnectionPos);
	
		connector.ResetTransform();
		connector.ScaleBy(Vec2f(length / 12.0f, 1.0f));
		connector.TranslateBy(Vec2f((length / 2), 1.0f * (flip ? 1 : -1)));
		connector.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
	}
	
	CSpriteLayer@ connector2 = this.getSpriteLayer("link2");
				
	if (connector2 !is null)
	{
		f32 maxDistance = 400;
			
		Vec2f hitPos;
		f32 length;
		bool flip = this.isFacingLeft();
		Vec2f startPos = Vec2f(-ElbowPos.x,ElbowPos.y);
		Vec2f endPos = Vec2f(-blob.get_Vec2f("hand_pos").x,-blob.get_Vec2f("hand_pos").y);
		f32 angle =	UpdateAngle(startPos,endPos);
		Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);

		length = (endPos - startPos).Length();
	
		connector2.SetOffset(Vec2f(-ElbowPos.x,-ElbowPos.y));
	
		connector2.ResetTransform();
		connector2.ScaleBy(Vec2f(length / 12.0f, 1.0f));
		connector2.TranslateBy(Vec2f((length / 2), 1.0f * (flip ? 1 : -1)));
		connector2.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
	}
}

int UpdateAngle(Vec2f pos1, Vec2f pos2)
{

	Vec2f aimpos=pos2;
	Vec2f pos=pos1;
	
	Vec2f aim_vec = (pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	//if(left) mouseAngle += 180;

	return -mouseAngle;
}