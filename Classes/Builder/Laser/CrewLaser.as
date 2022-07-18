
#include "BombCommon.as";

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.bullet = true;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");

	//dont collide with top of the map
	this.SetMapEdgeFlags(0);

	this.server_SetTimeToDie(10);
	
	this.getSprite().SetLighting(false);
	this.getSprite().SetZ(49.0f);
	
	this.SetLight(true);
	this.SetLightRadius(8);
	this.SetLightColor(SColor(255, 255, 0, 0));
	
	this.Tag("laser");
	this.set_f32("Damage", 10.0f);
	
	if(this.getName() == "mantisspit"){
		this.SetLight(false);
		this.set_f32("Damage", 15.0f);
	}
	
	if(this.getName() == "engilaser"){
		this.set_f32("Damage", 5.0f);
	}
}

void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();

	f32 angle;

	angle = (this.getVelocity()).Angle();
	this.setAngleDegrees(-angle);

	shape.SetGravityScale(0.0f);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(blob !is null)
	if(blob.hasTag("flesh") && blob.getTeamNum() != this.getTeamNum())
	{
		this.server_Hit(blob, point1, this.getOldVelocity(), this.get_f32("Damage"), 0, false);
		this.server_Die();
	}
	
	if(solid)this.server_Die();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.hasTag("flesh") && blob.getTeamNum() != this.getTeamNum())
	{
		return true;
	}

	return false;
}