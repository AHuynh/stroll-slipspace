package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.Player;
	
	/**
	 * Abstract console class
	 * @author Alexander Huynh
	 */
	public class ABST_Console extends ABST_Object 
	{
		private var players:Array;
		public const RANGE:int = 20;		// maximum range in px from which a player can activate this console
		
		protected var CONSOLE_NAME:String = "none";
		
		/// the two HUD objects for the consoles
		protected var hud_consoles:Array;
		
		/// true if a player is currently using this console
		public var inUse:Boolean = false;	
		
		/// the active player if this console is inUse; otherwise the nearest player
		public var closestPlayer:Player;
		
		public function ABST_Console(_cg:ContainerGame, _mc_object:MovieClip, _players:Array)
		{
			super(_cg, _mc_object);
			hud_consoles = cg.hudConsoles;
			players = _players;
		}

		public function setProximity(p:Player, dist:Number):void
		{
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
		 * @param	keys	array with indexes [0-4] representing R, U, L, D, Action
		 */
		public function holdKey(keys:Array):void
		{
			// override this function
		}
		
		/**
		 * Called when a player is attempting to sit at a console
		 * @param	p		the Player attempting to sit at a console
		 */
		public function onAction(p:Player):void
		{
			if (!inUse)
			{
				if (closestPlayer != null && closestPlayer == p)
				{
					inUse = true;
					closestPlayer.sitAtConsole(this);
					mc_object.gotoAndStop(3);
					mc_object.prompt.visible = false;
	
					hud_consoles[closestPlayer.playerID].gotoAndStop(CONSOLE_NAME);
					updateHUD(true);
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
				mc_object.gotoAndStop(2);
				mc_object.prompt.visible = true;
				hud_consoles[closestPlayer.playerID].gotoAndStop("none");
				updateHUD(false);
				closestPlayer = null;
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
		 * @return		MovieClip (SWC_GUI.Module.mod)
		 */
		protected function getHUD():MovieClip
		{
			if (closestPlayer == null)
			{
				trace("[ABST_Console] WARNING: hud called without an active player!");
				return new MovieClip();
			}
			else if (CONSOLE_NAME == "none")
			{
				trace("[ABST_Console] WARNING: CONSOLE_NAME is not set!");
				//return new MovieClip();
			}
			return hud_consoles[closestPlayer.playerID].mod;
		}
	}
}