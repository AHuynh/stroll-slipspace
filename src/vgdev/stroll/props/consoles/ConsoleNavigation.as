package vgdev.stroll.props.consoles 
{
	/**
	 * Dictates how on-course the ship is to the next slipsector
	 * @author Alexander Huynh, Jimmy Spearman
	 */
	private var SHIP_HEADING_MAX:Number = 1;
	private var SHIP_HEADING_MIN:Number = -1;
	 
	///Number determining how far off course ship is. Maintain this at 0 for best navigation.
	public var shipHeading:Number = 0;
	
	public class ConsoleNavigation extends ABST_Console 
	{
		
		public function ConsoleNavigation(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "navigation";
		}
		
		private function adjustHeading(change:Number) 
		{
			newHeading:Number = shipHeading + change;
			
			if (newHeading > SHIP_HEADING_MAX) {
				shipHeading = SHIP_HEADING_MAX;
			} else if (newHeading < SHIP_HEADING_MIN) {
				shipHeading = SHIP_HEADING_MIN;
			} else {
				shipHeading = newHeading;
			}
		
		}
	}
}