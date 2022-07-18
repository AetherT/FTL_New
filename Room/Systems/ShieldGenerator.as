
int ShieldWidth = 2;

void onInit(CBlob @ this){
	this.set_u8("MaxLevel",8);
	this.set_u8("Level",2);
	
	this.set_u16("Recharge",0);
	
	this.addCommandID("vehicle getout");
	this.addCommandID("form_shield");
	
	this.set_Vec2f("aim",this.getPosition());
	
	this.set_u32("last_placement",getGameTime());
	
	this.Tag("power_lights");
	
	this.set_u8("SystemIcon",1);
	
	///////////////////////AI SHIP HACK
	
	if(this.getTeamNum() != 0){
		this.set_u8("Level",2+XORRandom(4)*6);
	}
}


void onTick(CBlob @ this)
{
	if(this.hasTag("shield_sound")){
		Sound::Play("shield_generate.ogg");
		this.Untag("shield_sound");
	}
	
	if(this.get_f32("Power")+this.get_u8("Zoltan_Power") > 0)this.set_u16("Recharge",this.get_u16("Recharge")+(this.get_f32("Power")+this.get_u8("Zoltan_Power"))*10.0);
	if(this.get_u16("Recharge") > 4000){
		layShield(this, 1);
		if(this.get_f32("Power")+this.get_u8("Zoltan_Power") > 2)layShield(this, 2);
		if(this.get_f32("Power")+this.get_u8("Zoltan_Power") > 4)layShield(this, 3);
		if(this.get_f32("Power")+this.get_u8("Zoltan_Power") > 6)layShield(this, 4);
		this.set_u16("Recharge",0);
	}
	
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob = ap.getOccupied();
			
			ap.offsetZ = 10.0f;

			if (blob !is null && ap.socket)
			{
				// GET OUT
				if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					this.SendCommand(this.getCommandID("vehicle getout"), params);
					break;
				}
				
				//Shield
				if (blob.isMyPlayer() && ap.isKeyPressed(key_action1))
				{
					this.SendCommand(this.getCommandID("form_shield"));
					break;
				}
				
				this.set_Vec2f("aim",blob.getAimPos());
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (isServer && cmd == this.getCommandID("vehicle getout"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());

		if (caller !is null)
		{
			this.server_DetachFrom(caller);
		}
	}
	
	if (cmd == this.getCommandID("form_shield"))
	{
		if(isServer && this.get_u32("last_placement") < getGameTime() && this.get_f32("Power")+this.get_u8("Zoltan_Power") > 0){
			for(int i = 0;i <= 0;i++){
			
				Vec2f Modifier = Vec2f(0,i*34);
			
				Vec2f CheckPos = Vec2f(this.get_Vec2f("aim").x+14,this.get_Vec2f("aim").y)+Modifier;
				
				int Alt = 0;
		
				if(CheckPos.x % (28*2) >= 28)Alt += 17;
				
				CheckPos = Vec2f(this.get_Vec2f("aim").x+14,this.get_Vec2f("aim").y-Alt+17)+Modifier;
				
				CheckPos = Vec2f(Maths::Floor(CheckPos.x/28)*28,Maths::Floor(CheckPos.y/34)*34+Alt);
				
				bool MapFree = true;
			
				for(int k = -1;k <= 1;k++)
				for(int l = -1;l <= 1;l++){
					if(getMap().isTileSolid(getMap().getTile(CheckPos+Vec2f(k*8,l*8))))MapFree = false;
				}
				
				if(MapFree){
				
					bool shield = false;
					
					CBlob@[] blobs;
					
					getMap().getBlobsAtPosition(CheckPos, @blobs);
					
					for (u32 k = 0; k < blobs.length; k++)
					{
						CBlob@ blob = blobs[k];
						if(blob.getName() == "shield" || blob.hasTag("room"))shield = true;
					}
					
					if(!shield){
						if(getNet().isServer()){
							CBlob @shield = server_CreateBlob("shield", this.getTeamNum(), CheckPos);
							shield.server_SetTimeToDie(10.0f);
						}
						this.Tag("shield_sound");
						this.Sync("shield_sound",true);
					}
				
				}
			}
			if(this.get_f32("Power")+this.get_u8("Zoltan_Power") > 0)
				this.set_u32("last_placement",getGameTime()+10*8/(this.get_f32("Power")+this.get_u8("Zoltan_Power")));
			else 
				this.set_u32("last_placement",getGameTime()+10*8);
		}
	}
}


