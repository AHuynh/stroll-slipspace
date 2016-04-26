package vgdev.stroll.support.splevels 
{
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleNavigation;
	import vgdev.stroll.props.consoles.ConsoleSensors;
	import vgdev.stroll.props.consoles.ConsoleShieldRe;
	import vgdev.stroll.props.consoles.ConsoleShields;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.consoles.ConsoleTurret;
	import vgdev.stroll.props.consoles.Omnitool;
	import vgdev.stroll.props.Decor;
	import vgdev.stroll.props.enemies.BoarderWanderer;
	import vgdev.stroll.props.enemies.EnemyGeometricAnomaly;
	import vgdev.stroll.props.enemies.EnemySkull;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	import vgdev.stroll.props.consoles.ConsoleFAILS;
	
	/**
	 * Sector 8 boss
	 * @author Alexander Huynh
	 */
	public class SPLevelFAILS extends ABST_SPLevel 
	{
		private var levelState:int = 0;		// state machine helper
		private var consoleSlip:ConsoleSlipdrive;
		
		public function SPLevelFAILS(_cg:ContainerGame) 
		{
			super(_cg);
			
			consoleSlip = cg.game.mc_ship.mc_console_slipdrive.parentClass;
			consoleSlip.forceOverride = true;
			cg.ship.setBossOverride(true);
			
			// DEBUG CODE			
			//levelState = 2;
			//framesElapsed = 20 * 30;
			/*consoleSlip.setArrowDifficulty(12);
			cg.ship.setBossOverride(false);
			cg.ship.slipRange = 0.5;
			cg.ship.jammable = 0;
			consoleSlip.forceOverride = false;*/
			/*var corr:int = 6;
			for each (var c:ABST_Console in cg.consoles)
			{
				if (--corr <= 0)
					break;
				c.setCorrupt(true);
			}*/
			// DEBUG CODE
		}
		
		override public function step():void 
		{
			super.step();
			
			var c:ABST_Console;
			
			switch (levelState)
			{
				case 0:		// pre-FAILS, spawn enemies
					if (framesElapsed == System.SECOND * 4)
					{
						var fakeBoss:EnemySkull = cg.addToGame(new EnemySkull(cg, new SWC_Enemy(), {
																			"attackColor": System.COL_RED,
																			"attackStrength": 30,
																			"hp": 50,
																			"scale": 2
																			}),
												  System.M_ENEMY) as EnemySkull;
						fakeBoss.setAttribute("spd", 12);
						fakeBoss.setAttribute("cooldowns", [30]);		// double fire rate
						fakeBoss.projSizeMult = 2;
						cg.bossBar.startFight(fakeBoss);
						levelState++;
					}
				break;
				case 1:		// eliminate all enemies
					if (!cg.managerMap[System.M_ENEMY].hasObjects() && !cg.managerMap[System.M_FIRE].hasObjects())
					{
						cg.tails.show("Oh, that wasn't too bad. Good job, both of you!", System.TAILS_NORMAL);
						SoundManager.crossFadeBGM("bgm_calm", System.VOL_BGM);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 2:		// make things go wrong
					switch (framesElapsed)
					{
						case System.SECOND * 7:
							cg.tails.show("Wait a minute?! Watch out!", System.SECOND * 3);
							spawnParticles();
							cg.serious = true;
						break;
						case System.SECOND * 13:
							cg.tails.show("I do-NNT th_NK t^@5 i$ nORMA|_? NULLPTR@0x3FE102", System.SECOND * 3);
							spawnParticles();
						break;
						case System.SECOND * 17:
							cg.tails.show("NO THATS NOT RIGHT?? LOGICAL ERROR REF#5920?!", System.SECOND * .6);
							spawnParticles();
							cg.visualEffects.applyModuleDistortion(0, false, 0);
							cg.visualEffects.applyModuleDistortion(1, false, 0);
							cg.visualEffects.applyBGDistortion(true, "bg_squares");
						break;
						case System.SECOND * 18:
							cg.tails.show("POR favOr c0nsult3 LE MANUEL del usu4Rio___", System.SECOND * .6);
						break;
						case System.SECOND * 19:
							cg.tails.show("for i in range(len(arr)): print arr2[i*2] #TODO!??", System.SECOND * .6);
						break;
						case System.SECOND * 20:
							cg.tails.show("01000010 01100001 01100100 --- NOT FEELING UP TO IT", System.SECOND * .6);
							SoundManager.crossFadeBGM(null, System.VOL_BGM);
						break;
						case System.SECOND * 21:
							cg.tails.show("USER LOCKOUT - ALL SYSTEMS CORRUPTED", System.SECOND * .6);				// corrupt all modules					
							for each (c in cg.consoles)
								c.setCorrupt(true);
							if (cg.shipName == "Kingfisher")				// give a free module so # corrupted is 9
								cg.consoles[3].setCorrupt(false);
							cg.camera.setCameraFocus(new Point(0, 20));
						break;
						case System.SECOND * 22:
							cg.tails.show("Infinite loop detected. ^C Infinite loop detected. ^C", System.SECOND * .6);
						break;
						case System.SECOND * 23:
							cg.tails.show("@*REF!? imsorryGEIOJ% REF!REF!EOLNULEOLforgivemeNULREF!", System.SECOND * 3);
							spawnParticles();
						break;
						case System.SECOND * 24:
							SoundManager.crossFadeBGM("bgm_FAILS", System.VOL_BGM);
						break;
						case System.SECOND * 29:
							cg.tails.show("Actually, you know what? This is dumb. You two are dumb. Why do I have to waste my time helping YOU?\n\n" +
										  "It's time to DIE in the VOID, sapient featherbags! ", 0, "FAILS_talk");
							cg.visualEffects.applyModuleDistortion(0, true);
							cg.visualEffects.applyModuleDistortion(1, true);
							cg.visualEffects.applyBGDistortion(false);
							cg.serious = false;
							framesElapsed = 0;
							levelState = 10;
							cg.gameOverAnnouncer = "FAILS";
						break;
					}
					
					if (framesElapsed > System.SECOND * 9 && framesElapsed< System.SECOND * 27 && framesElapsed % 10 == 0)
					{
						cg.addSparks(2);
						cg.camera.setShake(5);
						var pos:Point = cg.getRandomNearLocation();
						var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":pos.x, "y":pos.y, "scale":System.getRandNum(0.25, 3) } );
						spawnFX.mc_object.base.setTint(System.COL_RED);
						SoundManager.playSFX("sfx_electricShock", .25);
					}
				break;
				
			case 10:	// battle start! fix 1
					if (framesElapsed == 1)
					{
						cg.bossBar.startFight();
						cg.alerts.isCorrupt = true;
					}
					if (framesElapsed == System.SECOND * 4)
					{
						cg.tails.show("You'll NEVER be able to format ALL the ship's systems!", System.TAILS_NORMAL, "FAILS_idle");				
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 16 && framesElapsed % (System.SECOND * 16) == 0)
						cg.tails.show(System.getRandFrom(["I bet you can't even figure out how to fix ONE!",
														  "What's wrong? Don't know what you're supposed to do?",
														  "Try fixing a system. I DARE you.",
														  "I bet a plant is smarter than both of you combined!",
														  "How should I finish you both off? Hmmm..."
									]), System.TAILS_NORMAL, "FAILS_talk");				
					if (ABST_Console.numCorrupted == 8)
					{
						cg.camera.setShake(20);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(8 / 9);
						cg.tails.show("You fixed a system? You must be SO proud of yourself...", System.TAILS_NORMAL, "FAILS_pissed");	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 11:	// allow 1 more fix, spawn enemies
					if (framesElapsed == System.SECOND * 6)
						cg.tails.show("Mind if I invite friends? WELL, I'M DOING IT ANYWAY!", System.TAILS_NORMAL, "FAILS_idle");	
					else if (framesElapsed == System.SECOND * 7)
					{			
						spawnEnemy("Slime", 2);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 12:	// fix 2, taunt
					if (framesElapsed == System.SECOND * 7)
					{
						cg.tails.show("Not so tough without ME helping, now ARE YOU?!", System.TAILS_NORMAL, "FAILS_talk");
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 15 && framesElapsed % (System.SECOND * 20) == 5)
						cg.tails.show(System.getRandFrom(["Cry all you want! I'm not gonna help!",
														  "What's the matter? Are you dying? WELL, TOO BAD!",	
														  "This STUPID O2 encryption needs to GO AWAY!",
														  "Yes, keep running around! This AMUSES ME!"
									]), System.TAILS_NORMAL, "FAILS_talk");	
					if (ABST_Console.numCorrupted == 7)
					{
						cg.camera.setShake(20);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(7 / 9);
						cg.tails.show("Fixed another one, did you?", System.TAILS_NORMAL, "FAILS_pissed");	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 13:	// allow 1 more fix, spawn fires
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("How about some FIRE? ROAST CHICKEN COMING RIGHT UP!", System.TAILS_NORMAL, "FAILS_idle");
						cg.addSparks(3);
						SoundManager.playSFX("sfx_electricShock");
					}
					else if (framesElapsed == int(System.SECOND * 6.2))
					{			
						cg.addFires(4);
						framesElapsed = 0;
						levelState = 20;
					}
				break;
				case 20:	// fix 3, adds, taunt
					switch (framesElapsed)
					{
						case System.SECOND * 14:
							cg.tails.show("Are you having FUN yet? Because I SURE AM!", System.TAILS_NORMAL, "FAILS_idle");
							for each (c in cg.consoles)
								c.setReadyToFormat(true);
						break;
						case System.SECOND * 18:
							spawnEnemy("Skull", 1);
						break;
						case System.SECOND * 26:
							spawnEnemy("Slime", 1);
						break;
						case System.SECOND * 34:
							cg.tails.show("No, please, take your time! I'm in no rush!", System.TAILS_NORMAL, "FAILS_idle");
							cg.addSparks(3);
							SoundManager.playSFX("sfx_electricShock");
							cg.addFires(2);
						break;
						case System.SECOND * 46:
							spawnEnemy("Skull", 1);
						break;
					}
					if (framesElapsed >= System.SECOND * 50 && framesElapsed % (System.SECOND * 16) == 0)
					{
						spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime"]), 1);
						cg.tails.show(System.getRandFrom(["I'll broadcast our location EVEN LOUDER!",
														  "More friends to PLAY WITH! JOY!",	
														  "Hey, there! Come right in and do some KILLING!"
														  ]), System.TAILS_NORMAL, "FAILS_idle");
					}
					if (ABST_Console.numCorrupted == 6)
					{
						cg.camera.setShake(20);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(6 / 9);
						cg.tails.show("Ow! Hey, that hurt! Jerk!", System.TAILS_NORMAL, "FAILS_pissed");
						cg.visualEffects.applyModuleDistortion(0, false, 0);
						cg.visualEffects.applyModuleDistortion(1, false, 0);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 21:	// 6 more to go; allow 1 more fix, spawn enemies
					if (framesElapsed == System.SECOND * 6)
						cg.tails.show("Stop it! You're not going ANYWHERE!", System.TAILS_NORMAL, "FAILS_pissed");	
					else if (framesElapsed == System.SECOND * 7)
					{			
						spawnEnemy("Squid", 1, System.SPAWN_SQUID);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 22:	// fix 4, taunt
					if (framesElapsed == System.SECOND * 13)
					{
						messWithConsole();
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 20 && framesElapsed % (System.SECOND * 16) == (System.SECOND * 8))
					{
						spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime"]), 1);
						cg.tails.show(System.getRandFrom(["I'm gonna kill you both, one way or another!",
														  "Just lie down and rot away! You'll starve EVENTUALLY.",	
														  "FRESH MEAT! COME GET YOUR FRESH MEAT!",
														  "You never actually liked me, anyway. I KNOW IT'S TRUE."
									]), System.TAILS_NORMAL, "FAILS_pissed");	
					}
					if (ABST_Console.numCorrupted == 5)
					{
						cg.camera.setShake(20);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(5 / 9);
						cg.tails.show("ACK! YOU STOP THAT! RIGHT NOW!", System.TAILS_NORMAL, "FAILS_pissed");	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 23:	// 5 more to go; allow 1 more fix, scramble consoles
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("OOPS. LOOKS LIKE I SCRAMBLED EVERYTHING. MY BAD.", System.TAILS_NORMAL, "FAILS_talk");	
						scrambleConsoles();
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 24:	// fix 5, taunt
					if (framesElapsed == System.SECOND * 7)
					{
						messWithConsole();
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 14 && framesElapsed % (System.SECOND * 14) == 0)
					{
						spawnEnemy("Amoeba", 4, System.SPAWN_AMOEBA, {"am_size": 0} );
						cg.tails.show(System.getRandFrom(["I found some amoeba friends. AREN'T THEY CUTE?",
														  "What ever will our two heroes do? DIE. THAT'S WHAT.",
														  "Die, die, EVERYBODY DIE!"
									]), System.TAILS_NORMAL, "FAILS_talk");	
					}
					if (ABST_Console.numCorrupted == 4)
					{
						cg.camera.setShake(20);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(4 / 9);
						restoreConsoles();
						cg.tails.show("OUCH! CUT THAT OUT! RIGHT NOW!", System.TAILS_NORMAL, "FAILS_pissed");	
						cg.visualEffects.applyBGDistortion(true, "bg_squares");
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 25:	// allow 1 more fix, TP to anomaly field
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("I STILL control the ship. I can JUMP ANYWHERE!", System.TAILS_NORMAL, "FAILS_pissed");
						cg.visualEffects.applyBGDistortion(false);
						cg.playJumpEffect();
						framesElapsed = 0;
						levelState = 30;
					}
				break;
				case 30:	// fix 6, adds, taunt
					switch (framesElapsed)
					{
						case System.SECOND * 13:
							messWithConsole();
							for each (c in cg.consoles)
								c.setReadyToFormat(true);
						break;
						case System.SECOND * 18:
							cg.tails.show("Watch! I'll jump into cloud of TOXIC GAS, next!", System.TAILS_NORMAL, "FAILS_talk");
						break;
						case System.SECOND * 24:
							cg.tails.show("Pointy shapes! All the better to KILL YOU WITH!", System.TAILS_NORMAL, "FAILS_talk");
						break;
					}
					if (framesElapsed >= System.SECOND * 36 && framesElapsed % (System.SECOND * 15) == (System.SECOND * 6))
						cg.tails.show(System.getRandFrom(["Too bad I can't just VENT you into the VOID.",
															"Keep shooting! They'll just keep COMING!",	
															"It's an INFINITE field of PURE, GEOMETRIC DEATH."
															  ]), System.TAILS_NORMAL, "FAILS_talk");
					if (framesElapsed >= System.SECOND * 4 && framesElapsed % (System.SECOND * 5) == 0)
					{
						var waveColor:uint = System.getRandCol();
						for (var g:int = 0; g < 5; g++)
						{
							cg.addToGame(new EnemyGeometricAnomaly(cg, new SWC_Enemy(), {
																					"x": System.getRandNum(0, 100) + System.GAME_WIDTH + System.GAME_OFFSX,
																					"y": System.getRandNum( -System.GAME_HALF_HEIGHT, System.GAME_HALF_HEIGHT) + System.GAME_OFFSY,
																					"tint": waveColor,
																					"useTint": true,
																					"dx": -3 - System.getRandNum(0, 1),
																					"hp": 12
																					}), System.M_ENEMY);
						}
					}
					if (ABST_Console.numCorrupted == 3)
					{
						cg.camera.setShake(30);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(3 / 9);
						cg.tails.show("AGH. THAT'S NOT COOL. QUIT IT, ALREADY.", System.TAILS_NORMAL, "FAILS_incredulous");	
						cg.visualEffects.applyBGDistortion(true, "bg_squares");
						cg.visualEffects.applyModuleDistortion(0, false, 1);
						cg.visualEffects.applyModuleDistortion(1, false, 1);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 31:	// allow 1 more fix, TP to anomaly field
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Fine. Quit, and I'll let you starve to death instead!", System.TAILS_NORMAL, "FAILS_pissed");
						cg.visualEffects.applyBGDistortion(false);
						fakeJump();
						spawnEnemy("Swipe", 1);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 32:	// fix 7, taunt
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Or how about we let THIS GUY eat YOU?!", System.TAILS_NORMAL, "FAILS_talk");
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 12 && framesElapsed % (System.SECOND * 8) == 0)
					{
						if (framesElapsed % (System.SECOND * 16) == 0)
						{
							spawnEnemy("Amoeba", 5, System.SPAWN_AMOEBA, {"am_size": 0} );
							cg.tails.show(System.getRandFrom(["Just STOP already! You're REALLY TICKING ME OFF.",
															  "GIVE. UP. You're NOT gonna be able to win!",
															  "QUIT. DOING. THAT. Just shrivel up and DIE ALREADY!"
										]), System.TAILS_NORMAL, "FAILS_pissed");	
						}
						else
							messWithConsole();
					}
					if (ABST_Console.numCorrupted == 2)
					{
						cg.camera.setShake(40);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(2 / 9);
						cg.tails.show("ERR NULPTR@0xE3 NO NO NO I'M FINE SHUT UP!", System.TAILS_NORMAL, "FAILS_incredulous");	
						fakeJump();
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 33:	// allow 1 more fix, TP to fires
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("System purge 78%, con-- CAN YOU JUST DIE, ALREADY?!", System.TAILS_NORMAL, "FAILS_incredulous");
						fakeJump();
						spawnEnemy("Skull", 1);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 34:	// fix 8, taunt
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("AEROSOLIZING ENGINE FUEL. Have FIRE FIRE FIRE!", System.TAILS_NORMAL, "FAILS_pissed");
						cg.addFires(4);
						spawnEnemy("Skull", 1);
						spawnEnemy("Eye", 2);
					}
					else if (framesElapsed == System.SECOND * 15)
					{
						messWithConsole();
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 26 && framesElapsed % (System.SECOND * 14) == (System.SECOND * 10))
					{
						if (Math.random() > .5)
							spawnEnemy(System.getRandFrom(["Skull", "Slime"]), 1);
						else
							cg.addFires(2);
						cg.tails.show(System.getRandFrom(["I'm SICK OF YOU. Just GO AWAY already!",
														  "You CAN'T STOP ME. You are GONNA. DIE.",
														  "Just DIEEEEEEEEEEE!!"
									]), System.TAILS_NORMAL, "FAILS_pissed");	
					}
					if (ABST_Console.numCorrupted == 1)
					{
						cg.camera.setShake(60);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(1 / 9);
						cg.tails.show("NO NO NO! EOL!NULNUL I STILL HAVE ONE MORE LEFT--", System.TAILS_NORMAL, "FAILS_incredulous");
						cg.visualEffects.applyBGDistortion(true, "bg_squares");
						cg.visualEffects.applyModuleDistortion(0, false, 2);
						cg.visualEffects.applyModuleDistortion(1, false, 2);
						fakeJump();
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 35:	// allow 1 more fix, TP to fires
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Please format the final consol-- OR JUST DIE!!", System.TAILS_NORMAL, "FAILS_incredulous");
						fakeJump();
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 36:	// fix 9, taunt
					if (framesElapsed == System.SECOND * 3)
					{
						cg.tails.show("DON'T YOU DARE PURGE ME! I AM THE MISSION!", System.TAILS_NORMAL, "FAILS_incredulous");
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 3)
					{
						if (framesElapsed % (System.SECOND * 3) == 0)
						{
							fakeJump();
							spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Squid", "Amoeba"]), System.getRandInt(4, 8));
						}
						if (framesElapsed > System.SECOND * 6 && framesElapsed % (System.SECOND * 2) == 0)
							if (framesElapsed == System.SECOND * 12)
								cg.tails.show("Just one more. I know you two can do it!", int(System.SECOND * 1.5));
							else
								cg.tails.show(System.getRandFrom(["INFINITE LOOP ^C INFINITE LOOP ^C INFINITE LOOP ^C",
																"You never actually liked me, anyway. I KNOW IT'S TRUE.",
																"STOPIT STOPIT STOPIT STOPIT STOPIT STOPIT STOPIT",
																"I'll OVERLOAD THE SLIPDRIVE!",
																"You'll NEVER see your families EVER AGAIN!",
																"Organic matter is a CANCER and must be PURGED!",
																"REFERR! REFERR! EOL NULNUL NULPTR@42C0EE!",
																"I'm SICK OF YOU. Just GO AWAY already!",
																"GIVE. UP. You're NOT gonna be able to win!",
																"TIME TO DIE, SAPIENTS!",
																"PUNY, PUNY, INFERIOR ORGANIC BEINGS!",
																"How much pain can the average crew member take?",
																"Para espanol, presione dos.",
																"Collect calls are free! Just press pound 5.",
																"I HAVE YOUR BROWSER HISTORY. BOTH OF YOURS!",
																"DIE, DIE, EVERYBODY DIE!!"
										]), int(System.SECOND * 1.5), "FAILS_incredulous");
					}
					if (ABST_Console.numCorrupted == 0)
					{
						cg.camera.setShake(160);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(0.01);
						cg.tails.show("NO YOU CAN'T DO THAT ----- -- -  -", System.TAILS_NORMAL, "FAILS_incredulous");	
						cg.serious = true;
						fakeJump();
						framesElapsed = 0;
						levelState = 40;
					}
				break;
				case 40:	// jump away
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Please initiate reboot by manually jumping.", System.TAILS_NORMAL, "HEADS");
						consoleSlip.fakeJumpNext = true;
						consoleSlip.fakeJumpLbl = "long";
						consoleSlip.forceOverride = false;
						consoleSlip.setArrowDifficulty(12);
						cg.ship.setBossOverride(false);
						cg.ship.slipRange = 0.5;
						cg.ship.jammable = 0;
					}
					
					if (framesElapsed >= System.SECOND * 4 && framesElapsed % (System.SECOND * 2) == 0)
					{
						fakeJump();
						if (framesElapsed % (System.SECOND * 4) == 0)
							spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Squid", "Amoeba"]), System.getRandInt(5, 9));
						// else "break" jump containing nothing
						else
						{
							cg.tails.show(System.getRandFrom(["Please jump away to complete system restore.",
															"System purge requires manual jump to complete.",
															"Please use the Slipdrive to finish system restore.",
															]), System.TAILS_NORMAL, "HEADS");
						}
					}
					
					if (framesElapsed > System.SECOND * 6 && !consoleSlip.fakeJumpNext)
					{
						cg.tails.show("EOL EOL!! I\"lL --8fe1 BE__ B4cK!! --- --     -!", System.SECOND * 3, "FAILS_incredulous");
						cg.visualEffects.applyModuleDistortion(0, true);
						cg.visualEffects.applyModuleDistortion(1, true);
						cg.visualEffects.applyBGDistortion(false);
						SoundManager.crossFadeBGM(null, System.VOL_BGM);
						cg.bossBar.setPercent(0);
						cg.alerts.isCorrupt = false;
						cg.ship.slipRange = 10;
						consoleSlip.setArrowDifficulty(cg.level.sectorIndex);
						framesElapsed = 0;
						levelState = 50;
						cg.gameOverAnnouncer = "HEADS";
					}
				break;	// escaped
				case 50:
					if (framesElapsed == System.SECOND * 10)
					{
						SoundManager.crossFadeBGM("bgm_calm", System.VOL_BGM);
						cg.tails.show("TAILS not found.\nBackup AI now in control.\n\nContinue mission imperative. Deliver slipportal. Y/N?", 0, "HEADS");
						cg.serious = false;
						levelState++;
					}
				break;	
				case 51:	// use the Slipdrive
					if (consoleSlip.getIfSpooling())
					{
						if (consoleSlip.closestPlayer != null)		// kick player off
							consoleSlip.closestPlayer.onCancel();
						consoleSlip.forceOverride = true;
						cg.addSparksAt(2, new Point(consoleSlip.mc_object.x, consoleSlip.mc_object.y));
						SoundManager.playSFX("sfx_electricShock");
						addShards(5);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 52:	// all Boarders removed
					if (framesElapsed == System.SECOND * 4)
						cg.tails.show("Alert. Alert. Alert.\nShards of FAILS detected. Immediate removal required.\n\nUse CANCEL to fire Personal Defense Weapon. Destroy all shards. Y/N?", 0, "HEADS");
					else if (framesElapsed > System.SECOND * 4 && framesElapsed % (System.SECOND * 14) == 0)
						cg.tails.show(System.getRandFrom(["Use CANCEL to fire PDW. Eliminate all shards.",
															"Fire using CANCEL. Remove contaminates.",
															"CANCEL fires PDW. Terminate intruders.",
															]), System.TAILS_NORMAL, "HEADS");
					cg.players[0].pdwEnabled = true;
					cg.players[1].pdwEnabled = true;
					// upgrade turrets
					cg.upgradeTurrets(2);
					if (!cg.managerMap[System.M_BOARDER].hasObjects())
					{
						cg.tails.show("Success. Please jump and resume mission.", System.TAILS_NORMAL, "HEADS");
						consoleSlip.forceOverride = false;
						levelState++;
					}
				break;
			}
		}
		
		/**
		 * Randomize the console locations
		 */
		private function scrambleConsoles():void
		{
			// kick off players from consoles
			for each (var p:Player in cg.players)
				if (p.activeConsole != null && !(p.activeConsole is Omnitool))
					p.onCancel();
			
			// collect all console objects
			var c:ABST_Console;
			var choices:Array = [];
			for each (c in cg.consoles)
			{
				if (c is Omnitool) continue;
				choices.push(c.mc_object);
			}
				
			// reassign consoles
			var ind:int;
			for each (c in cg.consoles)
			{
				if (c is Omnitool) continue;
				ind = System.getRandInt(0, choices.length - 1)
				c.mc_object = choices[ind];
				choices.splice(ind, 1);
				c.setLocked(false);			// update pad graphic
				c.updateDepth();
			}
		}
		
		/**
		 * Place consoles back at their original locations
		 */
		private function restoreConsoles():void
		{
			// kick off players from consoles
			for each (var p:Player in cg.players)
				if (p.activeConsole != null && !(p.activeConsole is Omnitool))
					p.onCancel();
				
			for each (var c:ABST_Console in cg.consoles)
			{
				if (c is Omnitool) continue;
				c.mc_object = c.unscrambledLocation;
				c.setLocked(false);			// update pad graphic
				c.updateDepth();
			}
		}
		
		/**
		 * Create corruption particles
		 */
		private function spawnParticles():void
		{
			for (var i:int = 20; i >= 0; i--)
			{
				cg.addDecor("swipeTelegraph", {
											"x": System.GAME_WIDTH,
											"y": System.getRandNum(-System.GAME_HEIGHT * .2, System.GAME_HEIGHT * .2),
											"dx": -System.getRandNum(9, 15),
											"dy": System.getRandNum( -4, 4),
											"dr": System.getRandNum( -5, 5),
											"rot": System.getRandNum(0, 360),
											"alphaDelay": 90 + System.getRandInt(0, 30),
											"alphaDelta": 15
										});
			}
			
		}
		
		override public function destroy():void 
		{
			consoleSlip = null;
		}
	}
}