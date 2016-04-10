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
	public class EProjectileHardened extends ABST_EProjectile 
	{	
		/// How much HP to remove from other Hardened projectiles (non-Hardened are assumed to be dmg = 1)
		protected var pdmg:int;
		protected var markedToKill:Boolean = false;
		
		public function EProjectileHardened(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			
			pdmg = System.setAttribute("pdmg", attributes, 1);
			hp = hpMax = System.setAttribute("hp", attributes, 1);
		}
		
		/**
		 * Get how much hardened HP this projectile will remove (not how much damage it will deal to non-projectiles)
		 * @return		pdmg
		 */
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
				if (collide is EProjectileHardened)
					(collide as EProjectileHardened).damage(pdmg);
				else
					(collide as ABST_EProjectile).destroy();
				destroy();
			}
			else if (getAffiliation() == System.AFFIL_PLAYER)
			{
				collide = managerEnem.collideWithOther(this, true);
				if (collide != null)
				{
					hp = 0;
					destroy();
					(collide as ABST_Enemy).changeHP(-dmg);
				}
			}
		}
			
		override protected function onShipHit():void
		{
			hp = 0;
			addShipDebris();
			cg.ship.damage(dmg, attackColor);
		}
		
		override public function destroySilently():void 
		{
			markedToKill = false;
			hp = 0;
			super.destroySilently();
		}
		
		override public function destroy():void
		{
			if (life <= 0 || (!markedToKill && hp == 0))
			{
				markedToKill = true;
				super.destroy();
			}
			else
				damage(1);
		}
	}
}