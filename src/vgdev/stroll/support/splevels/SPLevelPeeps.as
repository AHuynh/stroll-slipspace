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
		private var boss:ABST_Enemy;
		
		private var elapseFlag:Boolean = true;
		
		private var consoleSlip:ConsoleSlipdrive;
		private var consoleState:int = 0;		// for after boss fight
		private var tailsState:int = 0;
		
		public function SPLevelPeeps(_cg:ContainerGame) 
		{
			super(_cg);
			consoleSlip = cg.game.mc_ship.mc_console_slipdrive.parentClass;
			consoleSlip.forceOverride = true;
			cg.ship.setBossOverride(true);
		}
		
		override public function step():void 
		{			
			// boss
			if (boss != null)
			{
				if (boss.getHP() == 0)
				{
					boss = null;
					elapseFlag = true;
					cg.managerMap[System.M_ENEMY].killAll();			// kill all adds
					cg.managerMap[System.M_EPROJECTILE].killAll();		// kill all enemy projectiles
					consoleSlip.forceOverride = false;
					cg.ship.setBossOverride(false);
					cg.ship.slipRange = 1;
				}
				return;
			}
	
			if (elapseFlag)
			{
				framesElapsed++;
			
				switch (framesElapsed)
				{
					case System.SECOND * 3:		// spawn boss
						boss = new EnemyPeeps(cg, new SWC_Enemy(), {} );
						cg.addToGame(boss, System.M_ENEMY);
						cg.bossBar.startFight(boss);
						elapseFlag = false;
					break;
					case System.SECOND * 6:		// boss defeated
						cg.tails.show("No more threats detected. Great work!", System.TAILS_NORMAL);
					break;
					case System.SECOND * 12:	// boss defeated
						cg.tails.show("Alright, we're 33% of the way there. Let's keep going!", System.TAILS_NORMAL);
						elapseFlag = false;
					break;
					case System.SECOND * 18:	// activate Omnitool and other consoles
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
					break;
					case System.SECOND * 26:
						cg.tails.show("Hey, help your friend up with an Omnitool!", System.TAILS_NORMAL);
					break;
					case System.SECOND * 38:
						framesElapsed = System.SECOND * 26 + 1;
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
					break;
				}
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
						framesElapsed = Math.max(framesElapsed, System.SECOND * 12 + 1);
						elapseFlag = true;
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
						framesElapsed = System.SECOND * 44;
					break;
				}
			}
			
			// revival check
			if (framesElapsed >= System.SECOND * 18 && framesElapsed <= System.SECOND * 38)
			{
				if (cg.players[0].getHP() > 0 && cg.players[1].getHP() > 0)
				{
					consoleSlip.forceOverride = false;
					cg.tails.show("That was close. OK, Let's jump to the next sector!", System.TAILS_NORMAL);
					framesElapsed = Math.max(framesElapsed, System.SECOND * 43);
					elapseFlag = false;
				}
			}
			// fires put out check
			else if (framesElapsed >= System.SECOND * 44 && framesElapsed <= System.SECOND * 45 && cg.managerMap[System.M_FIRE].numObjects() == 0)
			{
				consoleSlip.forceOverride = false;
				cg.tails.show("Crisis averted! Use the Omnitool to repair stuff, too.", System.TAILS_NORMAL);
				framesElapsed = System.SECOND * 99;
				elapseFlag = false;
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
