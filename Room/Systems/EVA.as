const u16 suit_create_delay = 60*30;

void onInit(CBlob @ this){
	this.set_u8("MaxLevel",0);
	
	this.addCommandID("equip");

	this.set_u32("next_suit", getGameTime()*suit_create_delay);
	this.set_bool("active", true);

	if (this is null) return;
	if (this.exists("active"))
		this.Sync("active", true);
	else this.set_bool("active", false);
	if (this.exists("next_suit"))
		this.Sync("next_suit", true);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.isOverlapping(caller) && caller.get_u16("air_tank") < 1250 && this.getTeamNum() == caller.getTeamNum()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("equip"), "Equip Space Suit", params);
		button.SetEnabled(this.get_bool("active"));
	}
}

void onTick(CBlob@ this)
{
	if (getGameTime() >= this.get_u32("next_suit"))
	{
		this.set_bool("active", true);
		if (this !is null) this.Sync("active", true);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("equip"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			if(getNet().isServer()){
				//caller.getInventory().server_RemoveItems("mat_scrap", helmet_scrap_cost);
				caller.Tag("space_suit");
				caller.set_u16("air_tank",1500);
				caller.Sync("space_suit",true);
				caller.Sync("air_tank",true);
			}
			caller.Tag("space_suit");
			caller.set_u16("air_tank",1500);
			this.set_u32("next_suit", getGameTime()+suit_create_delay);
			this.set_bool("active", false);
		}
	}
}