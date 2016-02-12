package vgdev.stroll.props 
{
	import vgdev.stroll.ContainerGame;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.System;

	/**
	 * An abstract class containing functionality useful to all game objects
	 * @author 	Alexander Huynh
	 */
	public class ABST_Object 
	{
		/// A reference to the active instance of ContainerGame
		protected var cg:ContainerGame;
		
		/// The MovieClip associated with this object (The actual graphic on the stage)
		public var mc_object:MovieClip;
		
		/// Indicates if this object should be removed
		protected var completed:Boolean = false;

		/**
		 * Should only be called through super(), never instantiated
		 * @param	_cg		The active instance of ContainerGame
		 */
		public function ABST_Object(_cg:ContainerGame, _mc_object:MovieClip = null) 
		{
			cg = _cg;
			mc_object = _mc_object;
		}
		
		/**
		 * Update this object
		 * @return			true if the prop is done and should be cleaned up
		 */
		public function step():Boolean
		{
			return completed;
		}
		
		public function isActive():Boolean
		{
			return !completed;
		}
		
		/**
		 * Update this object's position
		 * @param	dx		the amount to change in the horizontal direction
		 * @param	dy		the amount to change in the vertical direction
		 */
		protected function updatePosition(dx:Number, dy:Number):void
		{
			mc_object.x += dx;
			mc_object.y += dy;
		}
		
		/**
		 * Clean-up function
		 */
		public function destroy():void
		{
			mc_object = null;
			cg = null;
			completed = true;
		}
	}
}