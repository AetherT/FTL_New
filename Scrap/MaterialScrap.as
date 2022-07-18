
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{

  this.maxQuantity = 250;

}


void onTick(CBlob@ this)
{
	Material::updateFrame(this);
}