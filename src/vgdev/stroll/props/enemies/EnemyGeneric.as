package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * An 'dumb' enemy with no weapons (i.e. debris)
	 * @author Alexander Huynh
	 */
	public class EnemyGeneric extends ABST_Enemy 
	{
		public function EnemyGeneric(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
		}
		
		// no weapons or distance maintaining on generic enemy
		override public function step():Boolean
		{
			if (!completed)
			{
				updatePrevPosition();
				updatePosition(dX, dY);
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateRotation(dR);	
				updateDamageFlash();				
			}
			return completed;
		}
	}
}