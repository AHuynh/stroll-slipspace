package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Object that can move outside the spaceship.
	 * Destroys self if it leaves the game area or hits the ship.
	 * @author Alexander Huynh
	 */
	public class ABST_EMovable extends ABST_Object 
	{
		protected var LIM_X_MIN:int;
		protected var LIM_X_MAX:int;
		protected var LIM_Y_MIN:int;
		protected var LIM_Y_MAX:int;
		protected const BUFFER:int = 100;
		
		protected var markedToKill:Boolean = false;
		protected var hitMask:MovieClip;
		
		protected var dX:Number = 0;
		protected var dY:Number = 0;
		
		public function ABST_EMovable(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip) 
		{
			super(_cg, _mc_object);
			hitMask = _hitMask;
			
			LIM_X_MIN = -System.GAME_WIDTH;
			LIM_X_MAX = System.GAME_WIDTH;
			LIM_Y_MIN = -System.GAME_HEIGHT;
			LIM_Y_MAX = System.GAME_HEIGHT;
		}

		override protected function updatePosition(dx:Number = this.dX, dy:Number = this.dY):void
		{
			var ptNew:Point = new Point(System.changeWithLimit(mc_object.x, dx), System.changeWithLimit(mc_object.y, dy));
			if (isPointValid(ptNew))
			{
				mc_object.x = ptNew.x;
				mc_object.y = ptNew.y;
				
				if (System.outOfBounds(mc_object.x, LIM_X_MIN, LIM_X_MAX, BUFFER) || System.outOfBounds(mc_object.y, LIM_Y_MIN, LIM_Y_MAX, BUFFER))
					kill();
			}
			else
			{
				// TODO collide with ship on this line
				kill();
			}
		}
		
		public function isPointValid(pt:Point):Boolean
		{			
			var ptL:Point = MovieClip(mc_object.parent).localToGlobal(pt);
			return (mc_object.hitTestObject(hitMask) && hitMask.hitTestPoint(ptL.x, ptL.y, true));
		}
		
		public function kill():void
		{
			// -- override this function
			if (!markedToKill)
			{
				markedToKill = true;
				completed = true;
				mc_object.visible = false;
			}
		}
	}
}