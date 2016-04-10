package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Object that can move outside the spaceship.
	 * Destroys self if it is leaving the game area or hits the ship.
	 * @author Alexander Huynh
	 */
	public class ABST_EMovable extends ABST_Object 
	{
		protected var LIM_X_MIN:int;
		protected var LIM_X_MAX:int;
		protected var LIM_Y_MIN:int;
		protected var LIM_Y_MAX:int;
		protected const BUFFER:int = 100;
		
		protected var ghost:Boolean = false;
		
		public function ABST_EMovable(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, _affiliation:int) 
		{
			super(_cg, _mc_object);
			mc_object.x = _pos.x - System.GAME_OFFSX;
			mc_object.y = _pos.y - System.GAME_OFFSY;
			
			affiliation = _affiliation;
			
			LIM_X_MIN = -System.GAME_WIDTH;
			LIM_X_MAX = System.GAME_WIDTH;
			LIM_Y_MIN = -System.GAME_HEIGHT;
			LIM_Y_MAX = System.GAME_HEIGHT;
		}

		override protected function updatePosition(dx:Number, dy:Number):void
		{
			if (completed)
				return;
			
			var ptNew:Point = new Point(mc_object.x + dx, mc_object.y + dy);
			if (ghost || isPointValid(ptNew))
			{
				mc_object.x = ptNew.x;
				mc_object.y = ptNew.y;
				
				if (System.directionalOutOfBounds(mc_object.x, dx, LIM_X_MIN, LIM_X_MAX, BUFFER) ||
					System.directionalOutOfBounds(mc_object.y, dy, LIM_Y_MIN, LIM_Y_MAX, BUFFER))
				{
					destroySilently();
				}
			}
			else if (!ghost)	// ship was hit
			{
				if (affiliation != System.AFFIL_PLAYER)
					onShipHit();
				destroy();
			}
		}
		
		/**
		 * Actions to perform when this enemy collides with the ship
		 */
		protected function onShipHit():void
		{
			// -- override this function
		}
		
		/**
		 * Determines if the given point is not hitting the ship
		 * @param	pt		The point to check for
		 * @return			true if the point is colliding with the ship
		 */
		public function isPointValid(pt:Point):Boolean
		{	
			var mask:MovieClip = affiliation != System.AFFIL_PLAYER ? cg.shipHitMask : cg.shipHullMask;
			if (!mc_object.hitTestObject(mask))
				return true;
			return !mask.hitTestPoint(pt.x + System.GAME_OFFSX, pt.y + System.GAME_OFFSY, true);
		}
	}
}