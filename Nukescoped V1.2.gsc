#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_rank;
 
//BO2 GSC Menu Base By Shark
 
init()
{
    level thread onplayerconnect();
    precacheShader("hud_remote_missile_target");
	precacheShader("headicon_dead");
	level.deads = "headicon_dead";
	level.esps = "hud_remote_missile_target";
}
 
onplayerconnect()
{
    for(;;)
    {
        level waittill( "connecting", player );
        if(player isHost())
                        player.status = "Host";
                else
                        player.status = "Unverified";
                       
        player thread onplayerspawned();
    }
}
 
onplayerspawned()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
   
    self.MenuInit = false;
   
    for(;;)
    {
                self waittill( "spawned_player" );
                self welcomeMessage();
                if( self.status == "Host" || self.status == "CoHost" || self.status == "Admin" || self.status == "VIP" || self.status == "Verified")
                {
                        if (!self.MenuInit)
                        {
                                self.MenuInit = true;
                                self thread MenuInit();
                                self thread closeMenuOnDeath();
                        }
                }
    }
}
 
drawText(text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort)
{
        hud = self createFontString(font, fontScale);
    hud setText(text);
    hud.x = x;
        hud.y = y;
        hud.color = color;
        hud.alpha = alpha;
        hud.glowColor = glowColor;
        hud.glowAlpha = glowAlpha;
        hud.sort = sort;
        hud.alpha = alpha;
        return hud;
}
 
drawShader(shader, x, y, width, height, color, alpha, sort)
{
        hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
    hud setParent(level.uiParent);
    hud setShader(shader, width, height);
    hud.x = x;
    hud.y = y;
    return hud;
}
 
verificationToNum(status)
{
        if (status == "Host")
                return 5;
        if (status == "CoHost")
                return 4;
        if (status == "Admin")
                return 3;
        if (status == "VIP")
                return 2;
        if (status == "Verified")
                return 1;
        else
                return 0;
}
 
verificationToColor(status)
{
        if (status == "Host")
                return "^2Host";
        if (status == "CoHost")
                return "^5CoHost";
        if (status == "Admin")
                return "^1Admin";
        if (status == "VIP")
                return "^4VIP";
        if (status == "Verified")
                return "^3Verified";
        else
                return "^7Unverified";
}
 
changeVerificationMenu(player, verlevel)
{
        if( player.status != verlevel)
        {              
                player.status = verlevel;
       
                self.menu.title destroy();
                self.menu.title = drawText("[" + verificationToColor(player.status) + "^7] " + player.name, "objective", 2, 280, 30, (1, 1, 1), 0, (0, 0.58, 1), 1, 3);
                self.menu.title FadeOverTime(0.3);
                self.menu.title.alpha = 1;
               
                if(player.status == "Unverified")
                        self thread destroyMenu(player);
       
                player suicide();
                self iPrintln("Set Access Level For " + player.name + " To " + verificationToColor(verlevel));
                player iPrintln("Your Access Level Has Been Set To " + verificationToColor(verlevel));
        }
        else
        {
                self iPrintln("Access Level For " + player.name + " Is Already Set To " + verificationToColor(verlevel));
        }
}
 
changeVerification(player, verlevel)
{
        player.status = verlevel;
}
 
Iif(bool, rTrue, rFalse)
{
        if(bool)
                return rTrue;
        else
                return rFalse;
}
 
welcomeMessage()
{
        notifyData = spawnstruct();
        notifyData.titleText = "^4 Nebulah ^4Private Patch"; //Line 1
        notifyData.notifyText = "^1Made ^0by ^1Nebulah"; //Line 2
        notifyData.glowColor = (2.55, 2.55, 2.55); //RGB Color array divided by 100
        notifyData.duration = 5; //Change Duration
        notifyData.font = "objective"; //font
        notifyData.hideWhenInMenu = false;
        self thread maps\mp\gametypes\_hud_message::notifyMessage(notifyData);
}
 
