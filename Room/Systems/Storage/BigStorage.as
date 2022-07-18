
void onInit(CBlob@ this)
{
	this.set_Vec2f("store_offset", Vec2f(1.50f, -3));
	this.Tag("storage");
}

void onTick(CBlob@ this)
{
	this.inventoryButtonPos = Vec2f(3, 10);
}

void onInit(CSprite@ this)
{

}