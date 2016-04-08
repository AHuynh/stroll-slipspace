package vgdev.stroll.support 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	/**
	 * Helper class for handling the TAILS window
	 * @author Alexander Huynh
	 */
	public class TAILS extends ABST_Support
	{
		private var tails:MovieClip;
		
		private var playerReady:Array = [false, false];
		public var showDuration:int = 0;
		
		private var tailsLarge:Boolean = false;
		
		public var tutorialMode:Boolean = true;
		public var showNew:Boolean = false;
		
		private var important:Boolean = false;
		
		public function TAILS(_cg:ContainerGame, _tails:MovieClip) 
		{
			super(_cg);
			tails = _tails;
			
			cg.gui.mc_left.visible = false;
			cg.gui.mc_right.visible = false;
			
			cg.gui.mc_left.mc_check.x = -83;
			cg.gui.mc_right.mc_check.x = 83;
		}
		
		public function isActive():Boolean
		{
			return tailsLarge && tails.visible;
		}
		
		override public function step():void
		{
			if (showDuration > 0 && --showDuration == 1)
			{
				tails.visible = false;
				tails.gotoAndStop(2);
				cg.isTailsPaused = false;
				important = false;
				if (showNew)
				{
					showNew = false;
					for each (var console:ABST_Console in cg.consoles)
						console.showNew(cg.level.sectorIndex);
				}
			}			
		}
		
		/**
		 * Show TAILS and populate its contents
		 * @param	text			String to show the players
		 * @param	showForFrames	int, how many frames to show the small popup, or 0 to use the large popup
		 * @param	emotion			String, frame label to use for TAILS' emotion
		 * @param	important		if true, don't allow future non-important messages to override this one
		 */
		public function show(text:String, showForFrames:int = 0, emotion:String = null, isImportant:Boolean = false):void
		{
			if (important && !isImportant) return;
			important = isImportant;
			
			showDuration = showForFrames;
			tails.gotoAndStop(showDuration == 0 ? 1 : 2);
			tails.visible = true;
			if (showDuration == 0)
			{
				hideHalf(true);	hideHalf(false);
			}
			tails.tf_message.text = text;
			
			tailsLarge = showDuration == 0;
			
			playerReady = [false, false];
			tails.mc_ready1.visible = tails.mc_ready2.visible = showDuration == 0;
			if (showDuration == 0)
			{
				tails.mc_ready1.gotoAndStop(1);		// show not ready
				tails.mc_ready2.gotoAndStop(1);
			}

			cg.isTailsPaused = showForFrames == 0;

			switch (emotion)
			{
				case null:
					if (Math.random() > .5)
						tails.avatar.talkForLoops(6, "talk");
					else
						tails.avatar.gotoAndPlay("idleSide");
					tails.base.gotoAndStop(1);
				break;
				case "FAILS_idle":
					if (Math.random() > .5)
						tails.avatar.gotoAndPlay("idleFails");
					else
						tails.avatar.gotoAndPlay("idleSideFails");
					tails.base.gotoAndStop(2);
				break;
				case "FAILS_talk":
					tails.avatar.talkForLoops(6, "talkFails");
					tails.base.gotoAndStop(2);
				break;
				case "FAILS_pissed":
					tails.avatar.talkForLoops(8, "talkPissed");
					tails.base.gotoAndStop(2);
				break;
				case "FAILS_incredulous":
					tails.avatar.talkForLoops(10, "talkIncredulous");
					tails.base.gotoAndStop(2);
				break;
				case "HEADS":
					tails.avatar.gotoAndPlay("idleHeads");
					tails.base.gotoAndStop(3);
				break;
			}
		}
		
		/**
		 * Show the half TAILS tutorial screen
		 * @param	isLeft			true to show P1's tutorial frame
		 * @param	title			String to place as the title
		 * @param	message			String to place as the message contents
		 */
		public function showHalf(isLeft:Boolean, title:String, message:String):void
		{
			tailsLarge = false;
			var mc:MovieClip = isLeft ? cg.gui.mc_left : cg.gui.mc_right;
			mc.visible = true;
			mc.tf_title.text = title;
			mc.tf_message.text = message;
		}
		
		/**
		 * Hide the half TAILS tutorial screen
		 * @param	isLeft			true to hide P1's tutorial frame
		 */
		public function hideHalf(isLeft:Boolean):void
		{
			isLeft ? cg.gui.mc_left.visible = false : cg.gui.mc_right.visible = false;
		}
		
		/**
		 * Call when a player has readied up. Hides TAILS and returns true if both players are ready.
		 * @param	playerID		The ID of the player to ready
		 * @return					true if both players have indicated they are ready
		 */
		public function acknowledge(playerID:int):Boolean
		{			
			if (showDuration > 0)
				return false;

			if (!playerReady[playerID])
			{
				if (playerID == 0)
					tails.mc_ready1.play();
				else if (playerID == 1)
					tails.mc_ready2.play();
			}
			playerReady[playerID] = true;
			
			if (playerReady[0] && playerReady[1])
			{
				showDuration = 30;
				SoundManager.playSFX("sfx_readybeep2G", .5);
				return true;
			}
			else
				SoundManager.playSFX("sfx_UI_Beep_Cs", .5);
			
			return false;
		}
		
		override public function destroy():void 
		{
			tails = null;
			super.destroy();
		}
	}
}