package vgdev.stroll.support 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
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
		
		private var bg1:MovieClip;
		private var bg2:MovieClip;
		
		public function Background(_cg:ContainerGame, _bg:MovieClip)
		{
			cg = _cg;
			bg = _bg;
			
			OFFSET = bg.base.base1.width;
			bg1 = bg.base.base1;
			bg2 = bg.base.base2;
		}
		
		public function step(shipSpeed:Number):void
		{
			bg1.x -= shipSpeed;
			if (bg1.x + OFFSET < LIM_LEFT)
			{
				//bg1.x += System.GAME_WIDTH * 1.8;
				var temp:MovieClip = bg1;
				bg1 = bg2;
				bg2 = temp;
			}
			bg2.x = bg1.x + System.GAME_WIDTH * 1.8;
		}
		
		public function setStyle(style:String, col:uint = System.COL_WHITE):void
		{
			bg1.gotoAndStop(style);
			bg2.gotoAndStop(style);
			
			System.tintObject(bg.base, col);
		}
		
		/**
		 * Set the background to a random one from a pre-defined pool
		 * @param	region	int, [0-2]
		 * @param	col
		 */
		public function setRandomStyle(region:int, col:uint = System.COL_WHITE):void
		{		
			switch (region)
			{
				case 0:
				default:
					setStyle(System.getRandFrom(["abstract_00"]), col);
					//setStyle(System.getRandFrom(["test1"]), col);
				break;
			}
		}
		
		public function setLocation(loc:Point):void
		{
			bg.base.x = loc.x;
			bg.base.y = loc.y;
		}
	}
}