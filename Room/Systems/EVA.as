
#include "Requirements.as"

void onInit(CBlob @ this){
	this.set_u8("MaxLevel",0);
	
	this.addCommandID("equip");
}

const int helmet_scrap_cost = 20;

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.isOverlapping(caller) && caller.get_u16("air_tank") < 1250 && this.getTeamNum() == caller.getTeamNum()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CBitStream reqs, missing;
		AddRequirement(reqs, "blob", "mat_scrap", "Scrap", helmet_scrap_cost);
		CInventory@ inv = caller.getInventory();
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("equip"), "Equip Space Suit: 20 Scrap", params);
		button.SetEnabled(hasRequirements(inv, reqs, missing));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("equip"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			CBitStream reqs, missing;
			AddRequirement(reqs, "blob", "mat_scrap", "Scrap", helmet_scrap_cost);
			CInventory@ inv = caller.getInventory();
			
			if(hasRequirements(inv, reqs, missing)){
			
				if(getNet().isServer()){
					//caller.getInventory().server_RemoveItems("mat_scrap", helmet_scrap_cost);
					server_TakeRequirements(inv,reqs);
					caller.Tag("space_suit");
					caller.set_u16("air_tank",1500);
					caller.Sync("space_suit",true);
					caller.Sync("air_tank",true);
				}
				caller.Tag("space_suit");
				caller.set_u16("air_tank",1500);
			}
		}
	}
}