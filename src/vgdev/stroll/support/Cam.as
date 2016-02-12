package vgdev.stroll.support 
{
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Cam 
	{
		private var cg:ContainerGame;
		
		private var focus:Point;
		private var scale:Number = 1;
		
		private var focusTgt:Point;
		private var scaleTgt:Number = 1;
		
		private const ADD_TRANSLATE:Array = [-10, 10];
		private const ADD_SCALE:Array = [-.05, .05];
		private const THRESH_TRANSLATE:Number = 5;
		private const THRESH_SCALE:Number = .05;
		
		public function Cam(_cg:ContainerGame) 
		{
			cg = _cg;
			
			focus = new Point(cg.game.x, cg.game.y);
			focusTgt = new Point(cg.game.x, cg.game.y);
		}
		
		public function step():void
		{
			focus.x = updateNumber(focus.x, focusTgt.x, ADD_TRANSLATE, THRESH_TRANSLATE);
			focus.y = updateNumber(focus.y, focusTgt.y, ADD_TRANSLATE, THRESH_TRANSLATE);
			scale = updateNumber(scale, scaleTgt, ADD_SCALE, THRESH_SCALE);
			
			cg.game.x = focus.x;
			cg.game.y = focus.y;
			cg.game.scaleX = cg.game.scaleY = scale;
		}
		
		private function updateNumber(num:Number, tgt:Number, add:Array, thresh:Number):Number
		{
			if (num == tgt)
				return num;
			num += add[num < tgt ? 1 : 0];
			if (Math.abs(num - tgt) < thresh)
				num = tgt;
			return num;
		}
		
		public function setCamera(newFocus:Point, newScale:Number):void
		{
			setCameraFocus(newFocus);
			setCameraScale(newScale);
		}
		
		public function setCameraFocus(newFocus:Point):void
		{
			focusTgt = newFocus;
		}
		
		public function setCameraScale(newScale:Number):void
		{
			scaleTgt = newScale;
		}
	}
}