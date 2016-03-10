package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Same as ABST_IProjectile (but not abstract)
	 * @author Alexander Huynh
	 */
	public class IProjectileGeneric extends ABST_IProjectile 
	{
		
		public function IProjectileGeneric(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, _hitMask, attributes);
		}
	}
}