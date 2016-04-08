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

		public function ConsoleNavigation(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean = false) 
		{
			super(_cg, _mc_object, _players, locked);
			CONSOLE_NAME = "Navigation";
			TUT_SECTOR = 0;
			TUT_TITLE = "Navigation Module";
			TUT_MSG = "Move the bar to the center to keep the ship on-course and travelling fast.\n\n" +
					  "The ship can jump using the Slipdrive module only if it's on-course!";
		}
		
		override public function holdKey(keys:Array):void 
		{
			if (broken) return;
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.holdKey(keys);
				return;
			}
			
			if (keys[0]) {
				cg.ship.adjustHeading(ADJUST_SENSITIVITY * (Math.abs(cg.ship.shipHeading) > .5 ? 2 : 1));
			}
			
			if (keys[2]) {
				cg.ship.adjustHeading(-ADJUST_SENSITIVITY * (Math.abs(cg.ship.shipHeading) > .5 ? 2 : 1));
			}
		}
		
		override public function updateHUD(isActive:Boolean):void
		{
			if (isActive) {
				if (corrupted)		// relinquish control if corrupted
				{
					consoleFAILS.updateHUD(isActive);
					return;
				}
			
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
			{
				if (corrupted)		// relinquish control if corrupted
					return consoleFAILS.step();
				updateHUD(true);
			}
			return super.step();
		}
	}
}