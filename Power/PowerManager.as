#include "LoadEvent.as";
#include "WeaponCommon.as";
#include "PowerCommon.as";

void onInit(CBlob @this){
	
	this.set_u8("CurrentPower",4);
	this.set_u8("MaxPower",5);
	
	this.set_u8("Level",5);
	this.set_u8("MaxLevel",100);
	
	this.set_u8("upgrade_cost_base",10);
	this.set_u8("upgrade_cost_level",1);

	this.set_u16("FTLDrive",0);
	this.set_u16("FTLDriveMax",10000);
	
	this.addCommandID("power_handle");
	this.addCommandID("ftl_jump");
}

void onTick(CBlob@ this){

	if(getGameTime() % 30 == 0){
	
		this.set_u8("MaxPower",this.get_u8("Level"));
	
		UpdateSystemAmount(this);

	}
	
	if(this.get_u16("FTLDrive") < this.get_u16("FTLDriveMax")){
		
		int addedPower = 0;
		
		CBlob@[] rooms;
	
		getBlobsByName("engine_room", rooms);
		
		for(int s = 0;s < rooms.length;s+=1){
			
			CBlob @room = rooms[s];
			
			if(room.getTeamNum() != this.getTeamNum())continue;
			
			addedPower += room.get_f32("Power");
		}
		
		this.set_u16("FTLDrive",this.get_u16("FTLDrive")+addedPower);
		this.Untag("played_ready");
	
	} else {
		if(!this.hasTag("played_ready")){
			this.Tag("played_ready");
			Sound::Play("ftl_ready.ogg");
		}
	}
	
	PilotControl(this);
}

void UpdateSystemAmount(CBlob@ this){

	CBlob@[] rooms;
	
	collectRooms(rooms);
	
	int totalPowerInUse = 0;
	
	for(int s = 0;s < rooms.length;s+=1){
		
		CBlob @room = rooms[s];
		
		if(room.getTeamNum() != this.getTeamNum())continue;
		
		totalPowerInUse += room.get_f32("Power");
	}
	
	this.set_u8("CurrentPower",this.get_u8("MaxPower")-totalPowerInUse);
	
	for(int s = 0;s < rooms.length;s+=1){
		
		CBlob @room = rooms[s];
		
		if(room.getTeamNum() != this.getTeamNum())continue;
		
		if(this.get_u8("CurrentPower") > 0){
			if(room.hasTag("ZoltanFullPower")){
				if(room.get_f32("Power")+room.get_u8("Zoltan_Power") < room.get_u8("Level")){
					room.set_f32("Power",room.get_f32("Power")+1);
					this.set_u8("CurrentPower",this.get_u8("CurrentPower")-1);
				}
				
				if(room.get_f32("Power") == room.get_u8("Level")){
					room.Untag("ZoltanFullPower");
				}
			}
		} else {
			room.Untag("ZoltanFullPower");
		}
		if(getNet().isServer()){
			room.Sync("Power",true);
			this.Sync("CurrentPower",true);
			room.Sync("ZoltanFullPower",true);
		}
	}
}

