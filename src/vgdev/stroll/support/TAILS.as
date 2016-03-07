package vgdev.stroll.support 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	/**
	 * Helper class for handling the TAILS window
	 * @author Alexander Huynh
	 */
	public class TAILS 
	{
		private var cg:ContainerGame;
		private var tails:MovieClip;
		
		private var playerReady:Array = [false, false];
		
		public function TAILS(_cg:ContainerGame, _tails:MovieClip) 
		{
			cg = _cg;
			tails = _tails;
		}
		
		public function isActive():Boolean
		{
			return tails.visible;
		}
		
		/**
		 * Show TAILS and populate its contents
		 * @param	text			String to show the players
		 */
		public function show(text:String):void
		{
			tails.visible = true;
			tails.tf_message.text = text;
			
			playerReady = [false, false];
			tails.mc_ready1.gotoAndStop(1);		// show X's
			tails.mc_ready2.gotoAndStop(1);
			
			// TODO dynamically
			if (Math.random() > .5)
				tails.avatar.talkForLoops(6);
			else
				tails.avatar.gotoAndPlay("idleSide");
		}
		
		/**
		 * Call when a player has readied up. Hides TAILS and returns true if both players are ready.
		 * @param	playerID		The ID of the player to ready
		 * @return					true if both players have indicated they are ready
		 */
		public function acknowledge(playerID:int):Boolean
		{
			playerReady[playerID] = true;
			
			if (playerID == 0)
				tails.mc_ready1.gotoAndStop(2);
			else if (playerID == 1)
				tails.mc_ready2.gotoAndStop(2);
			
			if (playerReady[0] && playerReady[1])
			{
				tails.visible = false;
				return true;
			}
			return false;
		}
	}
}