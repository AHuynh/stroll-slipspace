package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.projectiles.ABST_Projectile;
	import vgdev.stroll.System;
	import vgdev.stroll.props.ABST_Object;
	
	/**
	 * Handles all projectiles outside of the spaceship
	 * @author Alexander Huynh
	 */
	public class ManagerEProjectile extends ABST_Manager 
	{
		public function ManagerEProjectile(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		override protected function collisionException(a:ABST_Object, b:ABST_Object):Boolean
		{
			return (a as ABST_Projectile).getAffiliation() == (b as ABST_Projectile).getAffiliation();
		}
	}

}