CreateMenu()
{
        self add_menu("Main Menu", undefined, "Unverified");
        self add_option("Main Menu", "Toggle God Mode", ::tgm);
        self add_option("Main Menu", "Toggle Unlimited Ammo", ::tua);
        self add_option("Main Menu", "Toggle Trickshot Aimbot (Azza)", ::tunfa);
        self add_option("Main Menu", "Toggle ESP", ::ToggleWallHack);
        self add_option("Main Menu", "Freeze Bots", ::freezeBots);
        self add_option("Main Menu", "Kill Yourself", ::sui);
        self add_option("Main Menu", "Save and Load", ::sal);
        self add_option("Main Menu", "Teleport", ::doTeleport);
        self add_option("Main Menu", "Enable Floaters", ::Floaters);
        self add_option("Main Menu", "Can Swap", ::DropCan);
        self add_option("Main Menu", "Change Class", ::ChangeClass);
        self add_option("Main Menu", "Trickshot Class", ::tsClass);
        self add_option("Main Menu", "Toggle Fake Prestiges", ::choosePrestige);
        self add_option("Main Menu", "Players", ::submenu, "PlayersMenu", "Players");
       
        self add_menu("PlayersMenu", "Billcams V1", "CoHost");
        for (i = 0; i < 12; i++)
        { self add_menu("pOpt " + i, "PlayersMenu", "CoHost"); }
}
 
updatePlayersMenu()
{
        self.menu.menucount["PlayersMenu"] = 0;
        for (i = 0; i < 12; i++)
        {
                player = level.players[i];
                name = player.name;
               
                playersizefixed = level.players.size - 1;
                if(self.menu.curs["PlayersMenu"] > playersizefixed)
                {
                        self.menu.scrollerpos["PlayersMenu"] = playersizefixed;
                        self.menu.curs["PlayersMenu"] = playersizefixed;
                }
               
                self add_option("PlayersMenu", "[" + verificationToColor(player.status) + "^7] " + player.name, ::submenu, "pOpt " + i, "[" + verificationToColor(player.status) + "^7] " + player.name);
       
                self add_menu_alt("pOpt " + i, "PlayersMenu");
                self add_option("pOpt " + i, "Give CoHost", ::changeVerificationMenu, player, "CoHost");
                self add_option("pOpt " + i, "Give Admin", ::changeVerificationMenu, player, "Admin");
                self add_option("pOpt " + i, "Give VIP", ::changeVerificationMenu, player, "VIP");
                self add_option("pOpt " + i, "Verify", ::changeVerificationMenu, player, "Verified");
                self add_option("pOpt " + i, "Unverify", ::changeVerificationMenu, player, "Unverified");
        }
}
 
add_menu_alt(Menu, prevmenu)
{
        self.menu.getmenu[Menu] = Menu;
        self.menu.menucount[Menu] = 0;
        self.menu.previousmenu[Menu] = prevmenu;
}
 
add_menu(Menu, prevmenu, status)
{
    self.menu.status[Menu] = status;
        self.menu.getmenu[Menu] = Menu;
        self.menu.scrollerpos[Menu] = 0;
        self.menu.curs[Menu] = 0;
        self.menu.menucount[Menu] = 0;
        self.menu.previousmenu[Menu] = prevmenu;
}
 
add_option(Menu, Text, Func, arg1, arg2)
{
        Menu = self.menu.getmenu[Menu];
        Num = self.menu.menucount[Menu];
        self.menu.menuopt[Menu][Num] = Text;
        self.menu.menufunc[Menu][Num] = Func;
        self.menu.menuinput[Menu][Num] = arg1;
        self.menu.menuinput1[Menu][Num] = arg2;
        self.menu.menucount[Menu] += 1;
}
 
openMenu()
{
        self freezeControls( false );
        self StoreText("Main Menu", "Main Menu");
                                       
        self.menu.background FadeOverTime(0.3);
        self.menu.background.alpha = 0.65;
 
        self.menu.line MoveOverTime(0.15);
        self.menu.line.y = -50;
       
        self.menu.scroller MoveOverTime(0.15);
        self.menu.scroller.y = self.menu.opt[self.menu.curs[self.menu.currentmenu]].y+1;
        self.menu.open = true;
}
 
closeMenu()
{
        for(i = 0; i < self.menu.opt.size; i++)
        {
                self.menu.opt[i] FadeOverTime(0.3);
                self.menu.opt[i].alpha = 0;
        }
       
        self.menu.background FadeOverTime(0.3);
        self.menu.background.alpha = 0;
       
        self.menu.title FadeOverTime(0.3);
        self.menu.title.alpha = 0;
       
       self.menu.line MoveOverTime(0.15);
        self.menu.line.y = -550;
       
        self.menu.scroller MoveOverTime(0.15);
        self.menu.scroller.y = -500;   
        self.menu.open = false;
}
 
