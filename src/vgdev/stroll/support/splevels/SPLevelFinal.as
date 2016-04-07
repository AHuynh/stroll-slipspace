package vgdev.stroll.support.splevels 
{
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
	
	/**
	 * Final boss, Sector 12
	 * @author Alexander Huynh
	 */
	public class SPLevelFinal extends ABST_SPLevel 
	{
		private var levelState:int = 0;				// state machine helper
		private var consoleSlip:ConsoleSlipdrive;
		
		private var tugOfWar:Boolean = false;		// flag for final phase
		private var morale:Number = 0.5;			// TAILS vs FAILS
		private var momentum:Number = 0.0001;		// amount to change morale by per frame (negative is winning)
		private const MOMENTUM_MAX:Number = 0.0002;
		private const D_MOMENTUM:Number = 0.0000003;// amount to change momentum by per frame
		private const FIX_MOMENTUM:Number = -0.07;	// amount to change momentum on a successful console fix
		
		private var checkFormat:Boolean = false;	// if true, a fixable console is eligible to increase momentum
		private var freeCorrupts:int = -1;			// if not -1, timer to corrupt a new console after one is fixed
		
		public function SPLevelFinal(_cg:ContainerGame) 
		{
			super(_cg);
			
			consoleSlip = cg.game.mc_ship.mc_console_slipdrive.parentClass;
			consoleSlip.fakeJumpNext = true;
			cg.ship.slipRange = 2;
			
			// DEBUG CODE
			levelState = 6;
			framesElapsed = 20 * 30;
			//consoleSlip.setArrowDifficulty(12);
			//cg.ship.setBossOverride(false);
			//cg.ship.slipRange = 0.5;
			//cg.ship.jammable = 999;
			//cg.bossBar.startFight();
			//consoleSlip.forceOverride = false;
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
					if (!consoleSlip.fakeJumpNext)
					{
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 1:		// initial jump failed
					if (framesElapsed == System.SECOND * 2)
					{
						cg.tails.show("Error. Slipdrive malfunction. Now troubleshooting.", System.TAILS_NORMAL, "HEADS");
						cg.ship.jammable = 999;
						cg.ship.slipRange = 15;
					}
					else if (framesElapsed == System.SECOND * 8)
					{
						cg.tails.show("Anomaly detected. Remove anomaly to continue.", System.TAILS_NORMAL, "HEADS");
						cg.level.spawn( { }, new Point(450, -270), "Portal");
					}
					if (framesElapsed > System.SECOND * 8 && cg.managerMap[System.M_ENEMY].numObjects() < cg.ship.jammable)
					{
						cg.tails.show("Malfunction resolved. Retry slipdrive now.", System.TAILS_NORMAL, "HEADS");
						levelState++;
						consoleSlip.fakeJumpNext = true;
					}
				break;
				case 2:
					if (!consoleSlip.fakeJumpNext)
					{
						levelState++;
						framesElapsed = 0;
						cg.ship.slipRange = 25;
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
						}
						else if (framesElapsed % (System.SECOND * 40) == 0)
							spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Spider", "Manta"]), 1);
					}
				break;
				case 4:
					if (!consoleSlip.fakeJumpNext)
					{
						levelState++;
						framesElapsed = 0;
						cg.ship.slipRange = 10;
						consoleSlip.forceOverride = true;
						addShards(3);
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
					}
				break;
				case 10:
					if (framesElapsed == 1)
					{
						cg.bossBar.startFight();
						cg.alerts.isCorrupt = true;
						cg.visualEffects.applyModuleDistortion(0, false, 0);
						cg.visualEffects.applyModuleDistortion(1, false, 0);
					}
					if (framesElapsed == System.SECOND * 3)
					{
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
					else if (framesElapsed > System.SECOND * 3 && framesElapsed % (System.SECOND * 22) == 0)
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
						cg.bossBar.setPercent(.8);
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
						cg.bossBar.setPercent(.65);
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
						{
							t = System.getRandNum(0, 360);
							portal = cg.level.spawn( { }, new Point(), "Portal") as EnemyPortal;
							portal.ELLIPSE_A = System.ORBIT_2_X;
							portal.ELLIPSE_B = System.ORBIT_2_Y;
							portal.mc_object.x = System.ORBIT_2_X * Math.cos(System.degToRad(t));
							portal.mc_object.y = System.ORBIT_2_Y * Math.sin(System.degToRad(t));
							portal.theta = t;
							portal.dTheta = 0.2;
							portal.multiplyCooldowns(3);	
						}
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
						cg.bossBar.setPercent(.4);
						cg.tails.show("NO! I\"M STILL IN CON@TROL__!!", System.TAILS_NORMAL, "FAILS_incredulous");
						cg.visualEffects.applyBGDistortion(false);
						framesElapsed = 0;
						levelState++;
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
							spawnEnemy("Spider", 10);
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
						levelState++;
						framesElapsed = 0;
					}
				break;
				case 17:
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("HEY WHAT?!", System.SECOND * 2, "FAILS_incredulous");
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
						break;
						case System.SECOND * 18:
							cg.tails.show("Hey, again! Sorry I took so long to fix myself.\n\nI knew you'd make it!\n\nAlright, just one moment! I'll handle FAILS.", 0);
							levelState = 20;
							framesElapsed = 0;
							tugOfWar = true;
							cg.ship.jammable = 0;
							consoleSlip.forceOverride = false;
							consoleSlip.fakeJumpNext = true;
						break;
					}
					if (framesElapsed > System.SECOND * 6 && framesElapsed < System.SECOND * 12 && framesElapsed % 15 == 0)
					{
						cg.addSparks(2);
						cg.camera.setShake(5);
						SoundManager.playSFX("sfx_electricShock", .25);
					}
				break;
				case 20:		// FAILS vs TAILS
					switch (framesElapsed)
					{
						case 1:
							cg.bossBar.setPercent(.5);
						break;
						case System.SECOND * 2:
							cg.tails.show("Check the BOSS bar down there! We need to push it all the way to 0%!\n\nOh! And use the slipdrive to jump away if there are too many enemies, OK?", 0);
						break;
						case System.SECOND * 9:
							cg.tails.show("Oh, it's YOU again. Didn't I KILL YOU?", System.TAILS_NORMAL, "FAILS_pissed");
							corruptRandom();
						break;
						case System.SECOND * 16:
							cg.tails.show("This is my job! Get out of here, you phony!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 24:
							cg.tails.show("STOP TOUCHING ME, YOU BLUE IDIOT!", System.TAILS_NORMAL, "FAILS_pissed");
						break;
						case System.SECOND * 35:
							cg.tails.show("You really made a mess, didn't you?!", System.TAILS_NORMAL);
						break;
					}
					if (framesElapsed > System.SECOND * 9 && ABST_Console.numCorrupted == 0)
					{
						levelState++;
						framesElapsed = 0;
						cg.tails.show("OW! ALRight, T0_UGH BIRDS. YOU AS4#D FOR IT.", System.TAILS_NORMAL, "FAILS_pissed");
					}
					if (framesElapsed > System.SECOND * 40 && framesElapsed % (System.SECOND * 15) == 0)
						cg.tails.show(System.getRandFrom(["You've got to format that console!",
														"I need your help! Format that console!"
							]), System.TAILS_NORMAL);
				break;
				case 21:
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("YOu 2 STAY ouT OF THI5. PLAY _ITH Th1S INSTE^D!", System.TAILS_NORMAL, "FAILS_pissed");
							t = System.getRandNum(0, 360);
							portal = cg.level.spawn( { }, new Point(), "Portal") as EnemyPortal;
							portal.ELLIPSE_A = System.ORBIT_1_X;
							portal.ELLIPSE_B = System.ORBIT_1_Y;
							portal.mc_object.x = System.ORBIT_1_X * Math.cos(System.degToRad(t));
							portal.mc_object.y = System.ORBIT_1_Y * Math.sin(System.degToRad(t));
							portal.theta = t;
							portal.dTheta = 0.3;
							portal.multiplyCooldowns(3);	
						break;
						case System.SECOND * 11:
							messWithConsole();
						break;
						case System.SECOND * 18:
							cg.tails.show("That's not fair! You big bully!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 27:
							corruptRandom();
							cg.tails.show("P2rsonally, I think RED is a NICER LOOK1--", System.TAILS_NORMAL, "FAILS_pissed");
							addSuiciders(2);
							addShards(2);
						break;
						case System.SECOND * 34:
							cg.tails.show("Hey, I just fixed that! And I'll fix it again!", System.TAILS_NORMAL);
						break;
					}
					if (framesElapsed > System.SECOND * 6 && ABST_Console.numCorrupted == 0)
					{
						levelState++;
						framesElapsed = 0;
						cg.tails.show("AGAI__N?! MAN I haAATE whENN THAT hsappeNSS!", System.TAILS_NORMAL, "FAILS_incredulous");
					}
					if (framesElapsed > System.SECOND * 40 && framesElapsed % (System.SECOND * 15) == 0)
						cg.tails.show(System.getRandFrom(["Hey! Get that one, too, guys!",
														"You've gotta do something! Help me out!"
							]), System.TAILS_NORMAL);
				break;
				case 22:
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("Irj? I SAID STOP FIGHTING ALR9=== OW!!", System.TAILS_NORMAL, "FAILS_incredulous");
						break;
						case System.SECOND * 12:
							cg.tails.show("Wow, this is definitely getting deleted. Bye!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 17:
							messWithConsole();
						break;
						case System.SECOND * 24:
							corruptRandom();
							cg.tails.show("HOW ABOUT SOME BATTLE DROIDS! Did't EXPECT THAT?!", System.TAILS_NORMAL, "FAILS_incredulous");
							addAssassins(2);
							addShards(3);
						break;
						case System.SECOND * 31:
							cg.tails.show("Hey, I just fixed that! And I'll fix it again!", System.TAILS_NORMAL);
						break;
					}
					if (framesElapsed > System.SECOND * 24 && ABST_Console.numCorrupted == 0)
					{
						levelState++;
						framesElapsed = 0;
						cg.tails.show("NULL REFERENCE ERROR I-- SHUT UP!", System.TAILS_NORMAL, "FAILS_incredulous");
						t = System.getRandNum(0, 360);	
						portal = cg.level.spawn( { }, new Point(), "Portal") as EnemyPortal;
						portal.ELLIPSE_A = System.ORBIT_1_X;
						portal.ELLIPSE_B = System.ORBIT_1_Y;
						portal.mc_object.x = System.ORBIT_1_X * Math.cos(System.degToRad(t));
						portal.mc_object.y = System.ORBIT_1_Y * Math.sin(System.degToRad(t));
						portal.theta = t;
						portal.dTheta = 0.4;
						portal.multiplyCooldowns(3);
					}
					if (framesElapsed > System.SECOND * 35 && framesElapsed % (System.SECOND * 16) == 0)
						cg.tails.show(System.getRandFrom(["Keep it up!",
														"Keep formatting those consoles!"
							]), System.TAILS_NORMAL);
				break;
				case 23:
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("I've had just about enough of you!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 15:
							corruptRandom();
							cg.tails.show("Woudj-a shut2uip SHut up SHUT UP!?!?!", System.TAILS_NORMAL, "FAILS_incredulous");
						break;
						case System.SECOND * 35:
							freeCorrupts = 15;
						break;
					}
					if (framesElapsed > System.SECOND * 35)
					{
						if (framesElapsed % (System.SECOND * 20) == 0)
						{
							if (framesElapsed % (System.SECOND * 40) == 0)
								cg.tails.show(System.getRandFrom(["I bet HEADS can do a better job than you!",
																  "They're gonna beat you! Don't you see?",
																  "You've had enough fun for today! Go away!",
																  "You're gonna be deleted once and for all!",
																  "We're gonna make it out of Slipspace! Watch!",
																  "You won't defeat us!",
																  "I'm gonna make you sorry you did this!"
											]), System.TAILS_NORMAL);
							else
								cg.tails.show(System.getRandFrom(["A-HAHAAHAHH!!! KEEP STRUGGLLLLING!",
																  "I geT TO KILl AL1 __THREE__ OF YOU!!",
																  "Yuo BILUE sduTUPID HE982ADD!.",
																  "a* == &b ? c * *d HUH WHAT DID I DO",
																  "sdfU GONNA DIE &2__ dIE TODAY! auHUHUHAA!",
																  ">:( :O D< >;)  ovo V-V OTL >;D",
																  "INFINIT== INFIN-- LOOP JUST KIDDING-_!"
											]), System.TAILS_NORMAL, "FAILS_incredulous");
						}
					}
					// always a portal up
					if (cg.managerMap[System.M_ENEMY].numObjects() < 1000)
					{
						t = System.getRandNum(0, 360);
						portal = cg.level.spawn( { }, new Point(), "Portal") as EnemyPortal;
						portal.ELLIPSE_A = System.ORBIT_2_X;
						portal.ELLIPSE_B = System.ORBIT_2_Y;
						portal.mc_object.x = System.ORBIT_2_X * Math.cos(System.degToRad(t));
						portal.mc_object.y = System.ORBIT_2_Y * Math.sin(System.degToRad(t));
						portal.theta = t;
						portal.dTheta = 0.4;
						portal.multiplyCooldowns(2);
					}
				break;
				case 30:		// victory
					switch (framesElapsed)
					{
						case System.SECOND * 6:
							cg.tails.show("That's right .. and now for the last step!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 12:
							cg.game.mc_ship.mc_console_navigation.parentClass.setCorrupt(true);
							cg.game.mc_ship.mc_console_navigation.parentClass.setReadyToFormat(true);
							cg.tails.show("This is the last one! Format her away for good!", System.TAILS_NORMAL);
						break;
					}
					if (framesElapsed > System.SECOND * 12)
					{
						if (framesElapsed % (System.SECOND * 4) == 0)
							cg.tails.show(System.getRandFrom(["HE-EY WHAT? Nnoo, DnoT TOUCH THAT CONS=OL#e!",
															  "YuorE nOT GOnnAS DELEE _YOUR FRIEND FAILS, ARE YA?",
															  "CA-WNT DeuIE; duONT' DO IT",
															  "s-__but I HAVENT KISllED YHOU YET",
															  "WN_O TUouch thaT! Dus't DO2(( IT! sEL!"
										]), System.SECOND * 2, "FAILS_incredulous");
						if (ABST_Console.numCorrupted == 0)
						{
							levelState++;
							framesElapsed = 0;
							consoleSlip.fakeJumpLbl = "long";
							consoleSlip.fakeJumpNext = true;
							cg.ship.slipRange = 0;
							cg.gui.tf_distance.text = "Supr Jmp";
							cg.playJumpEffect("long");
							cg.tails.show("YOU TWO ARe still st u p   i  d    --!", 55, "FAILS_incredulous");
							cg.bossBar.setPercent(0);
							cg.visualEffects.applyModuleDistortion(0, true);
							cg.visualEffects.applyModuleDistortion(1, true);
						}
					}
				break;
				case 31:
					if (framesElapsed == System.SECOND * 8)
					{
						cg.tails.show("Well, I'm glad that's over!\nGreat work, both of you!\n\nI've fixed the slipdrive, so when you're ready, let's get outta here!");
						consoleSlip.forceOverride = false;
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
						cg.level.sectorIndex = 13;
						cg.background.setStyle("homeworld");
						cg.background.resetBackground();
						consoleSlip.forceOverride = true;
					}
				break;
				case 32:
					if (framesElapsed == System.SECOND * 4)
						cg.tails.show("That's it! We made it! We did it!", System.TAILS_NORMAL * 2);
				break;
			}
			
			if (tugOfWar)
				handleLastPhase();
		}
		
		/**
		 * Corrupt a random console, instantly make it fixable, and set the check flag
		 */
		private function corruptRandom():void
		{
			var c:ABST_Console;
			do {
				c = System.getRandFrom(cg.consoles);
			} while (c.corrupted || c is Omnitool);
			c.setCorrupt(true);
			c.setReadyToFormat(true);
			checkFormat = true;
		}
		
		/**
		 * Things that need to be constantly updated for the final phase
		 */
		private function handleLastPhase():void
		{
			momentum = System.changeWithLimit(momentum, D_MOMENTUM, -MOMENTUM_MAX, MOMENTUM_MAX);
			morale = System.changeWithLimit(morale, momentum, 0.011, 1);		// need to win with a fix
						
			// if a corrupted console has been formatted
			if (checkFormat && ABST_Console.numCorrupted == 0)
			{
				checkFormat = false;
				momentum += FIX_MOMENTUM;
				morale = System.changeWithLimit(morale, -0.1, 0.01);
				cg.tails.show(System.getRandFrom(["N-N-N-NOT COOL, YO",
												  "EOL EOL NULREF! REF!YOU STOP THAT NOW",
												  "FAUL-AULT-LUTY LOGGG-C MODULE. I'M FINE.",
												  "294:GOTO a245    ; helper to KILL YOU",
												  "--at && corrupted) return; // OUCH",
												  "OUCH THAT WASNT VERY NICE",
												  ">:( ig02-- gonNA MAKE YOU PA-- PAIN"
							]), System.TAILS_NORMAL, "FAILS_incredulous");
				cg.camera.setShake(20);
				SoundManager.playSFX("sfx_electricShock");
				cg.addSparks(4);
			}
			
			if (freeCorrupts > 0 && ABST_Console.numCorrupted == 0 && --freeCorrupts <= 0)
			{
				corruptRandom();
				freeCorrupts = 45;
			}			
				
			// allow jumps on a cooldown
			if (!consoleSlip.fakeJumpNext)
			{
				consoleSlip.fakeJumpNext = true;
				cg.ship.slipRange = 40;
			}
			
			// win state
			if (morale <= 0.01)
			{
				fakeJump();
				levelState = 30;
				framesElapsed = 0;
				tugOfWar = false;
				cg.tails.show("N-O-OOOOO IMPSOSIPBLE!? -- REF REF!", System.TAILS_NORMAL, "FAILS_incredulous");
				consoleSlip.forceOverride = true;
			}
			
			cg.bossBar.setPercent(morale);
		}
	}
}