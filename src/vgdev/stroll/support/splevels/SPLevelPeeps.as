package vgdev.stroll.support.splevels 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	import vgdev.stroll.props.enemies.EnemyPeeps;
	import vgdev.stroll.props.enemies.InternalFire;
	import vgdev.stroll.support.SoundManager;
	import vgdev.stroll.System;
	
	/**
	 * Helper for TAILS and for after Peeps dies
	 * @author Alexander Huynh
	 */
	public class SPLevelPeeps extends ABST_SPLevel 
	{
		private var levelState:int = 0;				// state machine helper
		private var boss:EnemyPeeps;
		
		private var elapseFlag:Boolean = true;
		
		private var consoleSlip:ConsoleSlipdrive;
		private var consoleState:int = 0;		// for after boss fight
		private var tailsState:int = 0;
		
		private var firstTP:Boolean = true;
		private var camCounter:int = 0;
		private var poi:Point;
		
		public function SPLevelPeeps(_cg:ContainerGame) 
		{
			super(_cg);
			consoleSlip = cg.game.mc_ship.mc_console_slipdrive.parentClass;
			consoleSlip.forceOverride = true;
			cg.ship.setBossOverride(true);
		}
		
		override public function step():void 
		{
			super.step();
			
			switch (levelState)
			{
				case 0:
					if (framesElapsed == (System.SECOND * 3))		// spawn boss
					{
						boss = new EnemyPeeps(cg, new SWC_Enemy(), {} );
						cg.addToGame(boss, System.M_ENEMY);
						cg.bossBar.startFight(boss);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 1:
					if (framesElapsed == (System.SECOND * 9))
							cg.tails.show("Hey! Hit both of those small eyes at the same time!", System.TAILS_NORMAL);
					if (boss.justTeleported)
					{
						boss.justTeleported = false;
						poi = new Point(boss.mc_object.x * .5, boss.mc_object.y * .3);
						camCounter = System.getRandInt(40, 80);
						if (firstTP)
						{
							firstTP = false;
							cg.tails.show("It teleported? Hold on, I'll adjust the sensors!", System.TAILS_NORMAL);
						}
						else
							cg.tails.show(System.getRandFrom(["Adjusting our sensors! Standby!",
														  "It teleported! I'll move the sensors!",
														  "Gimme a sec; I'll find him again!"
									]), System.TAILS_NORMAL);	
					}
					if (boss.firstIncap == 1)
					{
						boss.firstIncap = 2;
						cg.tails.show("Awrk! Shoot the big eye! Shoot the big eye!", System.TAILS_NORMAL);
					}
					if (camCounter > 0 && --camCounter == 0)
					{
						if (poi != null)
							cg.camera.setCameraFocus(poi);
						poi = null;
					}
					if (boss.getHP() == 0 && boss.mc_object == null)		// wait for true death
					{
						boss = null;
						elapseFlag = true;
						cg.managerMap[System.M_ENEMY].killAll();			// kill all adds
						cg.managerMap[System.M_EPROJECTILE].killAll();		// kill all enemy projectiles
						consoleSlip.forceOverride = false;
						cg.ship.setBossOverride(false);
						cg.ship.slipRange = 1;
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 2:
					switch (framesElapsed)
					{
						case System.SECOND * 6:		// boss defeated
							cg.tails.show("No more threats detected. Great work!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 12:	// boss defeated
							cg.tails.show("Alright, we're 33% of the way there. Let's keep going!", System.TAILS_NORMAL);
							levelState = 99;
						break;
					}
				break;
				case 3:		// activate Omnitool and other consoles
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Uhh, alright, don't panic!\nI'll deploy the ship's Omnitools and activate a few more consoles.\n\n" +
									  "Use the Omnitool to help your friend up, quickly!");		  
						cg.tails.showNew = true;
						cg.tails.tutorialMode = true;
						cg.camera.setCameraFocus(new Point(0, -100));
						
						// unlock the new consoles
						cg.game.mc_ship.mc_console_shield.parentClass.setLocked(false);
						cg.game.mc_ship.mc_console_sensors.parentClass.setLocked(false);
						cg.game.mc_ship.item_fe_0.parentClass.setLocked(false);
						cg.game.mc_ship.item_fe_1.parentClass.setLocked(false);
						
						// upgrade turrets
						cg.upgradeTurrets(1);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 4:
					// revival check
					if (cg.players[0].getHP() > 0 && cg.players[1].getHP() > 0)
					{
						consoleSlip.forceOverride = false;
						cg.tails.show("That was close. OK, Let's jump to the next sector!", System.TAILS_NORMAL);
						levelState = 99;
					}
					if (framesElapsed == System.SECOND * 7)
						cg.tails.show("Hey, help your friend up with an Omnitool!", System.TAILS_NORMAL);
					else if (framesElapsed == System.SECOND * 7 && framesElapsed % (System.SECOND * 15) == 0)
					{
						switch (tailsState)
						{
							case 0:
								cg.tails.show("Hold the button down with the Omnitool to revive!", System.TAILS_NORMAL);
							break;
							case 1:
								cg.tails.show("Are you gonna revive your friend?", System.TAILS_NORMAL);
							break;
							case 2:
								cg.tails.show("C'mon, help up your friend already...", System.TAILS_NORMAL);
							break;
							case 3:
								cg.tails.show("Just remember, I *DO* control the ship's O2...", System.TAILS_NORMAL);
							break;
						}
						tailsState = (tailsState + 1) % 4;
					}
				break;
				case 10:
					// fires put out check
					if (cg.managerMap[System.M_FIRE].numObjects() == 0)
					{
						consoleSlip.forceOverride = false;
						cg.tails.show("Crisis averted! Use the Omnitool to heal stuff, too.", System.TAILS_NORMAL);
						levelState = 99;
					}
				break;
			}
			
			// player tries to use the Slipdrive
			if (consoleSlip.getIfSpooling())
			{
				switch (consoleState++)
				{
					case 0:		// incapacitate player
						consoleSlip.closestPlayer.mc_object.x += 20;
						consoleSlip.closestPlayer.changeHP( -9999);
						consoleSlip.changeHP( -250);
						consoleSlip.forceOverride = true;
						addSparks(consoleSlip.mc_object);
						SoundManager.playSFX("sfx_electricShock");
						cg.tails.show("Whoa! An electric overflow; watch out!", System.TAILS_NORMAL);
						framesElapsed = 0;
						levelState = 3;
					break;
					case 1:		// ignite a fire
						consoleSlip.forceOverride = true;
						addSparks(consoleSlip.mc_object);
						SoundManager.playSFX("sfx_electricShock");
						var spawns:Array = [[0, 0], [17, 5]];
						for (var f:int = 0; f < 2; f++)
						{
							cg.addToGame(new InternalFire(cg, new SWC_Decor(),
													new Point(consoleSlip.mc_object.x + spawns[f][0], consoleSlip.mc_object.y + spawns[f][1]),
													cg.shipInsideMask),
										System.M_FIRE);
						}
						cg.tails.show("Eek! Fire! Quick, use the Omnitool before it spreads!", int(System.TAILS_NORMAL * 1.5));
						framesElapsed = 0;
						levelState = 10;
					break;
				}
			}
		}
		
		private function addSparks(loc:MovieClip):void
		{
			for (var i:int = 0; i < 5; i++)
				cg.addDecor("electricSparks", {
						"x": System.getRandNum(loc.x - 50, loc.x + 50),
						"y": System.getRandNum(loc.y - 50, loc.y + 50),
						"dr": System.getRandNum( -40, 40),
						"rot": System.getRandNum(0, 360),
						"scale": System.getRandNum(.7, 1.5)
				});
		}
	}
}
