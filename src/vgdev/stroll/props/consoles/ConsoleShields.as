package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Configures the shield color
	 * @author Alexander Huynh
	 */
	public class ConsoleShields extends ABST_Console 
	{
		private var mc_shield:MovieClip;
		
		/// The number of frames to wait in-between shield swaps
		protected var cooldown:int = 30;
		
		/// The current cooldown count, where 0 is ready to swap
		protected var cdCount:int = 0;
		
		private var shieldCols:Array = [System.COL_GREEN, System.COL_RED, System.COL_YELLOW, System.COL_BLUE];
		private var currShield:int = -1;
		
		public function ConsoleShields(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "shields";
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
				
				if (cg.ship.getShields() > 0)
					SoundManager.playSFX("sfx_shieldrecharge");
				
				currShield = key;
				updateHUD(true);
			}
		}
		
		override protected function updateHUD(isActive:Boolean):void
		{
			if (isActive)
				getHUD().shieldIndicator.gotoAndStop(currShield + 2);
		}
	}
}