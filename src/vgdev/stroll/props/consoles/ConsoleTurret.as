package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ConsoleTurret extends ABST_Console 
	{
		protected var turret:MovieClip;
		
		/// The number of frames to wait in-between shots
		protected var cooldown:int = 10;
		
		/// The current cooldown count, where 0 is ready to fire
		protected var cdCount:int = 0;
		
		/// The min and max values of rotation that can be applied to the turret nozzle's rotation
		protected var gimbalLimits:Array = [0, 0];
		
		/// The IDs of the keys that are used to move the turret in pairs (0 and 1, 2 and 3)
		protected var controlIDs:Array;
		
		/// How many degrees per frame the gimbal can rotate at
		protected var gimbalSpeed:Number = 4;
		
		public function ConsoleTurret(_cg:ContainerGame, _mc_object:MovieClip, _turret:MovieClip, _players:Array, _gimbalLimits:Array, _controlIDs:Array) 
		{
			super(_cg, _mc_object, _players);	
			turret = _turret;
			gimbalLimits = _gimbalLimits;
			controlIDs = _controlIDs;
		}
		
		/**
		 * Performs some sort of functionality based on keys HELD by this console's active player
		 * @param	keys	array with indexes [0-4] representing R, U, L, D, Action
		 */
		override public function holdKey(keys:Array):void
		{
			for (var i:int = 0; i < 4; i++)
			{
				if (keys[i])
				{
					if (controlIDs[0] == i || controlIDs[1] == i)
					{
						traverse(-1);
					}
					else if (controlIDs[2] == i || controlIDs[3] == i)
					{
						traverse(1);
				}
				}
			}
			
			if (keys[4])
			{
				if (cdCount == 0)
				{
					cdCount = cooldown;
					// TODO fire
				}
			}
		}
		
		/**
		 * Traverse the turret's nozzle by gimbalSpeed in the dir direction with respect to gimbal limits
		 * @param	dir		direction multiplier, either 1 or -1
		 */
		protected function traverse(dir:int):void
		{
			turret.nozzle.rotation = System.changeWithLimit(turret.nozzle.rotation, gimbalSpeed * dir, gimbalLimits[0], gimbalLimits[1]);
		}
	}
}