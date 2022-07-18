
#include "LoaderColors.as";
#include "WeaponCommon.as";
#include "MaterialCommon.as";
#include "LoaderColours.as";

const SColor color_airlock(0xffFF643C);

const SColor color_room1x1(0xff838383);
const SColor color_room2x1(0xff848484);
const SColor color_room1x2(0xff858585);
const SColor color_room2x2(0xff868686);

const SColor color_reactor(0xffff3737);
const SColor color_reactordefunct(0xffa12424);
const SColor color_pilot_seat(0xffff6414);
const SColor color_EVA(0xff64ff14);
const SColor color_oxygen(0xff3264FF);
const SColor color_gravity(0xff6432FF);
const SColor color_shields(0xff3296ff);
const SColor color_cargobay(0xffc0408b);
const SColor color_engines(0xff32fff3);
const SColor color_medbay(0xff320000);

const SColor color_turret(0xffc0c040);
const SColor color_weaponroom(0xffffff40);
const SColor color_randomweapon(0xff14c800);

const SColor color_scrap(0xff503c28);

const SColor color_civ_ship(0xffc81414);
const SColor color_der_ship(0xffc81515);
const SColor color_pir_ship(0xffc81616);
const SColor color_mil_ship(0xffc81717);
const SColor color_tra_ship(0xffc81818);
const SColor color_com_ship(0xffc81919);

const SColor color_sky(0xffa5bdc8);

void wipeWorld(CMap@ map, int StartY, int EndY){

	CBlob@[] blobs;

	getBlobs(blobs);
	
	if(getNet().isServer())
	for (u32 k = 0; k < blobs.length; k++)
	{
		CBlob@ blob = blobs[k];
		if(StartY*8+64 < blob.getPosition().y && EndY*8+64 > blob.getPosition().y)
		if(blob.getPosition().x > getMap().tilemapwidth/2*8 || blob.getName() == "ship_ai"){
			blob.Tag("no death effect");
			blob.Sync("no death effect",true);
			blob.server_Die();
		}
	}
	
	if(EndY > getMap().tilemapheight)EndY = getMap().tilemapheight;
	
	for(int i = 0;i < getMap().tilemapwidth/2;i++)
	for(int j = StartY;j < EndY;j++){
		SetTile(Vec2f((getMap().tilemapwidth/2)*8+i*8,j*8), CMap::tile_empty);
	}

}

int TeamNum = 0;

bool loadEvent(CMap@ map, const string& in filename, int team)
{

	print("Loading '"+filename+"' event! Rooms will be team:"+team);

	TeamNum = team+1;
	
	CFileImage@ image = CFileImage( filename );

	//TODO: Swap planet background
	
	if(image.isLoaded())
	{
	
		while(image.nextPixel())
		{
			//print("processing: "+image.getPixelPosition().x+","+image.getPixelPosition().y);
			
			if(getNet().isServer())getNet().server_KeepConnectionsAlive();
			
			SColor pixel = image.readPixel();
			Vec2f offset = image.getPixelPosition()+Vec2f(getMap().tilemapwidth/2,0);
			
			offset = Vec2f(offset.x*8,offset.y*8);
			
			handlePixel(pixel, offset, team);

			if(getNet().isServer())getNet().server_KeepConnectionsAlive();
		}
		return true;
	}
	return false;
}

int CivShips = 2;
int TraShips = 2;
int ComShips = 4;
int DerShips = 3;
int MilShips = 1;
int PirShips = 3;

