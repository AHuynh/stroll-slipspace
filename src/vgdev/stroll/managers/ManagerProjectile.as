package vgdev.stroll.managers 
{
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileHardened;
	import vgdev.stroll.System;
	import vgdev.stroll.props.ABST_Object;
	
	/**
	 * Handles all projectiles
	 * @author Alexander Huynh
	 */
	public class ManagerProjectile extends ABST_Manager 
	{
		public function ManagerProjectile(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		// ignore projectile collisions if they are on the same team
		override protected function collisionException(a:ABST_Object, b:ABST_Object):Boolean
		{
			return (a as ABST_EProjectile).getAffiliation() == (b as ABST_EProjectile).getAffiliation();
		}
	}
}