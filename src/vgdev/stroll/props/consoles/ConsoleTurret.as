package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.ABST_Enemy;
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
		protected var gimbalLimits:Array = [0, 0];
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
		
		private var turretID:int;
		private const MINI_SCALE:Number = .09;
		private const MINI_LEAD:Number = .75;
		
		public function ConsoleTurret(_cg:ContainerGame, _mc_object:MovieClip, _turret:MovieClip, _players:Array, _gimbalLimits:Array, _controlIDs:Array, _turretID:int) 
		{
			super(_cg, _mc_object, _players, false);	
			CONSOLE_NAME = "Turret";
			TUT_SECTOR = 0;
			TUT_TITLE = "Turret Module";
			TUT_MSG = "Control one of the ship's turrets.\nHold to fire continuously.\n\nComes with its own sensors and aim-assist, too!"
			turret = _turret;
			gimbalLimits = _gimbalLimits;
			controlIDs = _controlIDs;
			turretID = _turretID;
			
			markerHelper = gimbalLimits[1] - gimbalLimits[0];
			
			turret.nozzle.spawn.visible = false;
		}
		
		// update cooldown
		override public function step():Boolean
		{
			if (cdCount > 0)
				cdCount--;
			if (inUse)
				updateHUD(true);
			return super.step();
		}
		
		/**
		 * Performs some sort of functionality based on keys HELD by this console's active player
		 * @param	keys	boolean array with indexes [0-4] representing R, U, L, D, Action
		 */
		override public function holdKey(keys:Array):void
		{
			if (hp == 0) return;
			
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
			if (keys[4])
			{
				if (cdCount == 0)		// fire a bullet
				{
					cdCount = cooldown;																	 
					var proj:ABST_EProjectile = new EProjectileGeneric(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_PLAYER,
																		"dir":			turret.nozzle.rotation + rotOff + System.getRandNum( -sway, sway),
																		"dmg":			6,
																		"life":			projectileLife,
																		"pos":			turret.nozzle.spawn.localToGlobal(new Point(turret.nozzle.spawn.x, turret.nozzle.spawn.y)),
																		"spd":			projectileSpeed,
																		"style":		"turret_small_orange"
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
					SoundManager.playSFX("sfx_laser1");
				}
			}
		}
		
		override protected function updateHUD(isActive:Boolean):void 
		{
			if (isActive)
			{
				var trot:Number = turret.nozzle.rotation;
				var hud:MovieClip = getHUD();
				hud.tf_cooldown.text = Math.round(10 * cdCount / System.SECOND).toString();
				hud.tf_rotation.text = Math.abs(Math.round(trot)) + "°";
				hud.mc_marker.x = 37 + 47 * ((trot - gimbalLimits[0]) / markerHelper);
				hud.mc_light.y = 18.5 - 9 * turretID;
				
				// small window graphics
				hud.mc_container.graphics.clear();
				hud.mc_container.graphics.lineStyle(1, System.COL_WHITE, 1);
				
				var theta:Number
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
					dist = System.getDistance(turret.x, turret.y, obj.mc_object.x, obj.mc_object.y) * MINI_SCALE;
					hud.mc_container.graphics.drawCircle(dist * Math.cos(theta), 23 + dist * Math.sin(theta), .5);
				}
				
				// draw enemies on minimap
				var px:Number, py:Number;
				var delta:Point, lead:Point;
				for each (obj in cg.managerMap[System.M_ENEMY].getAll())
				{
					if (!obj.isActive()) continue;
					
					// enemy
					dist = System.getDistance(turret.x, turret.y, obj.mc_object.x, obj.mc_object.y) * MINI_SCALE;
					theta = System.degToRad(270 - trot + rotOff + System.getAngle(turret.x, turret.y, obj.mc_object.x, obj.mc_object.y));
					px = dist * Math.cos(theta) - 2;
					py = 23 + dist * Math.sin(theta) - 2;
					hud.mc_container.graphics.drawRect(px, py, 4, 4);
					hud.mc_container.graphics.moveTo(px + 2, py + 2);
					
					// lead target
					hud.mc_container.graphics.lineStyle(.25, System.COL_WHITE, 1);
					delta = (obj as ABST_Enemy).getDelta();
					lead = new Point(obj.mc_object.x + delta.x * dist * MINI_LEAD, obj.mc_object.y + delta.y * dist * MINI_LEAD);
					dist = System.getDistance(turret.x, turret.y, lead.x, lead.y) * MINI_SCALE;
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
		 * Traverse the turret's nozzle by gimbalSpeed in the dir direction with respect to gimbal limits
		 * @param	dir		direction multiplier, either 1 or -1 for now
		 */
		protected function traverse(dir:Number):void
		{
			turret.nozzle.rotation = System.changeWithLimit(turret.nozzle.rotation, gimbalSpeed * dir, gimbalLimits[0], gimbalLimits[1]);
		}
	}
}