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
		/// Determines magnitude of the effect the directional keys have on the ship heading
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
				getHUD().mc_navbar.x = 68 * cg.ship.shipHeading;
				getHUD().mc_okay.visible = cg.ship.isHeadingGood();
			}
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			var isHPzero:Boolean = super.changeHP(amt);
			cg.ship.navOnline = !isHPzero;
			return isHPzero;
		}
		
		override public function step():Boolean 
		{
			if (inUse)
				updateHUD(true);
			return super.step();
		}
	}
}