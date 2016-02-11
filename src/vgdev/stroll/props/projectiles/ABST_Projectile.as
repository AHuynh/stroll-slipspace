package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
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

		protected var life:int;
		protected var affiliation:int;
		
		public function ABST_Projectile(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, pos:Point, _dir:Number, _spd:Number,
										_life:int, _affiliation:int, style:String = null, col:uint = 0) 
		{
			super(_cg, _mc_object, _hitMask);
			dir = _dir;
			spd = _spd;
			life = _life;
			affiliation = _affiliation;
			
			mc_object.x = pos.x -= System.GAME_OFFSX;
			mc_object.y = pos.y -= System.GAME_OFFSY;
			mc_object.rotation = dir;
			
			if (style != null)
				mc_object.gotoAndStop(style);
		}
		
		override public function step():Boolean
		{
			if (--life <= 0)
				kill();
			else
				updatePosition(System.forward(spd, dir, true), System.forward(spd, dir, false));		
			return completed;
		}
		
		public function getAffiliation():int
		{
			return affiliation;
		}
	}
}