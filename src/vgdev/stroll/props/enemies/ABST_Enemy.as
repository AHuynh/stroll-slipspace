package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.System;
	import vgdev.stroll.props.projectiles.*;
	
	/**
	 * Base class for enemies outside of the ship
	 * @author Alexander Huynh
	 */
	public class ABST_Enemy extends ABST_EMovable 
	{
		protected var cooldowns:Array = [60];
		protected var cdCounts:Array = [0];
		
		/// The min and max range from the ship that this Enemy should keep between
		protected var ranges:Array = [200, 300];
		
		protected var hpMax:Number = 100;
		protected var hp:Number = hpMax;
		
		protected var dX:Number = 0;
		protected var dY:Number = 0;
		
		protected var spd:Number = 1;
		protected var drift:Number = .25;
		protected var driftDir:int = 1;
		
		public function ABST_Enemy(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, _pos:Point) 
		{
			super(_cg, _mc_object, _hitMask);
			
			mc_object.x = _pos.x;
			mc_object.y = _pos.y;
		}
		
		override public function step():Boolean
		{
			updatePosition(dX, dY);
			maintainRange();
			
			// update weapons
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					cdCounts[i] = cooldowns[i];
					var proj:ABST_Projectile = new ProjectileGeneric(cg, new SWC_Bullet(), cg.shipHitMask,
																	 mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																	 mc_object.rotation, 3, 150, System.AFFIL_ENEMY);
					cg.addToGame(proj, System.M_EPROJECTILE);
				}
			}
			
			
			return completed;
		}
		
		public function damage(dmg:Number):void
		{
			hp = System.changeWithLimit(hp, -dmg, 0);
			if (hp == 0)
				kill();
		}
		
		/**
		 * Keep between ranges[0] and ranges[1]
		 */
		protected function maintainRange():void
		{
			var dist:Number = System.getDistance(mc_object.x, mc_object.y, hitMask.x, hitMask.y);
			var rot:Number = System.getAngle(mc_object.x, mc_object.y, hitMask.x, hitMask.y);
			mc_object.rotation = rot;
			if (dist < ranges[0])
			{
				updatePosition(System.forward( -spd, rot, true), System.forward( -spd, rot, false));
				driftDir = -1;
			}
			else if (dist > ranges[1])
			{
				updatePosition(System.forward(spd, rot, true), System.forward(spd, rot, false));
				driftDir = 1;
			}
			else
				updatePosition(System.forward(drift * driftDir, rot, true), System.forward(drift * driftDir, rot, false));
		}
	}
}