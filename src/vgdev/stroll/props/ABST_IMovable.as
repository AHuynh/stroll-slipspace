package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Object that can move inside the spaceship.
	 * @author Alexander Huynh
	 */
	public class ABST_IMovable extends ABST_Object 
	{
		protected var validMCs:Array;
		protected var hitMask:MovieClip;
		
		public function ABST_IMovable(_cg:ContainerGame, _validMCs:MovieClip) 
		{
			super(_cg);
			
			hitMask = _validMCs;
		}
		
		/**
		 * Move the obstacle's x and y
		 */
		override protected function updatePosition(dx:Number, dy:Number):void
		{
			var ptNew:Point = new Point(changeWithLimit(mc_object.x, dx), changeWithLimit(mc_object.y, dy));
			if (isPointValid(ptNew))
			{
				mc_object.x = ptNew.x;
				mc_object.y = ptNew.y;
			}
		}
		
		public function isPointValid(pt:Point):Boolean
		{			
			var ptL:Point = MovieClip(mc_object.parent).localToGlobal(pt);
			return !(mc_object.hitTestObject(hitMask) && hitMask.hitTestPoint(ptL.x, ptL.y, true));
		}
	}
}