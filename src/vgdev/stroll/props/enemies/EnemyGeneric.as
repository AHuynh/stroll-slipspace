package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Same as ABST_Enemy
	 * @author Alexander Huynh
	 */
	public class EnemyGeneric extends ABST_Enemy 
	{
		
		public function EnemyGeneric(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, attributes:Object) 
		{
			super(_cg, _mc_object, _pos, attributes);
		}
	}
}