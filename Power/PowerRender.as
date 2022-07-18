
#include "PowerCommon.as";

void onRender(CRules@ this)
{

	if(getLocalPlayer() is null)return;
	if(getLocalPlayer().getBlob() is null)return;
	int Team = getLocalPlayer().getBlob().getTeamNum();
	
	CBlob@[] blobs;
	
	getBlobsByName("reactorroom", blobs);

	for(int b = 0;b < blobs.length;b+=1){
		
		CBlob@ blob = blobs[b];
		
		if(blob.getTeamNum() == Team){
	
			int GUIScale = 2;
			
			int Power = blob.get_u8("CurrentPower");
			int PowerMax = blob.get_u8("MaxPower");
			
			int Y = getScreenHeight()-24*GUIScale;
			
			for(int p = PowerMax-1;p >= 0; p -= 1){
			
				if(p < Power)GUI::DrawIcon("PowerBars.png", 1, Vec2f(20,5), Vec2f(4*GUIScale,Y-(p*6*GUIScale)));
				else GUI::DrawIcon("PowerBars.png", 0, Vec2f(20,5), Vec2f(4*GUIScale,Y-(p*6*GUIScale)));
				
				if(p < Power)GUI::DrawIcon("PowerBarLinks.png", 1, Vec2f(8,12), Vec2f(25*GUIScale,Y+2*GUIScale-(p*6*GUIScale)));
				else GUI::DrawIcon("PowerBarLinks.png", 0, Vec2f(8,12), Vec2f(25*GUIScale,Y+2*GUIScale-(p*6*GUIScale)));
			
			}
			
			int PowerUp = 3;
			if(Power > 0)PowerUp = 0;
			
			GUI::DrawIcon("PowerLinks.png", PowerUp, Vec2f(16,8), Vec2f(25*GUIScale,Y+14*GUIScale));
			
			int SysX = 0;
			
			CBlob@[] rooms;
			
			collectRooms(rooms);
			
			for(int s = 0;s < rooms.length;s+=1){
				
				CBlob @room = rooms[s];
				
				if(room.getTeamNum() != blob.getTeamNum())continue;
				
				int SystemPower = 0;
				int SystemMax = 0;
				int SystemZoltan = 0;
				int SystemDamage = 0;
				int SystemIon = 0;
				
				int RepairAmount = 0;
				int Grief = 0;
				
				SystemPower = room.get_f32("Power");
				SystemMax = room.get_u8("Level");
				SystemDamage = room.get_u8("Damage");
				SystemIon = room.get_u16("IonDamage");
				SystemZoltan = room.get_u8("Zoltan_Power");
				
				RepairAmount = room.get_u16("Repair_Amount");
				Grief = room.get_u16("Grief");
				f32 RepairMax = 2000;
				
				if(SystemMax > 0){
				
					GUI::DrawIcon("PowerLinks.png", PowerUp+2, Vec2f(16,8), Vec2f(25*GUIScale+(SysX*20*GUIScale)+12*GUIScale,Y+14*GUIScale));
					if(SysX != 0)GUI::DrawIcon("PowerLinks.png", PowerUp+1, Vec2f(16,8), Vec2f(25*GUIScale+(SysX*20*GUIScale)-2*GUIScale,Y+14*GUIScale));
					
					int status = 0;
					if(SystemPower+SystemZoltan > 0){
						status = 1;
						if(SystemDamage > 0)status = 2;
					}
					if(SystemDamage >= SystemMax)status = 3;
					if(SystemIon > 0 && getGameTime() % 30 < 15)status = 4;
					
					if(getControls().getMouseScreenPos().x > 24*GUIScale+(SysX*20*GUIScale)+16*GUIScale && getControls().getMouseScreenPos().x < 24*GUIScale+(SysX*20*GUIScale)+32*GUIScale){
						room.Tag("power_hover");
						GUI::DrawIcon("PowerIconHover.png", 0, Vec2f(18,18), Vec2f(23*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-5*GUIScale));
					} else {
						room.Untag("power_hover");
					}
					
					GUI::DrawIcon("PowerIconOrbs.png", status, Vec2f(16,16), Vec2f(24*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-4*GUIScale));
					GUI::DrawIcon("PowerIcons.png", room.get_u8("SystemIcon"), Vec2f(16,16), Vec2f(24*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-4*GUIScale));
					
					for(int p = 0;p < SystemMax;p+=1){
						int seperation = 0;
						
						if(room.get_u8("SystemIcon") == 1)seperation = (p/2)*3;
						
						if(p < SystemPower)GUI::DrawIcon("MiniPowerBars.png", 1, Vec2f(12,4), Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale));
						else if(p >= SystemMax-SystemDamage){
							GUI::DrawIcon("MiniPowerBars.png", 3, Vec2f(12,4), Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale));
							if(p == SystemMax-SystemDamage && RepairAmount > 0){
								GUI::DrawRectangle(Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale), Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale)+Vec2f((12.0f*(RepairAmount/RepairMax*1.0f))*GUIScale,4*GUIScale), SColor(255, 255, 255, 0));
							}
						}
						else GUI::DrawIcon("MiniPowerBars.png", 0, Vec2f(12,4), Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale));
						if(p < SystemIon && p < SystemPower)GUI::DrawIcon("MiniPowerBars.png", 4, Vec2f(12,4), Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale));
						if(p < SystemPower+SystemZoltan && p >= SystemPower+SystemZoltan-SystemZoltan)GUI::DrawIcon("MiniPowerBars.png", 2, Vec2f(12,4), Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale));
						if(p == SystemMax-SystemDamage-1 && Grief > 0 && SystemMax-SystemDamage > 0){
							GUI::DrawRectangle(Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale)+Vec2f((12.0f-(12.0f*(Grief/RepairMax*1.0f)))*GUIScale,0), Vec2f(26*GUIScale+(SysX*20*GUIScale)+16*GUIScale,Y-12*GUIScale-p*6*GUIScale-seperation*GUIScale)+Vec2f(12*GUIScale,4*GUIScale), SColor(255, 191, 64, 64));
						}
					}
					
					SysX += 1;
				
				}
			}
			
			Y = 4*GUIScale;
			
			int FTLLength = 10;
			float FTLCharge = (blob.get_u16("FTLDrive")*1.0f)/(blob.get_u16("FTLDriveMax")*1.0f);
			
			bool Charged = false;
			
			if(FTLCharge >= 1.0f)Charged = true;
			
			CBlob@[] blobs;
			
			getBlobsByName("event_loader", blobs);
			
			if(blobs.length > 0)Charged = true;
			
			for(int b = 0;b < FTLLength;b+=1){
			
				int image = 1;
				
				if(b == 0)image = 0;
				if(b == FTLLength-1)image = 2;
				
				GUI::DrawIcon("FTLJumpBar.png", image, Vec2f(12,48), Vec2f(getScreenWidth()/2+b*12*GUIScale-FTLLength*6*GUIScale,Y));
				
				if(!Charged){
					if(b+1 < FTLLength*FTLCharge)GUI::DrawIcon("FTLJumpBar.png", image+3, Vec2f(12,48), Vec2f(getScreenWidth()/2+b*12*GUIScale-FTLLength*6*GUIScale,Y));
				} else {
					GUI::DrawIcon("FTLJumpBar.png", image+6, Vec2f(12,48), Vec2f(getScreenWidth()/2+b*12*GUIScale-FTLLength*6*GUIScale,Y));
				}
			
			}
			
			if(Charged){
				if(blobs.length > 0)
				{
					if(blobs[0].get_u16("timer") <= 10*30)GUI::DrawIcon("JUMPSOON.png", 0, Vec2f(96,48), Vec2f(getScreenWidth()/2-48*GUIScale,Y));
					else GUI::DrawIcon("JUMPING.png", 0, Vec2f(98,48), Vec2f(getScreenWidth()/2-48*GUIScale,Y));
				}
				else 
					GUI::DrawIcon("JUMP.png", 0, Vec2f(96,48), Vec2f(getScreenWidth()/2-48*GUIScale,Y));
			}
			
			v_showminimap = false;
		}
	}
}