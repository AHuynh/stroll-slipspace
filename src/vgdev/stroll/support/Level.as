package vgdev.stroll.support 
{
	import flash.geom.Point;	
	import vgdev.stroll.props.enemies.*;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Support functionality related to the level
	 * @author Alexander Huynh
	 */
	public class Level 
	{
		private var cg:ContainerGame;
		private var timeline:int = 0;
		
		private var counter:int = -1;
		
		public function Level(_cg:ContainerGame)
		{
			cg = _cg;
		}
	
		public function step():void
		{
			if (counter == -1 || --counter != 0)
				return;
			/*// TODO remove hardcode
			timeline++;
			switch (timeline)
			{
				case System.SECOND * 4:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(200, 200), System.COL_RED), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(180, 190), System.COL_RED), System.M_ENEMY);
				break;
				case System.SECOND * 15:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-300, -100), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-350, 0), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-300, 100), System.COL_BLUE), System.M_ENEMY);
				break;
				case System.SECOND * 28:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-100, -250), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(100, -250), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-100, 250), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(100, 250), System.COL_BLUE), System.M_ENEMY);
				break;
				case System.SECOND * 40:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(300, -320), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(330, -300), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(360, -340), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(360, -240), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(380, -250), System.COL_GREEN), System.M_ENEMY);
				break;
				case System.SECOND * 65:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-400, 320), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-330, 300), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-460, 340), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-520, 240), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-380, 250), System.COL_YELLOW), System.M_ENEMY);
				break;
			}*/
			switch (timeline)
			{
				case 1:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(200, 200), System.COL_RED), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(180, 190), System.COL_RED), System.M_ENEMY);
				break;
				case 2:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-300, -100), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-350, 0), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-300, 100), System.COL_BLUE), System.M_ENEMY);
				break;
				case 3:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-100, -250), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(100, -250), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-100, 250), System.COL_BLUE), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(100, 250), System.COL_BLUE), System.M_ENEMY);
				break;
				case 4:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(300, -320), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(330, -300), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(360, -340), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(360, -240), System.COL_GREEN), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(380, -250), System.COL_GREEN), System.M_ENEMY);
				break;
				case 5:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-400, 320), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-330, 300), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-460, 340), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-520, 240), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-380, 250), System.COL_YELLOW), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-120, 230), System.COL_RED), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(120, 270), System.COL_RED), System.M_ENEMY);
				break;
			}
		}
		
		public function nextWave():void
		{
			counter = 90;
			timeline++;
			
			switch (timeline)
			{
				case 1:
					cg.ship.slipRange = 9;
				break;
				case 2:
					cg.ship.slipRange = 9.4;
				break;
				case 3:
					cg.ship.slipRange = 19;
				break;
				case 4:
					cg.ship.slipRange = 22;
				break;
				case 5:
					cg.ship.slipRange = 25;
				break;
			}
		}
	}
}