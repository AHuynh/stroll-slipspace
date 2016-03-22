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
		private var players:Array;
		public const RANGE:int = 20;		// maximum range in px from which a player can activate this console
		
		/// Used as a label in the HUD object
		protected var CONSOLE_NAME:String = "None";
		
		/// The two HUD objects for the consoles, an Array of MovieClips
		protected var hud_consoles:Array;
		
		/// The if a player is currently using this console
		public var inUse:Boolean = false;	
		
		/// The active player if this console is inUse; otherwise the nearest player
		public var closestPlayer:Player;
		
		/// The width of the HP bar
		private var BAR_WIDTH:Number;
		
		protected var TUT_SECTOR:int = 0;
		protected var TUT_TITLE:String = "Unknown Module";
		protected var TUT_MSG:String = "Hey! I can't find the description for this module...";
		
		protected var unlocked:Boolean = true;
		
		// use mc_object.parent class to access the ABST_Console class associated with a console MovieClip
		
		public function ABST_Console(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean = false)
		{
			super(_cg, _mc_object);
			hud_consoles = cg.hudConsoles;
			players = _players;
			
			unlocked = !locked;
			hp = hpMax = 1000;
			
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
					mc_object.base.gotoAndPlay(1);
				else
					mc_object.base.gotoAndStop("off");
			}
			else	// Omnitool
			{
				mc_object.visible = unlocked;
			}
		}
		
		override public function changeHP(amt:Number):Boolean
		{
			hp = System.changeWithLimit(hp, amt, 0, hpMax);		
			
			// disable console
			if (hp == 0)
			{
				onCancel();
				//setConsoleEnabled(false);		// TODO stop the beneficial effects of this console
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
		 * @param	p		if not null, p is the closest Player in range of this console
		 * @param	dist	how far away p is
		 */
		public function setProximity(p:Player, dist:Number):void
		{
			if (!unlocked) return;
			if (p != null)
			{
				if (closestPlayer == null || (p != closestPlayer && getDistance(p) < dist))
					closestPlayer = p;
			}
			else if (!inUse)
				closestPlayer = null;
			setPromptVisible(p != null);
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
		
		/**
		 * Performs some sort of functionality based on keys PRESSED by this console's active player
		 * @param	key		[0-4] representing R, U, L, D, Action
		 */
		public function onKey(key:int):void
		{
			// -- override this function
		}
		
		/**
		 * Performs some sort of functionality based on keys HELD by this console's active player
		 * @param	keys	boolean array with indexes [0-4] representing R, U, L, D, Action
		 */
		public function holdKey(keys:Array):void
		{
			// -- override this function
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
				if (closestPlayer != null && closestPlayer == p)
				{
					inUse = true;
					closestPlayer.sitAtConsole(this);
					mc_object.gotoAndStop(3);				// change console graphic to 'on'
					mc_object.prompt.visible = false;		// hide the '!'
	
					// show the appropriate module UI
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
					
					SoundManager.playSFX("sfx_UI_Beep_C", .5);
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
				hud_consoles[closestPlayer.playerID].gotoAndStop("none");	// reset the module UI
				cg.hudTitles[closestPlayer.playerID].visible = false;
				hud_consoles[closestPlayer.playerID].mc_tutorial.visible = false;
				cg.tails.hideHalf(closestPlayer.playerID == 0);
				updateHUD(false);
				closestPlayer = null;
				
				SoundManager.playSFX("sfx_UI_Beep_B", .5);
			}
		}
		
		/**
		 * Do something when the player first arrives, or leaves, this console
		 * @param	isActive		true if the player just got here; false if the player is leaving
		 */
		protected function updateHUD(isActive:Boolean):void
		{
			// override this function
		}
				
		/**
		 * Gets the MovieClip representing the module
		 * Useful when updating UI graphics based on what's happening in the module
		 * @return		MovieClip (specifically, SWC_GUI.Module.mod)
		 */
		protected function getHUD():MovieClip
		{
			if (closestPlayer == null)
			{
				trace("[ABST_Console] WARNING: getHUD called without an active player!");
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