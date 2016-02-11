package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.Player;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ABST_Console extends ABST_Object 
	{
		private var players:Array;
		private const RANGE:int = 20;		// maximum range in px from which a player can activate this console
		
		/// true if a player is currently using this console
		public var inUse:Boolean = false;	
		
		/// the active player if this console is inUse; otherwise the nearest player
		public var closestPlayer:Player;
		
		public function ABST_Console(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object);
			players = _players;
		}
		
		override public function step():Boolean
		{
			if (!inUse)
			{
				closestPlayer = null;
				var closestDist:Number = 99999;
				var dist:Number;
				var player:Player;
				for (var i:int = 0; i < players.length; i++)
				{
					player = players[i];
					dist = System.getDistance(mc_object.x, mc_object.y, player.mc_object.x, player.mc_object.y - 15);
					if (dist < RANGE && dist < closestDist)
					{
						dist = closestDist;
						closestPlayer = player;
						mc_object.prompt.visible = true;
					}
				}
				
				if (closestPlayer == null)
				{
					mc_object.prompt.visible = false;
				}
			}

			return false;
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
				}
			}
		}

		public function onCancel():void
		{
			if (inUse)
			{
				inUse = false;
				closestPlayer = null;
				mc_object.gotoAndStop(2);
				mc_object.prompt.visible = true;
			}
		}
	}
}