destroyMenu(player)
{
    player.MenuInit = false;
    closeMenu();
       
        wait 0.3;
       
        for(i=0; i < self.menu.menuopt[player.menu.currentmenu].size; i++)
        { player.menu.opt[i] destroy(); }
               
        player.menu.background destroy();
        player.menu.scroller destroy();
        player.menu.line destroy();
        player.menu.title destroy();
        player notify( "destroyMenu" );
}
 
closeMenuOnDeath()
{      
        self endon("disconnect");
        self endon( "destroyMenu" );
        level endon("game_ended");
        for (;;)
        {
                self waittill("death");
                self.menu.closeondeath = true;
                self submenu("Main Menu", "Main Menu");
                closeMenu();
                self.menu.closeondeath = false;
        }
}
 
StoreShaders()
{
        self.menu.background = self drawShader("white", 320, -50, 300, 500, (0, 0, 0), 0, 0);
        self.menu.scroller = self drawShader("white", 320, -500, 300, 17, (0, 0, 0), 255, 1);
        self.menu.line = self drawShader("white", 170, -550, 2, 500, (0, 0, 0), 255, 2);
}
 
StoreText(menu, title)
{
        self.menu.currentmenu = menu;
        self.menu.title destroy();
        self.menu.title = drawText(title, "objective", 2, 280, 30, (1, 1, 1), 0, (0, 0.58, 1), 1, 3);
        self.menu.title FadeOverTime(0.3);
        self.menu.title.alpha = 1;
       
    for(i=0; i < self.menu.menuopt[menu].size; i++)
    {
        self.menu.opt[i] destroy();
        self.menu.opt[i] = drawText(self.menu.menuopt[menu][i], "objective", 1.6, 280, 68 + (i*20), (1, 1, 1), 0, (0, 0, 0), 0, 4);
                self.menu.opt[i] FadeOverTime(0.3);
                self.menu.opt[i].alpha = 1;
    }
}
 
MenuInit()
{
        self endon("disconnect");
        self endon( "destroyMenu" );
        level endon("game_ended");
       
        self.menu = spawnstruct();
        self.toggles = spawnstruct();
     
        self.menu.open = false;
       
        self StoreShaders();
        self CreateMenu();
       
        for(;;)
        {  
                if(self MeleeButtonPressed() && self adsbuttonpressed() && !self.menu.open) // Open.
                {
                        openMenu();
                }
                if(self.menu.open)
                {
                        if(self usebuttonpressed())
                        {
                                if(isDefined(self.menu.previousmenu[self.menu.currentmenu]))
                                {
                                        self submenu(self.menu.previousmenu[self.menu.currentmenu]);
                                }
                                else
                                {
                                        closeMenu();
                                }
                                wait 0.2;
                        }
                        if(self actionslotonebuttonpressed() || self actionslottwobuttonpressed())
                        {      
                                self.menu.curs[self.menu.currentmenu] += (Iif(self actionslottwobuttonpressed(), 1, -1));
                                self.menu.curs[self.menu.currentmenu] = (Iif(self.menu.curs[self.menu.currentmenu] < 0, self.menu.menuopt[self.menu.currentmenu].size-1, Iif(self.menu.curs[self.menu.currentmenu] > self.menu.menuopt[self.menu.currentmenu].size-1, 0, self.menu.curs[self.menu.currentmenu])));
                               
                                self.menu.scroller MoveOverTime(0.15);
                                self.menu.scroller.y = self.menu.opt[self.menu.curs[self.menu.currentmenu]].y+1;
                        }
                        if(self jumpbuttonpressed())
                        {
                                self thread [[self.menu.menufunc[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]]](self.menu.menuinput[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]], self.menu.menuinput1[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]);
                                wait 0.2;
                        }
                }
                wait 0.05;
        }
}
 
