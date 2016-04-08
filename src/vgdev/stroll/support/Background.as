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
	public class Background extends ABST_Support
	{
		public var bg:MovieClip;
		
		private const LIM_LEFT:Number = 0;// -120;
		private var OFFSET:Number;
		
		public var bg1:MovieClip;
		private var bg2:MovieClip;
		
		private const REGION_0:Array = ["abstract_00", "abstract_01", "abstract_02"];
		
		public function Background(_cg:ContainerGame, _bg:MovieClip)
		{
			super(_cg);
			bg = _bg;
			
			bg1 = bg.base.base1;
			bg2 = bg.base.base2;
			OFFSET = bg1.width;
		}
		
		public function stepBG(shipSpeed:Number):void
		{
			bg1.x -= shipSpeed;
			if (bg1.x + OFFSET < LIM_LEFT)
			{
				var temp:MovieClip = bg1;
				bg1 = bg2;
				bg2 = temp;
			}
			bg2.x = bg1.x + OFFSET;
			
			bg1.x = int(bg1.x);
			bg2.x = int(bg2.x);
		}
		
		public function setStyle(style:String, col:uint = 0xFFFFFF):void
		{
			bg1.gotoAndStop(style);
			bg2.gotoAndStop(style);
			
			System.tintObject(bg.base, col, System.getRandNum(.6, .75));
		}
		
		public function resetBackground():void
		{
			bg1.x = 0;
			bg2.x = 1728;
		}
		
		/**
		 * Set the background to a random one from a pre-defined pool
		 * @param	region	int, [0-2]
		 * @param	col
		 */
		public function setRandomStyle(region:int, col:uint = 0xFFFFFF):void
		{		
			switch (region)
			{
				case 0:
				default:
					setStyle(System.getRandFrom(REGION_0), col);
					//setStyle(System.getRandFrom(["test1"]), col);
				break;
			}
		}
		
		public function setLocation(loc:Point):void
		{
			bg.base.x = loc.x;
			bg.base.y = loc.y;
		}
		
		override public function destroy():void 
		{
			bg = null;
			bg1 = null;
			bg2 = null;
			super.destroy();
		}
	}
}