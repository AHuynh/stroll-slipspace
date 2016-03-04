package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.projectiles.ABST_Projectile;
	import vgdev.stroll.props.projectiles.ProjectileGeneric;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * A console that controls a basic ship turret
	 * @author Alexander Huynh
	 */
	public class ConsoleTurret extends ABST_Console 
	{
		/// Reference to the linked turret
		protected var turret:MovieClip;
		
		/// The number of frames to wait in-between shots
		protected var cooldown:int = 5;
		
		/// The current cooldown count, where 0 is ready to fire
		protected var cdCount:int = 0;
		
		/// The min and max values of rotation that can be applied to the turret nozzle's rotation
		protected var gimbalLimits:Array = [0, 0];
		
		/// The IDs of the keys that are used to move the turret in pairs (0 and 1, 2 and 3)
		protected var controlIDs:Array;
		
		/// How many degrees per frame the gimbal can rotate at
		protected var gimbalSpeed:Number = 4;
		
		/// Speed of projectiles shot
		protected var projectileSpeed:Number = 12;
		
		/// How many frames projectiles shot will last
		protected var projectileLife:Number = 60;
		
		/// Degrees to vary shots in each direction (total range is sway * 2)
		protected var sway:Number = 3.5;
		
		/// Rotation offset, if the mc_object's initial rotation is not 0
		public var rotOff:int = 0;
		
		public function ConsoleTurret(_cg:ContainerGame, _mc_object:MovieClip, _turret:MovieClip, _players:Array, _gimbalLimits:Array, _controlIDs:Array) 
		{
			super(_cg, _mc_object, _players);	
			CONSOLE_NAME = "turret";
			turret = _turret;
			gimbalLimits = _gimbalLimits;
			controlIDs = _controlIDs;
			
			turret.nozzle.spawn.visible = false;
		}
		
		override public function step():Boolean
		{
			if (cdCount > 0)
				cdCount--;
			return super.step();
		}
		
		/**
		 * Performs some sort of functionality based on keys HELD by this console's active player
		 * @param	keys	array with indexes [0-4] representing R, U, L, D, Action
		 */
		override public function holdKey(keys:Array):void
		{
			if (hp == 0) return;
			
			// turret aiming
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
			
			// turret firing
			if (keys[4])
			{
				if (cdCount == 0)		// fire a bullet
				{
					cdCount = cooldown;																	 
					var proj:ABST_Projectile = new ProjectileGeneric(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_PLAYER,
																		"attackColor":	System.COL_WHITE,
																		"dir":			turret.nozzle.rotation + rotOff + System.getRandNum( -sway, sway),
																		"dmg":			6,
																		"life":			projectileLife,
																		"pos":			turret.nozzle.spawn.localToGlobal(new Point(turret.nozzle.spawn.x, turret.nozzle.spawn.y)),
																		"spd":			projectileSpeed,
																		"style":		null
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
					SoundManager.playSFX("sfx_laser1");
				}
			}
		}
		
		/**
		 * Traverse the turret's nozzle by gimbalSpeed in the dir direction with respect to gimbal limits
		 * @param	dir		direction multiplier, either 1 or -1 for now
		 */
		protected function traverse(dir:Number):void
		{
			turret.nozzle.rotation = System.changeWithLimit(turret.nozzle.rotation, gimbalSpeed * dir, gimbalLimits[0], gimbalLimits[1]);
		}
	}
}