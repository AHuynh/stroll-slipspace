package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.System;
	import vgdev.stroll.props.projectiles.*;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Base class for enemies outside of the ship
	 * @author Alexander Huynh
	 */
	public class ABST_Enemy extends ABST_EMovable 
	{
		protected var cooldowns:Array = [60];
		protected var cdCounts:Array = [0];
		
		/// The min and max range from the ship that this Enemy should keep between
		protected var ranges:Array = [290, 500];
		
		protected var hpMax:Number;
		protected var hp:Number;
		
		protected var dX:Number = 0;
		protected var dY:Number = 0;
		
		protected var spd:Number = 1;
		protected var drift:Number = .25;
		protected var driftDir:int = 1;

		protected var colAlpha:Number = 0;
		protected const DCOL:Number = .04;
		
		/// One of the 4 colors to use on projectiles
		protected var attackColor:uint;
	
		protected var attackStrength:Number;
		
		public function ABST_Enemy(_cg:ContainerGame, _mc_object:MovieClip, _pos:Point, attributes:Object) 
		{
			super(_cg, _mc_object, _pos, System.AFFIL_ENEMY);
			
			mc_object.x = _pos.x;
			mc_object.y = _pos.y;
			
			attackColor = System.setAttribute("attackColor", attributes, System.COL_WHITE);
			attackStrength = System.setAttribute("attackStrength", attributes, 8);
			hpMax = hp = System.setAttribute("hp", attributes, 30);
		}
		
		override public function step():Boolean
		{
			updatePosition(dX, dY);
			maintainRange();
			updateWeapons();		
			
			// update red 'damage taken' flash; reduce its opacity
			if (colAlpha > 0)
			{
				colAlpha = System.changeWithLimit(colAlpha, -DCOL, 0);
				mc_object.hitFlash.alpha = colAlpha;
			}
			
			return completed;
		}
		
		protected function updateWeapons():void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					var proj:ABST_Projectile = new ProjectileGeneric(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_ENEMY,
																		"attackColor":	attackColor,
																		"dir":			mc_object.rotation,
																		"dmg":			attackStrength,
																		"life":			150,
																		"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																		"spd":			3,
																		"style":		null
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
				}
			}
		}
		
		/**
		 * Additional functionality when a projectile is fired.
		 */
		protected function onFire():void
		{
			// -- override this function
		}
		
		/**
		 * Deal damage to this enemy
		 * @param	dmg		The amount of damage to deal (positive number to deal damage)
		 */
		public function damage(dmg:Number):void
		{
			hp = System.changeWithLimit(hp, -dmg, 0);
			colAlpha = .7;
			if (hp == 0)
			{
				SoundManager.playSFX("sfx_explosionlarge1");
				kill();
			}
		}
		
		/**
		 * Keep distance between self and ship between ranges[0] and ranges[1]
		 */
		protected function maintainRange():void
		{
			var dist:Number = System.getDistance(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
			var rot:Number = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
			mc_object.rotation = rot;
			if (dist < ranges[0])
			{
				updatePosition(System.forward( -spd, rot, true), System.forward( -spd, rot, false));
				driftDir = -1;
			}
			else if (dist > ranges[1])
			{
				updatePosition(System.forward(spd, rot, true), System.forward(spd, rot, false));
				driftDir = 1;
			}
			else
				updatePosition(System.forward(drift * driftDir, rot, true), System.forward(drift * driftDir, rot, false));
		}
	}
}