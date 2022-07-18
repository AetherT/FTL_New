
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

#include "WeaponCommon.as";
 
const SColor color_airlock(0xffFF643C);

const SColor color_room1x1(0xff838383);
const SColor color_room2x1(0xff848484);
const SColor color_room1x2(0xff858585);
const SColor color_room2x2(0xff868686);

const SColor color_reactor(0xffff3737);
const SColor color_pilot_seat(0xffff6414);
const SColor color_EVA(0xff64ff14);
const SColor color_oxygen(0xff3264FF);
const SColor color_gravity(0xff6432FF);
const SColor color_engines(0xff32fff3);

const SColor color_randomweapon(0xff14c800);
 
namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_whatever = 300
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if (pixel == color_airlock)
	{
		spawnBlob(map, "airlock", offset, 0, true);
	}
	else if (pixel == color_room1x1)
	{
		spawnBlob(map, "onebyoneroom", offset, 0);
	}
	else if (pixel == color_room2x1)
	{
		spawnBlob(map, "twobyoneroom", offset, 0);
	}
	else if (pixel == color_room1x2)
	{
		spawnBlob(map, "onebytworoom", offset, 0);
	}
	else if (pixel == color_room2x2)
	{
		spawnBlob(map, "twobytworoom", offset, 0);
	}
	else if (pixel == color_reactor)
	{
		CBlob @room = spawnBlob(map, "reactorroom", offset, 0);
		room.set_u16("oxygen",1000);
		
		for(int i =0;i < 20;i++){
			CBlob @scrap = spawnBlob(map, "mat_scrap", offset, 0);
			scrap.server_SetQuantity(50);
		}
		
		CBlob @weapon = spawnBlob(map, "weapon", offset, 0);
		weapon.set_u16("type",XORRandom(WeaponAmount-1)+1);
	}
	else if (pixel == color_pilot_seat)
	{
		spawnBlob(map, "pilots_seat", offset, 0);
		for(int i =0;i < 10;i++){
			CBlob @scrap = spawnBlob(map, "mat_scrap", offset, 0);
			scrap.server_SetQuantity(50);
		}
		
	}
	else if (pixel == color_EVA)
	{
		CBlob @room = spawnBlob(map, "eva_room", offset, 0);
		room.set_u16("oxygen",1000);
		
		for(int i =0;i < 10;i++){
			CBlob @scrap = spawnBlob(map, "mat_scrap", offset, 0);
			scrap.server_SetQuantity(50);
		}
	}
	else if (pixel == color_oxygen)
	{
		CBlob @room = spawnBlob(map, "oxygen_generator", offset, 0);
		room.set_u16("oxygen",1000);
		
		for(int i =0;i < 10;i++){
			CBlob @scrap = spawnBlob(map, "mat_scrap", offset, 0);
			scrap.server_SetQuantity(50);
		}
	}
	else if (pixel == color_gravity)
	{
		spawnBlob(map, "gravity_generator", offset, 0);
		
		CBlob @scrap = spawnBlob(map, "mat_scrap", offset, 0);
		scrap.server_SetQuantity(50);
	}
	else if (pixel == color_randomweapon)
	{
		CBlob @weapon = spawnBlob(map, "weapon", offset, 0);
		weapon.set_u16("type",XORRandom(WeaponAmount-1)+1);
	}
	else if (pixel == color_engines)
	{
		spawnBlob(map, "engine_room", offset, 0);
	}
}