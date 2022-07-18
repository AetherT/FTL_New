// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as";
#include "Requirements.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{

	AddIconToken("$1x1icon$", "RoomIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$2x1icon$", "RoomIcons.png", Vec2f(16, 16), 1);
	AddIconToken("$1x2icon$", "RoomIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$2x2icon$", "RoomIcons.png", Vec2f(16, 16), 3);
	AddIconToken("$airlock_icon$", "Airlock.png", Vec2f(8, 8), 0);
	AddIconToken("$turret_icon$", "TurretIcon.png", Vec2f(24, 24), 0);
	
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Hull Block");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 2);
		blocks[0].push_back(b);
	}
	/*{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Hull Scaffolding\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Stone", 2);
		blocks[0].push_back(b);
	}*/
	/*{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Plasteel Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 1);
		blocks[0].push_back(b);
	}*/
	/*{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Plasteel Scafolding\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Wood", 1);
		blocks[0].push_back(b);
	}*/
	{
		BuildBlock b(0, "airlock", "$airlock_icon$", "Airlock");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 1);
		blocks[0].push_back(b);
	}
	
	{
		BuildBlock b(0, "turret", "$turret_icon$", "Turret");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 30);
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	
	
	{
		BuildBlock b(0, "twobyoneroom", "$2x1icon$", "2 x 1 Room");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 20);
		b.size.Set(40, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "onebytworoom", "$1x2icon$", "1 x 2 Room");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 20);
		b.size.Set(16, 40);
		blocks[0].push_back(b);
	}
	
	{
		BuildBlock b(0, "onebyoneroom", "$1x1icon$", "1 x 1 Room");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 10);
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "twobytworoom", "$2x2icon$", "2 x 2 Room");
		AddRequirement(b.reqs, "blob", "mat_scrap", "Scrap", 40);
		b.size.Set(40, 40);
		blocks[0].push_back(b);
	}
	
	
	
	
}