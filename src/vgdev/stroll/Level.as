package vgdev.stroll 
{
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Level 
	{
		private var game:ContainerGame;
		private var gui:SWC_GUI;
		
		public var distGoal:Number = 4.37;
		public var distTrav:Number = 0;
		private var distChange:Number = .002;
		
		public function Level(_game:ContainerGame, _gui:SWC_GUI)
		{
			game = _game;
			gui = _gui;
			
			gui.tf_distanceG.text = "/ " + System.formatDecimal(distGoal, 3) + " LY";
		}
	
		public function step():void
		{
			distTrav = System.changeWithLimit(distTrav, distChange, 0, distGoal);
			gui.tf_distance.text = System.formatDecimal(distTrav, 3).toString();
		}
	}
}