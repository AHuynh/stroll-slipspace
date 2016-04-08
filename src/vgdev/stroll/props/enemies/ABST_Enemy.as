package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.System;
	import vgdev.stroll.props.projectiles.*;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Base class for enemies outside of the ship
	 * @author Alexander Huynh
	 */
	public class ABST_Enemy extends ABST_EMovable 
	{
		// cooldowns for weapons; can keep track of more than one weapon if desired
		protected var cooldowns:Array = [60];
		protected var cdCounts:Array = [30];
		
		/// The max distance from the enemy's range ellipse the enemy can stray to; default 20
		protected var rangeVary:Number = 20;
		protected var orbitX:Number = System.ORBIT_0_X;
		protected var orbitY:Number = System.ORBIT_0_Y;
				
		protected var dX:Number = 0;
		protected var dY:Number = 0;
		protected var dR:Number = 0;
		
		protected var prevPosition:Point;
		
		protected var spd:Number = 1;			// speed (in px) at which to move at when going to a target
		protected var drift:Number = .25;		// speed (in px) at which to move at when idling
		protected var driftDir:int = 1;			// direction of drift, 1 or -1

		protected var colAlpha:Number = 1;		// helper for displaying the red flash on taking a hit
		protected const DCOL:Number = .04;
		
		/// One of the 4 colors to use on projectiles
		protected var attackColor:uint;
	
		/// Amount of damage to give its projectiles
		protected var attackStrength:Number;
		
		/// Amount of damage to deal to the ship if the enemy itself collides with it
		protected var attackCollide:Number;
		
		protected var selfColor:uint = System.COL_WHITE;
		protected var ct:ColorTransform;
		
		/// If null, use mc_object as normal for collisions, else use hitbox specifically
		public var hitbox:MovieClip = null;
		private var useHitbox:Boolean = false;
		private var useRandom:Boolean = false;
		private var useTint:Boolean = false;
		
		protected var playDeathSFX:Boolean = true;
		
		/// If true, shouldn't be killed by normal means; ignore remove code in manager
		public var stubborn:Boolean = false;
		
		public function ABST_Enemy(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, new Point(System.setAttribute("x", attributes, 0), System.setAttribute("y", attributes, 0)), System.AFFIL_ENEMY);
			
			dX = System.setAttribute("dx", attributes, 0);
			dY = System.setAttribute("dy", attributes, 0);
			dR = System.setAttribute("dr", attributes, 0);
			mc_object.rotation = System.setAttribute("rot", attributes, 0);
			setScale(System.setAttribute("scale", attributes, 1));
			spd = System.setAttribute("spd", attributes, 1);
				
			attackColor = System.setAttribute("attackColor", attributes, System.COL_WHITE);
			attackStrength = System.setAttribute("attackStrength", attributes, 8);
			attackCollide = System.setAttribute("attackCollide", attributes, 15);
			
			if (attributes["tint"] != null)
				selfColor = attributes["tint"] == "random" ? System.getRandCol() : attributes["tint"];
			else
				selfColor = System.setAttribute("collideColor", attributes, System.COL_WHITE);
			
			useHitbox = attributes["customHitbox"] != null;
			useRandom = attributes["random"] != null;
			useTint =  System.setAttribute("useTint", attributes, false);
			
			hpMax = hp = System.setAttribute("hp", attributes, 30);
			
			ct = new ColorTransform();
			mc_object.base.transform.colorTransform = ct;
			
			prevPosition = new Point(mc_object.x, mc_object.y);
			
			if (attributes["noSpawnFX"] == null)
			{
				var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "rot": System.getRandNum(0, 360), "scale": mc_object.scaleX * 2 } );
				spawnFX.mc_object.base.setTint(attackColor);
			}
		}
		
		protected function setStyle(style:String):void
		{
			mc_object.gotoAndStop(style);
			mc_object.spawn.visible = false;
			mc_object.mc_bar.visible = false;
			if (useRandom)
				mc_object.base.gotoAndStop(System.getRandInt(1, mc_object.base.totalFrames));
			if (useTint)
				setBaseColor(selfColor);
			if (useHitbox)
			{
				if (mc_object.hitbox == null)
					trace("[ENEMY] Warning: Missing hitbox for enemy:", this);
				else
				{
					hitbox = mc_object.hitbox;
					hitbox.visible = false;
				}
			}
		}
		
		/**
		 * Directly set a protected member
		 * @param	attr	key
		 * @param	val		value to set the key
		 */
		public function setAttribute(attr:String, val:*):void
		{
			switch (attr)
			{
				case "spd":			spd = val;			return;
				case "drift":		drift = val;		return;
				case "cooldowns":	cooldowns = val;	return;
				default:			trace("[ABST_Enemy] Couldn't handle setting", attr, val);
			}
		}
		
		/**
		 * Set the color tint of this enemy, accounting for the 'hit flash'
		 * @param	col		uint color to use
		 */
		protected function setBaseColor(col:uint):void
		{
			selfColor = col;			
			ct.redMultiplier = selfColor >> 16 & 0x0000FF / 255;
			ct.greenMultiplier = Math.min(selfColor >> 8 & 0x0000FF / 255, (0xFF / 255) * colAlpha);
			ct.blueMultiplier = Math.min(selfColor & 0x0000FF / 255, (0xFF / 255) * colAlpha);
			if (mc_object != null)
				mc_object.base.transform.colorTransform = ct;
		}
		
		/**
		 * How many enemies this enemy counts for towards jamming
		 * @return		int, how many enemies this enemy counts as (default 1)
		 */
		public function getJammingValue():int
		{
			return 1;
		}
		
		override public function step():Boolean
		{
			if (!completed)
			{
				updatePrevPosition();
				updatePosition(dX, dY);
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateRotation(dR);
				maintainRange();
				updateWeapons();		
				updateDamageFlash();				
			}
			return completed;
		}
		
		public function updatePrevPosition():void
		{
			prevPosition.x = mc_object.x;
			prevPosition.y = mc_object.y;
		}
		
		/**
		 * Returns calculated dX and dY of this enemy
		 * @return		Point (dX, dY)
		 */
		public function getDelta():Point
		{
			return new Point(mc_object.x - prevPosition.x, mc_object.y - prevPosition.y);
		}
		
		protected function updateDamageFlash():void
		{
			// update red 'damage taken' flash; reduce its opacity
			if (colAlpha < 1)
			{
				colAlpha = System.changeWithLimit(colAlpha, DCOL, 0, 1);
				setBaseColor(selfColor);
			}
		}
		
		/**
		 * Update all weapon cooldowns and fire when appropriate
		 */
		protected function updateWeapons():void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					var proj:ABST_EProjectile = new EProjectileGeneric(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_ENEMY,
																		"attackColor":	attackColor,
																		"dir":			mc_object.rotation + System.getRandNum(-5, 5),
																		"dmg":			attackStrength,
																		"life":			150,
																		"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																		"spd":			3,
																		"style":		"eye"
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
				}
			}
		}
		
		override protected function onShipHit():void 
		{
			cg.ship.damage(attackCollide, selfColor);
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
		 * @param	amt		The amount of damage to deal (negative to deal damage)
		 * @return			true if this object's HP is 0
		 */
		override public function changeHP(amt:Number):Boolean 
		{
			if (amt < 0)
				colAlpha = .3;
			hp = System.changeWithLimit(hp, amt, 0, hpMax);
			if (hp == 0)
				destroy();
			return hp == 0;
		}
		
		/**
		 * Keep distance between self and ship within elliptical orbit plus or minus rangeVary
		 */
		protected function maintainRange():void
		{				
			var dist:Number = System.getDistance(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
			var theta:Number = System.getAngle(cg.shipHitMask.x, cg.shipHitMask.y, mc_object.x, mc_object.y);
			var rot:Number = (theta + 180) % 360;
			mc_object.rotation = rot;
			var tgtPoint:Point = new Point(orbitX * Math.cos(System.degToRad(theta)),  orbitY * Math.sin(System.degToRad(theta)));
			var tgtDist:Number = System.getDistance(tgtPoint.x, tgtPoint.y, cg.shipHitMask.x, cg.shipHitMask.y);
			
			if (dist > tgtDist + rangeVary)			// too far away
			{
				updatePosition(System.forward(spd, rot, true), System.forward(spd, rot, false));
				driftDir = 1;
			}
			else if (dist < tgtDist - rangeVary)	// too close
			{
				updatePosition(System.forward( -spd, rot, true), System.forward( -spd, rot, false));
				driftDir = -1;
			}
			else									// in-between
			{
				updatePosition(System.forward(drift * driftDir, rot, true), System.forward(drift * driftDir, rot, false));
			}
		}
		
		override public function destroySilently():void 
		{
			super.destroy();
		}
		
		override public function destroy():void 
		{
			SoundManager.playSFX("sfx_explosionlarge1", 0.5);
			if (playDeathSFX)
				SoundManager.playSFX("sfx_monsterdeath");
			var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "scale":1 } );
			spawnFX.mc_object.base.setTint(System.COL_ORANGE);
			super.destroy();
		}
	}
}