void PilotControl(CBlob @this){

	if(getNet().isClient()){
	
		if(getLocalPlayer() is null)return;
		if(getLocalPlayer().getBlob() is null)return;
		if(!getLocalPlayer().getBlob().isAttachedToPoint("PILOT"))return;
		if(getLocalPlayer().getBlob().getTeamNum() != this.getTeamNum())return;
	
		int GUIScale = 2;
	
		int SysX = 0;
		
		CControls @controls = getControls();
		if(!this.hasTag("click")){
			
			
			int SysX = 0;
	
			CBlob@[] rooms;
			
			collectRooms(rooms);
			
			for(int s = 0;s < rooms.length;s+=1){
				
				CBlob @room = rooms[s];
				
				if(room.getTeamNum() != this.getTeamNum())continue;
				
				int mandatoryPowerIncrements = 1;
				
				if(room.getName() == "shield_generator")mandatoryPowerIncrements = 2;
				
				int SystemPower = 0;
				int SystemMax = 0;
				int SystemZoltan = 0;
				int SystemDamage = 0;
				int SystemIon = 0;
				
				SystemPower = room.get_f32("Power");
				SystemMax = room.get_u8("Level");
				SystemDamage = room.get_u8("Damage");
				SystemIon = room.get_u16("IonDamage");
				SystemZoltan = room.get_u8("Zoltan_Power");
				
				if(SystemIon <= 0)
				if(controls.getMouseScreenPos().x > 24*GUIScale+(SysX*20*GUIScale)+16*GUIScale && getControls().getMouseScreenPos().x < 24*GUIScale+(SysX*20*GUIScale)+32*GUIScale){
					
					if(controls.mousePressed1){
						if(SystemMax-SystemDamage <= SystemPower+SystemZoltan+mandatoryPowerIncrements-1 || this.get_u8("CurrentPower") < mandatoryPowerIncrements)Sound::Play("cant_power.ogg");
						else Sound::Play("power_up.ogg");
						this.Tag("click");
						CBitStream bt;
						bt.write_netid(room.getNetworkID());
						bt.write_bool(true);
						this.SendCommand(this.getCommandID("power_handle"), bt);
					}
					if(controls.mousePressed2){
						this.Tag("click");
						CBitStream bt;
						bt.write_netid(room.getNetworkID());
						bt.write_bool(false);
						this.SendCommand(this.getCommandID("power_handle"), bt);
						Sound::Play("power_down.ogg");
					}
				
				}
				
				SysX += 1;
			}
			
			
			
			//FTL button
			if(controls.mousePressed1){
				if(controls.getMouseScreenPos().x > getScreenWidth()/2-60*GUIScale && controls.getMouseScreenPos().x < getScreenWidth()/2+60*GUIScale && controls.getMouseScreenPos().y < 52*GUIScale && controls.getMouseScreenPos().y > 4*GUIScale){
					
					this.SendCommand(this.getCommandID("ftl_jump"));
					this.Tag("click");
				}
			}
			
		} else {
			if(!controls.mousePressed1 && !controls.mousePressed2)this.Untag("click");
		}
		
	}
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (isServer && cmd == this.getCommandID("power_handle"))
	{
		int roomNetID = params.read_netid();
		
		bool OnOff = params.read_bool();
		
		CBlob @room = getBlobByNetworkID(roomNetID);
		
		if(room !is null){
		
			int mandatoryPowerIncrements = 1;
				
			if(room.getName() == "shield_generator")mandatoryPowerIncrements = 2;
		
			int SystemPower = 0;
			int SystemMax = 0;
			int SystemZoltan = 0;
			int SystemDamage = 0;
			int SystemIon = 0;
			
			SystemPower = room.get_f32("Power");
			SystemMax = room.get_u8("Level");
			SystemDamage = room.get_u8("Damage");
			SystemIon = room.get_u16("IonDamage");
			SystemZoltan = room.get_u8("Zoltan_Power");
		
			if(SystemIon <= 0){
				if(OnOff){
					if(this.get_u8("CurrentPower") >= mandatoryPowerIncrements && SystemMax-SystemDamage >= SystemPower+mandatoryPowerIncrements){
						room.set_f32("Power",room.get_f32("Power")+mandatoryPowerIncrements);
						this.set_u8("CurrentPower",this.get_u8("CurrentPower")-mandatoryPowerIncrements);
						room.Sync("Power",true);
						this.Sync("CurrentPower",true);
					}
				} else {
					if(SystemPower > 0){
						room.set_f32("Power",room.get_f32("Power")-mandatoryPowerIncrements);
						if(room.get_f32("Power") < 0)room.set_f32("Power",0);
						this.set_u8("CurrentPower",this.get_u8("CurrentPower")+mandatoryPowerIncrements);
						room.Sync("Power",true);
						this.Sync("CurrentPower",true);
					}
				}
			}
		
		}
	}
	
	if (cmd == this.getCommandID("ftl_jump"))
	{
		if(this.get_u16("FTLDrive") >= this.get_u16("FTLDriveMax")){
			
			this.set_u16("FTLDrive",0);
			this.Tag("first_jump");
			
			Sound::Play("ftl_soon.ogg");
			
			if(isServer){
				this.Sync("FTLDrive",true);
				this.Sync("first_jump",true);
				server_CreateBlob("event_loader",0,this.getPosition());
			}
		}
	}
}




