package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.System;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	
	/**
	 * A projectile with HP
	 * @author Alexander Huynh
	 */
	public class ProjectileHardened extends ProjectileGeneric 
	{
		protected var hpMax:int;
		protected var hp:int;
	
		/// How much HP to remove from other Hardened projectiles (non-Hardened are assumed to be dmg = 1)
		protected var pdmg:int;
		
		public function ProjectileHardened(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			
			pdmg = System.setAttribute("pdmg", attributes, 1);
			hp = hpMax = System.setAttribute("hp", attributes, 1);
		}
		
		public function getDamage():int
		{
			return pdmg;
		}
		
		/**
		 * Make this Hardened projectile take damage
		 * @param	dmg		The amount of damage to deal (a positive int)
		 */
		public function damage(dmg:int):void
		{
			hp = System.changeWithLimit(hp, -dmg, 0);
		}
		
		override protected function updateCollisions():void
		{
			var collide:ABST_Object = managerProj.collideWithOther(this);
			if (collide != null)
			{
				if (collide is ProjectileHardened)
					(collide as ProjectileHardened).damage(pdmg);
				else
					(collide as ABST_Projectile).kill();
				kill();
			}
			else if (getAffiliation() == System.AFFIL_PLAYER)
			{
				collide = managerEnem.collideWithOther(this, true);
				if (collide != null)
				{
					hp = 0;
					kill();
					(collide as ABST_Enemy).damage(dmg);
				}
			}
		}
			
		override protected function onShipHit():void
		{
			hp = 0;
			cg.ship.damage(dmg, attackColor);
		}
		
		override public function kill():void
		{
			if (!markedToKill && hp == 0)
			{
				markedToKill = true;
				completed = true;
				mc_object.visible = false;
			}
			else
				damage(1);
		}
	}
}