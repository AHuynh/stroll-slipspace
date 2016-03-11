package vgdev.stroll.props.consoles 
{	
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	/**
	 * Dictates how on-course the ship is to the next slipsector
	 * @author Alexander Huynh, Jimmy Spearman
	 */
	
	
	public class ConsoleNavigation extends ABST_Console 
	{
		//determines magnitude of the effect the directional keys have on the ship heading
		public var ADJUST_SENSITIVITY:Number = 0.01;
		
		

		
		public function ConsoleNavigation(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "navigation";
		}
		
		
		override public function holdKey(keys:Array):void 
		{
			
			if (keys[0]) {
				cg.ship.adjustHeading(ADJUST_SENSITIVITY);
			}
			
			if (keys[2]) {
				cg.ship.adjustHeading(-ADJUST_SENSITIVITY)
			}
			
			
		}
		
		override protected function updateHUD(isActive:Boolean):void
		{
			if (isActive) {
				getHUD().barCurr.x = 70 * cg.ship.shipHeading;
			}
		
		}
		
		override public function step():Boolean 
		{
			updateHUD(inUse);
			return super.step();
		}
		
		
	}
	
	
}