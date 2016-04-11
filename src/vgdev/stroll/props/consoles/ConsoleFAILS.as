package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	
	/**
	 * Collect all of the orbs
	 * @author Alexander Huynh
	 */
	public class ConsoleFAILS extends ABST_Console 
	{
		public static var puzzleActive:Boolean = false;
		private var localPuzzleActive:Boolean = false
		
		private var originalConsole:ABST_Console;
		
		public static var difficulty:int = 0;
		private const MAX_DIFFICULTY:int = 6;
		
		private var delta:Point = new Point();		// deltas of the marker
		private const MAX_SPD:Number = 2;
		private const ROT_SPEED:Number = 8;			// degrees per frame to rotate at
		private const ACCEL:Number = .08;			// rate to change speed
		
		private var targets:Array;
		private var targetDeltas:Array;
		private var tgtTotal:int = 1;
		
		private const ARENA_HEIGHT:Number = 48;
		private const ARENA_WIDTH:Number = 136;
		
		private const COLLECT_RANGE:Number = 6;
		
		public var freeTimer:int = -1;
		
		public function ConsoleFAILS(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, _originalConsole:ABST_Console) 
		{
			super(_cg, _mc_object, _players, false);
			CONSOLE_NAME = "fails";
			originalConsole = _originalConsole;
		}
		
		override public function onKey(key:int):void 
		{
			if (!puzzleActive && freeTimer == -1 && originalConsole.debuggable)
			{
				if (key == 4)		// start debugging this
				{
					// turn off ability to debug all other consoles
					for each (var c:ABST_Console in cg.consoles)
					{
						if (c == originalConsole) continue;
						c.setReadyToFormat(false);
						if (c.closestPlayer != null)
							c.setAlready(true);
					}
					startPuzzle();
				}
			}
		}
		
		private function startPuzzle():void
		{
			beingUsed = true;
			puzzleActive = true;
			localPuzzleActive = true;
			targets = [];
			targetDeltas = [];
			// create targets
			tgtTotal = 3 + int(difficulty / 2);
			for (var i:int = 0; i < tgtTotal; i++)
			{
				targets.push(new Point(System.getRandNum( -ARENA_WIDTH, ARENA_WIDTH) * .5,
									   System.getRandNum( -ARENA_HEIGHT, ARENA_HEIGHT) * .5));
				targetDeltas.push(new Point(System.getRandNum(0, Math.max(0, difficulty - 2) * .5) * (Math.random() > .5 ? 1 : -1),
											System.getRandNum(0, Math.max(0, difficulty - 2) * .5) * (Math.random() > .5 ? 1 : -1)));
			}
			
			closestPlayer = originalConsole.closestPlayer;
			var ui:MovieClip = getHUD();
			ui.mc_container.mc_marker.visible = true;
			ui.mc_container.mc_marker.x = 0;
			ui.mc_container.mc_marker.y = 0;
			ui.mc_container.mc_marker.rotation = 0;
			delta = new Point();
			
			ui.tf_cooldown.visible = false;
		}
		
		override public function step():Boolean 
		{
			var ui:MovieClip;
			
			if (freeTimer != -1)
			{
				freeTimer--;
				if (freeTimer == 0)
				{
					originalConsole.enableConsole();		// trigger the beneficial effects on some consoles for being alive
					if (originalConsole.closestPlayer != null)
						originalConsole.closestPlayer.onCancel();
					originalConsole.setCorrupt(false);
				}
				else if (freeTimer == 15)
				{
					ui = getHUD();
					if (ui != null && MovieClip(ui.parent).currentFrameLabel == "fails")
						ui.tf_cooldown.text = "Rebooting\nnow...";
				}
				return false;
			}
			
			if (!originalConsole.inUse || !localPuzzleActive) return false;
			
			closestPlayer = originalConsole.closestPlayer;
			ui = getHUD();
			if (ui == null || MovieClip(ui.parent).currentFrameLabel != "fails")
				return false;
			
			var marker:MovieClip = ui.mc_container.mc_marker;
			
			marker.x += delta.x;
			marker.y += delta.y;
			
			marker.x = System.wrap(marker.x, .5 * ARENA_WIDTH);
			marker.y = System.wrap(marker.y, .5 * ARENA_HEIGHT);
			
			ui.mc_container.graphics.clear();
			ui.mc_container.graphics.lineStyle(1, System.COL_WHITE);
			
			var len:int = targets.length;
			ui.tf_data.text = (tgtTotal - len).toString() + "/" + tgtTotal.toString();
			
			var tgt:Point;
			for (var i:int = len - 1; i >= 0; i--)
			{
				tgt = targets[i];
				// chance to reset existing targets
				if (difficulty >= 4 && Math.random() > .99)
				{
					tgt.x = System.getRandNum( -ARENA_WIDTH, ARENA_WIDTH) * .5;
					tgt.y = System.getRandNum( -ARENA_HEIGHT, ARENA_HEIGHT) * .5;
					targetDeltas[i].x = System.getRandNum(0, Math.max(0, difficulty - 2) * .5) * (Math.random() > .5 ? 1 : -1);
					targetDeltas[i].y = System.getRandNum(0, Math.max(0, difficulty - 2) * .5) * (Math.random() > .5 ? 1 : -1);
				}
				// update position with wrapping
				else
				{
					tgt.x = System.wrap(tgt.x + targetDeltas[i].x, .5 * ARENA_WIDTH);
					tgt.y = System.wrap(tgt.y + targetDeltas[i].y, .5 * ARENA_HEIGHT);
				}
				
				// orb collected
				if (System.getDistance(marker.x, marker.y, tgt.x, tgt.y) < COLLECT_RANGE)
				{
					targets.splice(i, 1);
					targetDeltas.splice(i, 1);
				}
				else
				{
					ui.mc_container.graphics.drawCircle(tgt.x, tgt.y, 2);
				}
			}
			
			// all orbs completed
			if (targets.length == 0)
			{
				puzzleActive = false;
				beingUsed = false;
				marker.visible = false;
				ui.tf_cooldown.visible = true;
				ui.tf_cooldown.text = "System\nformatted!";
				ui.tf_data.text = "OK";
				ui.mc_marker.x = 94;
				freeTimer = 60;
				difficulty = System.changeWithLimit(difficulty, 1, 0, MAX_DIFFICULTY);
				for each (var c:ABST_Console in cg.consoles)
					if (c.closestPlayer != null && c != originalConsole)
						c.setAlready(false);
			}
			else
				ui.mc_marker.x = 48 + 46 * ((tgtTotal - len) / tgtTotal);
			
			return false;
		}

		override public function holdKey(keys:Array):void 
		{
			if (!originalConsole.inUse || !localPuzzleActive) return;
			
			closestPlayer = originalConsole.closestPlayer;
			var ui:MovieClip = getHUD();
			if (ui == null || MovieClip(ui.parent).currentFrameLabel != "fails") return;
			
			if (keys[0])
				ui.mc_container.mc_marker.rotation += ROT_SPEED;
			if (keys[1])
			{
				delta.x = Math.min(delta.x + System.forward(ACCEL, ui.mc_container.mc_marker.rotation, true), MAX_SPD);
				delta.x = Math.max(delta.x + System.forward(ACCEL, ui.mc_container.mc_marker.rotation, true), -MAX_SPD);
				delta.y = Math.min(delta.y + System.forward(ACCEL, ui.mc_container.mc_marker.rotation, false), MAX_SPD);
				delta.y = Math.max(delta.y + System.forward(ACCEL, ui.mc_container.mc_marker.rotation, false), -MAX_SPD);
			}
			if (keys[2])
				ui.mc_container.mc_marker.rotation -= ROT_SPEED;
		}
		
		override public function onAction(p:Player):void 
		{
			// do not call originalConsole.onAction(), as originalConsole continues after calling this onAction()
			if (!originalConsole.debuggable) return;
			
			closestPlayer = originalConsole.closestPlayer;
			var ui:MovieClip = getHUD();
			if (ui == null || MovieClip(ui.parent).currentFrameLabel != "fails") return;
			
			ui.mc_container.mc_marker.visible = false;
			ui.mc_marker.x = 48;
			ui.tf_data.text = "RDY";
		}
		
		override public function onCancel():void 
		{
			// do not call originalConsole.onCancel(), as originalConsole continues after calling this onCancel()
			
			if (freeTimer != -1)
				return;
			
			if (localPuzzleActive)
			{
				puzzleActive = false;
				beingUsed = false;
				for each (var c:ABST_Console in cg.consoles)		// allow any corrupted console to be tried again
					c.setReadyToFormat(true);
			}
			localPuzzleActive = false;
			targets = [];
			targetDeltas = [];
		}
		
		override public function destroy():void 
		{
			originalConsole = null;
			mc_object = null;
			cg = null;
			closestPlayer = null;
			inUse = false;
			hud_consoles = null;
			players = null;
			completed = true;
		}
	}
}