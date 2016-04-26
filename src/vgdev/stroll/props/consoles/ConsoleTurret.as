package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.display.NativeMenuItem;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
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
		protected var cooldown:int = 7;
		
		/// The current cooldown count, where 0 is ready to fire
		protected var cdCount:int = 0;
		
		/// The min and max values of rotation that can be applied to the turret nozzle's rotation
		public var gimbalLimits:Array = [0, 0];
		protected var gimbalFree:Boolean = false;
		public var trot:Number = 0;
		private var markerHelper:Number;
		
		/// The IDs of the keys that are used to move the turret in pairs (0 and 1, 2 and 3)
		protected var controlIDs:Array;
		
		/// How many degrees per frame the gimbal can rotate at
		protected var gimbalSpeed:Number = 4;
		
		/// Speed of projectiles shot
		protected var projectileSpeed:Number = 14;
		
		/// How many frames projectiles shot will last
		protected var projectileLife:Number = 60;
		
		/// Degrees to vary shots in each direction (total range is sway * 2)
		protected var sway:Number = 3.5;
		
		/// Rotation offset, if the mc_object's initial rotation is not 0
		public var rotOff:int = 0;
		
		/// If true, shots fired won't collide with ship
		protected var ghost:Boolean = false;
		
		public var turretID:int;
		private const MINI_LEAD:Number = .68;
		private const MINI_SCALE:Number = .09;
		public var leadAmt:Number = MINI_LEAD;
		public var distAmt:Number = MINI_SCALE;
		
		/// Turret power, [0-2]
		private var level:int = 0;
		private var triple:Boolean = false;
		
		/// Don't immediately fire upon console activation
		private var entryDelay:int = 0;
		
		public function ConsoleTurret(_cg:ContainerGame, _mc_object:MovieClip, _turret:MovieClip, _players:Array, _gimbalLimits:Array, _controlIDs:Array, _turretID:int, _ghost:Boolean = false)
		{
			super(_cg, _mc_object, _players, false);
			ghost = _ghost;
			CONSOLE_NAME = "Turret";
			TUT_SECTOR = 0;
			TUT_TITLE = "Turret Module";
			TUT_MSG = "Control one of the ship's turrets.\nHold to fire continuously.\n\nComes with its own sensors and aim-assist, too!"
			turret = _turret;
			gimbalLimits = _gimbalLimits;
			controlIDs = _controlIDs;
			turretID = _turretID;
			
			if (gimbalLimits[0] == -180 && gimbalLimits[1] == 180)
				gimbalFree = true;
			markerHelper = gimbalLimits[1] - gimbalLimits[0];
			
			turret.nozzle.spawn.visible = false;
			if (ghost)
				turret.alpha = 0.6;
		}
		
		/*public function getSpawnPoint():Point
		{
			return turret.nozzle.localToGlobal(new Point(turret.nozzle.spawn.x, turret.nozzle.spawn.y));
		}*/
		
		public function getSpawnPoint():Point
		{
			return new Point(turret.x, turret.y);
		}
		
		// update cooldown
		override public function step():Boolean
		{
			if (corrupted)		// relinquish control if corrupted
				return consoleFAILS.step();
			
			if (cdCount > 0)
				cdCount--;
			if (entryDelay > 0)
				entryDelay--;
				
			if (inUse)
				updateHUD(true);
			return super.step();
		}
		
		override public function onAction(p:Player):void 
		{
			entryDelay = 5;
			super.onAction(p);
			if (inUse && !corrupted)
			{
				var hud:MovieClip = getHUD();
				hud.mc_light.y = 18.5 - 9 * turretID;
				hud.msg_cannon.visible = cg.shipName == "Kingfisher";
			}
		}
		
		/**
		 * Performs some sort of functionality based on keys HELD by this console's active player
		 * @param	keys	boolean array with indexes [0-4] representing R, U, L, D, Action
		 */
		override public function holdKey(keys:Array):void
		{
			if (broken) return;
			
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.holdKey(keys);
				return;
			}
			
			var used:Array = [false, false];
			
			// turret aiming
			for (var i:int = 0; i < 4; i++)
			{
				if (keys[i])	// if the key is being held down
				{
					if (!used[0] && (controlIDs[0] == i || controlIDs[1] == i))		// if the key is one of the keys mapped to -rotate the turret
					{
						traverse( -1);
						used[0] = true;
					}
					else if (!used[1] && (controlIDs[2] == i || controlIDs[3] == i))	// if the key is one of the keys mapped to +rotate the turret
					{
						traverse(1);
						used[1] = true;
					}
				}
			}
			
			// turret firing
			if (entryDelay == 0 && keys[4] && cdCount == 0)
				fire();
		}
		
		/**
		 * Override to define functionality for turret variants
		 */
		protected function fire():void
		{
			cdCount = cooldown;
			triple = !triple;
			var proj:ABST_EProjectile;											
			for (var n:int = 0; n < 3; n++)
			{
				if (n != 1 && (!triple || level == 0)) continue;
				proj = new EProjectileGeneric(cg, new SWC_Bullet(),
														{	 
															"affiliation":	System.AFFIL_PLAYER,
															"dir":			turret.nozzle.rotation + rotOff + System.getRandNum(-sway, sway) + (n - 1) * 10,
															"dmg":			n == 1 ? 5 : 1.5,
															"life":			projectileLife,
															"pos":			turret.nozzle.spawn.localToGlobal(new Point(turret.nozzle.spawn.x, turret.nozzle.spawn.y)),
															"spd":			projectileSpeed,
															"scale":		n == 1 ? 1 : .5,
															"style":		"turret_small_orange",
															"ghost":		ghost
														});
				cg.addToGame(proj, System.M_EPROJECTILE);
			}
			SoundManager.playSFX("sfx_laser1", .6);
		}
		
		/**
		 * Upgrade the turret and show the "New!" icon
		 * @param	lvl		Turret level, [0-2]
		 */
		public function setLevel(lvl:int):void
		{
			mc_object.mc_newIndicator.visible = true;
			level = lvl;
			cooldown = lvl == 2 ? 5 : 7;
			switch (lvl)
			{
				case 0:	sway = 3.5;	break;
				case 1:	sway = 3;	break;
				case 2:	sway = 1.5;	break;
			}
		}
		
		override public function updateHUD(isActive:Boolean):void 
		{
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.updateHUD(isActive);
				return;
			}
			
			if (isActive)
			{
				trot = turret.nozzle.rotation;
				var hud:MovieClip = getHUD();
				hud.tf_cooldown.text = Math.round(10 * cdCount / System.SECOND).toString();
				hud.tf_rotation.text = Math.abs(Math.round(trot)) + "°";
				hud.mc_marker.x = 37 + 47 * ((trot - gimbalLimits[0]) / markerHelper);
				hud.msg_reload.visible = cdCount > 6;
				
				// small window graphics
				hud.mc_container.graphics.clear();
				hud.mc_container.graphics.lineStyle(1, System.COL_WHITE, 1);
				
				var theta:Number
				if (!gimbalFree)
					for (var i:int = 1; i >= 0; i--)
					{
						theta = System.degToRad(270 - trot + gimbalLimits[i]);
						hud.mc_container.graphics.moveTo(0, 23);
						hud.mc_container.graphics.lineTo(50 * Math.cos(theta), 23 + 50 * Math.sin(theta));
					}
				
				// draw projectiles on minimap
				var dist:Number;
				var obj:ABST_Object;
				for each (obj in cg.managerMap[System.M_EPROJECTILE].getAll())
				{
					if (!obj.isActive()) continue;
					theta = System.degToRad(270 - trot + rotOff + System.getAngle(turret.x, turret.y, obj.mc_object.x, obj.mc_object.y));
					dist = System.getDistance(turret.x, turret.y, obj.mc_object.x, obj.mc_object.y) * distAmt;
					hud.mc_container.graphics.drawCircle(dist * Math.cos(theta), 23 + dist * Math.sin(theta), .5);
				}
				
				// draw enemies on minimap
				var px:Number, py:Number;
				var delta:Point, lead:Point;
				for each (obj in cg.managerMap[System.M_ENEMY].getAll())
				{
					if (!obj.isActive()) continue;
					
					// enemy
					dist = System.getDistance(turret.x, turret.y, obj.mc_object.x, obj.mc_object.y) * distAmt;
					theta = System.degToRad(270 - trot + rotOff + System.getAngle(turret.x, turret.y, obj.mc_object.x, obj.mc_object.y));
					px = dist * Math.cos(theta) - 2;
					py = 23 + dist * Math.sin(theta) - 2;
					hud.mc_container.graphics.drawRect(px, py, 4, 4);
					hud.mc_container.graphics.moveTo(px + 2, py + 2);
					
					// lead target
					hud.mc_container.graphics.lineStyle(.25, System.COL_WHITE, 1);
					delta = (obj as ABST_Enemy).getDelta();
					lead = new Point(obj.mc_object.x + delta.x * dist * leadAmt, obj.mc_object.y + delta.y * dist * leadAmt);
					dist = System.getDistance(turret.x, turret.y, lead.x, lead.y) * distAmt;
					theta = System.degToRad(270 - trot + rotOff + System.getAngle(turret.x, turret.y, lead.x, lead.y));
					px = dist * Math.cos(theta) - 1;
					py = 23 + dist * Math.sin(theta) - 1;
					hud.mc_container.graphics.lineTo(px + 1, py + 1);
					hud.mc_container.graphics.drawRect(px, py, 2, 2);
					hud.mc_container.graphics.lineStyle(1, System.COL_WHITE, 1);
				}
			}
		}
		
		/**
		 * Overwrite the current cooldown count with a new value
		 * @param	time		Frames to set the cooldown count
		 */
		public function setActiveCooldown(time:int):void
		{
			cdCount = time;
		}
		
		/**
		 * Traverse the turret's nozzle by gimbalSpeed in the dir direction with respect to gimbal limits
		 * @param	dir		direction multiplier, either 1 or -1 for now
		 */
		protected function traverse(dir:Number):void
		{
			if (gimbalFree)
				turret.nozzle.rotation += gimbalSpeed * dir;
			else
				turret.nozzle.rotation = System.changeWithLimit(turret.nozzle.rotation, gimbalSpeed * dir, gimbalLimits[0], gimbalLimits[1]);
			trot = turret.nozzle.rotation;
		}
	}
}