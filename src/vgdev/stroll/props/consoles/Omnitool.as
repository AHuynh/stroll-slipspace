package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.media.SoundChannel;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.enemies.InternalFire;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * An omnitool that can be picked up by players
	 * @author Alexander Huynh
	 */
	public class Omnitool extends ABST_Console
	{		
		private const RATE_EXTINGUISH:Number = -5;
		public static const RANGE_EXTINGUISH:Number = 65
		
		private const RATE_REPAIR:Number = 5;
		public static const RANGE_REPAIR:Number = 30
		
		private const RATE_REVIVE:Number = 1.5;
		private const RATE_HEAL:Number = 0.5;
		private const GOAL_REVIVE:Number = 90;
		public static const RANGE_REVIVE:Number = 40;
		private var reviveProgress:Number = 0;
		
		private var sfx:SoundChannel;
		
		public function Omnitool(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean)
		{
			super(_cg, _mc_object, _players, locked);
			CONSOLE_NAME = "Omnitool";
			TUT_SECTOR = 4;
			TUT_TITLE = "Omnitool";
			TUT_MSG = "A restorative tool that you can take with you.\n\n" +
					  "Press and hold to extinguish fires, repair modules, and revive allies.";
		}
		
		/**
		 * Called when a player is attempting to pick up this item
		 * @param	p		the Player attempting to pick this up
		 */
		override public function onAction(p:Player):void
		{
			if (!inUse)
			{				
				if (closestPlayer != null && closestPlayer == p && closestPlayer.activeConsole == null)
				{
					inUse = true;
					closestPlayer.sitAtConsole(this, false);
					mc_object.visible = false;
					closestPlayer.mc_object.mc_omnitool.visible = true;
	
					hud_consoles[closestPlayer.playerID].gotoAndStop(CONSOLE_NAME.toLowerCase());
					cg.hudTitles[closestPlayer.playerID].visible = true;
					cg.hudTitles[closestPlayer.playerID].text = CONSOLE_NAME;
					updateHUD(true);
					if (cg.tails.tutorialMode)
					{
						hud_consoles[closestPlayer.playerID].mc_tutorial.visible = true;
						hud_consoles[closestPlayer.playerID].mc_tutorial.gotoAndStop(CONSOLE_NAME.toLowerCase());
						
						cg.tails.showHalf(closestPlayer.playerID == 0, TUT_TITLE, TUT_MSG);
					}
					mc_object.mc_newIndicator.visible = false;
				}
			}
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			// -- do nothing; Omnitool is invincible
			return false;
		}
		
		/**
		 * Helper to get the distance from this object to another
		 * @param	other		the other ABST_Obect
		 * @return				the distance in pixels
		 */
		override public function getDistance(other:ABST_Object):Number
		{
			return System.getDistance(mc_object.x, mc_object.y, other.mc_object.x, other.mc_object.y);
		}
		
		public function stopSFX():void
		{
			if (sfx)
			{
				sfx.stop();
				sfx = null;
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
				hud_consoles[closestPlayer.playerID].mc_tutorial.visible = false;
				cg.hudTitles[closestPlayer.playerID].visible = false;
				cg.tails.hideHalf(closestPlayer.playerID == 0);
				updateDepth();
				closestPlayer = null;
				updateHUD(false);
				stopSFX();
			}
		}
		
		override public function holdKey(keys:Array):void
		{
			var ui:MovieClip = getHUD();
			
			if (!keys[4]) 
			{
				reviveProgress = 0;
				ui.tf_status.text = "Idle";
				stopSFX();
				return;
			}
			ui.tf_status.text = "Searching";
			
			// affect fires
			if (affectItems(System.M_FIRE, RANGE_EXTINGUISH, RATE_EXTINGUISH, "extinguish"))
			{
				ui.tf_status.text = "Douse";
				return;
			}
			
			// heal or revive incapacitated players
			for each (var player:Player in cg.players)
			{				
				if (player == closestPlayer)
					continue;
				if (System.getDistance(closestPlayer.mc_object.x, closestPlayer.mc_object.y, player.mc_object.x, player.mc_object.y) < RANGE_REVIVE)
				{
					if (player.getHP() == player.getHPmax())
						continue;
					
					if (player.getHP() != 0)
					{
						if (!sfx)
							sfx = SoundManager.getSFX("sfx_healingloop");
						player.changeHP(RATE_HEAL);
						ui.tf_status.text = "Heal";
						addRestorativeParticles(player.mc_object.x + System.getRandNum( -6, 6),
												player.mc_object.y - 20 + System.getRandNum( -6, 6));
						return;
					}
					
					reviveProgress += RATE_REVIVE;
					player.updateReviveUI(reviveProgress / GOAL_REVIVE);
					
					ui.tf_status.text = "Rez " + int(100 * reviveProgress / GOAL_REVIVE) + "%";
					
					addRestorativeParticles(player.mc_object.x + System.getRandNum( -6, 6),
											player.mc_object.y - 20 + System.getRandNum( -6, 6));

					if (reviveProgress >= GOAL_REVIVE)
					{
						player.revive();
						reviveProgress = 0;
					}
					if (!sfx)
						sfx = SoundManager.getSFX("sfx_healingloop");
					return;
				}
			}
			
			// repair consoles
			if (affectItems(System.M_CONSOLE, RANGE_REPAIR, RATE_REPAIR, "repair"))
			{
				ui.tf_status.text = "Repair";
				return;
			}
			
			stopSFX();
			reviveProgress = 0;
		}
		
		private function addRestorativeParticles(locX:Number, locY:Number):void
		{
			cg.addDecor("plus", { "x": locX + System.getRandNum(-12, 12), "y": locY + System.getRandNum(-12, 12), "dy": -1, "alphaDelay": 5, "alphaDelta": 20 } );
			if (Math.random() > .7)
				cg.addDecor("repair", {"x": locX, "y": locY});	
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
														"dy": System.forward(System.getRandNum(3, 5), angle + System.getRandNum( -10, 10), false),
														"random": true,
														"alphaDelay": 1,
														"alphaDelta": 30
													  });	
							break;
							case "repair":
								addRestorativeParticles(item.mc_object.x + System.getRandNum( -6, 6), item.mc_object.y + System.getRandNum( -6, 6));
							break;
						}
						
					}
					item.changeHP(rate);
					
					if (!sfx)
						sfx = SoundManager.getSFX("sfx_healingloop");
					
					// can only deal with 1 item at a time; it will be the closest since items will be sorted
					return true;
				}
			}
			return false;
		}
	}
}