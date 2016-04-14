package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Abstract console class
	 * @author Alexander Huynh
	 */
	public class ABST_Console extends ABST_Object 
	{
		protected var players:Array;
		public static const RANGE:int = 12;		// maximum range in px from which a player can activate this console
		
		/// Used as a label in the HUD object
		public var CONSOLE_NAME:String = "None";
		
		/// The two HUD objects for the consoles, an Array of MovieClips
		protected var hud_consoles:Array;
		
		/// If a player is currently using this console
		public var inUse:Boolean = false;	
		
		/// The active player if this console is inUse; otherwise the nearest player
		public var closestPlayer:Player;
		protected var playerProximities:Array;
		
		/// The width of the HP bar
		private var BAR_WIDTH:Number;
		
		protected var TUT_SECTOR:int = 0;
		protected var TUT_TITLE:String = "Unknown Module";
		protected var TUT_MSG:String = "Hey! I can't find the description for this module...";
		
		protected var unlocked:Boolean = true;
		// use mc_object.parentClass to access the ABST_Console class associated with a console MovieClip
		
		// --- FAILS helper ------------------------------------
		public var corrupted:Boolean = false;				// if true, console is either "corrupt" or "fails"
		public var debuggable:Boolean = false;				// if true, this console can be debugged ("fails")
		public static var numCorrupted:int = 0;
		public static var beingUsed:Boolean = false;		// if true, 1 player already debugging
		protected var consoleFAILS:ConsoleFAILS = null;		// the ConsoleFAILS class to use if corrupt
		public var unscrambledLocation:MovieClip;
		// ----------------------------------------------------
		
		private var HP_THRESH:int;
		protected var broken:Boolean = false;
		
		public function ABST_Console(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean = false)
		{
			super(_cg, _mc_object);
			unscrambledLocation = mc_object;
			hud_consoles = cg.hudConsoles;
			players = _players;
			
			playerProximities = [9999, 9999];
			
			unlocked = !locked;
			hp = hpMax = 1000;
			HP_THRESH = int(hpMax * .3);
			
			mc_object.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		/**
		 * Helper to init the HP bar
		 * 
		 * @param	e	the captured Event, unused
		 */
		private function onAddedToStage(e:Event):void
		{
			mc_object.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			mc_object.parentClass = this;
			if (mc_object.mc_bar != null)
			{
				mc_object.mc_bar.visible = false;		// hide the HP bar
				BAR_WIDTH = mc_object.mc_bar.bar.width;
			}
			setLocked(!unlocked);
		}
		
		/**
		 * Set if this console is locked or not
		 * @param	isLocked
		 */
		public function setLocked(isLocked:Boolean):void
		{
			unlocked = !isLocked;
			if (mc_object.mc_pad != null)
			{
				mc_object.mc_pad.gotoAndStop(unlocked ? CONSOLE_NAME.toLowerCase() : 1);
				if (unlocked)
					mc_object.base.gotoAndPlay(corrupted ? "corrupt" : 1);
				else
					mc_object.base.gotoAndStop("off");
			
				mc_object.mc_corruption.visible = corrupted;
				mc_object.mc_fixIndicator.visible = false;
			}
			else	// Omnitool
			{
				mc_object.visible = unlocked;
			}
		}
		
		public function isUnlocked():Boolean
		{
			return unlocked;
		}
		
		public function isBroken():Boolean
		{
			return broken;
		}
		
		override public function changeHP(amt:Number):Boolean
		{
			hp = System.changeWithLimit(hp, amt, 0, hpMax);		
			
			// disable console
			if (hp == 0 && !broken)
			{
				broken = true;
				mc_object.gotoAndStop(4);
				if (inUse)
					closestPlayer.onCancel();
				else
					onCancel();
				disableConsole();	//stop the beneficial effects of this console
			}
			// repair console
			else if (broken && amt > 0)
			{
				if (hp > HP_THRESH)
				{
					broken = false;
					mc_object.gotoAndStop(corrupted ? 4 : 2);
					if (inUse)
						setHUD(CONSOLE_NAME);
				}
			}
			
			if (hp != hpMax)
			{
				mc_object.mc_bar.visible = true;
				mc_object.mc_bar.bar.width = (hp / hpMax) * BAR_WIDTH;
			}
			else
				mc_object.mc_bar.visible = false;
				
			return hp == 0;
		}

		/**
		 * Updates the closest player and '!' display for this console
		 * Called by ManagerProximity
		 * @param	p		Player to update proximities for
		 */
		public function setProximity(p:Player):void
		{
			if (!unlocked || inUse) return;
			
			playerProximities[p.playerID] = broken ? 99999 : getDistance(p);
			var closest:Player = null;
			var closestDist:Number = 99999;
			
			for (var i:int = 0; i < playerProximities.length; i++)
			{
				if (playerProximities[i] > RANGE) continue;
				if (playerProximities[i] < closestDist)
				{
					closestDist = playerProximities[i];
					closest = players[i];
				}
			}
			
			closestPlayer = closest;
			setPromptVisible(closestPlayer != null)
		}
		
		/**
		 * Helper to get the distance from this object to another
		 * @param	other		the other ABST_Obect
		 * @return				the distance in pixels
		 */
		override public function getDistance(other:ABST_Object):Number
		{
			return System.getDistance(mc_object.x, mc_object.y + 17, other.mc_object.x, other.mc_object.y);
		}
		
		/**
		 * Override this in ABST_Item
		 * @param	vis
		 */	
		public function setPromptVisible(vis:Boolean):void
		{
			if (!unlocked) mc_object.prompt.visible = false;
			mc_object.prompt.visible = vis;
		}
		
		override public function step():Boolean 
		{
			if (corrupted)		// relinquish control if corrupted
				return consoleFAILS.step();
			return super.step();
		}
		
		/**
		 * Performs some sort of functionality based on keys PRESSED by this console's active player
		 * @param	key		[0-4] representing R, U, L, D, Action
		 */
		public function onKey(key:int):void
		{
			// -- override this function
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.onKey(key);
				return;
			}
		}
		
		/**
		 * Performs some sort of functionality based on keys HELD by this console's active player
		 * @param	keys	boolean array with indexes [0-4] representing R, U, L, D, Action
		 */
		public function holdKey(keys:Array):void
		{
			// -- override this function
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.holdKey(keys);
				return;
			}
		}
		
		/**
		 * Show the "New!" indicator if the sector is appropriate
		 * @param	sector	the current sector
		 */
		public function showNew(sector:int):void
		{
			mc_object.mc_newIndicator.visible = sector == TUT_SECTOR;
		}
		
		/**
		 * Called when a player is attempting to sit at a console
		 * Called by ContainerGame
		 * @param	p		the Player attempting to sit at a console
		 */
		public function onAction(p:Player):void
		{
			if (!inUse && unlocked)
			{
				if (closestPlayer != null && closestPlayer == p && closestPlayer.activeConsole == null)
				{
					inUse = true;
					closestPlayer.sitAtConsole(this);
					mc_object.gotoAndStop(corrupted ? 4 : 3);	// change console graphic to 'on'
					mc_object.prompt.visible = false;			// hide the '!'
	
					// show the appropriate module UI
					setHUD(CONSOLE_NAME);
					updateHUD(true);
					if (cg.tails.tutorialMode)						
						cg.tails.showHalf(closestPlayer.playerID == 0, TUT_TITLE, TUT_MSG);
					mc_object.mc_newIndicator.visible = false;
					
					SoundManager.playSFX("sfx_UI_Beep_C", .5);
					
					if (corrupted)
						consoleFAILS.onAction(p);
				}
			}
		}

		/**
		 * Called when a player leaves this console
		 */
		public function onCancel():void
		{			
			if (inUse)
			{
				inUse = false;
				mc_object.gotoAndStop(2);									// change console graphic to 'shut off'
				mc_object.prompt.visible = true;							// show the '!'
				setHUD("none");
				cg.tails.hideHalf(closestPlayer.playerID == 0);
				updateHUD(false);
				
				if (corrupted)
					consoleFAILS.onCancel();
				
				closestPlayer = null;
				SoundManager.playSFX("sfx_UI_Beep_B", .5);
			}
		}
		
		/**
		 * Update the module HUD
		 * @param	label		Name of the module
		 */
		public function setHUD(label:String):void
		{			
			var cName:String = label;
			if (label != "none" && corrupted)
			{
				label = debuggable ? "fails" : "corrupt";
				cName = "ERROR";
			}
			else if (label != "none" && broken)
				label = "broken";
			
			hud_consoles[closestPlayer.playerID].gotoAndStop(label.toLowerCase());
			cg.hudTitles[closestPlayer.playerID].visible = label != "none";
			cg.hudTitles[closestPlayer.playerID].text = cName;
			if (cg.tails.tutorialMode && label != "none" && label != "broken")
			{
				hud_consoles[closestPlayer.playerID].mc_tutorial.visible = label != "none";
				if (label != "fails")
					hud_consoles[closestPlayer.playerID].mc_tutorial.gotoAndStop(label.toLowerCase());
				cg.hudTitles[closestPlayer.playerID].text = label;
			}
			
			if (label == "corrupt")
			{
				var ui:MovieClip = getHUD();
				ui.msg_loading.visible = !beingUsed;
				ui.msg_already.visible = beingUsed;
			}
			
			//trace("[ABST_Console] Setting HUD for", CONSOLE_NAME, label, closestPlayer.playerID);
		}
		
		/**
		 * Specific helper for when 1 player starts formatting, to say "ALREADY FIXING" on the other player
		 */
		public function setAlready(isFixing:Boolean):void
		{
			var ui:MovieClip = getHUD();
			if (ui == null) return;
			if (ui.msg_loading == null) return;
			ui.msg_loading.visible = !isFixing;
			ui.msg_already.visible = isFixing;
		}
		
		/**
		 * Potentially do a one-off bad thing if the console is disabled
		 */
		public function disableConsole():void
		{
			// -- override this function
		}
		
		/**
		 * Potentially do a one-off good thing if the console is enabled
		 */
		public function enableConsole():void
		{
			// -- override this function
		}
		
		/**
		 * Do something when the player first arrives, or leaves, this console
		 * @param	isActive		true if the player just got here; false if the player is leaving
		 */
		public function updateHUD(isActive:Boolean):void
		{
			// override this function
			if (corrupted)
				consoleFAILS.updateHUD(isActive);
		}
		
		// ------- FAILS METHODS BELOW ----------------------------------------------------------------
		/**
		 * Corrupt or uncorrupt the console
		 * @param	isCorrupt		true if the console should be corrupted
		 */
		public function setCorrupt(isCorrupt:Boolean):void
		{
			if (CONSOLE_NAME == "Omnitool") return;
			
			corrupted = isCorrupt;
			if (corrupted)
			{
				consoleFAILS = new ConsoleFAILS(cg, mc_object, players, this);
				if (inUse)
					closestPlayer.onCancel();
				disableConsole();
				numCorrupted++;
			}
			else
			{
				mc_object.mc_fixIndicator.visible = false;
				consoleFAILS.destroy();
				consoleFAILS = null;
				numCorrupted--;
			}
			mc_object.mc_corruption.visible = corrupted;
			mc_object.base.gotoAndPlay(corrupted ? "corrupt" : 1);
		}
		
		/**
		 * Make this console available to format (ignored if not corrupted)
		 * @param	isDebuggable		true if the console can be debugged
		 */
		public function setReadyToFormat(isDebuggable:Boolean):void
		{
			if (CONSOLE_NAME == "Omnitool") return;
			if (!corrupted) return;
			if (consoleFAILS != null && consoleFAILS.freeTimer != -1) return;
			debuggable = isDebuggable;
			if (inUse)
				setHUD(CONSOLE_NAME);
			mc_object.mc_fixIndicator.visible = debuggable;
		}
		// ------- FAILS METHODS ABOVE ----------------------------------------------------------------
				
		/**
		 * Gets the MovieClip representing the module
		 * Useful when updating UI graphics based on what's happening in the module
		 * @return		MovieClip (specifically, SWC_GUI.Module.mod)
		 */
		public function getHUD():MovieClip
		{
			if (closestPlayer == null)
			{
				trace("[ABST_Console] WARNING: getHUD called without an active player!", CONSOLE_NAME);
				return null;
			}
			else if (CONSOLE_NAME == "None")
			{
				trace("[ABST_Console] WARNING: CONSOLE_NAME is not set!");
			}
			return hud_consoles[closestPlayer.playerID].mod;
		}
	}
}