void loadShip(CMap@ map, int team, Vec2f position, string type)
{

	int amount = 0;

	if(type == "Civ")amount = CivShips;
	if(type == "Trans")amount = TraShips;
	if(type == "Com")amount = ComShips;
	if(type == "Debris")amount = DerShips;
	if(type == "Pirate")amount = PirShips;
	if(type == "Mil")amount = MilShips;
	
	if(amount < 1)return;
	
	string filename = type+"Ship"+XORRandom(amount)+".png";
	
	print("Loading '"+filename+"'! Ship will be team:"+team);

	//print("Loading ship: "+filename+" at position: "+position.x+","+position.y);

	CFileImage@ image = CFileImage( filename );
	
	if(image.isLoaded())
	{
	
		if(getNet().isServer())server_CreateBlob("ship_ai",team,Vec2f(0,0));
	
		while(image.nextPixel())
		{
			//print("processing: "+image.getPixelPosition().x+","+image.getPixelPosition().y);
			
			if(getNet().isServer())getNet().server_KeepConnectionsAlive();
			
			SColor pixel = image.readPixel();
			Vec2f offset = image.getPixelPosition()+Vec2f(position.x/8,position.y/8)-Vec2f(50,50);
			
			offset = Vec2f(offset.x*8,offset.y*8);
			
			handlePixel(pixel, offset, team);

			if(getNet().isServer())getNet().server_KeepConnectionsAlive();
		}
	}
	
	if(type != "Debris"){
		CBlob@[] rooms;
			
		getBlobsByName("reactorroom", rooms);
		
		for (u32 l = 0; l < rooms.length; l++)
		{
			
			CBlob @room = rooms[l];
			
			if(room !is null)
			if(team == room.getTeamNum()){
				string race = "human";
					
				if(type == "Civ"){
					if(XORRandom(2) == 0)race = "zoltan";
					if(XORRandom(2) == 0)race = "engi";
				}
				if(type == "Trans"){
					if(XORRandom(2) == 0)race = "engi";
				}
				if(type == "Com"){
					if(XORRandom(2) == 0)race = "rock";
					if(XORRandom(2) == 0)race = "zoltan";
					if(XORRandom(2) == 0)race = "mantis";
				}
				
				if(type == "Mil"){
					if(XORRandom(2) == 0)race = "rock";
					if(XORRandom(2) == 0)race = "zoltan";
					if(XORRandom(2) == 0)race = "mantis";
				}
				
				for (u32 i = 0; i < 5+XORRandom(5); i++)
				if(getNet().isServer()){
					
					if(type == "Pirate"){
						if(XORRandom(6) == 0)race = "rock";
						if(XORRandom(7) == 0)race = "zoltan";
						if(XORRandom(8) == 0)race = "engi";
						if(XORRandom(5) == 0)race = "slug";
						if(XORRandom(4) == 0)race = "mantis";
					}
					
					server_CreateBlob(race,team,room.getPosition());
				}
				
			}
		}
	}
}

