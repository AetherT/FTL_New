
#include "WeaponCommon.as";

void onInit(CBlob@ this)
{
	this.setAimPos(this.getPosition()+Vec2f(0,-32));
	
	this.set_u16("gun_type",0);
	
	this.addCommandID("attach");
	this.addCommandID("dettach");
	this.addCommandID("fire_weapon");
	this.addCommandID("auto_fire_weapon");
	
	this.set_u16("charge_time",0);
	this.set_u8("shots_fired",0);
	this.set_u8("shots_cooldown",0);
	
	this.set_u8("chains",0);
	this.set_u8("chaindecay",0);
	
	this.Tag("builder always hit");
	
	this.set_netid("my_room",0);
	
	
	this.set_Vec2f("real_aim",Vec2f(0,-16));
	this.set_Vec2f("sprite_aim",Vec2f(0,-16));
	
	this.Untag("autofiring");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.isOverlapping(caller) && this.getTeamNum() == caller.getTeamNum()){
		if(caller.getCarriedBlob() !is null){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(0, Vec2f(0,0), this, this.getCommandID("attach"), "Attach weapon", params);
			button.SetEnabled(caller.getCarriedBlob().getName() == "weapon");
		} else 
		if(this.get_u16("gun_type") > 0){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			
			CButton@ button = caller.CreateGenericButton(1, Vec2f(0,0), this, this.getCommandID("dettach"), "Dettach weapon", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("attach"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			if(caller.getCarriedBlob() !is null && this.get_u16("gun_type") == 0){
			
				this.set_u16("gun_type",caller.getCarriedBlob().get_u16("type"));
				caller.getCarriedBlob().server_Die();
			
				if(getNet().isServer()){
					this.Sync("gun_type",true);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("dettach"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			if(this.get_u16("gun_type") != 0){
			
				CBlob @weapon = server_CreateBlob("weapon",0,this.getPosition());
				weapon.set_u16("type",this.get_u16("gun_type"));

				this.set_u16("gun_type",0);
				
				if(getNet().isServer()){
					this.Sync("gun_type",true);
					weapon.Sync("type",true);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("fire_weapon"))
	{
		Vec2f Aim = params.read_Vec2f();
		
		this.set_Vec2f("real_aim",Aim);

		fireWeapon(this);
		
		this.Untag("autofiring");
	}
	
	if (cmd == this.getCommandID("auto_fire_weapon"))
	{
		Vec2f Aim = params.read_Vec2f();
		
		this.set_Vec2f("real_aim",Aim);
		
		this.Tag("autofiring");
	}
}

void onDie(CBlob@ this)
{
	if(this.hasTag("no death effect"))return;
	if(getNet().isServer()){
		if(XORRandom(5) == 0)
		if(this.get_u16("gun_type") > 0){
			CBlob @weapon = server_CreateBlob("weapon",0,this.getPosition());
			if(weapon !is null)weapon.set_u16("type",this.get_u16("gun_type"));
		}
	}
}

void onTick(CBlob@ this)
{
	this.Untag("projectiles_ignore_me");
	if(this.get_netid("my_room") > 0){
		CBlob @room = getBlobByNetworkID(this.get_netid("my_room"));
		if(room is null){
			this.set_netid("my_room",0);
			this.Untag("autofiring");
		} else {
			this.set_Vec2f("sprite_aim",room.get_Vec2f("aim"));
			this.Tag("projectiles_ignore_me");
		}
	}
	
	if(this.hasTag("autofiring") || this.hasTag("firing"))fireWeapon(this);
	
	int GunType = this.get_u16("gun_type");
	
	bool hasPower = false;
	
	CBlob @room = getBlobByNetworkID(this.get_netid("my_room"));
	
	if(room !is null){
		if(WeaponPower[GunType] <= room.get_f32("Power")+room.get_u8("Zoltan_Power"))hasPower = true;
	}
	
	if(hasPower){
	
		if(this.get_u16("charge_time") < ChargeTime[GunType])this.set_u16("charge_time",this.get_u16("charge_time")+1);
		else {
		
			this.set_u16("charge_time",ChargeTime[GunType]);
		
			if(this.get_u8("chains") > 0){
				this.set_u8("chaindecay",this.get_u8("chaindecay")+1);
				if(this.get_u8("chaindecay") >= 30){
					this.set_u8("chaindecay",0);
					this.set_u8("chains",0);
				}
			}
		}
	} else {
		if(this.get_u16("charge_time") <= 0){
			if(this.get_u8("chains") > 0){
				this.set_u8("chains",0);
			}
		} else {
			this.set_u16("charge_time",this.get_u16("charge_time")-1);
		}
	}
	
	this.Untag("temp blob");
}

void fireWeapon(CBlob @this){

	int GunType = this.get_u16("gun_type");
	
	this.Untag("firing");
	
	if(this.get_u16("charge_time") >= ChargeTime[GunType]){
	
		CBlob@[] reactors;
		getBlobsByName("reactorroom", reactors);
		for (u8 i = 0; i < reactors.length; i++)
		{
			if (reactors[i] !is null && reactors[i].getTeamNum() == 0)
			{
				reactors[i].set_u32("no_scrap", getGameTime()+900); // make it not spawn scrap for 30 seconds if any gun is firing
			}
		}
		if(this.get_u8("shots_cooldown") <= 0){
			
			if(ProjectileType[GunType] != ""){

				Vec2f dir = this.get_Vec2f("real_aim") - this.getPosition();
				dir.Normalize();
				if(getNet().isServer()){
					CBlob @projectile = server_CreateBlob(ProjectileType[GunType],this.getTeamNum(),this.getPosition()+(dir*48));
					if(projectile !is null)projectile.setVelocity(dir*16);
				}
				if(ProjectileType[GunType] == "laser" || ProjectileType[GunType] == "heavy_laser")Sound::Play("laser.ogg");
				if(ProjectileType[GunType] == "ion" || ProjectileType[GunType] == "ion2")Sound::Play("ion_spawn.ogg");
			}
			
			if(this.get_u8("chains") < ChainMax[GunType])this.set_u8("chains",this.get_u8("chains")+1);
			
			this.set_u8("chaindecay",0);
			
			this.set_u8("shots_cooldown",5);
			
			this.set_u8("shots_fired",this.get_u8("shots_fired")+1);
		
		} else {
			this.set_u8("shots_cooldown",this.get_u8("shots_cooldown")-1);
		}
		
		if(this.get_u8("shots_fired") > Shots[GunType]-1){
			this.set_u16("charge_time",ChainExtraSpeed[GunType]*this.get_u8("chains"));
			this.set_u8("shots_cooldown",0);
			this.set_u8("shots_fired",0);
		}
		if(getNet().isServer()){
			this.Sync("charge_time",true);
			this.Sync("shots_cooldown",true);
			this.Sync("shots_fired",true);
		}
	} else {
		this.Untag("firing");
		if(getNet().isServer())this.Sync("firing",true);
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50.0f);

	CSpriteLayer@ port = this.addSpriteLayer("port", "Turret.png", 24, 24);

	if (port !is null)
	{
		Animation@ anim = port.addAnimation("default", 0, false);
		anim.AddFrame(1);
		port.SetAnimation(anim);
		port.SetRelativeZ(5.0f);
		port.SetLighting(false);
	}
	
	CSpriteLayer@ portbars = this.addSpriteLayer("portbars", "Turret.png", 24, 24);
	
	if (portbars !is null)
	{
		Animation@ anim = portbars.addAnimation("default", 0, false);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		portbars.SetAnimation(anim);
		portbars.SetRelativeZ(6.0f);
		portbars.SetLighting(false);
	}
	
	CSpriteLayer@ portlights = this.addSpriteLayer("portlights", "Turret.png", 24, 24);
	
	if (portlights !is null)
	{
		Animation@ anim = portlights.addAnimation("default", 0, false);
		anim.AddFrame(6);
		anim.AddFrame(7);
		anim.AddFrame(8);
		anim.AddFrame(9);
		portlights.SetAnimation(anim);
		portlights.SetRelativeZ(6.0f);
		portlights.SetLighting(false);
	}
	
	CSpriteLayer@ weapon = this.addSpriteLayer("weapon", "WeaponSprite.png", 96, 16);

	if (weapon !is null)
	{
		Animation@ anim = weapon.addAnimation("default", 0, false);
		anim.AddFrame(0);
		weapon.SetAnimation(anim);
		weapon.SetRelativeZ(2.5f);
		weapon.SetLighting(false);
	}
	
	this.getBlob().getShape().SetRotationsAllowed(false);
	
	CSpriteLayer@ connector = this.addSpriteLayer("link", "TurretLink.png", 24, 24);
	
	if(connector !is null)
	{
		Animation@ anim = connector.addAnimation("default", 0, false);
		anim.AddFrame(0);
		connector.SetRelativeZ(-1.0f);
		connector.SetVisible(false);
		connector.SetOffset(Vec2f(0.0f, 0.0f));
	}
}

void onTick(CSprite@ this){

	CBlob @blob = this.getBlob();
	
	if(blob is null)return;

	Vec2f dir = blob.getPosition() - blob.get_Vec2f("sprite_aim");
	f32 angle = dir.Angle();
	
	if(blob.get_Vec2f("sprite_aim").x == 0 && blob.get_Vec2f("sprite_aim").y == 0){
		angle = 270;
	}
	
	int RoomPower = 0;
	int RoomBars = 0;
	
	CBlob @room = getBlobByNetworkID(blob.get_netid("my_room"));
	if(room !is null){
		RoomPower = room.get_f32("Power")+room.get_u8("Zoltan_Power");
		RoomBars = room.get_u8("Level");
	}
	
	if(this.getSpriteLayer("port") !is null){
		this.getSpriteLayer("port").ResetTransform();
		this.getSpriteLayer("port").RotateBy(-angle+180, Vec2f(0,0));
	}
	
	if(this.getSpriteLayer("portbars") !is null){
		if(RoomBars > 0){
			this.getSpriteLayer("portbars").ResetTransform();
			this.getSpriteLayer("portbars").RotateBy(-angle+180, Vec2f(0,0));
			this.getSpriteLayer("portbars").SetFrameIndex(RoomBars-1);
			this.getSpriteLayer("portbars").SetVisible(true);
		} else this.getSpriteLayer("portbars").SetVisible(false);
	}
	
	if(this.getSpriteLayer("portlights") !is null){
		if(RoomPower > 0){
			this.getSpriteLayer("portlights").ResetTransform();
			this.getSpriteLayer("portlights").RotateBy(-angle+180, Vec2f(0,0));
			this.getSpriteLayer("portlights").SetFrameIndex(RoomPower-1);
			this.getSpriteLayer("portlights").SetVisible(true);
		} else this.getSpriteLayer("portlights").SetVisible(false);
	}
	
	if(this.getSpriteLayer("weapon") !is null){
		this.getSpriteLayer("weapon").ResetTransform();
		this.getSpriteLayer("weapon").RotateBy(-angle+180, Vec2f(0,0));
		
		
		
		this.getSpriteLayer("weapon").SetFrame(blob.get_u16("gun_type")*6+((blob.get_u16("charge_time")*1.0f)/(ChargeTime[blob.get_u16("gun_type")]*1.0f)*5));
	}
	
	
	CSpriteLayer@ connector = this.getSpriteLayer("link");
				
	if (connector !is null && blob.get_netid("my_room") > 0)
	{
	
		CBlob @room = getBlobByNetworkID(blob.get_netid("my_room"));
	
		if(room !is null){

			f32 maxDistance = 400;
				
			Vec2f hitPos;
			f32 length;
			bool flip = this.isFacingLeft();
			f32 angle =	UpdateAngle(blob);
			Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
			Vec2f startPos = blob.getPosition();
			Vec2f endPos = room.getPosition();

			length = (endPos - startPos).Length();
		
			connector.ResetTransform();
			connector.ScaleBy(Vec2f(length / 24.0f, 1.0f));
			connector.TranslateBy(Vec2f((length / 2), 1.0f * (flip ? 1 : -1)));
			connector.RotateBy((flip ? 180 : 0)+angle, Vec2f(0,0));
			connector.SetVisible(true);
			
		} else {
			connector.SetVisible(false);
		}
	}

}

int UpdateAngle(CBlob@ this)
{

	Vec2f aimpos=this.getPosition();
	Vec2f pos=this.getPosition();
	
	if(this.get_netid("my_room") > 0){
		CBlob @room = getBlobByNetworkID(this.get_netid("my_room"));
		
		if(room !is null){
			aimpos = room.getPosition();
		}
	}
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	if(!this.isFacingLeft()) mouseAngle += 180;

	return -mouseAngle;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(hitterBlob.hasTag("flesh")){
		if(hitterBlob.getTeamNum() != this.getTeamNum())return 0;
		else return damage;
	}
	
	CBlob @room = getBlobByNetworkID(this.get_netid("my_room"));
	
	if(room !is null){
		/*if(room.get_u8("Level") > room.get_u8("Damage")){
			int damage = 0;
			
			if(hitterBlob !is null){
				if(hitterBlob.hasTag("laser"))damage = hitterBlob.get_u8("Damage");
			}
			
			room.set_u8("Damage",room.get_u8("Damage")+damage);
			if(getNet().isServer())room.Sync("Damage",true);
			
			return 0;
		}*/
		return 0;
	}
	
	return damage;
}

/*
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	CBlob @room = getBlobByNetworkID(blob.get_netid("my_room"));
	
	if(room !is null){
	
		Vec2f Pos = blob.getPosition();
		Vec2f AimPos = blob.get_Vec2f("aim");
		
		GUI::DrawLine(getDriver().getScreenPosFromWorldPos(Pos)/2, getDriver().getScreenPosFromWorldPos(AimPos)/2, SColor(100, 255, 0, 0));
	
	}
}*/