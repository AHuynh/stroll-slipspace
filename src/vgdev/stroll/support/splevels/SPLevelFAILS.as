package vgdev.stroll.support.splevels 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.enemies.EnemySkull;
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
			levelState = 10;
			framesElapsed = 0;					
			for each (var c:ABST_Console in cg.consoles)
				c.setCorrupt(true);
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
																			//"hp": 50,
																			"hp": 1,
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
							cg.tails.show("POR FAVOR c0nsult3 LE MANUEL del usu4Rio___", System.SECOND * .6);
						break;
						case System.SECOND * 19:
							cg.tails.show("for i in range(len(arr)): print arr2[i*2]", System.SECOND * .6);
						break;
						case System.SECOND * 20:
							cg.tails.show("01000010 01100001 01100100 NOT FEELING UP TO IT", System.SECOND * .6);
						break;
						case System.SECOND * 21:
							cg.tails.show("USER LOCKOUT - ALL SYSTEMS CORRUPTED", System.SECOND * .6);				// corrupt all modules					
							for each (c in cg.consoles)
								c.setCorrupt(true);
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
				
				case 10:	// battle start!
					if (framesElapsed == System.SECOND * 6)
					{
						cg.tails.show("You'll NEVER be able to format ALL the ship's systems!", System.TAILS_NORMAL);				
						for each (c in cg.consoles)
							c.setReadyToFormat(true);
					}
					
					if (framesElapsed > System.SECOND * 6 && framesElapsed % 30 == 0)
						if (!ConsoleFAILS.puzzleActive)		
							for each (c in cg.consoles)
								c.setReadyToFormat(true);
				break;
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