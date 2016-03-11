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
		// cooldowns for weapons; can keep track of more than one weapon if desired
		protected var cooldowns:Array = [60];
		protected var cdCounts:Array = [0];
		
		/// The min and max range from the ship that this Enemy should keep between
		protected var ranges:Array = [290, 500];
				
		protected var dX:Number = 0;
		protected var dY:Number = 0;
		protected var dR:Number = 0;
		
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
		
		public function ABST_Enemy(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, new Point(System.setAttribute("x", attributes, 0), System.setAttribute("y", attributes, 0)), System.AFFIL_ENEMY);
			
			dX = System.setAttribute("dx", attributes, 0);
			dY = System.setAttribute("dy", attributes, 0);
			dR = System.setAttribute("dr", attributes, 0);
			mc_object.rotation = System.setAttribute("rot", attributes, 0);
			setScale(System.setAttribute("scale", attributes, 1));
				
			attackColor = System.setAttribute("attackColor", attributes, System.COL_WHITE);
			attackStrength = System.setAttribute("attackStrength", attributes, 8);
			attackCollide = System.setAttribute("attackCollide", attributes, 15);
			
			if (attributes["tint"] != null)
				selfColor = attributes["tint"] == "random" ? System.getRandCol() : attributes["tint"];
			useHitbox = attributes["customHitbox"] != null;
			
			hpMax = hp = System.setAttribute("hp", attributes, 30);
			
			ct = new ColorTransform();
			mc_object.base.transform.colorTransform = ct;
		}
		
		protected function setStyle(style:String):void
		{
			mc_object.gotoAndStop(style);
			mc_object.spawn.visible = false;
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
		 * Set the color tint of this enemy, accounting for the 'hit flash'
		 * @param	col		uint color to use
		 */
		protected function setBaseColor(col:uint):void
		{
			selfColor = col;			
			ct.redMultiplier = selfColor >> 16 & 0x0000FF / 255;
			ct.greenMultiplier = Math.min(selfColor >> 8 & 0x0000FF / 255, (0xFF / 255) * colAlpha);
			ct.blueMultiplier = Math.min(selfColor & 0x0000FF / 255, (0xFF / 255) * colAlpha)
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
																		"style":		null
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
			colAlpha = .3;
			hp = System.changeWithLimit(hp, amt, 0, hpMax);
			if (hp == 0)
				destroy();
			return hp == 0;
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
		
		override public function destroySilently():void 
		{
			super.destroy();
		}
		
		override public function destroy():void 
		{
			SoundManager.playSFX("sfx_explosionlarge1");
			cg.addDecor("explosion_small", { "x":mc_object.x, "y":mc_object.y, "scale":4 } );
			super.destroy();
		}
	}
}