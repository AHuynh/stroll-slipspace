package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Sector 4 boss. 1 of 2 extra eyes.
	 * @author Alexander Huynh
	 */
	public class EnemyPeepsEye extends ABST_Enemy 
	{
		private var mainBody:EnemyPeeps;		// reference to the main body of the boss
		
		// TODO invincibility when eyes are closed
		
		public function EnemyPeepsEye(_cg:ContainerGame, _mc_object:MovieClip, _mainBody:EnemyPeeps) 
		{
			super(_cg, _mc_object, {});
			setStyle("peeps_eye");
			mainBody = _mainBody;
			
			// TODO initialize things like x, y, hp, etc. (there is no attributes object)
			
			// [small shot]
			cdCounts = [90];		// initial cooldown value (TODO balance)
			cooldowns = [140];		// cooldown value (TODO balance)
		}
		
		override internal function updatePosition(dx:Number, dy:Number):void 
		{
			// TODO maintain relative offset and rotation to mainBody (or do this in EnemyPeeps)
		}
		
		//mc_object.base.gotoAndStop("closed");		// display this Peeps eye with its eye closed (default state)
		//mc_object.base.gotoAndStop("open");		// display this Peeps eye with its eye closed
	}
}