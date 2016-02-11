package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.System;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ABST_Projectile extends ABST_EMovable 
	{
		// polar
		protected var spd:Number;
		protected var dir:Number;

		protected var affiliation:int;
		
		public function ABST_Projectile(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, _dir:Number, _spd:Number, _affiliation:int) 
		{
			super(_cg, _mc_object, _hitMask);
			dir = _dir;
			spd = _spd;
			affiliation = _affiliation;
		}
		
		override public function step():Boolean
		{
			updatePosition(System.forward(spd, dir, true), System.forward(spd, dir, false));			
			return completed;
		}
		
		public function getAffiliation():int
		{
			return affiliation;
		}
	}
}