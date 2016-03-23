package vgdev.stroll.support.splevels 
{
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.consoles.Omnitool;
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
					else if (framesElapsed >= System.SECOND * 27 && framesElapsed % (System.SECOND * 18) == 0)
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
					if (framesElapsed == System.SECOND * 13)
						cg.tails.show("Are you confused? GOOD. PUNY, PUNY SAPIENT MINDS.", System.TAILS_NORMAL);
					else if (framesElapsed >= System.SECOND * 23 && framesElapsed % (System.SECOND * 16) == 0)
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
						//cg.tails.show("OUCH! CUT THAT OUT! RIGHT NOW!", System.TAILS_NORMAL);	
						cg.tails.show("That's it to test for now. There's no more!", System.TAILS_NORMAL);	
						framesElapsed = 0;
						levelState++;
					}
				break;
			}
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