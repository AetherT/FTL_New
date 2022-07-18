const Vec2f vent_pos = Vec2f(-10, 12);

void onInit(CBlob@ this)
{
	//this.SetLight(true);
	//this.SetLightRadius(32);
	//this.SetLightColor(SColor(255, 255, 240, 210));\
	this.set_u32("no_scrap", 0);
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("/Reactor.ogg");
	this.SetEmitSoundPaused(false);
	this.SetEmitSoundSpeed(1);
	this.SetEmitSoundVolume(0.1f);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	u32 time = getGameTime();
	
	if (isServer() && blob.get_u32("no_scrap") < getGameTime() && blob.getTeamNum() == 0)
	{
		if (XORRandom(200) == 0)
		{
			CBlob@[] scrap;
			getBlobsByTag("limited_scrap", scrap);
			if (scrap.length > 8) return;

			Vec2f pos = blob.getPosition()+Vec2f(350+XORRandom(350), XORRandom(512)-256);
			CBlob@ s = server_CreateBlob("mat_scrap", 0, pos);
			s.server_SetQuantity(XORRandom(4)+1);
			s.AddForce(Vec2f(XORRandom(30)*-0.1f, XORRandom(20)/10-0.5f));
			s.Tag("limited_scrap");
		}
	}
	
	if (time % 3 == 0)
	{
		makeSteamParticle(blob.getPosition() + vent_pos);
	}
}

void makeSteamParticle(Vec2f pos, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), pos, Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}