package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
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
		private const RANGE_EXTINGUISH:Number = 65
		
		private const RATE_REPAIR:Number = 5;
		private const RANGE_REPAIR:Number = 30
		
		private const RATE_REVIVE:Number = 1;
		private const GOAL_REVIVE:Number = 90;
		private const RANGE_REVIVE:Number = 40;
		private var reviveProgress:Number = 0;
		
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
		
		override public function changeHP(amt:Number):Boolean 
		{
			// -- do nothing; Omnitool is invincible
			return false;
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
			if (!keys[4]) return;
			
			// affect fires
			if (affectItems(System.M_FIRE, RANGE_EXTINGUISH, RATE_EXTINGUISH, "extinguish"))
				return;
			
			// repair consoles
			if (affectItems(System.M_CONSOLE, RANGE_REPAIR, RATE_REPAIR, "repair"))
				return;
			
			// revive incapacitated players
			for each (var player:Player in cg.players)
			{				
				if (player == closestPlayer || player.getHP() != 0)
					continue;
				if (System.getDistance(closestPlayer.mc_object.x, closestPlayer.mc_object.y, player.mc_object.x, player.mc_object.y) < RANGE_REVIVE)
				{					
					reviveProgress += RATE_REVIVE;
					
					if (Math.random() < .7)
						cg.addDecor("repair", {
													"x": player.mc_object.x + System.getRandNum(-6, 6),
													"y": player.mc_object.y + System.getRandNum(-6, 6),
													"dy": System.getRandNum(-.5, -1)
												  });	
					
					// TODO reviving graphic
					if (reviveProgress >= GOAL_REVIVE)
					{
						player.revive();
						reviveProgress = 0;
					}
					return;
				}
			}
			reviveProgress = 0;
		}
		
		/**
		 * Attempt to affect the closest item in the set of items
		 * @param	manager			the manager managing the items to be affected
		 * @param	range			the range of the omnitool for these items
		 * @param	rate			the rate to change item's HP by per tick
		 * @param	visualEffect	the String label of the Decor item to use
		 * @return					true if an item was affected
		 */
		private function affectItems(manager:int, range:Number, rate:Number, visualEffect:String):Boolean
		{
			if (cg.managerMap[manager].hasObjects())
			{
				var items:Array = cg.managerMap[manager].getNearby(closestPlayer, range);
				var facing:int = closestPlayer.facing;
				var angle:Number;
				for each (var item:ABST_Object in items)
				{
					// skip if the item isn't active
					if (!item.isActive())
						continue;
						
					// skip if trying to heal the item but it is at max HP
					if (rate > 0 && item.getHP() == item.getHPmax())
						continue;
					
					// skip if not facing the item
					if (facing == 0 && item.mc_object.x < closestPlayer.mc_object.x || 
						facing == 1 && item.mc_object.y > closestPlayer.mc_object.y || 
						facing == 2 && item.mc_object.x > closestPlayer.mc_object.x || 
						facing == 3 && item.mc_object.y < closestPlayer.mc_object.y)
						continue;
						
					// create the visual effect
					angle = System.getAngle(closestPlayer.mc_object.x, closestPlayer.mc_object.y, item.mc_object.x, item.mc_object.y);
					if (Math.random() < .7)
					{
						switch (visualEffect)
						{
							case "extinguish":
								cg.addDecor(visualEffect, {
														"x": closestPlayer.mc_object.x + System.getRandNum(-5, 5),
														"y": closestPlayer.mc_object.y - 10 + System.getRandNum(-5, 5),
														"dx": System.forward(System.getRandNum(3, 5), angle + System.getRandNum(-10, 10), true),
														"dy": System.forward(System.getRandNum(3, 5), angle + System.getRandNum(-10, 10), false)
													  });	
							break;
							case "repair":
								cg.addDecor(visualEffect, {
														"x": item.mc_object.x + System.getRandNum(-6, 6),
														"y": item.mc_object.y + System.getRandNum(-6, 6),
														"dy": System.getRandNum(-.5, -1)
													  });	
							break;
						}
						
					}
					item.changeHP(rate);
					
					// can only deal with 1 item at a time; it will be the closest since items will be sorted
					return true;
				}
			}
			return false;
		}
	}
}