void layShield(CBlob @ this, int Level)
{
	int direction = 1;
	
	if(this.getTeamNum() != 0)direction = -1;
	
	Vec2f StartPos = this.getPosition()+Vec2f(240*direction+Level*direction*28,0);
	
	int Alt = 0;
	
	if(StartPos.x % (28*2) >= 28)Alt += 17;
	
	//if(Alt != 0)print("level:"+Level+" is shifted +17 y.");
	
	StartPos = Vec2f(Maths::Floor(StartPos.x/28)*28,Maths::Floor(StartPos.y/34)*34+Alt);
	
	for(int i = -(ShieldWidth+Level);i < ShieldWidth;i += 1){
		
		Vec2f CheckPos = StartPos+Vec2f(0,i*34+Maths::Ceil(Level/2)*34);
		
		bool MapFree = true;
		
		for(int k = -1;k <= 1;k++)
		for(int l = -1;l <= 1;l++){
			if(getMap().isTileSolid(getMap().getTile(CheckPos+Vec2f(k*8,l*8))))MapFree = false;
		}
		
		if(MapFree){
		
			bool shield = false;
			
			CBlob@[] blobs;
			
			getMap().getBlobsAtPosition(CheckPos, @blobs);
			
			for (u32 k = 0; k < blobs.length; k++)
			{
				CBlob@ blob = blobs[k];
				if(blob.getName() == "shield" || blob.hasTag("room"))shield = true;
			}
			
			if(!shield){
				if(getNet().isServer())server_CreateBlob("shield", this.getTeamNum(), CheckPos);
				this.Tag("shield_sound");
				this.Sync("shield_sound",true);
				break;
			}
		
		}
	}
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ arm_rest = this.addSpriteLayer("arm_rest", this.getFilename() , 40, 40, blob.getTeamNum(), blob.getSkinNum());

	if (arm_rest !is null)
	{
		Animation@ anim = arm_rest.addAnimation("default", 0, false);
		anim.AddFrame(1);
		//arm_rest.SetOffset(Vec2f(3.0f, -7.0f));
		arm_rest.SetRelativeZ(100);
	}
	
	// this.SetEmitSound("/ShieldGenerator.ogg");
	// this.SetEmitSoundPaused(false);
	// this.SetEmitSoundSpeed(1);
	// this.SetEmitSoundVolume(0.1f);
}


void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if(blob.get_u32("last_placement") >= getGameTime())return;

	if(getLocalPlayer() is null)return;
	if(getLocalPlayer().getBlob() is null)return;
	if(!getLocalPlayer().getBlob().isAttachedToPoint("SHOOTER"))return;
	if(getLocalPlayer().getBlob().getTeamNum() != blob.getTeamNum())return;
	if(!getLocalPlayer().getBlob().isAttachedTo(blob))return;
	
	Vec2f Aim = blob.get_Vec2f("aim");

	for(int i = 0;i <= 0;i++){
			
		Vec2f Modifier = Vec2f(0,i*34);
	
		Vec2f CheckPos = Vec2f(Aim.x+14,Aim.y)+Modifier;
		
		int Alt = 0;

		if(CheckPos.x % (28*2) >= 28)Alt += 17;
		
		CheckPos = Vec2f(Aim.x+14,Aim.y-Alt+17)+Modifier;
		
		CheckPos = Vec2f(Maths::Floor(CheckPos.x/28)*28,Maths::Floor(CheckPos.y/34)*34+Alt);
		
		CheckPos = getDriver().getScreenPosFromWorldPos(CheckPos);
		
		GUI::DrawIcon("ShieldIcon.png", 0, Vec2f(16,16), CheckPos-Vec2f(16,16));
		
	}
	
}
