package vgdev.stroll.support 
{
	import flash.geom.ColorTransform;
	import vgdev.stroll.ContainerGame;
	import flash.display.MovieClip;
	import vgdev.stroll.System;
	
	/**
	 * Support functionality related to the ship
	 * @author Alexander Huynh
	 */
	public class Ship 
	{
		private var cg:ContainerGame;
		
		private var hpMax:Number = 1000;			// maximum hull strength
		private var hp:Number = hpMax;				// current hull strength
		
		// -- Shield --------------------------------------------------------------------------------------
		private var mc_shield:MovieClip;			// reference to the shield MovieClip
		private var shieldMax:Number = 100;			// actual value of shields
		private var shield:Number = shieldMax;		// max value of shields
		
		private var shieldReCurr:int = 0;			// current reboot timer
		private var shieldRecharge:int = 90;		// time since last hit until shield starts to recharge
		private var shieldReAmt:Number = .25;		// amount to recharge shield per frame
		
		private const SHIELD_DA:Number = .03;		// amount to fade shield alpha per frame
		private var shieldCD:int = 0;				// current frames to hold before starting shield fade
		private const SHIELD_CD:int = 15;			// frames to hold before starting shield fade
		private const SHIELD_MA:Number = .1;		// minimum alpha of shield as long as it is non-zero
		
		/// Amount to multiply damage by if attack color matches shield color
		private var shieldMitigation:Number = .35;
		
		private var shieldCol:uint = System.COL_WHITE;	// current shield color
		private var shieldCTF:ColorTransform;
		// ------------------------------------------------------------------------------------------------
		
		// -- Navigation -----------------------------------------------------------------------------------
		public var shipHeading:Number = 0; //Number determining how far off course ship is. Maintain this at 0 for best navigation.
		
		private var SHIP_HEADING_MAX:Number = 1; 	//Max value shipHeading can have
		private var SHIP_HEADING_MIN:Number = -1; 	//Min value shipHeading can have
		
		private var HEADING_RUNAWAY:Number = 1.003;  //Scaling factor applied to heading every game tick
		private var HEADING_JUMP:Number = 0.001;		//max value of random jumps applied to the heading every game tick 
		// ------------------------------------------------------------------------------------------------
		
		// -- Slipdrive -----------------------------------------------------------------------------------
		public var slipRange:Number = 1;			// 'distance' until slipdrive is in range
		private var MAX_SLIP_SPEED:Number = .03;
		private var MIN_SLIP_SPEED:Number = .01;
		
		public var slipSpeed:Number = MAX_SLIP_SPEED;	// amount to reduce slipRange per frame
		private var slipLimits:Array = [0, 1];		// min and max values of slipSpeed
		public var jammable:int = 0;				// if non-zeo, prevents jumping if at least jammable enemies are present
		// ------------------------------------------------------------------------------------------------
		
		public function Ship(_cg:ContainerGame)
		{
			cg = _cg;
			mc_shield = cg.game.mc_ship.shield;
			
			shieldCTF = new ColorTransform();
			setShieldColor(shieldCol);
		}
		
		public function getShields():Number
		{
			return shield;
		}
		
		/**
		 * Deal damage to the ship (with shields in effect)
		 * @param	dmg		Amount of damage to deal (a positive value to damage)
		 * @param	col		Color type of damage
		 */
		public function damage(dmg:Number, col:uint = 0):void
		{
			// shields absorb all damage until it breaks
			// a 10 damage attack against 100 hull and 20 shield results in 100 hull and 10 shield
			// a 10 damage attack against 100 hull and 1 shield results in 100 hull and 0 shield
			// a 10 damage attack against 100 hull and 0 shield results in 90 hull and 0 shield
			if (shield > 0)
			{
				if (shieldCol == col)
					dmg *= shieldMitigation;
				shield = System.changeWithLimit(shield, -dmg, 0);
				SoundManager.playSFX("sfx_hitshield1");
			}
			else
			{
				hp = System.changeWithLimit(hp, -dmg, 0);
				SoundManager.playSFX("sfx_hithull1");
			}
						
			updateIntegrity();
			
			//if (hp == 0)
			//	game over
			
			if (shield > 0)
				mc_shield.base.alpha = .75;
			else if (mc_shield.base.alpha != 0)
			{
				mc_shield.fx.gotoAndPlay("offline");
				mc_shield.base.alpha = 0;
			}
			
			cg.setHitMask(shield == 0);
				
			shieldCD = SHIELD_CD;
			shieldReCurr = shieldRecharge;
		}
		
		/**
		 * Deal direct damage to the hull, ignoring shields
		 * @param	dmg
		 */
		public function damageDirect(dmg:Number):void
		{
			hp = System.changeWithLimit(hp, -dmg, 0);
			updateIntegrity();
			
			//if (hp == 0)
			//	game over
		}
		
		/**
		 * Update the UI
		 */
		private function updateIntegrity():void
		{
			cg.gui.tf_hull.text = Math.ceil(100 * hp / hpMax).toString();
			cg.gui.tf_shield.text = Math.ceil(100 * shield / shieldMax).toString();
		}
		
		/**
		 * Set the color of the ship's shield
		 * @param	col		The color to use
		 */
		public function setShieldColor(col:uint):void
		{
			shieldCol = col;
			shieldCTF.color = shieldCol;
			mc_shield.transform.colorTransform = shieldCTF;
			
			if (shield > 0)
			{
				mc_shield.fx.gotoAndPlay("rebootStart");
				mc_shield.base.alpha = Math.max(mc_shield.base.alpha, .5);
				shieldCD = SHIELD_CD;
			}
		}
		
		public function adjustHeading(change:Number):void 
		{
			var newHeading:Number = shipHeading + change;
			
			if (newHeading > SHIP_HEADING_MAX) {
				shipHeading = SHIP_HEADING_MAX;
			} else if (newHeading < SHIP_HEADING_MIN) {
				shipHeading = SHIP_HEADING_MIN;
			} else {
				shipHeading = newHeading;
			}
		
		}
		
		public function scaleHeading(factor:Number):void
		{
			var change:Number = shipHeading * factor - shipHeading;
			adjustHeading(change);
		}
		
		private function updateShields():void
		{
			if (shieldReCurr > 0)
			{
				if (--shieldReCurr == 0)
				{
					cg.setHitMask(false);
					mc_shield.fx.gotoAndPlay("rebootStart");
					SoundManager.playSFX("sfx_shieldrecharge");
				}
			}
			else if (shield < shieldMax)
			{
				shield = System.changeWithLimit(shield, shieldReAmt, 0, shieldMax);
				if (shield == shieldMax)
				{
					mc_shield.fx.gotoAndPlay("rebootFull");
					mc_shield.base.alpha = SHIELD_MA;
				}
				updateIntegrity();
			}
			
			if (shieldCD > 0)
			{
				shieldCD--;
			}
			else if (mc_shield.base.alpha > SHIELD_MA)
			{
				mc_shield.base.alpha = System.changeWithLimit(mc_shield.base.alpha, -SHIELD_DA, SHIELD_MA);
			}
		}
		
		private function updateNavigation():void {
			scaleHeading(HEADING_RUNAWAY);
			adjustHeading((Math.random() - 0.5) * HEADING_JUMP);
			slipSpeed = MAX_SLIP_SPEED - ((MAX_SLIP_SPEED - MIN_SLIP_SPEED) * Math.abs(shipHeading));
			trace("Current Heading: " + shipHeading + "Current Slip Speed: " + slipSpeed);
		}
		
		private function updateSlip():void
		{
			if (slipRange > 0)
			{
				slipRange = System.changeWithLimit(slipRange, -slipSpeed, 0);
				if (slipRange == 0)
				{
					SoundManager.playSFX("sfx_bell");
					cg.gui.mc_jumpReady.visible = true;
				}
				cg.gui.tf_distance.text = Math.ceil(slipRange).toString() + " LY";
			}
		}
		
		/**
		 * Check if the slipdrive is ready
		 * @return		"ready" if jump is ready; otherwise reason why not
		 */
		public function isJumpReady():String
		{
			// TODO add other limiting conditions here
			if (!isNavGood()) {
				//change to say navigation sucks
				return "range";
			}
			if (jammable != 0 && cg.managerMap[System.M_ENEMY].numObjects() >= jammable)
				return "jammed";
			return slipRange == 0 ? "ready" : "range";
		}
		
		public function isNavGood():Boolean 
		{
			return Math.abs(shipHeading) < 0.035;
		}
		
		
		/**
		 * Attempt to jump the ship to the next sector
		 * @return		true if the jump succeeded
		 */
		public function jump():Boolean
		{
			if (isJumpReady())
			{
				SoundManager.playSFX("sfx_slipjump");
				cg.jump();
				return true;
			}
			return false;
		}
		
		public function step():void
		{
			updateSlip();
			updateNavigation();
			updateShields();
		}
	}
}