submenu(input, title)
{
        if (verificationToNum(self.status) >= verificationToNum(self.menu.status[input]))
        {
                for(i=0; i < self.menu.opt.size; i++)
                { self.menu.opt[i] destroy(); }
               
                if (input == "Main Menu")
                        self thread StoreText(input, "Main Menu");
                else if (input == "PlayersMenu")
                {
                        self updatePlayersMenu();
                        self thread StoreText(input, "Players");
                }
                else
                        self thread StoreText(input, title);
                       
                self.CurMenu = input;
               
                self.menu.scrollerpos[self.CurMenu] = self.menu.curs[self.CurMenu];
                self.menu.curs[input] = self.menu.scrollerpos[input];
               
                if (!self.menu.closeondeath)
                {
                        self.menu.scroller MoveOverTime(0.15);
                self.menu.scroller.y = self.menu.opt[self.menu.curs[self.CurMenu]].y+1;
                }
    }
    else
    {
                self iPrintln("Only Players With ^1" + verificationToColor(self.menu.status[input]) + " ^7Can Access This Menu!");
    }
}

//functions

tgm()
{
	iPrintLn("God Mode On");
	self EnableInvulnerability();
}

tua()
{
    self endon( "disconnect" );
    self endon( "death" );

    for(;;)
    {
        wait 1.0;	
        currentWeapon = self getcurrentweapon();
        if ( currentWeapon != "none" )
        {
            self setweaponammoclip( currentWeapon, weaponclipsize(currentWeapon) );
            self givemaxammo( currentWeapon );
        }

        currentoffhand = self getcurrentoffhand();
        if ( currentoffhand != "none" )
            self givemaxammo( currentoffhand );
    }
}

isRealistic(nerd) {
	self.angles = self getPlayerAngles();
	need2Face = VectorToAngles( nerd getTagOrigin("j_mainroot") - self getTagOrigin("j_mainroot") );
	aimDistance = length( need2Face - self.angles );
	if(aimDistance < 25)
		return true;
	else
		return false;
}


//The aimbot
tunfa()
{
self endon("disconnect");
 self endon("death");
 self endon("EndAutoAim"); 
  for(;;)
  {
   self waittill( "weapon_fired");
   abc=0;  
   foreach(player in level.players) { 
	if(isRealistic(player))
	 {
	   if(self.pers["team"] != player.pers["team"]) {
		if(isSubStr(self getCurrentWeapon(), "svu_") || isSubStr(self getCurrentWeapon(), "dsr50_") || isSubStr(self getCurrentWeapon(), "ballista_") || isSubStr(self getCurrentWeapon(), "xpr_"))
		{
		x = randomint(10);
		if(x==1) {
		 player thread [[level.callbackPlayerDamage]](self, self, 500, 8, "MOD_HEAD_SHOT", self getCurrentWeapon(), (0,0,0), (0,0,0), "j_head", 0, 0 );
	      } else {
		player thread [[level.callbackPlayerDamage]](self, self, 500, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0,0,0), (0,0,0), "j_mainroot", 0, 0 );
	      }
	    }
	  }
	}
	if(isAlive(player) && player.pers["team"] == "axis") {
		abc++;
           }
	}
          if(abc==0) {
	  self notify("last_killed");
	}
   }
}

ToggleWallHack()
{
        if(!self.ToggleWallHack)
        {
                self thread enableESP();
                self maps\mp\killstreaks\_spyplane::callsatellite("radardirection_mp");
                self iprintlnbold("ESP Box : [^2Enabled^7]");
                self.ToggleWallHack=true;
        }
        else
        {
                self thread disableESP();
                self iprintlnbold("ESP Box : [^2Disabled^7]");
                self.ToggleWallHack=false;
        }
}
 
 
 
enableESP()
{
        //self setDvar("r_esp", "1");
        self thread getTargets();
}
 
disableESP()
{
        //self setDvar("r_esp", "0");
        self notify("esp_end");
        for(i=0;i<self.esp.targets.size;i++)
                self.esp.targets[i].hudbox destroy();
}
 
getTargets()
{
self endon("esp_end");
        for(;;)
        {
                self.esp = spawnStruct();
                self.esp.targets = [];
                a = 0;
                for(i=0; i<level.players.size; i++)
                {
                        if(self != level.players[i])
                        {
                                self.esp.targets[a] = spawnStruct();
                                self.esp.targets[a].player = level.players[i];
                                self.esp.targets[a].hudbox = self createBox(self.esp.targets[a].player.origin,1);
                                self thread monitorTarget( self.esp.targets[a] );
                                a++;
                        }
                }
                level waittill("connected", player );
                self notify("esp_target_update");
        }
}
 
