package vgdev.stroll.support 
{
	import flash.geom.Point;	
	import vgdev.stroll.props.ABST_EMovable;
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
			switch (timeline)
			{
				case 1:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(200, 200), {"attackColor":System.COL_RED}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(180, 190), {"attackColor":System.COL_RED}), System.M_ENEMY);
				break;
				case 2:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-100, -250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(100, -250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-100, 250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(100, 250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
				break;
				case 3:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(300, -320), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(330, -300), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(360, -340), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(360, -240), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(380, -250), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.ship.jammable = 3;
				break;
				/*case 4:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-400, 320), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-330, 300), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-460, 340), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-520, 240), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-380, 250), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-120, 230), {"attackColor":System.COL_RED}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(120, 270), {"attackColor":System.COL_RED}), System.M_ENEMY);
				break;*/
				case 4:
					var e:ABST_Enemy = new EnemyColorSwapper(cg, new SWC_Enemy, new Point(500, System.getRandNum(-100, 100)), {"attackColor":System.getRandCol(), "attackStrength":10, "hp":300});
					e.setScale(2);
					cg.addToGame(e, System.M_ENEMY);
					cg.ship.jammable = 1;
				break;
			}
		}

		public function nextWave():Boolean
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
			
			return timeline > 5;
		}
	}
}