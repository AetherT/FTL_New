
#include "CheckFaction.as";

void onInit(CBlob@ this)
{
	this.addCommandID("vehicle getout");

	this.addCommandID("auto_fire_weapon");
	
	this.Tag("builder always hit");
	
	this.set_Vec2f("AI_aim",Vec2f(0,0));
	
	if(XORRandom(2) == 0)this.Tag("AI_smart");
	
	this.Untag("auto_fire");
	
	this.set_netid("my_turret",0);
	
	this.set_u8("MaxLevel",4);
	
	this.set_u8("upgrade_cost_base",25);
	this.set_u8("upgrade_cost_level",10);
	
	this.Tag("power_lights");
	
	this.set_u8("SystemIcon",6);
	
	///////////////////////AI SHIP HACK
	
	if(this.getTeamNum() != 0){
		this.set_u8("Level",4);
	}
}

void onTick(CBlob@ this)
{
	bool isAI = false;
	
	CBlob @turret = getBlobByNetworkID(this.get_netid("my_turret"));
	
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
				if(blob.getBrain().isActive())isAI = true;
				
				// GET OUT
				if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					this.SendCommand(this.getCommandID("vehicle getout"), params);
					return;
				}
				
				if(!this.hasTag("auto_fire"))this.set_Vec2f("aim",blob.getAimPos());
				
				//Fire
				if (blob.isMyPlayer() && ap.isKeyPressed(key_action1))
				{
					if(turret !is null){
						CBitStream params;
						params.write_Vec2f(getControls().getMouseWorldPos());
						turret.SendCommand(turret.getCommandID("fire_weapon"), params);
					}
					this.Untag("auto_fire");
					return;
				}
				
				//AutoFire
				if (blob.isMyPlayer() && ap.isKeyJustPressed(key_action2))
				{
					if(turret !is null){
						CBitStream params;
						params.write_Vec2f(getControls().getMouseWorldPos());
						turret.SendCommand(turret.getCommandID("auto_fire_weapon"), params);
					}
					this.Tag("auto_fire");
					this.set_Vec2f("aim",blob.getAimPos());
					return;
				}
			}
		}
	}
	
	if(getNet().isServer()){
		if(isAI)if(XORRandom(10) == 0)fireWeapon(this);
	}
	
	if(isAI)
	if(this.get_f32("Power") > 0){
		
		/*if(!this.hasTag("AI_smart")){
			if(this.get_Vec2f("AI_aim").x > -100)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(-XORRandom(10),0));
			if(this.get_Vec2f("AI_aim").x < 100)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(XORRandom(10),0));
			
			if(this.get_Vec2f("AI_aim").y > -50)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(0,-XORRandom(10)));
			if(this.get_Vec2f("AI_aim").y < 50)this.set_Vec2f("AI_aim",this.get_Vec2f("AI_aim")+Vec2f(0,XORRandom(10)));
			
			this.set_Vec2f("aim",this.getPosition()+Vec2f(-200,0)+this.get_Vec2f("AI_aim"));
		} else */
		{
		
			CBlob@[] blobs;
	
			getBlobsByTag("room", blobs);

			int FoundTarget = 0;
			
			while (FoundTarget >= 0 && FoundTarget < 100)
			{
				CBlob@ blob = blobs[XORRandom(blobs.length)];
				if(checkFaction(blob) != checkFaction(this) && blob.getPosition().x < this.getPosition().x){
					this.set_Vec2f("aim",blob.getPosition());
					break;
				}
				FoundTarget++;
			}
		
		}
		
		if(getNet().isServer()){
			if(turret !is null){
				CBitStream params;
				params.write_Vec2f(this.get_Vec2f("aim"));
				turret.SendCommand(turret.getCommandID("auto_fire_weapon"), params);
			}
		}
	}
	
	
	
	if(getNet().isServer()){
		if(this.get_netid("my_turret") <= 0 || getBlobByNetworkID(this.get_netid("my_turret")) is null){ //If we don't have a turret
		
			CBlob@[] turrets;
		
			getBlobsByName("turret", turrets);
			
			CBlob @closestTurret = null;
			int closestDistance = 160;
			
			for (u32 l = 0; l < turrets.length; l++) //Loop through turrets
			{
				
				CBlob @turret = turrets[l];
				
				if(turret.getTeamNum() == this.getTeamNum())
				if(getBlobByNetworkID(turret.get_netid("my_room")) is null){ //If we find a turret without a room;
					if(this.getDistanceTo(turret) < closestDistance || closestDistance < 0){
						@closestTurret = turret;
						closestDistance = this.getDistanceTo(turret);
					}
				}
			}
			
			if(closestTurret !is null){ //Match made! :D
				this.set_netid("my_turret",closestTurret.getNetworkID());
				closestTurret.set_netid("my_room",this.getNetworkID());
				
				this.Sync("my_turret",true);
				closestTurret.Sync("my_room",true);
			}
		
		}
	}
	
	if(getBlobByNetworkID(this.get_netid("my_turret")) is null){
		this.set_netid("my_turret",0);
		this.Sync("my_turret",true);
	} else {
		if(getBlobByNetworkID(this.get_netid("my_turret")).hasTag("autofiring"))this.Tag("auto_fire");
		else this.Untag("auto_fire");
	}
}

void fireWeapon(CBlob@ this){

		
	CBlob @turret = getBlobByNetworkID(this.get_netid("my_turret"));
	
	if(turret !is null){
		turret.Tag("firing");
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
	
	if (cmd == this.getCommandID("auto_fire_weapon"))
	{
		this.Tag("auto_fire");
		if(getNet().isServer())this.Sync("auto_fire",true);
	}
}


void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ arm_rest = this.addSpriteLayer("arm_rest", this.getFilename() , 40, 16, blob.getTeamNum(), blob.getSkinNum());

	if (arm_rest !is null)
	{
		Animation@ anim = arm_rest.addAnimation("default", 0, false);
		anim.AddFrame(1);
		//arm_rest.SetOffset(Vec2f(3.0f, -7.0f));
		arm_rest.SetRelativeZ(100);
	}
}


void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if(getLocalPlayer() is null)return;
	if(getLocalPlayer().getBlob() is null)return;
	if(!getLocalPlayer().getBlob().isAttachedToPoint("SHOOTER"))return;
	if(getLocalPlayer().getBlob().getTeamNum() != blob.getTeamNum())return;
	if(!getLocalPlayer().getBlob().isAttachedTo(blob))return;
	
	Vec2f Aim = getDriver().getScreenPosFromWorldPos(blob.get_Vec2f("aim"));
	
	if(!blob.hasTag("auto_fire"))GUI::DrawIcon("Target.png", 0, Vec2f(16,16), Aim-Vec2f(16,16));
	else GUI::DrawIcon("AutoTarget.png", 0, Vec2f(16,16), Aim-Vec2f(16,16));
	
}
