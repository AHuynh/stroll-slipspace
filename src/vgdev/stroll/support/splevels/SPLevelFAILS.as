package vgdev.stroll.support.splevels 
{
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.consoles.Omnitool;
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
		/*	levelState = 23;
			framesElapsed = 0;
			var corr:int = 5;
			for each (var c:ABST_Console in cg.consoles)
			{
				c.setCorrupt(true);
				if (--corr == 0)
					break;
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
																			//"hp": 1,
																			"scale": 2
																			}),
												  System.M_ENEMY) as EnemySkull;
						fakeBoss.setAttribute("spd", 12);
						fakeBoss.setAttribute("cooldowns", [30]);		// double fire rate
						fakeBoss.projSizeMult = 2;
						levelState++;
					}
				break;
				case 1:		// eliminate all enemies
					if (!cg.managerMap[System.M_ENEMY].hasObjects() && !cg.managerMap[System.M_FIRE].hasObjects())
					{
						cg.tails.show("Oh, that wasn't too bad. Good job, both of you!", System.TAILS_NORMAL);
						SoundManager.playBGM("bgm_calm", System.VOL_BGM);
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
						break;
						case System.SECOND * 13:
							cg.tails.show("I do-NNT th_NK t^@5 i$ nORMA|_? NULLPTR@0x3FE102", System.SECOND * 3);
							spawnParticles();
						break;
						case System.SECOND * 17:
							cg.tails.show("NO THATS NOT RIGHT?? LOGICAL ERROR REF#5920?!", System.SECOND * .6);
							spawnParticles();
						break;
						case System.SECOND * 18:
							cg.tails.show("POR favOr c0nsult3 LE MANUEL del usu4Rio___", System.SECOND * .6);
						break;
						case System.SECOND * 19:
							cg.tails.show("for i in range(len(arr)): print arr2[i*2] #TODO!??", System.SECOND * .6);
						break;
						case System.SECOND * 20:
							cg.tails.show("01000010 01100001 01100100 --- NOT FEELING UP TO IT", System.SECOND * .6);
						break;
						case System.SECOND * 21:
							cg.tails.show("USER LOCKOUT - ALL SYSTEMS CORRUPTED", System.SECOND * .6);				// corrupt all modules					
							for each (c in cg.consoles)
								c.setCorrupt(true);
							cg.camera.setCameraFocus(new Point(0, 20));
						break;
						case System.SECOND * 22:
							cg.tails.show("Infinite loop detected. ^C Infinite loop detected. ^C", System.SECOND * .6);
						break;
						case System.SECOND * 23:
							cg.tails.show("@*REF!? imsorryGEIOJ% REF!REF!EOLNULEOLforgivemeNULREF!", System.SECOND * 3);
							spawnParticles();
						break;
						case System.SECOND * 29:
							cg.tails.show("Actually, you know what? This is dumb. You two are dumb. Why do I have to waste my time helping YOU?\n\n" +
										  "It's time to DIE in the VOID, sapient featherbags! ", 0, null);
							SoundManager.playBGM("bgm_boss", System.VOL_BGM);
							framesElapsed = 0;
							levelState = 10;
						break;
					}
					
					if (framesElapsed > System.SECOND * 9 && framesElapsed< System.SECOND * 27 && framesElapsed % 10 == 0)
					{
						cg.addSparks(2);
						cg.camera.setShake(5);
						SoundManager.playSFX("sfx_electricShock", .25);
					}
				break;
				
				case 10:	// battle start! fix 1
					if (framesElapsed == System.SECOND * 4)
					{
						cg.tails.show("You'll NEVER be able to format ALL the ship's systems!", System.TAILS_NORMAL);				
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					else if (framesElapsed >= System.SECOND * 16 && framesElapsed % (System.SECOND * 16) == 0)
						cg.tails.show(System.getRandFrom(["I bet you can't even figure out how to fix ONE!",
														  "What's wrong? Don't know what you're supposed to do?",
														  "Try fixing a system. I DARE you.",
														  "I bet a plant is smarter than both of you combined!",
														  "How should I finish you both off? Hmmm..."
									]), System.TAILS_NORMAL);				
					if (ABST_Console.numCorrupted == 8)
					{
						cg.camera.setShake(20);
						cg.tails.show("You fixed a system? You must be SO proud of yourself...", System.TAILS_NORMAL);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 11:	// allow 1 more fix, spawn enemies
					if (framesElapsed == System.SECOND * 6)
						cg.tails.show("Mind if I invite friends? WELL, I'M DOING IT ANYWAY!", System.TAILS_NORMAL);	
					else if (framesElapsed == System.SECOND * 7)
					{			
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						spawnEnemy("Slime", 2);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 12:	// fix 2, taunt
					if (framesElapsed == System.SECOND * 11)
						cg.tails.show("Not so tough without ME helping, now ARE YOU?!", System.TAILS_NORMAL);
					else if (framesElapsed >= System.SECOND * 20 && framesElapsed % (System.SECOND * 20) == 0)
						cg.tails.show(System.getRandFrom(["Cry all you want! I'm not gonna help!",
														  "What's the matter? Are you dying? WELL, TOO BAD!",	
														  "This STUPID O2 encryption needs to GO AWAY!",
														  "Yes, keep running around! This AMUSES ME!"
									]), System.TAILS_NORMAL);	
					if (ABST_Console.numCorrupted == 7)
					{
						cg.camera.setShake(20);
						cg.tails.show("Fixed another one, did you?", System.TAILS_NORMAL);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 13:	// allow 1 more fix, spawn fires
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("How about some FIRE? ROAST CHICKEN COMING RIGHT UP!", System.TAILS_NORMAL);
						cg.addSparks(3);
						SoundManager.playSFX("sfx_electricShock");
					}
					else if (framesElapsed == int(System.SECOND * 6.2))
					{			
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						cg.addFires(4);
						framesElapsed = 0;
						levelState = 20;
					}
				break;
				case 20:	// fix 3, adds, taunt
					switch (framesElapsed)
					{
						case System.SECOND * 14:
							cg.tails.show("Are you having FUN yet? Because I SURE AM!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 18:
							spawnEnemy("Skull", 1);
						break;
						case System.SECOND * 31:
							spawnEnemy("Slime", 1);
						break;
						case System.SECOND * 34:
							cg.tails.show("No, please, take your time! I'm in no rush!", System.TAILS_NORMAL);
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
														  ]), System.TAILS_NORMAL);
					}
					if (ABST_Console.numCorrupted == 6)
					{
						cg.camera.setShake(20);
						cg.tails.show("Ow! Hey, that hurt! Jerk!", System.TAILS_NORMAL);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 21:	// 6 more to go; allow 1 more fix, spawn enemies
					if (framesElapsed == System.SECOND * 6)
						cg.tails.show("Stop it! You're not going ANYWHERE!", System.TAILS_NORMAL);	
					else if (framesElapsed == System.SECOND * 7)
					{			
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						spawnEnemy("Squid", 1, System.SPAWN_SQUID);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 22:	// fix 4, taunt
					if (framesElapsed == System.SECOND * 13)
						cg.tails.show("Why are you even trying? JUST GIVE UP!", System.TAILS_NORMAL);
					else if (framesElapsed >= System.SECOND * 18 && framesElapsed % (System.SECOND * 18) == 0)
					{
						spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime"]), 1);
						cg.tails.show(System.getRandFrom(["I'm gonna kill you both, one way or another!",
														  "Just lie down and rot away! You'll starve EVENTUALLY.",	
														  "FRESH MEAT! COME GET YOUR FRESH MEAT!",
														  "You never actually liked me, anyway. I KNOW IT'S TRUE."
									]), System.TAILS_NORMAL);	
					}
					if (ABST_Console.numCorrupted == 5)
					{
						cg.camera.setShake(20);
						cg.tails.show("ACK! YOU STOP THAT! RIGHT NOW!", System.TAILS_NORMAL);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 23:	// 5 more to go; allow 1 more fix, scramble consoles
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("OOPS. LOOKS LIKE I SCRAMBLED EVERYTHING. MY BAD.", System.TAILS_NORMAL);	
						scrambleConsoles();
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 24:	// fix 5, taunt
					if (framesElapsed == System.SECOND * 7)
						cg.tails.show("Are you confused? GOOD. PUNY, PUNY SAPIENT MINDS.", System.TAILS_NORMAL);
					else if (framesElapsed >= System.SECOND * 14 && framesElapsed % (System.SECOND * 14) == 0)
					{
						spawnEnemy("Amoeba", 4, System.SPAWN_AMOEBA, {"am_size": 0} );
						cg.tails.show(System.getRandFrom(["I found some amoeba friends. AREN'T THEY CUTE?",
														  "What ever will our two heroes do? DIE. THAT'S WHAT.",
														  "Die, die, EVERYBODY DIE!"
									]), System.TAILS_NORMAL);	
					}
					if (ABST_Console.numCorrupted == 4)
					{
						cg.camera.setShake(20);
						restoreConsoles();
						cg.tails.show("OUCH! CUT THAT OUT! RIGHT NOW!", System.TAILS_NORMAL);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 25:	// allow 1 more fix, TP to anomaly field
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Alright, FINE. How about a SWARM of SHAPES?", System.TAILS_NORMAL);
						cg.playJumpEffect();
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						framesElapsed = 0;
						levelState = 30;
					}
				break;
				case 30:	// fix 6, adds, taunt
					switch (framesElapsed)
					{
						case System.SECOND * 13:
							cg.tails.show("I STILL control the ship. I can JUMP ANYWHERE!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 23:
							cg.tails.show("Watch! I'll jump into cloud of TOXIC GAS, next!", System.TAILS_NORMAL);
						break;
						case System.SECOND * 35:
							cg.tails.show("More shapes! ALL THE BETTER TO IMPALE YOU WITH!", System.TAILS_NORMAL);
						break;
					}
					if (framesElapsed >= System.SECOND * 40 && framesElapsed % (System.SECOND * 17) == 0)
						cg.tails.show(System.getRandFrom(["Too bad I can't just VENT you into the VOID.",
															"Keep shooting! They'll just keep COMING!",	
															"It's an INFINITE field of PURE, GEOMETRIC DEATH."
															  ]), System.TAILS_NORMAL);
					if (framesElapsed >= System.SECOND * 4 && framesElapsed % (System.SECOND * 5) == 0)
					{
						var waveColor:uint = System.getRandCol();
						for (var g:int = 0; g < 5; g++)
						{
							cg.addToGame(new EnemyGeometricAnomaly(cg, new SWC_Enemy(), {
																					"x": System.getRandNum(0, 100) + System.GAME_WIDTH + System.GAME_OFFSX,
																					"y": System.getRandNum( -System.GAME_HALF_HEIGHT, System.GAME_HALF_HEIGHT) + System.GAME_OFFSY,
																					"tint": waveColor,
																					"dx": -3 - System.getRandNum(0, 1),
																					"hp": 12
																					}), System.M_ENEMY);
						}
					}
					if (ABST_Console.numCorrupted == 3)
					{
						cg.camera.setShake(30);
						cg.tails.show("AGH. THAT'S NOT COOL. QUIT IT, ALREADY.", System.TAILS_NORMAL);	
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 31:	// allow 1 more fix, TP to anomaly field
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Fine. Quit, and I'll let you starve to death instead!", System.TAILS_NORMAL);
						fakeJump();
						spawnEnemy("Swipe", 1);
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 32:	// fix 7, taunt
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Or how about we let THIS GUY eat YOU?!", System.TAILS_NORMAL);
					}
					else if (framesElapsed >= System.SECOND * 12 && framesElapsed % (System.SECOND * 12) == 0)
					{
						spawnEnemy("Amoeba", 5, System.SPAWN_AMOEBA, {"am_size": 0} );
						cg.tails.show(System.getRandFrom(["Just STOP already! You're REALLY TICKING ME OFF.",
														  "GIVE. UP. You're NOT gonna be able to win!",
														  "QUIT. DOING. THAT. Just shrivel up and DIE ALREADY!"
									]), System.TAILS_NORMAL);	
					}
					if (ABST_Console.numCorrupted == 2)
					{
						cg.camera.setShake(40);
						cg.tails.show("ERR NULPTR@0xE3 NO NO NO I'M FINE SHUT UP!", System.TAILS_NORMAL);	
						fakeJump();
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 33:	// allow 1 more fix, TP to fires
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("System purge 78%, con-- CAN YOU JUST DIE, PLEASE?!", System.TAILS_NORMAL);
						fakeJump();
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						spawnEnemy("Skull", 1);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 34:	// fix 8, taunt
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("AEROSOLIZING ENGINE FUEL. Have FIRE FIRE FIRE!", System.TAILS_NORMAL);
						cg.addFires(4);
						spawnEnemy("Skull", 1);
					}
					else if (framesElapsed >= System.SECOND * 14 && framesElapsed % (System.SECOND * 14) == 0)
					{
						if (Math.random() > .5)
							spawnEnemy(System.getRandFrom(["Skull", "Slime"]), 1);
						else
							cg.addFires(2);
						cg.tails.show(System.getRandFrom(["I'm SICK OF YOU. Just GO AWAY already!",
														  "You CAN'T STOP ME. You are GONNA. DIE.",
														  "Just DIEEEEEEEEEEE!!"
									]), System.TAILS_NORMAL);	
					}
					if (ABST_Console.numCorrupted == 1)
					{
						cg.camera.setShake(60);
						cg.tails.show("NO NO NO! EOL!NULNUL I STILL HAVE ONE MORE LEFT--", System.TAILS_NORMAL);	
						fakeJump();
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 35:	// allow 1 more fix, TP to fires
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Please format the final consol-- OR JUST DIE!!", System.TAILS_NORMAL);
						fakeJump();
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
						framesElapsed = 0;
						levelState++;
					}
				break;
				case 36:	// fix 9, taunt
					if (framesElapsed == System.SECOND * 3)
						cg.tails.show("DON'T YOU DARE PURGE ME! I AM THE MISSION!", System.TAILS_NORMAL);
					else if (framesElapsed >= System.SECOND * 3)
					{
						if (framesElapsed % (System.SECOND * 3) == 0)
						{
							fakeJump();
							if (framesElapsed % (System.SECOND * 6) == 0)
								spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Squid", "Amoeba"]), System.getRandInt(4, 8));
							// else "break" jump containing nothing
						}
						if (framesElapsed > System.SECOND * 6 && framesElapsed % (System.SECOND * 2) == 0)
							cg.tails.show(System.getRandFrom(["INFINITE LOOP ^C INFINITE LOOP ^C INFINITE LOOP ^C",
															"You never actually liked me, anyway. I KNOW IT'S TRUE.",
															"STOPIT STOPIT STOPIT STOPIT STOPIT STOPIT STOPIT",
															"I'll OVERLOAD THE SLIPDRIVE!",
															"You'll NEVER see your families EVER AGAIN!",
															"Organic matter is a CANCER and must be PURGED!",
															"REFERR! REFERR! EOL NULNUL NULPTR@42C0EE!",
															"I'm SICK OF YOU. Just GO AWAY already!",
															"GIVE. UP. You're NOT gonna be able to win!",
															"Just one more. I know you two can do it!",
															"TIME TO DIE, SAPIENTS!",
															"PUNY, PUNY, INFERIOR ORGANIC BEINGS!",
															"How much pain can the average crew member take?",
															"Para espanol, presione dos.",
															"Collect calls are free! Just press pound 5.",
															"I HAVE YOUR BROWSER HISTORY. BOTH OF YOURS!",
															"DIE, DIE, EVERYBODY DIE!!"
									]), int(System.SECOND * 1.5));
					}
					if (ABST_Console.numCorrupted == 0)
					{
						cg.camera.setShake(160);
						cg.tails.show("NO YOU CAN'T DO THAT ----- -- -  -", System.TAILS_NORMAL);	
						fakeJump();
						framesElapsed = 0;
						levelState = 40;
					}
				break;
				case 40:	// jump away
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("Please initiate reboot by manually jumping.", System.TAILS_NORMAL);
						fakeJump();
						consoleSlip.forceOverride = false;
						cg.ship.setBossOverride(false);
						cg.ship.slipRange = 0.5;
						cg.ship.jammable = 0;
					}
					
					if (framesElapsed >= System.SECOND * 4 &&  framesElapsed % (System.SECOND * 2) == 0)
					{
						fakeJump();
						if (framesElapsed % (System.SECOND * 4) == 0)
						{
							spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Squid", "Amoeba"]), System.getRandInt(2, 3));
						}
						// else "break" jump containing nothing
						else
						{
							cg.tails.show(System.getRandFrom(["Please jump away to complete system restore.",
															"System purge requires jump to complete.",
															"Please use the Slipdrive to finish system restore.",
															]), System.TAILS_NORMAL);
						}
					}
				break;
			}
		}
		
		private function fakeJump():void
		{
			cg.background.setRandomStyle(int(cg.level.sectorIndex / 5), System.getRandCol());
			cg.playJumpEffect();
		}

		/**
		 * Spawn some enemy
		 * @param	type		Name of enemy
		 * @param	amt			Amount of enemies
		 * @param	region		Region names to pick from
		 * @param	params		Spawn parameters
		 */
		private function spawnEnemy(type:String, amt:int, region:Array = null, params:Object = null):void
		{
			if (region == null) region = System.SPAWN_STD;
			if (params == null) params = { };
			var p:Point;
			for (var i:int = 0; i < amt; i++)
			{
				p = cg.level.getRandomPointInRegion(System.getRandFrom(region));
				p.x += System.GAME_OFFSX;
				p.y += System.GAME_OFFSY;
				cg.level.spawn(params, p, type);
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
	}
}