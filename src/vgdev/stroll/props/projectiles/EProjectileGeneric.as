package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Same as ABST_Projectile (but not abstract)
	 * @author Alexander Huynh
	 */
	public class EProjectileGeneric extends ABST_EProjectile 
	{
		
		public function EProjectileGeneric(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
		}
	}
}