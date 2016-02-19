package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Same as ABST_Projectile (but not abstract)
	 * @author Alexander Huynh
	 */
	public class ProjectileGeneric extends ABST_Projectile 
	{
		
		public function ProjectileGeneric(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
		}
	}
}