package vgdev.stroll.support.splevels 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.enemies.EnemySwipe;
	import vgdev.stroll.System;
	
	/**
	 * Hard sector level; chooses from all 4 colors
	 * @author Alexander Huynh
	 */
	public class SPLevelRainbow extends ABST_SPLevel 
	{
		private var nextWave:int = System.SECOND * 5;
		private var colors:Array = [System.COL_BLUE, System.COL_GREEN, System.COL_RED, System.COL_YELLOW];
		
		private var first:Boolean = true;
		private var swipe:Boolean = false;
		
		public function SPLevelRainbow(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		override public function step():void 
		{
			super.step();
			
			if (framesElapsed > nextWave)
			{
				framesElapsed = 0;
				first = false;
				var c:int = System.getRandInt(0, colors.length - 1);
				switch (colors[c])
				{
					case System.COL_BLUE:
						spawnEnemy("Manta", 1);
						spawnEnemy("Slime", 3);
						nextWave = System.SECOND * 25;
					break;
					case System.COL_GREEN:
						spawnEnemy("Amoeba", 2, ["distant_orbit"], {"am_size": 1} );
						spawnEnemy("Breeder", 1, ["medium_orbit", "distant_orbit"]);
						nextWave = System.SECOND * 27;
					break;
					case System.COL_RED:
						spawnEnemy("Eye", 3, ["medium_orbit", "distant_orbit"]);
						spawnEnemy("Skull", 2);
						nextWave = System.SECOND * 32;
					break;
					case System.COL_YELLOW:
						spawnEnemy("Spider", 3, ["medium_orbit", "distant_orbit"]);
						spawnEnemy("Squid", 1, ["medium_orbit"]);
						nextWave = System.SECOND * 28;
					break;
				}
				colors.splice(c, 1);
				if (colors.length == 0)
				{
					nextWave = System.SECOND * 90;
					colors = [System.COL_BLUE, System.COL_GREEN, System.COL_RED, System.COL_YELLOW];
				}
				else if (!swipe && colors.length == 1)
				{
					swipe = false;
					cg.addToGame(new EnemySwipe(cg, new SWC_Enemy(), { "attackStrength": 50 } ), System.M_ENEMY);
					cg.tails.show("Alert. Swiping enemy detected.", System.TAILS_NORMAL, "HEADS", true);
				}
			}
			else if (!first && framesElapsed + (System.SECOND * 4) == nextWave)
				cg.tails.show(System.getRandFrom([ "Next wave imminent.",
												"New enemies inbound.",
												"Additional foes detected."
												]), System.TAILS_NORMAL, "HEADS", true);
			
		}
	}
}