
#include "RosterCommon.as";

void onInit(CBlob @ this){
	this.set_u8("MaxLevel",3);
	
	this.Tag("power_lights");
	
	this.set_u8("SystemIcon",4);
	
	this.getSprite().SetEmitSound("healing.ogg");
	this.getSprite().SetEmitSoundPaused(true);
}


void onTick(CBlob @ this)
{
	
	bool sound_pause = true;
	
	f32 heal_amount = 0.33333f;
	
	if(this.get_f32("Power") < 1.0f)heal_amount = 0.0f;
	else if(this.get_f32("Power") < 2.0f)heal_amount *= 1.0f;
	else if(this.get_f32("Power") < 3.0f)heal_amount *= 2.0f;
	else if(this.get_f32("Power") < 4.0f)heal_amount *= 4.0f;
	
	if(heal_amount > 0)
	for(int i = 0; i < this.getTouchingCount(); i++){
		CBlob@ object = this.getTouchingByIndex(i);
		
		if(object.getHealth() < object.getInitialHealth())
		if(object.hasTag("flesh") && object.getTeamNum() == this.getTeamNum()){
			if(getNet().isServer()){
				object.server_Heal(heal_amount);
			}
			
			for(int i = 0; i < heal_amount*10; i++)
			if(XORRandom(7) == 0)
			ParticleAnimated("HealParticle.png", object.getPosition()+Vec2f(XORRandom(13)-6,XORRandom(13)-6), Vec2f(XORRandom(5)-2,0)*0.25, 0, 0.5f, 5, -0.05f, true);
			
			if(object is getLocalPlayerBlob())sound_pause = false;
		}
	}
	
	this.getSprite().SetEmitSoundPaused(sound_pause);
	
}