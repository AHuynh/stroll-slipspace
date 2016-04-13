package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Configures the shield color
	 * @author Alexander Huynh
	 */
	public class ConsoleShields extends ABST_Console 
	{
		/// A reference to the shield MovieClip
		private var mc_shield:MovieClip;
		
		/// The number of frames to wait in-between shield swaps
		protected var cooldown:int = 30;
		
		/// The current cooldown count, where 0 is ready to swap
		protected var cdCount:int = 0;
		
		private var shieldCols:Array = [System.COL_GREEN, System.COL_RED, System.COL_YELLOW, System.COL_BLUE];
		private var currShield:int = -1;
		
		public function ConsoleShields(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean = false) 
		{

			super(_cg, _mc_object, _players, locked);
			CONSOLE_NAME = "Shield Frq";
			TUT_SECTOR = 4;

			TUT_TITLE = "Shield Frequency Module";
			TUT_MSG = "If you match the shield color to the color of enemies' attacks, our shields will take less damage!"
			mc_shield = cg.game.mc_ship.shield;
		}
		
		// reduce shield switch cooldown
		override public function step():Boolean
		{
			if (corrupted)		// relinquish control if corrupted
				return consoleFAILS.step();
			
			if (cdCount > 0)		
				cdCount--;
			if (inUse)
				updateHUD(true);
			return super.step();
		}
		
		override public function onKey(key:int):void
		{
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.onKey(key);
				return;
			}
			
			if (cdCount != 0 || broken)		// quit if shield switch is on cooldown or console is destroyed
				return;
				
			// if a direction key was hit and the corresponding color isn't already active
			if (key != 4 && key != currShield)
			{
				cg.ship.setShieldColor(shieldCols[key])
				cdCount = cooldown;

				// play the shield switch sound if shields are actually up
				if (cg.ship.getShields() > 0)
					SoundManager.playSFX("sfx_shieldrecharge");
				
				currShield = key;
				updateHUD(true);
			}
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			var isZero:Boolean = super.changeHP(amt);
			if (isZero) cg.ship.setShieldColor(System.COL_WHITE);
			return isZero;
		}
		
		override public function disableConsole():void 
		{
			cg.ship.setShieldColor(System.COL_WHITE);
			currShield = -1;
		}
		
		public function onCooldown():Boolean
		{
			return cdCount > 0;
		}
		
		// update the active color displayed on the module HUD
		override public function updateHUD(isActive:Boolean):void
		{
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.updateHUD(isActive);
				return;
			}
			
			if (isActive)
			{
				//getHUD().shieldIndicator.gotoAndStop(currShield + 2);
				getHUD().tf_cooldown.text =  Math.ceil(100 * (1 - (cdCount / cooldown))).toString();
				getHUD().tf_recharge.text = Math.ceil(100 * (1 - (cg.ship.shieldReCurr / cg.ship.shieldRecharge))).toString();		
				
				/*var ct:ColorTransform = new ColorTransform();
				ct.color = currShield == -1 ? System.COL_WHITE : shieldCols[currShield];
				hud_consoles[0].transform.colorTransform = ct;
				hud_consoles[1].transform.colorTransform = ct;*/
			}
		}
	}
}