#include "Hitters.as";

void onInit(CBlob@ this)
{

	CShape@ shape = this.getShape();
	if (shape is null) return;

	shape.SetRotationsAllowed(false);
	shape.SetStatic(true);
	
	ShapeConsts@ consts = shape.getConsts();
	if (consts is null) return;

	consts.collideWhenAttached = false;
	consts.waterPasses = true;
	consts.mapCollisions = false;
	
	this.SetLight(true);
	this.SetLightRadius(16);
	this.SetLightColor(SColor(255, 152, 216, 254));

	CSprite @sprite = this.getSprite();
	
	if(sprite !is null){
		sprite.setRenderStyle(RenderStyle::additive);
		sprite.SetLighting(false);
	
		//sprite.SetEmitSound("shield_generate.ogg");
		//sprite.SetEmitSoundPaused(false);
		//sprite.SetEmitSoundSpeed(1);
		//sprite.SetEmitSoundVolume(0.5f);
		
		//Sound::Play("shield_generate.ogg"); //So irriating
	}
	
	
	this.server_SetTimeToDie(80);
	
	this.sendonlyvisible = false;
	
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}