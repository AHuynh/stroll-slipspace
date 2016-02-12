package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.managers.ManagerEProjectile;
	import vgdev.stroll.managers.ManagerGeneric;
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	import vgdev.stroll.System;
	
	/**
	 * Base class for all projectiles outside of the ship
	 * @author Alexander Huynh
	 */
	public class ABST_Projectile extends ABST_EMovable 
	{
		// polar
		protected var spd:Number;
		protected var dir:Number;

		/// Time in frames until this projectile kills itself
		protected var life:int;
		
		/// Base amount of damage to deal
		protected var dmg:Number = 6;
		
		protected var managerProj:ManagerEProjectile;
		protected var managerEnem:ManagerGeneric;
		
		public function ABST_Projectile(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, _affiliation:int, _dir:Number, _spd:Number,
										_life:int, style:String = null, col:uint = 0) 
		{
			super(_cg, _mc_object, _pos, _affiliation);
			dir = _dir;
			spd = _spd;
			life = _life;
			
			managerProj = cg.managerMap[System.M_EPROJECTILE];
			managerEnem = cg.managerMap[System.M_ENEMY];
			
			mc_object.rotation = dir;
			
			if (style != null)
				mc_object.gotoAndStop(style);
		}
		
		override public function step():Boolean
		{
			if (--life <= 0)
				kill();
			else
			{
				updatePosition(System.forward(spd, dir, true), System.forward(spd, dir, false));	
				var collide:ABST_Object = managerProj.collideWithOther(this);
				if (collide != null)
				{
					kill();
					(collide as ABST_Projectile).kill();
				}
				else if (getAffiliation() == System.AFFIL_PLAYER)
				{
					collide = managerEnem.collideWithOther(this, true);
					if (collide != null)
					{
						kill();
						(collide as ABST_Enemy).damage(dmg);
					}
				}
			}
			return completed;
		}
		
		override protected function onShipHit():void
		{
			cg.ship.damage(dmg);
		}
	}
}