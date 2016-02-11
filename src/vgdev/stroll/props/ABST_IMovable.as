package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Object that can move inside the spaceship.
	 * @author Alexander Huynh
	 */
	public class ABST_IMovable extends ABST_Object 
	{
		protected var hitMask:MovieClip;
		
		public function ABST_IMovable(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip) 
		{
			super(_cg, _mc_object);
			hitMask = _hitMask;
		}

		override protected function updatePosition(dx:Number, dy:Number):void
		{
			var ptNew:Point = new Point(System.changeWithLimit(mc_object.x, dx), System.changeWithLimit(mc_object.y, dy));
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