void handlePixel(SColor pixel, Vec2f offset, int team)
{
	u8 alpha = pixel.getAlpha();

	CMap @map = getMap();
	
	if(alpha < 255)
	{
		alpha &= ~0x80;
		SColor rgb = SColor(0xFF, pixel.getRed(), pixel.getGreen(), pixel.getBlue());
		const Vec2f position = offset;

		//print(" ARGB = "+alpha+", "+rgb.getRed()+", "+rgb.getGreen()+", "+rgb.getBlue());

		// BLOCKS
		if(rgb == map_colors::alpha_ladder)
		{
			spawnBlob(map, "ladder", team, position, 0, true);
			
		}
		else if(rgb == map_colors::spikes)
		{
			spawnBlob(map, "spikes", team, position, true);
			
		}
		else if(rgb == map_colors::alpha_stone_door)
		{
			spawnBlob(map, "stone_door", team, position, 0, true);
			
		}
		else if(rgb == map_colors::alpha_trap_block)
		{
			spawnBlob(map, "trap_block", team, position, true);
			
		}
		else if(rgb == map_colors::alpha_wooden_door)
		{
			spawnBlob(map, "wooden_door", team, position, 0, true);
			
		}
		else if(rgb == map_colors::alpha_wooden_platform)
		{
			spawnBlob(map, "wooden_platform", team, position, 0, true);
			
		}
	}
	else if(pixel == map_colors::tile_ground)
	{
		SetTile(offset, CMap::tile_ground);
	}
	else if(pixel == map_colors::sky)
	{
		SetTile(offset, CMap::tile_empty);
	}
	else if(pixel == map_colors::tile_ground_back)
	{
		SetTile(offset, CMap::tile_ground_back);
	}
	else if(pixel == map_colors::tile_stone)
	{
		SetTile(offset, CMap::tile_stone);
	}
	else if(pixel == map_colors::tile_thickstone)
	{
		SetTile(offset, CMap::tile_thickstone);
	}
	else if(pixel == map_colors::tile_bedrock)
	{
		SetTile(offset, CMap::tile_bedrock);
	}
	else if(pixel == map_colors::tile_gold)
	{
		SetTile(offset, CMap::tile_gold);
	}
	else if(pixel == map_colors::tile_castle)
	{
		SetTile(offset, CMap::tile_castle);
	}
	else if(pixel == map_colors::tile_castle_back)
	{
		SetTile(offset, CMap::tile_castle_back);
	}
	else if(pixel == map_colors::tile_castle_moss)
	{
		SetTile(offset, CMap::tile_castle_moss);
	}
	else if(pixel == map_colors::tile_castle_back_moss)
	{
		SetTile(offset, CMap::tile_castle_back_moss);
	}
	else if(pixel == map_colors::tile_wood)
	{
		SetTile(offset, CMap::tile_wood);
	}
	else if(pixel == map_colors::tile_wood_back)
	{
		SetTile(offset, CMap::tile_wood_back );
	}
	else if(pixel == map_colors::tile_grass)
	{
		SetTile(offset, CMap::tile_grass+XORRandom(3));
	}
	else if(pixel == map_colors::water_air)
	{
		if(getNet().isServer())map.server_setFloodWaterWorldspace(offset, true);
	}
	else if(pixel == map_colors::water_backdirt)
	{
		if(getNet().isServer())map.server_setFloodWaterWorldspace(offset, true);
		SetTile(offset, CMap::tile_ground_back);
	}
	else if(pixel == map_colors::princess)
	{
		spawnBlob(map, "princess", offset, team, false);
		
	}
	else if(pixel == map_colors::necromancer)
	{
		spawnBlob( map, "necromancer", offset, team, false);
		
	}
	else if (pixel == map_colors::knight_shop)
	{
		spawnBlob( map, "knightshop", offset, 255);
	}
	else if (pixel == map_colors::builder_shop)
	{
		spawnBlob( map, "buildershop", offset, 255);
		
	}
	else if (pixel == map_colors::archer_shop)
	{
		spawnBlob( map, "archershop", offset, 255);
		
	}
	else if (pixel == map_colors::boat_shop)
	{
		spawnBlob( map, "boatshop", offset, 255);
		
	}
	else if(pixel == map_colors::vehicle_shop)
	{
		spawnBlob(map, "vehicleshop", offset, 255);
		
	}
	else if(pixel == map_colors::quarters)
	{
		spawnBlob(map, "quarters", offset, 255);
		
	}
	else if(pixel == map_colors::storage_noteam)
	{
		spawnBlob(map, "storage", offset, 255);
		
	}
	else if(pixel == map_colors::barracks_noteam)
	{
		spawnBlob(map, "barracks", offset, 255);
		
	}
	else if(pixel == map_colors::factory_noteam)
	{
		spawnBlob(map, "factory", offset, 255);
		
	}
	else if(pixel == map_colors::tunnel_blue)
	{
		spawnBlob(map, "tunnel", offset, 0);
		
	}
	else if(pixel == map_colors::tunnel_red)
	{
		spawnBlob(map, "tunnel", offset, 1);
		
	}
	else if(pixel == map_colors::tunnel_noteam)
	{
		spawnBlob(map, "tunnel", offset, 255);
		
	}
	else if(pixel == map_colors::kitchen)
	{
		spawnBlob(map, "kitchen", offset, 255);
		
	}
	else if(pixel == map_colors::nursery)
	{
		spawnBlob(map, "nursery", offset, 255);
		
	}
	else if(pixel == map_colors::research)
	{
		spawnBlob(map, "research", offset, 255);
		
	}
	else if(pixel == map_colors::workbench)
	{
		spawnBlob(map, "workbench", offset, -1, true);
		
	}
	else if(pixel == map_colors::campfire)
	{
		spawnBlob(map, "fireplace", offset, -1, true, Vec2f(0.0f, -4.0f));
		
	}
	else if(pixel == map_colors::saw)
	{
		spawnBlob( map, "saw", offset, -1, false);
		
	}
	else if (pixel == map_colors::flowers)
	{
		spawnBlob( map, "flowers", offset, -1);
		
	}
	else if (pixel == map_colors::log)
	{
		spawnBlob( map, "log", offset, -1);
		
	}
	else if (pixel == map_colors::shark)
	{
		spawnBlob( map, "shark", offset, -1);
		
	}
	else if (pixel == map_colors::fish)
	{
		CBlob@ fishy = spawnBlob( map, "fishy", offset, -1);
		if (fishy !is null)
		{
			fishy.set_u8("age", (offset.x * 997) % 4 );
		}
		
	}
	else if (pixel == map_colors::bison)
	{
		spawnBlob( map, "bison", offset, -1, false);
		
	}
	else if (pixel == map_colors::chicken)
	{
		spawnBlob( map, "chicken", offset, -1, false);
		
	}
	else if (pixel == map_colors::platform_up)
	{
		spawnBlob( map, "wooden_platform", offset, 255, true );
		
	}
	else if (pixel == map_colors::platform_right)
	{
		CBlob@ blob = spawnBlob(map, "wooden_platform", offset, 255, false);
		if(blob !is null){
		blob.setAngleDegrees(90.0f);
		blob.getShape().SetStatic(true);
		}
	}
	else if (pixel == map_colors::platform_down)
	{
		CBlob@ blob = spawnBlob( map, "wooden_platform", offset, 255, false );
		if(blob !is null){
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 180.0f );
		shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::platform_left)
	{
		CBlob@ blob = spawnBlob( map, "wooden_platform", offset, 255, false );
		if(blob !is null){
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( -90.0f );
		shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::wooden_door_h_blue)
	{
		spawnBlob( map, "wooden_door", offset, 0, true );
		
	}
	else if (pixel == map_colors::wooden_door_v_blue)
	{
		CBlob@ blob = spawnBlob( map, "wooden_door", offset, 0, false );
		if(blob !is null){
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::wooden_door_h_red)
	{
		spawnBlob( map, "wooden_door", offset, 1, true );
		
	}
	else if (pixel == map_colors::wooden_door_v_red)
	{
		CBlob@ blob = spawnBlob( map, "wooden_door", offset, 1, false );
		if(blob !is null){
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::wooden_door_h_noteam)
	{
		spawnBlob( map, "wooden_door", offset, 255, true );
		
	}
	else if (pixel == map_colors::wooden_door_v_noteam)
	{
		CBlob@ blob = spawnBlob( map, "wooden_door", offset, 255, false );
		if(blob !is null){
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::stone_door_h_blue)
	{
		spawnBlob( map, "stone_door", offset, 0, true );
		
	}
	else if (pixel == map_colors::stone_door_v_blue)
	{
		CBlob@ blob = spawnBlob( map, "stone_door", offset, 0, false );
		if(blob !is null){
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::stone_door_h_red)
	{
		spawnBlob( map, "stone_door", offset, 1, true );
		
	}
	else if (pixel == map_colors::stone_door_v_red)
	{
		CBlob@ blob = spawnBlob( map, "stone_door", offset, 1, false );
		if(blob !is null){
		CShape@ shape = blob.getShape();
		blob.setAngleDegrees( 90.0f );
		shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::stone_door_h_noteam)
	{
		spawnBlob( map, "stone_door", offset, 255, true );
		
	}
	else if (pixel == map_colors::stone_door_v_noteam)
	{
		CBlob@ blob = spawnBlob( map, "stone_door", offset, 255, false );
		if(blob !is null){
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 90.0f );
			shape.SetStatic( true );
		}
	}
	else if (pixel == map_colors::trapblock_blue)
	{
		spawnBlob( map, "trap_block", offset, 0, true);
		
	}
	else if (pixel == map_colors::trapblock_red)
	{
		spawnBlob( map, "trap_block", offset, 1, true);
		
	}
	else if (pixel == map_colors::trapblock_noteam)
	{
		spawnBlob( map, "trap_block", offset, 255, true );
		
	}
	else if(pixel == map_colors::chest)
	{
		spawnBlob(map, "chest", 255, offset);
		
	}
	else if (pixel == map_colors::drill)
	{
		spawnBlob( map, "drill", offset, -1);
		
	}
	else if (pixel == map_colors::trampoline)
	{
		if(getNet().isServer()){
			CBlob@ trampoline = server_CreateBlobNoInit("trampoline");
			if (trampoline !is null)
			{
				trampoline.setPosition(offset);
				trampoline.Init();
			}
		}
	}
	else if (pixel == map_colors::lantern)
	{
		spawnBlob( map, "lantern", offset, -1, true);
		
	}
	else if (pixel == map_colors::crate)
	{
		spawnBlob( map, "crate", offset, -1);
		
	}
	else if (pixel == map_colors::bucket)
	{
		spawnBlob( map, "bucket", offset, -1);
		
	}
	else if (pixel == map_colors::sponge)
	{
		spawnBlob( map, "sponge", offset, -1);
		
	}
	else if (pixel == map_colors::steak)
	{
		spawnBlob( map, "steak", offset, -1);
		
	}
	else if (pixel == map_colors::burger)
	{
		spawnBlob( map, "food", offset, -1);
		
	}
	else if (pixel == map_colors::heart)
	{
		spawnBlob( map, "heart", offset, -1);
		
	}
	else if (pixel == map_colors::mountedbow)
	{
		spawnBlob( map, "mounted_bow", offset, -1, true, Vec2f(0.0f, 4.0f));
		
	}
	else if (pixel == map_colors::waterbombs)
	{
		spawnBlob( map, "mat_waterbombs", offset, -1);
		
	}
	else if (pixel == map_colors::arrows)
	{
		spawnBlob( map, "mat_arrows", offset, -1);
		
	}
	else if (pixel == map_colors::bombarrows)
	{
		spawnBlob( map, "mat_bombarrows", offset, -1);
		
	}
	else if (pixel == map_colors::waterarrows)
	{
		spawnBlob( map, "mat_waterarrows", offset, -1);
		
	}
	else if (pixel == map_colors::firearrows)
	{
		spawnBlob( map, "mat_firearrows", offset, -1);
		
	}
	else if (pixel == map_colors::bolts)
	{
		spawnBlob( map, "mat_bolts", offset, -1);
		
	}
	else if (pixel == map_colors::blue_mine)
	{
		spawnBlob( map, "mine", offset, 0);
		
	}
	else if (pixel == map_colors::red_mine)
	{
		spawnBlob( map, "mine", offset, 1);
		
	}
	else if (pixel == map_colors::mine_noteam)
	{
		spawnBlob( map, "mine", offset, -1);
		
	}
	else if (pixel == map_colors::boulder)
	{
		spawnBlob( map, "boulder", offset, -1, false, Vec2f(8.0f, -8.0f));
		
	}
	else if (pixel == map_colors::satchel)
	{
		spawnBlob( map, "satchel", offset, -1);
		
	}
	else if (pixel == map_colors::keg)
	{
		spawnBlob( map, "keg", offset, -1);
		
	}
	else if (pixel == map_colors::gold)
	{
		spawnBlob( map, "mat_gold", offset, -1);
		
	}
	else if (pixel == map_colors::stone)
	{
		spawnBlob( map, "mat_stone", offset, -1);
		
	}
	else if (pixel == map_colors::wood)
	{
		spawnBlob( map, "mat_wood", offset, -1);
		
	}
	else if(pixel == map_colors::dummy)
	{
		spawnBlob(map, "dummy", offset, 1, true);
		
	}
	else if (pixel == color_airlock)
	{
		spawnBlob(map, "airlock", offset+Vec2f(4,4), team, true);
	}
	else if (pixel == color_room1x1)
	{
		spawnBlob(map, "onebyonewindowroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_room2x1)
	{
		spawnBlob(map, "twobyonewindowroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_room1x2)
	{
		spawnBlob(map, "onebytwowindowroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_room2x2)
	{
		spawnBlob(map, "twobytwowindowroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_reactor)
	{
		spawnBlob(map, "reactorroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_reactordefunct)
	{
		spawnBlob(map, "defunctreactorroom", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_pilot_seat)
	{
		spawnBlob(map, "pilots_seat", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_oxygen)
	{
		spawnBlob(map, "oxygen_generator", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_EVA)
	{
		spawnBlob(map, "eva_room", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_gravity)
	{
		spawnBlob(map, "gravity_generator", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_turret)
	{
		CBlob @turret = spawnBlob(map, "turret", offset+Vec2f(4,4), team);
		if(turret !is null){
			turret.set_u16("gun_type",XORRandom(WeaponAmount-1)+1);
			turret.set_Vec2f("aim",turret.getPosition()+Vec2f(-32,0));
		}
	}
	else if (pixel == color_randomweapon)
	{
		CBlob @weapon = spawnBlob(map, "weapon", offset+Vec2f(4,4), team);
		if(weapon !is null)weapon.set_u16("type",XORRandom(WeaponAmount-1)+1);
	}
	else if (pixel == color_weaponroom)
	{
		spawnBlob(map, "weapon_room", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_scrap)
	{
		CBlob @scrap = spawnBlob(map, "mat_scrap", offset+Vec2f(XORRandom(8),XORRandom(8)), -1);
		if(scrap !is null)scrap.server_SetQuantity(XORRandom(200)+1);
	}
	
	else if (pixel == color_civ_ship)
	{
		loadShip(map, TeamNum, offset, "Civ");
		TeamNum++;
	}
	else if (pixel == color_der_ship)
	{
		loadShip(map, TeamNum, offset, "Debris");
		TeamNum++;
	}
	else if (pixel == color_pir_ship)
	{
		loadShip(map, TeamNum, offset, "Pirate");
		TeamNum++;
	}
	else if (pixel == color_mil_ship)
	{
		loadShip(map, TeamNum, offset, "Mil");
		TeamNum++;
	}
	else if (pixel == color_tra_ship)
	{
		loadShip(map, TeamNum, offset, "Trans");
		TeamNum++;
	}
	else if (pixel == color_com_ship)
	{
		loadShip(map, TeamNum, offset, "Com");
		TeamNum++;
	}
	
	else if (pixel == color_shields)
	{
		spawnBlob(map, "shield_generator", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_cargobay)
	{
		CBlob @storage = spawnBlob(map, "big_storage", offset+Vec2f(4,4), team);
		if(storage !is null)if(getNet().isServer())Material::createFor(storage, "mat_scrap", XORRandom(300)+1);
	}
	else if (pixel == color_engines)
	{
		spawnBlob(map, "engine_room", offset+Vec2f(4,4), team);
	}
	else if (pixel == color_medbay)
	{
		spawnBlob(map, "medbay", offset+Vec2f(4,4), team);
	}
	
}

void SetTile(Vec2f pos, int tile){

	if(getNet().isServer())getMap().server_SetTile(pos, tile);
	//else getMap().SetTile(getMap().getTileOffset(pos), tile);
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position)
{
	if(!getNet().isServer())return null;
	
	CBlob@ blob = server_CreateBlob(name, team, position);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, const bool fixed)
{
	if(!getNet().isServer())return null;
	
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, u16 angle)
{
	if(!getNet().isServer())return null;
	
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, u16 angle, const bool fixed)
{
	if(!getNet().isServer())return null;
	
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, Vec2f offset, int team, bool attached_to_map, Vec2f posOffset)
{
	if(!getNet().isServer())return null;
	
	CBlob@ blob = server_CreateBlob(name, team, offset + posOffset);
	if(blob !is null && attached_to_map)
	{
		blob.getShape().SetStatic( true );
	}
	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, Vec2f offset, int team, bool attached_to_map = false)
{
	if(!getNet().isServer())return null;
	
	return spawnBlob(map, name, offset, team, attached_to_map, Vec2f_zero);
}