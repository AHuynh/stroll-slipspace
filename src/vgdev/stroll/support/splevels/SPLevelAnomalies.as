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
		private const MIN_TIME:int = 30;	// minumum delay between spawning waves
		
		private var waveColor:uint = System.getRandCol();
		private var nextColor:int = System.getRandInt(1, 2);		// wait this many waves before changing colors
		
		public function SPLevelAnomalies(_cg:ContainerGame) 
		{
			super(_cg);
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
																		"dx": -3 - System.getRandNum(0, 1),
																		"hp": 12
																		});
				cg.addToGame(spawn, System.M_ENEMY);
			}
			
			// update the wave color
			if (--nextColor <= 0)
			{
				waveColor = System.getRandCol([waveColor]);
				nextColor = System.getRandInt(1, 3);
			}
			
			// TAILS
			switch (nextWave)
			{
				case 108:
					cg.tails.show("The field is getting denser!", System.TAILS_NORMAL);
				break;
				case 48:
					cg.tails.show("There's too many! We need to jump away!", System.TAILS_NORMAL);
				break;
			}
			
			// reset the spawn timer
			framesElapsed = 0;
			nextWave = System.changeWithLimit(nextWave, D_TIME, MIN_TIME);
		}
	}
}