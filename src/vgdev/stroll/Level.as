package vgdev.stroll 
{
	import flash.geom.Point;	
	import vgdev.stroll.props.enemies.*;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Level 
	{
		private var cg:ContainerGame;
		private var gui:SWC_GUI;
		
		public var distGoal:Number = 4.37;
		public var distTrav:Number = 0;
		private var distChange:Number = .002;
		
		private var timeline:int = 0;
		
		public function Level(_cg:ContainerGame, _gui:SWC_GUI)
		{
			cg = _cg;
			gui = _gui;
			
			gui.tf_distanceG.text = "/ " + System.formatDecimal(distGoal, 3) + " LY";
		}
	
		public function step():void
		{
			// update distance
			distTrav = System.changeWithLimit(distTrav, distChange, 0, distGoal);
			gui.tf_distance.text = System.formatDecimal(distTrav, 3).toString();
			
			// TODO remove hardcode
			timeline++;
			switch (timeline)
			{
				case System.SECOND * 3:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(200, 200)), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(180, 190)), System.M_ENEMY);
				break;
				case System.SECOND * 10:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-300, -100)), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-350, 0)), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-300, 100)), System.M_ENEMY);
				break;
				case System.SECOND * 16:
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-100, -250)), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(100, -250)), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(-100, 250)), System.M_ENEMY);
					cg.addToGame(new ABST_Enemy(cg, new SWC_Enemy(), new Point(100, 250)), System.M_ENEMY);
				break;
			}
		}
	}
}