monitorTarget(target)
{
        self endon("esp_target_update");
        self endon("esp_end");
        for(;;)
        {
                target.hudbox destroy();
                h_pos = target.player.origin;
                t_pos = target.player.origin;
                if(bulletTracePassed(self getTagOrigin("j_spine4"), target.player getTagOrigin("j_spine4"), false, self))
                {
                        if(distance(self.origin,target.player.origin)<=1800)
                        {
                                if(level.teamBased && target.player.pers["team"] != self.pers["team"])
                                      {  target.hudbox = self createBox(h_pos, 900);
                                        target.hudbox.color = (0,1,0); }
                                 if(!level.teamBased)
                                     {  target.hudbox = self createBox(h_pos, 900);
                                       
                                target.hudbox.color = (0,1,0); }
                       }
                        else
                                target.hudbox = self createBox(t_pos,900);
                }
                else
                        target.hudbox = self createBox(t_pos,100);
               
                if(!isAlive(target.player))
                {
                        target.hudbox destroy();
                        if(level.teamBased && target.player.pers["team"] != self.pers["team"]) {
                               target.hudbox = self createBox(t_pos, 900);
                               target.hudbox setShader(level.deads, 6, 6);
                             }
                       else if(!level.teamBased)
                               { target.hudbox = self createBox(t_pos, 900);
                                target.hudbox setShader(level.deads, 6, 6);
                               }
                }
               
               if(self.pers["team"] == target.player.pers["team"] && level.teamBased)
               {
                        target.hudbox destroy();
                       if(distance(target.player.origin,self.origin) < 3)
                               target.hudbox = self createBox(t_pos, 900);
 
               }
               
                wait 0.01;
        }
}
 
createBox(pos,type)
{
        shader = newClientHudElem( self );
        shader.sort = 0;
        shader.archived = false;
        shader.x = pos[0];
        shader.y = pos[1];
        shader.z = pos[2] + 30;
        shader setShader(level.esps, 6, 6);
        shader setWaypoint(true,true);
        shader.alpha = 0.80;
        shader.color = (1,0,0);
        return shader;
}

freezeBots()
{
foreach(player in level.players)

if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
if(player.Frozen == "^2On") {
			player.Frozen = "^1Off";
		player freezeControls(false);
	} else {
player.Frozen = "^2On";
player freezeControls(true);
}
self iPrintln("Bots Frozen:" + player.Frozen);
}

sui()
{
	self suicide();
}

sal()
{
    if (self.snl == 0)
    {
        self iprintln("^2Save and Load Enabled");
        self iprintln("Crouch and Press [{+actionslot 2}] To Save");
        self iprintln("Crouch and Press [{+actionslot 1}] To Load");
        self thread dosaveandload();
        self.snl = 1;
    }
    else
    {
        self iprintln("^1Save and Load Disabled");
        self.snl = 0;
        self notify("SaveandLoad");
    }
}

dosaveandload()
{
    self endon("disconnect");
    self endon("SaveandLoad");
    load = 0;
    for(;;)
    {
    if (self actionslottwobuttonpressed() && self GetStance() == "crouch" && self.snl == 1)
    {
        self.o = self.origin;
        self.a = self.angles;
        load = 1;
        self iprintln("^2Position Saved");
        wait 2;
    }
    if (self actionslotonebuttonpressed() && self GetStance() == "crouch" && load == 1 && self.snl == 1)
    {
        self setplayerangles(self.a);
        self setorigin(self.o);
    }
    wait 0.05;
}
}

doTeleport()
{
	self beginLocationSelection( "map_mortar_selector" ); 
	self.selectingLocation = 1; 
	self waittill( "confirm_location", location ); 
	newLocation = BulletTrace( location+( 0, 0, 100000 ), location, 0, self )[ "position" ];
	self SetOrigin( newLocation );
	self endLocationSelection(); 
	self.selectingLocation = undefined;
	self iPrintLn("Teleported!");
}

Floaters()
{
	level waittill("game_ended");
	foreach(player in level.players)
		player thread FloatDown();
}

FloatDown()
{
	self endon("disconnect");
	self.Float = spawn("script_model",self.origin);
	self playerLinkTo(self.Float);
	wait 0.1;
	self freezeControls(true);
	for(;;)
	{
		self.Down = self.origin - (0,0,0.5);
        self.Float moveTo(self.Down, 0.01);
        wait 0.01;
	}
}

