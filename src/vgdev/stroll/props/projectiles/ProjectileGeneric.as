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
		
		public function ProjectileGeneric(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, pos:Point, _dir:Number, _spd:Number,
										  _life:int, _affiliation:int, style:String = null, col:uint = 0) 
		{
			super(_cg, _mc_object, pos,  _affiliation, _dir, _spd, _life, style, col);
		}
	}
}