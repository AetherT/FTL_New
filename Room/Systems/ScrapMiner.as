u8 a=1;
void onTick(CBlob@ this)

{
  
  if(a%50 == 0)
  {

   CBlob@ new_blob = server_CreateBlob("mat_scrap", -1, this.getPosition());
    
    
   
  }
 a++;
}