package vgdev.stroll.support.splevels 
{
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	/**
	 * Provides functionality for a slipspace sector that requires code logic
	 * @author Alexander Huynh
	 */
	public class ABST_SPLevel 
	{
		protected var cg:ContainerGame;
		protected var framesElapsed:int = 0;
		
		public function ABST_SPLevel(_cg:ContainerGame) 
		{
			cg = _cg;
		}
		
		public function step():void
		{
			framesElapsed++;
			// -- override this function
		}
		
		public function destroy():void
		{
			// -- override this function
		}

		/**
		 * Spawn some enemy
		 * @param	type		Name of enemy
		 * @param	amt			Amount of enemies
		 * @param	region		Region names to pick from
		 * @param	params		Spawn parameters
		 */
		protected function spawnEnemy(type:String, amt:int, region:Array = null, params:Object = null):void
		{
			if (region == null) region = [System.SPAWN_STD];
			if (params == null) params = { };
			var p:Point;
			for (var i:int = 0; i < amt; i++)
			{
				p = cg.level.getRandomPointInRegion(System.getRandFrom(region));
				p.x += System.GAME_OFFSX;
				p.y += System.GAME_OFFSY;
				cg.level.spawn(params, p, type);
			}
		}
	}
}