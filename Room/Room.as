// Workbench

#include "Requirements.as"
#include "ShopCommon.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	Vec2f Pos = this.getPosition()-Vec2f(this.getSprite().getFrameWidth()/2,this.getSprite().getFrameHeight()/2);
	
	if(this.getName() == "onebyonewindowroom" || this.getName() == "onebytwowindowroom" || this.getName() == "twobyonewindowroom" || this.getName() == "twobytwowindowroom"){
		for(int i = 0;i < this.getSprite().getFrameWidth();i += 8)
		for(int j = 0;j < this.getSprite().getFrameHeight();j += 8){
			getMap().server_SetTile(Pos+Vec2f(i+4,j+4), CMap::tile_empty);
		}
	} else {
		for(int i = 0;i < this.getSprite().getFrameWidth();i += 8)
		for(int j = 0;j < this.getSprite().getFrameHeight();j += 8){
			getMap().server_SetTile(Pos+Vec2f(i+4,j+4), CMap::tile_castle_back);
		}
	}
	
	this.set_u16("oxygen",0);
	
	this.SetLight(true);
	f32 lightsize = 32;
	if(this.getSprite().getFrameWidth()/2+16 > lightsize)lightsize = this.getSprite().getFrameWidth()/2+16;
	if(this.getSprite().getFrameHeight()/2+16 > lightsize)lightsize = this.getSprite().getFrameHeight()/2+16;
	this.SetLightRadius(lightsize);
	
	this.Tag("room");
	
	this.set_u8("SystemIcon",0);
	
	this.set_u8("Level",1);
	this.set_u8("MaxLevel",0);
	
	this.set_f32("Power",0);
	this.set_u8("Zoltan_Power",0);
	
	this.set_u8("Damage", 0);
	this.set_u16("Repair_Amount", 0);
	this.set_u16("Grief", 0);
	
	this.set_u16("IonDamage",0);
	this.set_u16("IonTime",0);
	
	this.addCommandID("upgrade");
	this.set_u8("upgrade_cost_base",25);
	this.set_u8("upgrade_cost_level",25);
	
	
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 6));
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	this.Tag(SHOP_AUTOCLOSE);
	this.addCommandID("shop made item");
	
	AddIconToken("$weapon_icon$", "SystemIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$engine_icon$", "SystemIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$shield_icon$", "SystemIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$oxy_icon$", "SystemIcons.png", Vec2f(32, 32), 9);
	AddIconToken("$cloning_icon$", "SystemIcons.png", Vec2f(32, 32), 8);
	AddIconToken("$gravity_icon$", "SystemIcons.png", Vec2f(32, 32), 10);
	AddIconToken("$eva_icon$", "SystemIcons.png", Vec2f(32, 32), 4);
	AddIconToken("$scanner_icon$", "SystemIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$medbay_icon$", "SystemIcons.png", Vec2f(32, 32), 6);
	
	AddIconToken("$small_storage_icon$", "SystemIcons.png", Vec2f(32, 32), 11);
	AddIconToken("$big_storage_icon$", "SystemIcons.png", Vec2f(32, 32), 11);
	AddIconToken("$arm_icon$", "SystemIcons.png", Vec2f(32, 32), 13);
	
	AddIconToken("$window_icon$", "WindowIcon.png", Vec2f(32, 32), 0);
	
	if(this.getName() == "onebyoneroom")
	{
		{
			ShopItem@ s = addShopItem(this, "Gravity Generator", "$gravity_icon$", "gravity_generator", "Sticks you to the floor, watch out for falling into space");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Cabinet", "$small_storage_icon$", "small_storage", "A small cabinet built in a wall. Useful for storing garbage");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Camera", "$scanner_icon$", "camera", "Reveals nearby rooms to nearby players");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 25);
		}
		{
			ShopItem@ s = addShopItem(this, "Window", "$window_icon$", "onebyonewindowroom", "A nice view");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 0);
		}
		
		this.Tag("power_lights");
	}
	else if(this.getName() == "onebytworoom")
	{
		{
			ShopItem@ s = addShopItem(this, "Oxygen Generator", "$oxy_icon$", "oxygen_generator", "Creates oxygen to supply nearby rooms");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		
		{
			ShopItem@ s = addShopItem(this, "Scrap Arm", "$arm_icon$", "scrap_arm", "Pulls in scrap from enemies");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Window", "$window_icon$", "onebytwowindowroom", "A nice view");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 0);
		}
		
		this.Tag("power_lights");
	}
	else if(this.getName() == "twobyoneroom")
	{
		{
			ShopItem@ s = addShopItem(this, "Engines", "$engine_icon$", "engine_room", "Allows FTL travel given enough time to charge");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Weapons", "$weapon_icon$", "weapon_room", "Controls nearby weapon ports");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "EVA", "$eva_icon$", "eva_room", "Provides a place to suit up for space walking");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Scanning", "$scanner_icon$", "scanner_room", "Reveals nearby rooms to players and enemy rooms.");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 100);
		}
		{
			ShopItem@ s = addShopItem(this, "Windows", "$window_icon$", "twobyonewindowroom", "A nice view");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 0);
		}
		
		this.Tag("power_lights");
	}
	else if(this.getName() == "twobytworoom")
	{
		{
			ShopItem@ s = addShopItem(this, "Shields System", "$shield_icon$", "shield_generator", "Generates a shield to protect the ship from lasers and debris");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Cloning Bay", "$cloning_icon$", "cloning_bay", "Revives dead and lost crew members");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Cargo Bay", "$big_storage_icon$", "big_storage", "A rather large cargo bay. Most of the space is taken up by old paper");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Medbay", "$medbay_icon$", "medbay", "Heals nearby allies");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 50);
		}
		{
			ShopItem@ s = addShopItem(this, "Windows", "$window_icon$", "twobytwowindowroom", "A nice view");
			AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 0);
		}
		//{
		//	ShopItem@ s = addShopItem(this, "Scrap Miner", "$window_icon$", "scrap_miner", "infinite scraps!!!");
		//	AddRequirement(s.requirements, "blob", "mat_scrap", "Scrap", 100);
		//}
		
		this.Tag("power_lights");
	}
	
	this.Tag("builder always hit");
	this.Tag("leaking");
}

