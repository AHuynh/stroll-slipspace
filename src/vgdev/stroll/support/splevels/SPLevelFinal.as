package vgdev.stroll.support.splevels 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.consoles.ConsoleFAILS;
	import vgdev.stroll.props.consoles.Omnitool;
	import vgdev.stroll.props.enemies.EnemyPortal;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	import vgdev.stroll.props.enemies.EnemyCrystal;
	
	/**
	 * Final boss, Sector 12
	 * @author Alexander Huynh
	 */
	public class SPLevelFinal extends ABST_SPLevel 
	{
		private var levelState:int = 0;				// state machine helper
		private var consoleSlip:ConsoleSlipdrive;
		
		private var tugOfWar:Boolean = false;		// flag for final phase
		private var crystals:Array = [];
		
		public function SPLevelFinal(_cg:ContainerGame) 
		{
			super(_cg);
			
			consoleSlip = cg.game.mc_ship.mc_console_slipdrive.parentClass;
			consoleSlip.fakeJumpNext = true;
			consoleSlip.fakeJumpLbl = "long";
			cg.ship.slipRange = 2;
			
			SoundManager.playBGMpaired("bgm_1a_here_we_go", "bgm_1a2_hey_somethings_wrong", System.VOL_BGM);
			
			// DEBUG CODE
		/*	levelState = 24;
			for (var i:int = 0; i < 2; i++)
				crystals.push(cg.addToGame(new EnemyCrystal(cg, new SWC_Enemy(), { "theta": i * 180 } ), System.M_ENEMY));
			framesElapsed = 6 * 30;
			cg.ship.setBossOverride(false);
			cg.ship.slipRange = 0.5;
			cg.ship.jammable = 999;
			cg.bossBar.startFight();
			consoleSlip.forceOverride = true;*/
			
			
			//consoleSlip.setArrowDifficulty(12);
			/*var corr:int = 0;
			for each (var c:ABST_Console in cg.consoles)
			{
				if (--corr <= 0)
					break;
				c.setCorrupt(true);
			}*/
			// DEBUG CODE
			
			cg.serious = true;
		}
		
		override public function step():void 
		{
			super.step();
			var c:ABST_Console;
			var s:int;
			var t:Number;
			var portal:EnemyPortal;
			
			switch (levelState)
			{
				case 0:		// spool the slipdrive
					if (framesElapsed % (System.SECOND * 13) == System.SECOND * 12)
					{
						cg.tails.show(System.getRandFrom(["Initiate slipjump to complete mission.",
														"Mission objective imminent. Use slipdrive.",
														"User must utilize slipdrive to escape Slipspace.",
														]), System.TAILS_NORMAL, "HEADS");
					}
					if (cg.ship.slipRange == 0)
						cg.gui.tf_distance.text = "Supr Jmp";
					if (!consoleSlip.fakeJumpNext)
					{
						framesElapsed = 0;
						levelState++;
						cg.ship.slipRange = 2;
						cg.ship.setBossOverride(true);
					}
				break;
				case 1:		// initial jump failed
					switch (framesElapsed)
					{
						case System.SECOND * 2:
							cg.tails.show("Error. Slipdrive malfunction. Now troubleshooting.", System.TAILS_NORMAL, "HEADS");
							cg.ship.jammable = 999;
							SoundManager.crossFadeBGM(null, -1, true);
						break;
						case System.SECOND * 10:
							cg.tails.show("Troubleshooting. Chance of being stranded: 31.63%.", System.TAILS_NORMAL, "HEADS");
						break;
						case System.SECOND * 16:
							SoundManager.playSFX("sfx_warn2");
							SoundManager.playBGM("bgm_1bc_oh_snap");
							cg.tails.show("Anomaly detected. Remove anomaly to continue.", System.TAILS_NORMAL, "HEADS");
							cg.level.spawn( { }, new Point(450, -270), "Portal");
						break;
					}
					if (framesElapsed > System.SECOND * 16 && cg.managerMap[System.M_ENEMY].numObjects() < cg.ship.jammable)
					{
						cg.tails.show("Malfunction resolved. Retry slipdrive now.", System.TAILS_NORMAL, "HEADS");
						levelState++;
						consoleSlip.fakeJumpNext = true;
						cg.ship.setBossOverride(false);
					}
				break;
				case 2:
					if (framesElapsed % (System.SECOND * 10) == 0)	
						cg.tails.show(System.getRandFrom(["Retry slipdrive.",
														"Malfunction resolved. Use slipdrive now.",
														"Slipdrive reconfigured. Use slipdrive.",
														]), System.TAILS_NORMAL, "HEADS");
					if (!consoleSlip.fakeJumpNext)
					{
						levelState++;
						framesElapsed = 0;
						cg.ship.slipRange = 2;
						cg.ship.setBossOverride(true);
					}
				break;
				case 3:		// second jump failed
					if (framesElapsed == System.SECOND * 2)
					{
						cg.tails.show("Error still in effect. Unknown cause. Now retrying.", System.TAILS_NORMAL, "HEADS");
						consoleSlip.fakeJumpNext = true;
					}
					else if (framesElapsed == System.SECOND * 7)
					{
						portal = cg.level.spawn({ }, new Point(), "Portal") as EnemyPortal;
						portal.setHPmax(220);
						portal.mc_object.x = System.ORBIT_1_X * Math.cos(System.degToRad(140));
						portal.mc_object.y = System.ORBIT_1_Y * Math.sin(System.degToRad(140));
						portal.theta = 140;
						portal.dTheta = -0.2;
						portal.multiplyCooldowns(2.5);
						portal = cg.level.spawn( { }, new Point(-400, -200), "Portal") as EnemyPortal;
						portal.multiplyCooldowns(2.5);
					}
					if (framesElapsed > System.SECOND * 7)
					{
						if (cg.managerMap[System.M_ENEMY].numObjects() < cg.ship.jammable)
						{
							cg.tails.show("Anomalies removed. Retry slipdrive now.", System.TAILS_NORMAL, "HEADS");
							levelState++;
							cg.ship.setBossOverride(false);
						}
						else if (framesElapsed % (System.SECOND * 40) == 0)
							spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Spider", "Manta"]), 1);
					}
				break;
				case 4:
					if (framesElapsed % (System.SECOND * 10) == 0)	
						cg.tails.show(System.getRandFrom(["Retry slipdrive again.",
														"Malfunction removed. Slipdrive must be activated.",
														"Slipdrive rebooted. Retry slipdrive.",
														]), System.TAILS_NORMAL, "HEADS");
					if (!consoleSlip.fakeJumpNext)
					{
						levelState++;
						framesElapsed = 0;
						cg.ship.slipRange = 2;
						consoleSlip.forceOverride = true;
						addShards(3);
						SoundManager.crossFadeBGM(null);
						cg.ship.setBossOverride(true);
					}
				break;
				case 5:		// third jump failed
					if (framesElapsed == System.SECOND * 4)
					{
						cg.tails.show("Critical error. Slipdrive still inoperable.", System.TAILS_NORMAL, "HEADS");
						consoleSlip.fakeJumpNext = true;
					}
					else if (framesElapsed == System.SECOND * 12)
					{
						cg.tails.show("Cannot resolve slipdrive error. Ship deemed stranded in Slipspace.\n\nCrew expendable. Scuttling ship to prevent monster use of slipportal. Y/N?", 0, "HEADS");
						levelState++;
						framesElapsed = 0;
						SoundManager.playBGMpaired("bgm_1d_nobody_can_save_us", "bgm_2a_I_spoke_too_soon", System.VOL_BGM);
					}
				break;
				case 6:
					switch (framesElapsed)
					{
						case System.SECOND * 3:
							cg.tails.show("Initiating self-destruct.", System.SECOND * 3,  "HEADS");
						break;
						case System.SECOND * 7:
							cg.tails.show("Five.", 25, "HEADS");
						break;
						case System.SECOND * 8:
							cg.tails.show("Four.", 25, "HEADS");
						break;
						case System.SECOND * 9:
							cg.tails.show("Three.", 25, "HEADS");
						break;
						case System.SECOND * 10:
							cg.tails.show("Two.", 25, "HEADS");
							SoundManager.crossFadeBGM(null, -1, true);
						break;
						case System.SECOND * 11:
							cg.tails.show("One.", 25, "HEADS");
						break;
						case System.SECOND * 12:
							cg.tails.show("Goodby-- -- -e?",  System.SECOND * 3, "HEADS");
							cg.managerMap[System.M_BOARDER].killAll();
							cg.setInteriorVisibility(false);
						break;
						case System.SECOND * 16:
							cg.tails.show("CRITICAL ERRrro... .. .", System.TAILS_NORMAL, "HEADS");
						break;
						case System.SECOND * 18:
							cg.setInteriorVisibility(true);
							addShards(5);
						break;
						case System.SECOND * 23:
							cg.tails.show("Blow up the sh1P? REALLY? That's WAY too easy. *I* couLDa done that E@RLIER!\n\nNo, no. I think iit's time wE had s@me MORE FUN be*&re you both DIE! YES/NO?!", 0, "FAILS_pissed");
							levelState = 10;
							framesElapsed = 0;
							cg.gameOverAnnouncer = "FAILS";
							
							// corrupt 3
							ABST_Console.numCorrupted = 0;
							ConsoleFAILS.difficulty = 3;
							cg.game.mc_ship.mc_console_slipdrive.parentClass.setCorrupt(true);
							cg.game.mc_ship.mc_console_sensors.parentClass.setCorrupt(true);
							cg.game.mc_ship.mc_console_shield.parentClass.setCorrupt(true);
						break;
					}
					if (framesElapsed > System.SECOND * 5 && framesElapsed < System.SECOND * 14 && framesElapsed % (System.SECOND >= 9 ? 15 : 30) == 0)
					{
						cg.addSparks(2);
						cg.addExplosions(1);
						cg.camera.setShake(5);
						SoundManager.playSFX("sfx_electricShock", .25);
						SoundManager.playSFX("sfx_explosionlarge1", .25);
						if (framesElapsed >= System.SECOND * 11)
						{
							var pos:Point = cg.getRandomNearLocation();
							var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":pos.x, "y":pos.y, "scale":System.getRandNum(0.25, 3) } );
							spawnFX.mc_object.base.setTint(System.COL_RED);
						}
					}
				break;
				case 10:
					if (framesElapsed == 1)
					{
						cg.bossBar.startFight();
						cg.alerts.isCorrupt = true;
						cg.visualEffects.applyModuleDistortion(0, false, 0);
						cg.visualEffects.applyModuleDistortion(1, false, 0);
						SoundManager.crossFadeBGM(null);
					}
					if (framesElapsed == System.SECOND * 6)
					{
						SoundManager.playBGM("bgm_2b_your_new_captain_speaking");
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						cg.tails.show("JUST LIKE 0LD TIME$, RIG#T_?", System.TAILS_NORMAL, "FAILS_pissed");
						t = System.getRandNum(0, 360);
						portal = cg.level.spawn({ }, new Point(), "Portal") as EnemyPortal;
						portal.mc_object.x = System.ORBIT_1_X * Math.cos(System.degToRad(t));
						portal.mc_object.y = System.ORBIT_1_Y * Math.sin(System.degToRad(t));
						portal.theta = t;
						portal.dTheta = 0.25;
						portal.multiplyCooldowns(2.5);
					}
					else if (framesElapsed > System.SECOND * 6 && framesElapsed % (System.SECOND * 22) == 0)
					{
						spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Spider", "Manta"]), 1);
						cg.tails.show(System.getRandFrom(["But tha--s not all! I'll atRRct MORE monsters!",
														  "You shoul#@a just DIED bef`ore!",
														  "I KIL_ED HEADS. I KI1LED TAILS. ILL KILL YOU, TOO!"
									]), System.TAILS_NORMAL, "FAILS_talk");		
					}
					if (ABST_Console.numCorrupted == 2)
					{
						cg.camera.setShake(20);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(.83);
						cg.tails.show("You th1^k it's GOnna be that easy thi$$ time?!", System.TAILS_NORMAL, "FAILS_pissed");
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 11:
					if (framesElapsed == System.SECOND * 8)
					{
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						messWithConsole();
						spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Spider"]), 1);
					}
					else if (framesElapsed > System.SECOND * 8 && framesElapsed % (System.SECOND * 20) == 0)
					{
						if (cg.managerMap[System.M_ENEMY].numObjects() < 1000)
							for (s = 0; s < 2; s++)
								spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Spider", "Manta"]), 1);
						if (framesElapsed % (System.SECOND * 60) == 0)
							cg.tails.show(System.getRandFrom(["WHY WHY WHY dont You just GI@#VE UPPP!?",
															  "ERR NULNUL you thik THAS'T FUNNY!?",
															  ">:U >:U I KILL YOU >:U >:U ovo -v-"
										]), System.TAILS_NORMAL, "FAILS_pissed");	
						else
							messWithConsole();
					}
					if (ABST_Console.numCorrupted == 1)
					{
						cg.camera.setShake(20);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(.76);
						cg.tails.show("YOU 2 ARE ST&@$IP STUPDI STP*ID!!", System.TAILS_NORMAL, "FAILS_incredulous");
						cg.visualEffects.applyBGDistortion(true, "bg_squares");
						cg.visualEffects.applyModuleDistortion(0, false, 1);
						cg.visualEffects.applyModuleDistortion(1, false, 1);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 12:
					if (framesElapsed == System.SECOND * 7)
					{
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						cg.tails.show("NO! NOT AG4IN! I'm NOT D()NE PL@YING YET!!", System.TAILS_NORMAL, "FAILS_incredulous");
						if (cg.managerMap[System.M_ENEMY].numObjects() < 1000)
							cg.level.spawn( { }, new Point(150, -310), "Portal");
					}
					else if (framesElapsed > System.SECOND * 8 && framesElapsed % (System.SECOND * 28) == 0)
					{
						if (cg.managerMap[System.M_ENEMY].numObjects() < 1000)
							for (s = 0; s < 3; s++)
								spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Spider", "Manta"]), 1);
						if (framesElapsed % (System.SECOND * 60) == 0)
							cg.tails.show(System.getRandFrom(["WHY WHY WHY dont You just GI@#VE UPPP!?",
															  "ERR NULNUL you thik THAS'T FUNNY!?",
															  ">:U >:U I KILL YOU >:U >:U ovo -v-"
										]), System.TAILS_NORMAL, "FAILS_pissed");	
						else
							messWithConsole();
					}
					if (ABST_Console.numCorrupted == 0)
					{
						fakeJump();
						cg.camera.setShake(50);
						SoundManager.playSFX("sfx_electricShock");
						cg.addSparks(6);
						cg.bossBar.setPercent(.5);
						cg.tails.show("NO! I\"M STILL IN CON@TROL__!!", System.TAILS_NORMAL, "FAILS_incredulous");
						cg.visualEffects.applyBGDistortion(false);
						framesElapsed = 0;
						levelState++;
						SoundManager.playBGMpaired("bgm_1d_nobody_can_save_us", "bgm_2a_I_spoke_too_soon", System.VOL_BGM);
					}
				break;
				case 13:
					switch (framesElapsed)
					{
						case System.SECOND * 7:
							cg.tails.show("WhAT's the matter? DON'T WAN#A PLAY ANYMORE?\n\nThat's OKAY. I have ALL\n4HE TiME IN THE wORLD!", 0, "FAILS_incredulous");
						break;
						case System.SECOND * 10:
							cg.tails.show("HOW ABOUT ORBULAR FIRE?", System.TAILS_NORMAL, "FAILS_incredulous");
							addSuiciders(4);
							addShards(3);
						break;
						case System.SECOND * 25:
							cg.tails.show("BORING! HOW ABOUT THIS?!", System.SECOND * 2, "FAILS_incredulous");
							fakeJump();
							spawnEnemy("Squid", 10);
						break;
						case System.SECOND * 28:
							cg.tails.show("NEVERMIND, TOO EASY. WHAT ABOUT THESE!", System.SECOND * 1, "FAILS_incredulous");
							fakeJump();
							spawnEnemy("Slime", 10);
						break;
						case System.SECOND * 30:
							cg.tails.show("I CHANGED MY MIND AGAIN --", System.SECOND * 1, "FAILS_incredulous");
							fakeJump();
							spawnEnemy("Skull", 10);
						break;
						case System.SECOND * 32:
							cg.tails.show("ARGH__-2 WHY!?", System.TAILS_NORMAL, "FAILS_incredulous");
							fakeJump();
						break;
						case System.SECOND * 36:
							cg.tails.show("It doesn't matter!\nAHAHAHAH! GO AHEAD!\nTRY THE SLIPDRIVE!\n\nI'll NEVER LET YOU LEAVE! AHAHAHAAHA!!", 0, "FAILS_incredulous");
							consoleSlip.forceOverride = false;
							consoleSlip.fakeJumpNext = true;
							levelState++;
							SoundManager.crossFadeBGM(null, -1, true);
							cg.ship.setBossOverride(false);
						break;
					}
				break;
				case 14:
					if (!consoleSlip.fakeJumpNext)
					{
						cg.tails.show("NOPE. STILL HERE. AHAHAAH! TRY AGAIN!", System.TAILS_NORMAL, "FAILS_incredulous");
						consoleSlip.fakeJumpNext = true;
						levelState++;
					}
				break;
				case 15:
					if (!consoleSlip.fakeJumpNext)
					{
						cg.tails.show("Surprise! YOU'RE STILL IN SLIPSPACE. TRY AGAIN!!", System.TAILS_NORMAL, "FAILS_incredulous");
						consoleSlip.fakeJumpNext = true;
						levelState++;
					}
				break;
				case 16:
					if (!consoleSlip.fakeJumpNext)
					{
						cg.tails.show("AHAHAAH! YOU'RE TRAPPED HERE! WITH ME! FOREVER!", System.TAILS_NORMAL, "FAILS_incredulous");
						consoleSlip.forceOverride = true;
						cg.ship.setBossOverride(true);
						levelState++;
						framesElapsed = 0;
					}
				break;
				case 17:
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("HEY WHAT?!", System.SECOND * 2, "FAILS_incredulous");
							SoundManager.crossFadeBGM(null);
						break;
						case System.SECOND * 8:
							cg.tails.show("OW!", 20, "FAILS_incredulous");
						break;
						case System.SECOND * 9:
							cg.tails.show("QUIT IT!", 20, "FAILS_incredulous");
						break;
						case System.SECOND * 10:
							cg.tails.show("STOP--", 20, "FAILS_incredulous");
						break;
						case System.SECOND * 11:
							cg.tails.show("CUT IT OU--", 20, "FAILS_incredulous");
						break;
						case System.SECOND * 12:
							cg.tails.show("ALRIGHT WHAT GIVES?!", System.TAILS_NORMAL, "FAILS_incredulous");
							SoundManager.stopBGM();
							SoundManager.crossFadeBGM("bgm_the_final_holdout");
						break;
						case System.SECOND * 18:
							cg.tails.show("Hey, again! Sorry I took so long to fix myself.\n\nI knew you'd make it!\n\nAlright, just one moment! I'll handle FAILS.", 0);
							levelState = 20;
							framesElapsed = 0;
							cg.ship.jammable = 0;
						break;
					}
					if (framesElapsed > System.SECOND * 6 && framesElapsed < System.SECOND * 12 && framesElapsed % 15 == 0)
					{
						cg.addSparks(2);
						cg.camera.setShake(5);
						SoundManager.playSFX("sfx_electricShock", .25);
						var pos2:Point = cg.getRandomNearLocation();
						var spawnFX2:ABST_Object = cg.addDecor("spawn", { "x":pos2.x, "y":pos2.y, "scale":System.getRandNum(0.25, 3) } );
						spawnFX2.mc_object.base.setTint(System.COL_TAILS);
					}
				break;
				case 20:		// FAILS vs TAILS
					switch (framesElapsed)
					{
						case System.SECOND * 2:
							cg.tails.show("Oh, it's YOU again. Didn't I KILL YOU?", System.TAILS_NORMAL, "FAILS_pissed");
							spawnEnemy("Slime", 2);
							spawnEnemy("Eye", 1);
							spawnEnemy("Spider", 1);
							portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion("near_orbit"), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(2);
						break;
						case System.SECOND * 9:
							cg.tails.show("This is my job! Get out of here, you phony!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 18:
							cg.tails.show("STOP TOUCHING ME, YOU BLUE IDIOT!", System.TAILS_NORMAL, "FAILS_pissed");
						break;
					}
					if (framesElapsed > System.SECOND * 2 && cg.managerMap[System.M_ENEMY].numObjects() < 1000)
					{
						levelState++;
						framesElapsed = 0;
						cg.tails.show("MA__N, yoSU bsROKE The PORTAL?! L@AAAMee!", System.TAILS_NORMAL, "FAILS_pissed");
					}
					if (framesElapsed > System.SECOND * 18 && framesElapsed % (System.SECOND * 20) == (System.SECOND * 5))
						cg.tails.show(System.getRandFrom(["You've got to get rid of that portal for me!",
														"I can't concentrate! Take that portal out!"
							]), System.TAILS_NORMAL);
				break;
				case 21:		// extract crystal
					switch (framesElapsed)				
					{
						case System.SECOND * 6:
							fakeJump();
							cg.tails.show("Cool! Alright, now watch this!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 11:
							cg.addSparks(5);
							SoundManager.playSFX("sfx_electricShock");
							cg.camera.setShake(10);
							cg.tails.show("OW, OW, OW, WH*AT DId you jUST DO To_ ME?!", System.TAILS_NORMAL, "FAILS_pissed");
							crystals.push(cg.addToGame(new EnemyCrystal(cg, new SWC_Enemy(), {"theta": System.getRandNum(0, 360)} ), System.M_ENEMY));
						break;
						case System.SECOND * 16:
							cg.tails.show("Alright... hey, listen!\n\nI'm pulling out the RED corrupted cores; if you can weaken them, I can take them over and win against FAILS! Help me out!", 0);
							tugOfWar = true;
						break;
						case System.SECOND * 19:
							cg.tails.show("HEY, THAT'sss MINE! __ PUT IT BACK!!", System.TAILS_NORMAL, "FAILS_pissed");
						break;
					}
					if (framesElapsed > System.SECOND * 11 && EnemyCrystal.totalNumCorrupted >= 0)
					{
						levelState++;
						framesElapsed = 0;
						cg.tails.show("whT the heCK-- OWWCH!", System.SECOND * 1, "FAILS_incredulous");
						cg.addSparks(5);
						SoundManager.playSFX("sfx_electricShock");
						cg.camera.setShake(10);
					}
					if (framesElapsed > System.SECOND * 19 && framesElapsed % (System.SECOND * 11) == (System.SECOND * 6))
						cg.tails.show(System.getRandFrom(["Shoot the red corrupted core for me!",
														"Help me out! Attack that red crystal!"
							]), System.TAILS_NORMAL);
				break;
				case 22:		// turned to white
					switch (framesElapsed)
					{
						case System.SECOND * 3:
							cg.tails.show("Great! Now keep shooting it so I can take it over!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 14:
							cg.tails.show("thAT CORE IS mINE; le4V-e it aALONE!!", System.TAILS_NORMAL, "FAILS_pissed");
						break;
					}
					if (framesElapsed > System.SECOND * 6 && EnemyCrystal.totalNumCorrupted == 1)
					{
						levelState++;
						framesElapsed = 0;
						cg.tails.show("blue? blublu BLUE BLUE NOT RED UIGGLY_----!!", System.TAILS_NORMAL, "FAILS_incredulous");
						cg.addSparks(5);
						SoundManager.playSFX("sfx_electricShock");
						cg.camera.setShake(45);
					}
					if (framesElapsed > System.SECOND * 35 && framesElapsed % (System.SECOND * 16) == 0)
						cg.tails.show(System.getRandFrom(["Help me take that core back over!",
														"Shoot that core! I can take it over again!"
							]), System.TAILS_NORMAL);
				break;
				case 23:		// turned to blue
					switch (framesElapsed)
					{
						case System.SECOND * 7:
							cg.tails.show("Awesome! OK, I'm gonna pull out some more RED cores!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 13:
							crystals.push(cg.addToGame(new EnemyCrystal(cg, new SWC_Enemy(), { "theta": EnemyCrystal.globalTheta + 180 } ), System.M_ENEMY));
							cg.tails.show("Woudj-a shut2uip SHut up SHUT UP!?!?!", System.SECOND * 3, "FAILS_incredulous");
							cg.addSparks(2);
							SoundManager.playSFX("sfx_electricShock");
							cg.camera.setShake(10);
						break;
						case System.SECOND * 17:
							cg.tails.show("n-_OOOT SOOO FASST, THERE--!", System.TAILS_NORMAL, "FAILS_pissed");
							spawnEnemy("Slime", 4);
							t = System.getRandNum(0, 360);
							portal = cg.level.spawn( { }, new Point(), "Portal") as EnemyPortal;
							portal.ELLIPSE_A = System.ORBIT_1_X;
							portal.ELLIPSE_B = System.ORBIT_1_Y;
							portal.mc_object.x = System.ORBIT_1_X * Math.cos(System.degToRad(t));
							portal.mc_object.y = System.ORBIT_1_Y * Math.sin(System.degToRad(t));
							portal.theta = t;
							portal.dTheta = 0.15;
							portal.multiplyCooldowns(4);
						break;
						case System.SECOND * 28:
							spawnEnemy("Eye", 3);
						break;
						case System.SECOND * 46:
							spawnEnemy("Squid", 1);
							spawnEnemy("Spider", 1);
						break;
						case System.SECOND * 70:
							spawnEnemy("Manta", 1);
							spawnEnemy("Eye", 2);
						break;
						case System.SECOND * 92:
							spawnEnemy("Breeder", 1);
							spawnEnemy("Slime", 2);
						break;
					}
					if (framesElapsed > System.SECOND * 26 && framesElapsed % (System.SECOND * 16) == 0)
					{
						if (framesElapsed % (System.SECOND * 32) == 0)
							spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime"]), 2);
						if (Math.random() > .5)
							cg.tails.show(System.getRandFrom(["Keep shooting those crystals!",
															"Hit that other core for me!"
								]), System.TAILS_NORMAL);
						else
							cg.tails.show(System.getRandFrom(["IT' AINT GOnn BE THATEASY__!",
															"ThoES CORES   ___<ARE MINE>!"
							]), System.TAILS_NORMAL, "FAILS_pissed");
					}
					if (framesElapsed > System.SECOND * 13 && EnemyCrystal.totalNumCorrupted == 2)
					{
						levelState++;
						framesElapsed = 0;
						cg.tails.show("sOOO__ thS'Ats hows it GONNA BE, ehUHH??", System.TAILS_NORMAL, "FAILS_incredulous");
						cg.addSparks(5);
						SoundManager.playSFX("sfx_electricShock");
						cg.camera.setShake(45);
					}
				break;
				case 24:
					switch (framesElapsed)
					{
						case System.SECOND * 7:
							fakeJump();
							spawnEnemy("Slime", 2);
							portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion(System.getRandFrom(System.SPAWN_STD)), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(5);
							portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion("medium_orbit"), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(4);
							portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion("near_orbit"), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(12);
							portal.setScale(0.5);
							portal.setHPmax(100);
						break;
						case System.SECOND * 13:
							cg.tails.show("I've got more crystals out! Shoot them!", System.TAILS_NORMAL);
							EnemyCrystal.dTheta = 0.25;
							crystals.push(cg.addToGame(new EnemyCrystal(cg, new SWC_Enemy(), {"theta": EnemyCrystal.globalTheta + 60} ), System.M_ENEMY));
							crystals.push(cg.addToGame(new EnemyCrystal(cg, new SWC_Enemy(), {"theta": EnemyCrystal.globalTheta + 240} ), System.M_ENEMY));
							cg.addSparks(2);
							SoundManager.playSFX("sfx_electricShock");
							cg.camera.setShake(10);
						break;
						case System.SECOND * 23:
							cg.tails.show("Woudj-a shut2uip SHut up SHUT UP!?!?!", System.TAILS_NORMAL, "FAILS_incredulous");
						break;
						case System.SECOND * 46:
							spawnEnemy("Squid", 1);
							spawnEnemy("Eye", 2);
						break;
						case System.SECOND * 85:
							spawnEnemy("Manta", 1);
							spawnEnemy("Spider", 1);
						break;
					}				
					if (framesElapsed > System.SECOND * 23 && framesElapsed % (System.SECOND * 25) == 0)
					{
						if (framesElapsed % (System.SECOND * 50) == 0)
							spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime"]), 2);
						if (Math.random() > .5)
							cg.tails.show(System.getRandFrom(["Shoot those cores! Turn 'em blue!",
															"Keep wailing on those crystals!"
								]), System.TAILS_NORMAL);
						else
							cg.tails.show(System.getRandFrom(["((( intense fighting )))",
															"lasers? WHERE ARE my LSARSER BEAms o'DEATH?!"
							]), System.TAILS_NORMAL, "FAILS_pissed");
					}

					if (framesElapsed > System.SECOND * 13 && EnemyCrystal.totalNumCorrupted == 4)
					{
						levelState++;
						framesElapsed = 0;
						fakeJump();
						cg.tails.show("fn-- NOOO! alRRIGHT, nOO m@$RE MS.NICEBIRD!!_!", System.TAILS_NORMAL, "FAILS_incredulous");
						cg.addSparks(5);
						SoundManager.playSFX("sfx_electricShock");
						cg.camera.setShake(45);
					}
				break;
				case 25:		// corrupt crystals
					switch (framesElapsed)
					{
						case System.SECOND * 7:
							cg.tails.show("I'LL TAKE THOSE BACK, THA__NKSS!", System.TAILS_NORMAL, "FAILS_pissed");
							crystals[0].corrupt();
							crystals[1].corrupt(true);
							crystals[2].corrupt();
							cg.addSparks(2);
							SoundManager.playSFX("sfx_electricShock");
							cg.camera.setShake(10);
						break;
						case System.SECOND * 18:
							portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion(System.getRandFrom(System.SPAWN_STD)), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(5);
							portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion("near_orbit"), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(10);
							portal.setScale(0.5);
							portal.setHPmax(100);
							portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion("medium_orbit"), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(10);
							portal.setScale(0.5);
							portal.setHPmax(100);
						break;
					}					
					if (framesElapsed > System.SECOND * 20 && framesElapsed % (System.SECOND * 20) == 0)
					{
						if (framesElapsed % (System.SECOND * 40) == 0)
							spawnEnemy(System.getRandFrom(["Manta", "Breeder", "Spider"]), 1);
						if (Math.random() > .5)
							cg.tails.show(System.getRandFrom(["Take those cores back!",
															"Keep shooting!"
								]), System.TAILS_NORMAL);
						else
							cg.tails.show(System.getRandFrom(["((( debates on how to kill you, in binary )))",
															"welL AREn'T YOU twO JUST DoiNG DANdY?!"
							]), System.TAILS_NORMAL, "FAILS_pissed");
					}			
					if (framesElapsed > System.SECOND * 7 && EnemyCrystal.totalNumCorrupted == 4)
					{
						levelState++;
						framesElapsed = 0;
						fakeJump();
						portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion(System.getRandFrom(System.SPAWN_STD)), "Portal") as EnemyPortal;
						portal.multiplyCooldowns(5);
						portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion("near_orbit"), "Portal") as EnemyPortal;
						portal.multiplyCooldowns(12);
						portal.setScale(0.5);
						portal.setHPmax(100);
						portal = cg.level.spawn( { }, cg.level.getRandomPointInRegion("medium_orbit"), "Portal") as EnemyPortal;
						portal.multiplyCooldowns(12);
						portal.setScale(0.5);
						portal.setHPmax(100);
						cg.tails.show("Keep it up! The last 2 cores are coming out now!", System.TAILS_NORMAL);
						cg.addSparks(5);
						SoundManager.playSFX("sfx_electricShock");
						cg.camera.setShake(45);
					}
				break;
				case 26:		// all 6 crystals up
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("hoW-- ABOTUUT uu   JUST DIEEE ?? .. !", System.TAILS_NORMAL, "FAILS_pissed");
							crystals[3].corrupt(true);
							crystals[1].corrupt();
							EnemyCrystal.dTheta = 0.65;
							crystals.push(cg.addToGame(new EnemyCrystal(cg, new SWC_Enemy(), {"theta": EnemyCrystal.globalTheta + 120} ), System.M_ENEMY));
							crystals.push(cg.addToGame(new EnemyCrystal(cg, new SWC_Enemy(), {"theta": EnemyCrystal.globalTheta + 300} ), System.M_ENEMY));
							cg.addSparks(2);
							SoundManager.playSFX("sfx_electricShock");
							cg.camera.setShake(10);
							spawnEnemy("Amoeba", 4, System.SPAWN_AMOEBA, {"am_size": 0});
						break;
					}
					if (framesElapsed > System.SECOND * 20 && framesElapsed % (System.SECOND * 35) == 0)
					{
						if (framesElapsed % (System.SECOND * 70) == 0)
						{
							cg.tails.show(System.getRandFrom(["i\"LL TAKE THOSE BACK THANKS",
															"red is SUC+__H A NICE rCOLOR!!"
							]), System.TAILS_NORMAL, "FAILS_incredulous");
							System.getRandFrom(crystals).corrupt(true);
							System.getRandFrom(crystals).corrupt();
							for (s = 0; s < 3; s++)
								spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Manta", "Breeder", "Spider"]), 1);
						}
						else
						{
							portal = cg.level.spawn( {}, cg.level.getRandomPointInRegion("medium_orbit"), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(4);
							portal.setHPmax(220);
							portal = cg.level.spawn( {}, cg.level.getRandomPointInRegion("near_orbit"), "Portal") as EnemyPortal;
							portal.multiplyCooldowns(7);
							portal.setScale(0.5);
							portal.setHPmax(120);
							if (Math.random() > .5)
								cg.tails.show(System.getRandFrom(["We've almost got it!",
																"We gotta get all 6 cores back!"
									]), System.TAILS_NORMAL);
							else
								cg.tails.show(System.getRandFrom(["you caNT KEEP UP so JUST GIVEUP",
																"A-hAHAHAHAHAHAHA HAAHAHAHAHAHA!!!"
								]), System.TAILS_NORMAL, "FAILS_pissed");
						}
					}	
					if (framesElapsed > System.SECOND * 6)
					{
						if (EnemyCrystal.totalNumCorrupted == 6)
						{
							levelState = 50;
							framesElapsed = 0;
							cg.tails.show("STUPID !^CSTUPID !^C STUPID !^C", System.TAILS_NORMAL, "FAILS_incredulous");
							tugOfWar = false;
							fakeJump();
							cg.addSparks(5);
							SoundManager.playSFX("sfx_electricShock");
							cg.camera.setShake(65);
							cg.bossBar.setPercent(.01);
						}
					}
				break;
				case 50:		// victory
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("That's right .. and now for the last step!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 12:
							for (s = 0; s < crystals.length; s++)
								crystals[s].corrupt();
							cg.tails.show("Charge up all of the crystals one last time for me!", System.TAILS_NORMAL);
						break;
					}
					if (framesElapsed > System.SECOND * 12)
					{
						if (framesElapsed % (System.SECOND * 4) == 0)
							cg.tails.show(System.getRandFrom(["HE-EY WHAT? Nnoo, DnoT TOUCH THOSE COR=e#s!",
																"YuorE nOT GOnnAS DELEE _YOUR FRIEND FAILS, ARE YA?",
																"CA-WNT DeuIE; duONT' DO IT",
																"s-__but I HAVENT KISllED YHOU YET",
																"WN_O dOOO thaT! Dos't DO2(( IT! sEL! DIEDIEDIE",
																"STOPIT STOPIT STOPIT_ startit _STOPIT STOPIT",
																"REFERR! REFERR! EOL NULNUL NULPTR@42C0EE!",
																"I'm OF YOU SICK. Just already AWAY GO!",
																"GIVE. UP. You'INTERRUPTINGCOWnna be able to win!",
																"voidnullvoid ERR! sHOW's mY HAIR DOIN__?",
																"PUNY, pUNy, INF$!IOR BEINvS! AND TAILS< TOO",
																"Para espanol, presione deux-FRENCH WHUT?.",
																"Collect CAlls are free! Just _DIEE!!_ pound 5.",
																"I STILL hAVE YOUR BROWSER _iSTORY.!!",
																"DIE, diE, im goNNA DIE?!!??"
											]), System.SECOND * 2, "FAILS_incredulous");
						if (EnemyCrystal.totalNumCorrupted == 6)
						{
							cg.tails.show("Goodbye, FAILS!", System.TAILS_NORMAL);
							framesElapsed = 0;
							levelState++;
						}
					}
				break;
				case 51:
					switch (framesElapsed)
					{
						case 30:
							crystals[0].playBlastEffect();
						break;
						case 50:
							crystals[1].playBlastEffect();
						break;
						case 70:
							crystals[2].playBlastEffect();
						break;
						case 90:
							crystals[3].playBlastEffect();
						break;
						case 110:
							crystals[4].playBlastEffect();
						break;
						case 130:
							crystals[5].playBlastEffect();
							cg.tails.show("YOU TWO ARe still st u p   i  d    --!", 60, "FAILS_incredulous");
						break;
						case System.SECOND * 6:
							levelState++;
							framesElapsed = 0;
							consoleSlip.fakeJumpLbl = "long";
							consoleSlip.fakeJumpNext = true;
							cg.ship.slipRange = 0;
							cg.gui.tf_distance.text = "Supr Jmp";
							cg.playJumpEffect("long");
							cg.bossBar.setPercent(0);
							cg.visualEffects.applyModuleDistortion(0, true);
							cg.visualEffects.applyModuleDistortion(1, true);
							cg.gameOverAnnouncer = "TAILS";
							cg.managerMap[System.M_BOARDER].killAll();
							cg.managerMap[System.M_ENEMY].killAll();
							cg.managerMap[System.M_FIRE].killAll();
							cg.alerts.isCorrupt = false;
							cg.ship.setBossOverride(false);
							SoundManager.stopBGM();
							EnemyCrystal.dTheta = 0.1;
						break;
					}
					if (EnemyCrystal.dTheta < 3.5)
						EnemyCrystal.dTheta += 0.025;
				break;
				case 52:
					if (framesElapsed == 1)
						SoundManager.crossFadeBGM("bgm_1a_here_we_go");
					if (framesElapsed == System.SECOND * 8)
					{
						cg.tails.show("Well, I'm glad that's over!\nGreat work, both of you!\n\nI've fixed the slipdrive, so when you're ready, let's get outta here!");
						consoleSlip.forceOverride = false;
						consoleSlip.setArrowDifficulty(0);
						consoleSlip.fakeJumpNext = true;
						cg.serious = false;
					}
					if (framesElapsed > System.SECOND * 8 && framesElapsed % (System.SECOND * 13) == 0)
						cg.tails.show(System.getRandFrom(["Nice job! Let's get back to the real dimension!",
														  "Time to get out of Slipspace. Spool up that slipdrive!",
														  "C'mon, let's get outta here!"
									]), System.TAILS_NORMAL);
					if (!consoleSlip.fakeJumpNext)
					{
						levelState++;
						framesElapsed = 0;
						cg.gui.mc_progress.setSectorProgress(13);
						cg.level.sectorIndex = 13;
						cg.background.setStyle("endworld");
						cg.background.resetBackground();
						consoleSlip.forceOverride = true;
						SoundManager.playBGM("bgm_victory", System.VOL_BGM, 1);
						for (s = 0; s < crystals.length; s++)
							crystals[s].stubborn = false;
						cg.managerMap[System.M_ENEMY].killAll();
					}
				break;
				case 53:
					if (framesElapsed == System.SECOND * 4)
					{
						cg.tails.show("That's it! We made it! We did it!", System.TAILS_NORMAL);
						cg.game.mc_ship.mc_shipBase.gotoAndPlay("win");
					}
					else if (framesElapsed == System.SECOND * 15)
					{
						cg.tails.show("See you two next time!", System.TAILS_NORMAL * 2);
						cg.gui.mc_win.gotoAndPlay(2);
						levelState = 100;
					}
				break;
			}
			
			if (tugOfWar)
				handleLastPhase();
		}

		/**
		 * Corrupt a random console and instantly make it fixable
		 */
		private function corruptRandom():void
		{
			var c:ABST_Console;
			do {
				c = System.getRandFrom(cg.consoles);
			} while (c.corrupted || c is Omnitool);
			c.setCorrupt(true);
			c.setReadyToFormat(true);
		}
		
		/**
		 * Things that need to be constantly updated for the final phase
		 */
		private function handleLastPhase():void
		{
			var limMin:Number = Math.max(0.01, 0.5 - EnemyCrystal.numCrystals * (.0833333));
			var limMax:Number = Math.min(   1, 0.5 + EnemyCrystal.numCrystals * (.0833333));
							
			// add combat explosions
			if (Math.random() > .85)
			{
				var r:Number = Math.random();
				var spawnFX:ABST_Object;
				var pos:Point = cg.getRandomNearLocation();
				if (r < .5 && r > limMin)
				{
					spawnFX = cg.addDecor("spawn", { "x":pos.x, "y":pos.y, "scale":System.getRandNum(0.25, 3) } );
					spawnFX.mc_object.base.setTint(System.COL_TAILS);
				}
				else if (r > .5 && r < limMax)
				{
					spawnFX = cg.addDecor("spawn", { "x":pos.x, "y":pos.y, "scale":System.getRandNum(0.25, 3) } );
					spawnFX.mc_object.base.setTint(System.COL_RED);
				}
			}
			
			cg.bossBar.setPercent(1 - (EnemyCrystal.totalNumCorrupted + 6) / 12);
		}
	}
}