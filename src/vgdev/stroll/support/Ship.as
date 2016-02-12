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
		private var mc_shield:MovieClip;
		
		private var hpMax:Number = 1000;
		private var hp:Number = hpMax;
		
		private var shieldMax:Number = 100;			// actual value of shields
		private var shield:Number = shieldMax;		// max value of shields
		
		private var shieldReCurr:int = 0;			// current reboot timer
		private var shieldRecharge:int = 120;		// time since last hit until shield starts to recharge
		private var shieldReAmt:Number = .25;		// amount to recharge shield per frame
		
		private const SHIELD_DA:Number = .03;
		private var shieldCD:int = 0;
		private const SHIELD_CD:int = 15;
		private const SHIELD_MA:Number = .1;
		
		private var shieldCol:uint = System.COL_WHITE;
		private var shieldCTF:ColorTransform;
		
		public function Ship(_cg:ContainerGame)
		{
			cg = _cg;
			mc_shield = cg.game.mc_ship.shield;
			
			shieldCTF = new ColorTransform();
			setShieldColor(shieldCol);
		}
		
		public function damage(dmg:Number):void
		{
			var overdamage:Number = shield - dmg;
			shield = Math.max(0, shield - dmg);
			
			if (overdamage < 0)
				hp = System.changeWithLimit(hp, overdamage, 0);
			
			updateIntegrity();
			
			//if (hp == 0)
			//	game over
			
			if (shield > 0)
				mc_shield.base.alpha = .75;
			else if (mc_shield.base.alpha != 0)
			{
				cg.setHitMask(true);
				mc_shield.fx.gotoAndPlay("offline");
				mc_shield.base.alpha = 0;
			}
				
			shieldCD = SHIELD_CD;
			shieldReCurr = shieldRecharge;
		}
		
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
		
		private function updateIntegrity():void
		{
			cg.gui.tf_hull.text = Math.ceil(100 * hp / hpMax).toString();
			cg.gui.tf_shield.text = Math.ceil(100 * shield / shieldMax).toString();
		}
		
		public function step():void
		{
			if (shieldReCurr > 0)
			{
				if (--shieldReCurr == 0)
				{
					cg.setHitMask(false);
					mc_shield.fx.gotoAndPlay("rebootStart");
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
	}
}