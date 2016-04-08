package vgdev.stroll.support.splevels 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.enemies.EnemyGeometricAnomaly;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.System;
	
	/**
	 * As time goes on, increase the amount of spawned debris
	 * @author Alexander Huynh
	 */
	public class SPLevelAnomalies extends ABST_SPLevel 
	{
		private var nextWave:int = 140;
		private const D_TIME:int = -4;		// frames to decrease nextWave by
		private const MIN_TIME:int = 50;	// minumum delay between spawning waves
		
		private var useColors:Boolean;
		private var waveColor:uint = System.COL_WHITE;
		private var nextColor:int = System.getRandInt(1, 2);		// wait this many waves before changing colors
		
		private var reminder:Boolean = true;
		
		public function SPLevelAnomalies(_cg:ContainerGame, _useColors:Boolean) 
		{
			super(_cg);
			useColors = _useColors;
			
			if (useColors)
				waveColor = System.getRandCol();
		}
		
		override public function step():void 
		{
			super.step();
			
			if (framesElapsed < nextWave)
				return;
			
			// create debris
			var spawn:EnemyGeometricAnomaly;
			for (var i:int = 0; i < 4; i++)
			{
				spawn = new EnemyGeometricAnomaly(cg, new SWC_Enemy(), {
																		"x": System.getRandNum(0, 100) + System.GAME_WIDTH + System.GAME_OFFSX,
																		"y": System.getRandNum( -System.GAME_HALF_HEIGHT, System.GAME_HALF_HEIGHT) + System.GAME_OFFSY,
																		"tint": waveColor,
																		"useTint": useColors,
																		"dx": -3 - System.getRandNum(0, 1),
																		"hp": 12
																		});
				cg.addToGame(spawn, System.M_ENEMY);
			}
			
			// update the wave color
			if (useColors && --nextColor <= 0)
			{
				waveColor = System.getRandCol([waveColor]);
				nextColor = System.getRandInt(1, 3);
			}
			
			// TAILS
			if (!useColors)
			{
				if (reminder && !cg.ship.isJumpReadySpecific("range"))
				{
					reminder = false;
					cg.tails.show("We're in range! Let's jump away!", System.TAILS_NORMAL);
				}
			}
			else
			{
				switch (nextWave)
				{
					case 108:
						cg.tails.show("The field is getting denser!", System.TAILS_NORMAL);
					break;
					case 48:
						cg.tails.show("There's too many! We need to jump away!", System.TAILS_NORMAL);
					break;
				}
			}
			
			// reset the spawn timer
			framesElapsed = 0;
			nextWave = System.changeWithLimit(nextWave, D_TIME, MIN_TIME);
		}
	}
}