void onTick(CBlob@ this)
{
	///////////////////////AI SHIP HACK
	if(this.getTeamNum() != 0){
		if(this.getName() == "weapon_room" || this.getName() == "shield_generator"){
	
			bool gotReactor = false;
			
			CBlob@[] reactors;
		
			getBlobsByName("reactorroom", reactors);
			
			for (u32 l = 0; l < reactors.length; l++)
			{
				CBlob @reactor = reactors[l];
				if(this.getTeamNum() == reactor.getTeamNum())
				gotReactor = true;
			}
	
			if(gotReactor)this.set_f32("Power", this.get_u8("Level"));
			else this.set_f32("Power", 0);
		
		}
	}
	if(this.getTeamNum() != 0){
		if(this.getName() == "oxygen_generator"){
	
			this.set_f32("Power", this.get_u8("Level"));
		
		}
	}
	
	
	if(this.hasTag("leaking")){
		if(this.get_u16("oxygen") > 0)this.set_u16("oxygen",this.get_u16("oxygen")-1);
	}
	
	
	if(checkForLeaks(this)){
		if(!this.hasTag("leaking")){
			if(getLocalPlayerBlob() !is null)
			if(getLocalPlayerBlob().getTeamNum() == this.getTeamNum())
			Sound::Play("leak.ogg");
		}
		this.Tag("leaking");
	} else {
		this.Untag("leaking");
	}
	
	float Red = (this.get_u16("oxygen")/1000.0);
	float power = 1.0;
	if(this.get_f32("Power") < 1)power = this.get_f32("Power")*0.9+0.1+(XORRandom(10)/100.0f);
	
	if(!this.hasTag("power_lights"))power = 1;
	
	this.SetLightColor(SColor(255, 255*power, Red*255*power, Red*255*power));
	
	if(this.get_u16("IonTime") > 0){
		this.set_u16("IonTime",this.get_u16("IonTime")-1);
	} else {
		this.set_u16("IonDamage",0);
	}
	
	int Zoltans = 0;
	
	//Count zoltans and people who are repairing
	for(int i = 0; i < this.getTouchingCount(); i++){
		CBlob@ object = this.getTouchingByIndex(i);
		
		if(object.getName() == "zoltan" && !object.hasTag("dead")){
			Zoltans += 1;
		}
		
		if(object.hasTag("repairing")){
			int repair = 6;
			
			if(object.getName() == "engi")repair *= 2;
			if(object.getName() == "mantis")repair /= 2;
			
			this.set_u16("Repair_Amount",this.get_u16("Repair_Amount")+repair);
			
			//print("found someone repairing("+repair+")"+". Current repair amount:"+this.get_u16("Repair_Amount"));
		}
	}
	
	this.set_u8("Zoltan_Power",Zoltans);
	
	//print("Power:"+this.get_f32("Power")+" Zoltans:"+Zoltans+" Level:"+this.get_u8("Level"));
	
	if(this.get_f32("Power") > this.get_u8("Level")-this.get_u8("Damage")){
		
		this.set_f32("Power",this.get_u8("Level")-this.get_u8("Damage"));
		
	} else {
	
		if(this.get_f32("Power")+Zoltans > this.get_u8("Level")-this.get_u8("Damage")){
			int dif = this.get_f32("Power")+Zoltans-this.get_u8("Level");
			this.set_f32("Power",this.get_u8("Level")-Zoltans);
			this.Tag("ZoltanFullPower");
		}
	
	}
	
	if(this.get_u16("Repair_Amount") > 0 && this.get_u16("Grief") > 0){
		int Dif = this.get_u16("Repair_Amount")-this.get_u16("Grief");
		if(Dif > 0){
			this.set_u16("Repair_Amount",Dif);
			this.set_u16("Grief",0);
		} else {
			this.set_u16("Repair_Amount",0);
			this.set_u16("Grief",-Dif);
		}
	}
	
	if(this.get_u8("Damage") < this.get_u8("Level")){
		if(this.get_u16("Grief") > 2000){
			this.set_u8("Damage", this.get_u8("Damage")+1);
			this.set_u16("Grief",0);
		}
	} else {
		this.set_u16("Grief",0);
	}
	
	if(this.get_u8("Damage") > 0){
		if(this.get_u16("Repair_Amount") > 2000){
			this.set_u8("Damage", this.get_u8("Damage")-1);
			this.set_u16("Repair_Amount",0);
		}
	} else {
		this.set_u16("Repair_Amount",0);
	}
	
	if(getNet().isServer())
	if(getGameTime() % 10 == 0){
		this.Sync("Damage",true);
		this.Sync("Grief",true);
		this.Sync("Repair_Amount",true);
		this.Sync("Power",true);
	}
	
	if(getNet().isClient()){
	
		if(getLocalPlayer() !is null)
		if(getLocalPlayer().getBlob() !is null){
		
			CBlob @blob = getLocalPlayer().getBlob();
		
			if(!getMap().rayCastSolid(blob.getPosition(), this.getPosition())){
				this.Tag("have_vision");
			} else {
				this.Untag("have_vision");
			}
			
			if(!this.hasTag("have_vision"))
			if(blob.getName() == "slug"){
				if(Maths::Sqrt(Maths::Pow(blob.getPosition().x-this.getPosition().x, 2)+Maths::Pow(blob.getPosition().y-this.getPosition().y, 2)) < 60){
					this.Tag("have_vision");
				}
			}
			
			if(!this.hasTag("have_vision")){
				CBlob@[] scanners;
				
				getBlobsByName("scanner_room", scanners);
				getBlobsByName("camera", scanners);
				
				for (u32 l = 0; l < scanners.length; l++)
				{
					
					CBlob @scanner = scanners[l];
					
					if(scanner.getTeamNum() != blob.getTeamNum())continue;
					
					if(scanner.getTeamNum() != this.getTeamNum())
					if(scanner.getName()=="scanner_room")
					if(blob.getDistanceTo(this) < 320){
						if(scanner.get_u8("Level") > 2)this.Tag("have_vision");;
					}
					
					int scanner_range = scanner.get_u8("Level")*64;
					
					if(blob.getDistanceTo(scanner) < scanner_range && this.getDistanceTo(scanner) < scanner_range){
						this.Tag("have_vision");
					}
				}
			}
		
		}
		this.SetLight(this.hasTag("have_vision"));
		//getMap().UpdateLightingAtPosition(this.getPosition(), 128.0f);
		
	}
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ covering = null;

	if(this.getFrameWidth() == 16){
		if(this.getFrameHeight() == 16){
			@covering = this.addSpriteLayer("covering", "OneByOneRoom.png" , 16, 16, blob.getTeamNum(), blob.getSkinNum());
		} else {
			@covering = this.addSpriteLayer("covering", "OneByTwoRoom.png" , 16, 40, blob.getTeamNum(), blob.getSkinNum());
		}
	} else {
		if(this.getFrameHeight() == 16){
			@covering = this.addSpriteLayer("covering", "TwoByOneRoom.png" , 40, 16, blob.getTeamNum(), blob.getSkinNum());
		} else {
			@covering = this.addSpriteLayer("covering", "TwoByTwoRoom.png" , 40, 40, blob.getTeamNum(), blob.getSkinNum());
		}
	}
	
	if (covering !is null)
	{
		Animation@ anim = covering.addAnimation("default", 0, false);
		anim.AddFrame(1);
		covering.SetRelativeZ(1000);
		//covering.setRenderStyle(RenderStyle::shadow);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ covering = this.getSpriteLayer("covering");

	if(covering !is null){
		covering.SetVisible(!blob.hasTag("have_vision"));
	}
}

bool checkForLeaks(CBlob@ this)
{
	Vec2f Pos = this.getPosition()-Vec2f(this.getSprite().getFrameWidth()/2,this.getSprite().getFrameHeight()/2);

	for(int i = -8;i < this.getSprite().getFrameWidth()+8;i += 8)
	for(int j = -8;j < this.getSprite().getFrameHeight()+8;j += 8)
	if(i == -8 || j == -8 || j+8 >= this.getSprite().getFrameHeight()+8 || i+8 >= this.getSprite().getFrameWidth()+8){
		
		if(!getMap().isTileSolid(getMap().getTile(Pos+Vec2f(i+4,j+4)))){
		
			bool leaking = true;
			
			CBlob@[] blobs;
			
			getMap().getBlobsAtPosition(Pos+Vec2f(i+4,j+4), @blobs);
			
			for (u32 k = 0; k < blobs.length; k++)
			{
				CBlob@ blob = blobs[k];
				if(blob.getName() == "airlock")leaking = false;
			}
			
			if(leaking)return true;
		
		}
	}
	
	return false;
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if(!blob.hasTag("have_vision") || blob.hasTag("power_hover")){
		
		int icon = -1;
		string filename = "SystemIcons.png";
		
		if(blob.get_u8("Damage") > 0)filename = "SystemIconsDamage.png";
		if(blob.get_u16("IonDamage") > 0)if(getGameTime() % 30 < 15)filename = "SystemIconsIon.png";
		if(blob.get_u8("Damage") >= blob.get_u8("Level"))filename = "SystemIconsDestroyed.png";
		if(blob.hasTag("power_hover"))filename = "SystemIconsHover.png";
		
		if(blob.getName() == "weapon_room")icon = 0;
		if(blob.getName() == "engine_room")icon = 1;
		if(blob.getName() == "scanner_room")icon = 2;
		if(blob.getName() == "camera")icon = 2;
		if(blob.getName() == "shield_generator")icon = 3;
		if(blob.getName() == "eva_room")icon = 4;
		//if(blob.getName() == "weapon_room")icon = 5; //Hacking
		if(blob.getName() == "medbay")icon = 6;
		if(blob.getName() == "pilots_seat")icon = 7;
		if(blob.getName() == "cloning_bay")icon = 8;
		if(blob.getName() == "oxygen_generator")icon = 9;
		if(blob.getName() == "gravity_generator")icon = 10;
		if(blob.getName() == "big_storage")icon = 11;
		if(blob.getName() == "small_storage")icon = 11;
		if(blob.getName() == "reactorroom")icon = 12;
		if(blob.getName() == "defunctreactorroom")icon = 12;
		if(blob.getName() == "scrap_arm")icon = 13;
		
		if(icon == -1)return;
		
		f32 scale = 1.0f;
		if(getCamera().targetFactor > 0.55)scale = 0.5f;
		GUI::DrawIcon(filename, icon, Vec2f(32,32), getDriver().getScreenPosFromWorldPos(blob.getPosition())-Vec2f(32.0f*scale,32.0f*scale), scale);
	}

	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	if (mouseOnBlob)if(blob.get_u16("Grief") > 0 || blob.get_u16("Repair_Amount") > 0)
	{
		Vec2f pos2d = blob.getScreenPos() + Vec2f(0, 20);
		Vec2f dim = Vec2f(24, 8);
		const f32 y = blob.getHeight() * 2.4f;
		const f32 Max = 2000;
		if (Max > 0.0f)
		{
			const f32 griefperc = blob.get_u16("Grief") / Max;
			const f32 repairperc = blob.get_u16("Repair_Amount") / Max;
			if (griefperc >= 0.0f)
			{
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 2));
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y + 2), Vec2f(pos2d.x - dim.x + griefperc * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 2), SColor(255, 191, 64, 64));
			}
			if (repairperc >= 0.0f && blob.get_u8("Damage") > 0)
			{
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y - 2), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 2));
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y + 2), Vec2f(pos2d.x - dim.x + repairperc * 2.0f * dim.x - 2, pos2d.y + y + dim.y - 2), SColor(255, 255, 255, 0));
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller) && this.getTeamNum() == caller.getTeamNum())
		this.set_bool("shop available", true);
	else
		this.set_bool("shop available", false);
		
	if(this.getName() != "onebyoneroom" &&
		this.getName() != "onebytworoom" &&
		this.getName() != "twobyoneroom" &&
		this.getName() != "twobytworoom")
			this.set_bool("shop available", false);
			
	if(this.isOverlapping(caller) && this.get_u8("Level") < this.get_u8("MaxLevel") && this.getTeamNum() == caller.getTeamNum()){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		CButton@ button = caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("upgrade"), "Cost to upgrade to level "+(this.get_u8("Level")+1)+": "+(this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level"))+" Scrap", params);
		
		CBitStream reqs, missing;
		AddRequirement(reqs, "blob", "mat_scrap", "Scrap", this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level"));
		CInventory@ inv = caller.getInventory();

		button.SetEnabled(hasRequirements(inv, reqs, missing));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds
		this.Tag("no death effect");
		
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		CBlob@ item = getBlobByNetworkID(params.read_netid());
		if (item !is null && caller !is null)
		{
			item.set_u16("oxygen",this.get_u16("oxygen"));
			this.getSprite().PlaySound("build_room.ogg");
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
		}
	}
	
	if (cmd == this.getCommandID("upgrade"))
	{

		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller !is null)
		{
			CBitStream reqs, missing;
			AddRequirement(reqs, "blob", "mat_scrap", "Scrap", this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level"));
			CInventory@ inv = caller.getInventory();
			
			if(this.get_u8("Level") < this.get_u8("MaxLevel"))
			if(hasRequirements(inv, reqs, missing)){
			
				if(getNet().isServer()){
					//caller.getInventory().server_RemoveItems("mat_scrap", this.get_u8("upgrade_cost_base")+this.get_u8("upgrade_cost_level")*this.get_u8("Level"));
					
					server_TakeRequirements(inv,reqs);
					
					this.set_u8("Level",this.get_u8("Level")+1);
					this.Sync("Level",true);
					
					this.server_SetHealth(this.getInitialHealth()/2.0f*this.get_u8("Level"));
				}
			
				this.getSprite().PlaySound("upgrade.ogg");
			}
		}
	}
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(this.get_u8("Level") > this.get_u8("Damage")){
		if(hitterBlob.hasTag("flesh")){
			int grief = 48;
			
			if(hitterBlob.getName() == "engi")grief /= 2;
			if(hitterBlob.getName() == "mantis")grief *= 2;
			
			if(hitterBlob.getTeamNum() == this.getTeamNum())grief *= 4;
			
			this.set_u16("Grief",this.get_u16("Grief")+grief);
			return 0.1f;
		}
		
		int damagez = 1;
		
		if(hitterBlob !is null){
			if(hitterBlob.hasTag("laser"))damagez = hitterBlob.get_u8("Damage");
		}
		
		this.set_u8("Damage",this.get_u8("Damage")+damagez);
		if(getNet().isServer())this.Sync("Damage",true);
		return 0;
	} else {
		if(getNet().isServer())
		{
			if(this.getTeamNum() != 0 && this.getName() != "reactorroom"){
				for(int i = 0; i < damage/5; i++){
					CBlob @scrap = server_CreateBlob("mat_scrap",-1,worldPoint);
					if(scrap !is null)scrap.server_SetQuantity(1+XORRandom(10));
					if(scrap !is null)scrap.setVelocity(Vec2f(-(10+XORRandom(15)),XORRandom(21)-10)*0.2f);
				}
			}
		}
	}
	
	return damage;
}