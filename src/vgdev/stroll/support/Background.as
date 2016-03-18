package vgdev.stroll.support 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Helper to manage the game's background
	 * @author Alexander Huynh
	 */
	public class Background 
	{
		private var cg:ContainerGame;
		private var bg:MovieClip;
		
		private const LIM_LEFT:Number = -System.GAME_HALF_WIDTH / 1.8;
		private var OFFSET:Number;
		
		public function Background(_cg:ContainerGame, _bg:MovieClip)
		{
			cg = _cg;
			bg = _bg;
			
			OFFSET = bg.base.base1.width * .5;
		}
		
		public function step(shipSpeed:Number):void
		{
			bg.base.base1.x -= shipSpeed;
			if (bg.base.base1.x + OFFSET < LIM_LEFT)
				bg.base.base1.x += System.GAME_WIDTH * 1.8;
			bg.base.base2.x = bg.base.base1.x + System.GAME_WIDTH * 1.8;
		}
		
		public function setStyle(style:String):void
		{
			bg.base.base1.gotoAndStop(style);
			bg.base.base2.gotoAndStop(style);
		}
	}
}