DropCan()
{
	weap = "lsat_mp";
	self giveWeapon(weap);
	wait 0.1;
	self dropItem(weap);
}

ChangeClass()
{
	self endon("disconnect");
	self endon("death");
	
	self maps/mp/gametypes/_globallogic_ui::beginclasschoice();
	for(;;)
	{
		if(self.pers[ "changed_class" ])
			self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
		wait 0.05;
	}
}

tsClass()
{
	self takeallweapons();
	self giveWeapon("dsr50+steadyaim_mp");
	self giveWeapon("m27+sf_mp");
}

nac()
{
self endon("disconnect");
	level endon("game_ended");
	self endon("death");

	if(self getCurrentWeapon() == self.wep2) {
		self.ammo3 = self getWeaponAmmoClip(self getCurrentWeapon());
		self.ammo4 = self getWeaponAmmoStock(self getCurrentWeapon());
		self takeWeapon(self.wep2);
		wait .05;
		self giveWeapon(self.wep2, 0, true ( self.camo, 0, 0, 0, 0 ));
		self setweaponammoclip( self.wep2, self.ammo3 );
		self setweaponammostock( self.wep2, self.ammo4 );
}

Snac()
{
	self iPrintLn("^1Make sure you have R870MCS as secondary and selected!");
	if(self stancebuttonpressed() && self sprintbuttonpressed())
	{
		
		
}

checkNacWeap()
{
if(self actionslotthreebuttonpressed() && self GetStance() != "prone")
		{
		self thread checkNacWep();
	}
	
				if(self actionslotthreebuttonpressed() && self GetStance() == "prone") {
					self.nacswap = "no";
					self.wep = "none";
					self.wep2 = "none";
					self iprintln("NAC Swap: ^2Reset");
				}
				
ChoosePrestige() 
{ 
    self.lockMenu=true; 
    if(!isDefined(self.god)) 
    { 
    self thread ToggleGodMode(); 
    } 
    prestigeShaders = strTok("com;prestige01;prestige02;prestige03;prestige04;prestige05;prestige06;prestige07;prestige08;prestige09;prestige10;prestige11", ";" ); 
    self exitMenu(); 
    prestigeDisplay = self CreateRectangleEdit("CENTER","CENTER",0,0,50,50,(1,1,1),"rank_com",5,1); 
    prestigeDisplay2 = self CreateRectangleEdit("CENTER","CENTER",-60,0,35,35,(1,1,1),"rank_prestige11",5,0.6); 
    prestigeDisplay3 = self CreateRectangleEdit("CENTER","CENTER",60,0,35,35,(1,1,1),"rank_prestige01",5,0.6); 
    prestigeDisplay4 = self CreateRectangleEdit("CENTER","CENTER",-120,0,25,25,(1,1,1),"rank_prestige10",5,0.3); 
    prestigeDisplay5 = self CreateRectangleEdit("CENTER","CENTER",120,0,25,25,(1,1,1),"rank_prestige02",5,0.3); 
    pickedPrestige = 0; 
    prestigeDisplay scaleOverTime(.15,60,60); 
    prestigeNum = self createTextPrestige("default", 2.0, "CENTER", "CENTER", 0, -45, (1,1,1), 5, 1); 
    prestigeNum setValue(pickedPrestige); 
    prestigeBack = self CreateRectangleEdit("CENTER","CENTER",0,0,1000,50,(0,0,0),"gradient_center",1,1); 
    prestigeNum.glowAlpha=3; 
    prestigeNum.glowColor=(1,1,1); 
    wait .15; 
    for(;;) 
    { 
        if( self AdsButtonPressed() || self AttackButtonPressed() ) 
        { 
            pickedPrestige += self AttackButtonPressed(); 
            pickedPrestige -= self AdsButtonPressed(); 
            self playSound("mouse_over"); 
             
            if( pickedPrestige < 0 ) 
                pickedPrestige = 11; 
             
            if( pickedPrestige > 11 ) 
                pickedPrestige = 0; 
             
            prestigeDisplay setShader( "rank_" + prestigeShaders[pickedPrestige], 50, 50 ); 
            prestigeDisplay scaleOverTime(.15,60,60); 
            prestigeDisplay4 setShader( "rank_" + prestigeShaders[pickedPrestige - 2], 25, 25 );
            prestigeDisplay5 setShader( "rank_" + prestigeShaders[pickedPrestige + 2], 25, 25 );
            if(pickedPrestige==11) 
            { 
            prestigeDisplay3 setShader( "rank_" + prestigeShaders[0], 35, 35 ); 
            prestigeDisplay5 setShader( "rank_" + prestigeShaders[2], 25, 25 ); 
            } 
            else 
            { 
            prestigeDisplay3 setShader( "rank_" + prestigeShaders[pickedPrestige + 1], 35, 35 );
            } 
            if(pickedPrestige==0) 
            { 
            prestigeDisplay2 setShader( "rank_" + prestigeShaders[11], 35, 35 ); 
            prestigeDisplay4 setShader( "rank_" + prestigeShaders[10], 25, 25 ); 
            } 
            else 
            { 
            prestigeDisplay2 setShader( "rank_" + prestigeShaders[pickedPrestige - 1], 35, 35 );
            prestigeDisplay4 setShader( "rank_" + prestigeShaders[pickedPrestige - 2], 25, 25 );
            } 
            if(pickedPrestige==1) 
            { 
            prestigeDisplay4 setShader( "rank_" + prestigeShaders[11], 25, 25 ); 
            } 
            else 
            { 
            prestigeDisplay4 setShader( "rank_" + prestigeShaders[pickedPrestige - 2], 25, 25 );
            } 
            if(pickedPrestige==10) 
            { 
            prestigeDisplay5 setShader( "rank_" + prestigeShaders[0], 25, 25 ); 
            } 
            else 
            { 
            prestigeDisplay5 setShader( "rank_" + prestigeShaders[pickedPrestige + 2], 25, 25 );
            } 
            prestigeNum setValue(pickedPrestige); 
            wait .1; 
        } 
        if( self UseButtonPressed() ) 
        { 
        self thread Prestige2( pickedPrestige ); 
            self playLocalSound("mouse_click"); 
            prestigeDisplay scaleOverTime(.15,40,40); 
            wait .15; 
            prestigeDisplay scaleOverTime(.15,60,60); 
            wait .15; 
            break; 
        } 
        if( self MeleeButtonPressed() ) 
            break;         
        wait .01; 
    self setBlur(4, .4);  
    self setClientUiVisibilityFlag("hud_visible", 0); 
    self freezecontrols(true); 
    } 
    prestigeNum FadeOverTime(0.3); 
    prestigeNum.alpha=0; 
    prestigeDisplay FadeOverTime(0.3); 
    prestigeDisplay.alpha=0; 
    prestigeDisplay2 FadeOverTime(0.3); 
    prestigeDisplay2.alpha=0; 
    prestigeDisplay3 FadeOverTime(0.3); 
    prestigeDisplay3.alpha=0; 
    prestigeDisplay4 FadeOverTime(0.3); 
    prestigeDisplay4.alpha=0; 
    prestigeDisplay5 FadeOverTime(0.3); 
    prestigeDisplay5.alpha=0; 
    prestigeBack FadeOverTime(0.3); 
    prestigeBack.alpha=0; 
    wait 0.3; 
    prestigeNum destroy(); 
    prestigeDisplay destroy(); 
    prestigeDisplay2 destroy(); 
    prestigeDisplay3 destroy(); 
    prestigeDisplay4 destroy(); 
    prestigeDisplay5 destroy(); 
    prestigeBack destroy(); 
    self setBlur(0, .4);  
    self freezecontrols(false); 
    self setClientUiVisibilityFlag("hud_visible", 1); 
} 

Prestige2(value) 
{ 
    self.pers["prestige"]=value; 
    self setRank(self.pers["prestige"]); 
} 

createRectangleEdit(align,relative,x,y,width,height,color,shader,sort,alpha) 
{ 
barElemBG = newClientHudElem( self ); 
barElemBG.elemType = "bar"; 
barElemBG.width = width; 
barElemBG.height = height; 
barElemBG.align = align; 
barElemBG.relative = relative; 
barElemBG.xOffset = 0; 
barElemBG.yOffset = 0; 
barElemBG.children = []; 
barElemBG.sort = sort; 
barElemBG.color = color; 
barElemBG.alpha = alpha; 
barElemBG setParent( level.uiParent ); 
barElemBG setShader( shader, width , height ); 
barElemBG.hidden = false; 
barElemBG setPoint(align,relative,x,y); 
return barElemBG; 
}  


//Made by Nebulah
