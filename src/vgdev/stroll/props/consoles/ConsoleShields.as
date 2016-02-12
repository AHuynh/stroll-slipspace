package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ConsoleShields extends ABST_Console 
	{
		private var mc_shield:MovieClip;
		
		/// The number of frames to wait in-between shield swaps
		protected var cooldown:int = 30;
		
		/// The current cooldown count, where 0 is ready to swap
		protected var cdCount:int = 0;
		
		private var shieldCols:Array = [System.COL_BLUE, System.COL_GREEN, System.COL_RED, System.COL_YELLOW];
		
		public function ConsoleShields(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object, _players);
			mc_shield = cg.game.mc_ship.shield;
		}
		
		override public function step():Boolean
		{
			if (cdCount > 0)
				cdCount--;
			return super.step();
		}
		
		override public function onKey(key:int):void
		{
			if (cdCount != 0)
				return;
				
			if (key != 4)
			{
				cg.ship.setShieldColor(shieldCols[key])
				cdCount = cooldown;
			}
		}
	}
}