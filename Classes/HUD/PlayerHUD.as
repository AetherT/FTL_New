
#include "RosterCommon.as";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if(blob.getPlayer() !is getLocalPlayer())return;
	
	int GUIScale = 2;
	
	int Y = 25*GUIScale;
	
	
	GUI::DrawIcon("HealthBar.png", 0, Vec2f(252,19), Vec2f(4*GUIScale,4*GUIScale));
	
	int Health = (((blob.getHealth())/blob.getInitialHealth())*25.0f);
	
	GUI::DrawIcon("HealthBars.png", Health, Vec2f(252,19), Vec2f(4*GUIScale,4*GUIScale));
	
	
	
	int scrap = blob.getBlobCount("mat_scrap");
	
	CBlob@[] storageBlobs;
	int team = blob.getTeamNum();
	
	getBlobsByTag("storage", @storageBlobs);
	
	for (int i = 0; i < storageBlobs.length; i++)
	{
		if (storageBlobs[i].getTeamNum() == team)
		{
			scrap += storageBlobs[i].getBlobCount("mat_scrap");
		}
	}
	
	
	
	GUI::DrawIcon("ScrapHUD.png", 0, Vec2f(50,19), Vec2f(258*GUIScale,4*GUIScale));
	
	GUI::SetFont("menu");
	Vec2f dimensions(0,0);
	string disp = "" + scrap;
	GUI::GetTextDimensions(disp, dimensions);
	GUI::DrawText(disp, Vec2f((258+34)*GUIScale,9*GUIScale) + Vec2f(-dimensions.x/2 , 0), SColor(255, 255, 255, 255));
	
	
	
	GUI::DrawIcon("Oxygen.png", 0, Vec2f(80,16), Vec2f(1*GUIScale,Y));
	
	int AirAmount = (((blob.get_u8("air_count")*1.0f)/180.0f)*24.0f);
	
	GUI::DrawIcon("OxygenBar.png", AirAmount, Vec2f(80,16), Vec2f(1*GUIScale,Y));
	
	if(blob.hasTag("space_suit")){
		AirAmount = (((blob.get_u16("air_tank")*1.0f)/1500.0f)*24.0f);
		GUI::DrawIcon("AirTankBar.png", AirAmount, Vec2f(80,16), Vec2f(1*GUIScale,Y));
	}
	
	Y += 16*GUIScale;
	
	
	
	
	//Player list

	bool cloning_first = false;
	f32 highest_clone_perc = 0.0f;
	
	CBlob@[] cloners;
	getBlobsByName("cloning_bay", @cloners);
	for (int i = 0; i < cloners.length; i++)
	{
		if (cloners[i].getTeamNum() == blob.getTeamNum())
		{
			f32 perc = cloners[i].get_u16("cloning_progress")/(300.0f*20.0f);
			cloning_first = true;
			if(perc > highest_clone_perc)highest_clone_perc = perc;
		}
	}
	
	for(int i = 0; i < getPlayerCount(); i += 1){
		CPlayer @player = getPlayer(i);
		if(player !is null){
			CBlob@ crew = player.getBlob();
			if(crew !is null){
				
				f32 hp_percent = 1.0f;
				hp_percent = crew.getHealth()/crew.getInitialHealth();
				
				int crewIcon = 0;
				
				if(crew.getName() == "engi")crewIcon = 1;
				if(crew.getName() == "zoltan")crewIcon = 2;
				if(crew.getName() == "mantis")crewIcon = 3;
				if(crew.getName() == "rock")crewIcon = 4;
				if(crew.getName() == "slug")crewIcon = 5;
				if(crew.getName() == "lanius")crewIcon = 6;
				if(crew.getName() == "crystal")crewIcon = 7;
				
				GUI::DrawRectangle(Vec2f(2*GUIScale,Y+1*GUIScale), Vec2f(78*GUIScale,Y+30*GUIScale), SColor(128, 128, 128, 128));
				GUI::DrawIcon("CrewBackground.png", 0, Vec2f(80,32), Vec2f(1*GUIScale,Y));
				GUI::DrawIcon("CrewIcons.png", crewIcon, Vec2f(32,32), Vec2f(1*GUIScale,Y));
				GUI::DrawText(player.getUsername(), Vec2f(31*GUIScale,Y+4*GUIScale), SColor(255, 255, 255, 255));
				GUI::DrawRectangle(Vec2f(31*GUIScale,Y+23*GUIScale), Vec2f(31*GUIScale+(GUIScale*(45.0f*hp_percent)),Y+27*GUIScale), SColor(255, 255.0f*(1.0f-hp_percent), 255.0f*hp_percent, 0));
				
				Y += 32*GUIScale;
			} else {

				if(cloning_first){
				
					GUI::DrawRectangle(Vec2f(2*GUIScale,Y+1*GUIScale), Vec2f(78*GUIScale,Y+30*GUIScale), SColor(128, 128, 128, 0));
					GUI::DrawIcon("CrewBackground.png", 2, Vec2f(80,32), Vec2f(1*GUIScale,Y));
					GUI::DrawIcon("CrewIcons.png", 8, Vec2f(32,32), Vec2f(1*GUIScale,Y));
					GUI::DrawText(player.getUsername(), Vec2f(31*GUIScale,Y+4*GUIScale), SColor(255, 255, 255, 255));
					
					GUI::DrawRectangle(Vec2f(31*GUIScale,Y+23*GUIScale), Vec2f(31*GUIScale+(GUIScale*(45.0f*highest_clone_perc)),Y+27*GUIScale), SColor(255, 255.0f, 255.0f*highest_clone_perc, 0));
					GUI::DrawText("Cloning", Vec2f(31*GUIScale,Y+12*GUIScale), SColor(255, 255, 255, 255));
					cloning_first = false;
				
				} else {
					GUI::DrawRectangle(Vec2f(2*GUIScale,Y+1*GUIScale), Vec2f(78*GUIScale,Y+30*GUIScale), SColor(128, 128, 0, 0));
					GUI::DrawIcon("CrewBackground.png", 1, Vec2f(80,32), Vec2f(1*GUIScale,Y));
					GUI::DrawIcon("CrewIcons.png", 8, Vec2f(32,32), Vec2f(1*GUIScale,Y));
					GUI::DrawText(player.getUsername(), Vec2f(31*GUIScale,Y+4*GUIScale), SColor(255, 255, 255, 255));
					
					GUI::DrawText("Deceased", Vec2f(31*GUIScale,Y+20*GUIScale), SColor(255, 255, 255, 255));
				}
				
				Y += 32*GUIScale;
			}
		}
	}
	
	
}