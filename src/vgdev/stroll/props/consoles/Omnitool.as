package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.enemies.InternalFire;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	
	/**
	 * An omnitool that can be picked up by players
	 * @author Alexander Huynh
	 */
	public class Omnitool extends ABST_Console
	{		
		private const RATE_EXTINGUISH:Number = -5;
		private const RANGE_EXTINGUISH:Number = 65;
		
		public function Omnitool(_cg:ContainerGame, _mc_object:MovieClip, _players:Array)
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "omnitool";
		}
		
		/**
		 * Called when a player is attempting to pick up this item
		 * @param	p		the Player attempting to pick this up
		 */
		override public function onAction(p:Player):void
		{
			if (!inUse)
			{				
				if (closestPlayer != null && closestPlayer == p)
				{
					inUse = true;
					closestPlayer.sitAtConsole(this, false);
					mc_object.visible = false;
					closestPlayer.mc_object.mc_omnitool.visible = true;
	
					hud_consoles[closestPlayer.playerID].gotoAndStop(CONSOLE_NAME);
					updateHUD(true);
				}
			}
		}
		
		/**
		 * Called when a player drops this item
		 */
		override public function onCancel():void
		{
			if (inUse)
			{
				inUse = false;
				mc_object.visible = true;
				closestPlayer.mc_object.mc_omnitool.visible = false;
				mc_object.x = closestPlayer.mc_object.x;
				mc_object.y = closestPlayer.mc_object.y;
				hud_consoles[closestPlayer.playerID].gotoAndStop("none");
				closestPlayer = null;
				updateHUD(false);
			}
		}		
		
		override public function holdKey(keys:Array):void
		{
			// detect fires
			if (keys[4] && cg.managerMap[System.M_FIRE].hasObjects())
			{
				var fires:Array = cg.managerMap[System.M_FIRE].getNearby(closestPlayer, RANGE_EXTINGUISH);
				var facing:int = closestPlayer.facing;
				var angle:Number;
				for each (var fire:InternalFire in fires)
				{
					if (!fire.isActive())
						continue;
					
					// skip if not facing the fire
					if (facing == 0 && fire.mc_object.x < closestPlayer.mc_object.x || 
						facing == 1 && fire.mc_object.y > closestPlayer.mc_object.y || 
						facing == 2 && fire.mc_object.x > closestPlayer.mc_object.x || 
						facing == 3 && fire.mc_object.y < closestPlayer.mc_object.y)
						continue;
					
					angle = System.getAngle(closestPlayer.mc_object.x, closestPlayer.mc_object.y, fire.mc_object.x, fire.mc_object.y);
					if (Math.random() < .7)
						cg.addDecor("extinguish", {
													"x": closestPlayer.mc_object.x + System.getRandNum(-5, 5),
													"y": closestPlayer.mc_object.y - 10 + System.getRandNum(-5, 5),
													"dx": System.forward(System.getRandNum(3, 5), angle + System.getRandNum(-10, 10), true),
													"dy": System.forward(System.getRandNum(3, 5), angle + System.getRandNum(-10, 10), false)
												  });
					fire.changeHP(RATE_EXTINGUISH);
				}
					
			}
		}
	}
}