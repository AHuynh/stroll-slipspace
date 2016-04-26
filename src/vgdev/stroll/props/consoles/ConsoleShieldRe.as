package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	
	/**
	 * Module that can reboot the shields
	 * Shields cannot charge if this module is destroyed/disabled (HP is 0)
	 * @author Alexander Huynh
	 */
	public class ConsoleShieldRe extends ABST_Console 
	{
		/// 2D array of shield SWCs
		private var shields:Array;
		/// 1D array of shield SWCs
		private var shieldsList:Array;
		
		private var startMC:MovieClip;		// pointer to the single far-left 'starting' cel
		private var endMC:MovieClip;		// pointer to the single far-right 'ending' cel
		
		private var marker:MovieClip;		// current cel position indicator
		private var markerPos:Point;
		
		private var startLoc:int;			// [0-2] corresponding to row location of start
		private var endLoc:int;				// [0-2] corresponding to row location of end
		
		private var puzzleCooldown:int = 0;					// if non-zero, puzzle is on cooldown
		private var COOLDOWN:int = System.SECOND * 8;		// amount to set the cooldown at
		
		private var puzzleActive:Boolean = false;
		private var shieldCharge:Number = 1;
		private var SHIELD_DELTA:Number = -.0035;	// amount to reduce shield charge per frame
		private var SHIELD_MIN:Number = 0.2;		// minimum amount of shieldCharge
		
		private var textCooldown:int = 0;
		private var complain:int = 0;
		
		public var puzzleSolution:Array;			// solution for WINGMAN
			
		public function ConsoleShieldRe(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean=false) 
		{
			super(_cg, _mc_object, _players, locked);
			CONSOLE_NAME = "Shield Re";
			TUT_SECTOR = 0;

			TUT_TITLE = "Shield Reboot Module";
			TUT_MSG = "Complete the maze to reboot the ship's shields. The faster you are, the more SP will be restored!\n\n" +
					  "Find a path from left to right.";
					  
			// custom stats
			if (cg.shipName == "Kingfisher")
			{
				COOLDOWN = System.SECOND * 5;
				SHIELD_DELTA = -.0045;
				SHIELD_MIN = 0.1;
			}
			
			// create shield cel grid
			shields = [];
			shieldsList = [];
			var cel:MovieClip;
			var ANCHOR:Point = new Point(-70, -17);
			for (var r:int = 0; r < 3; r++)
			{
				var subArr:Array = [];
				for (var c:int = 0; c < 6; c++)
				{
					cel = new SWC_ShieldObj();
					cel.gotoAndStop("plain");
					cel.x = ANCHOR.x + c * 18;
					cel.y = ANCHOR.y + r * 18;
					
					subArr.push(cel);
					shieldsList.push(cel);
				}
				shields.push(subArr);
			}
			
			startMC = new SWC_ShieldObj();
			startMC.x = -88;
			startMC.gotoAndStop("end");
			
			endMC = new SWC_ShieldObj();
			endMC.x = 38;
			endMC.gotoAndStop("end");
			endMC.scaleX = -1;
			
			marker = new SWC_ShieldObj();
			marker.gotoAndStop("marker");
			
			shieldsList.push(startMC);
			shieldsList.push(endMC);
			shieldsList.push(marker);
			
			setAllVisible(false);
		}
		
		/**
		 * Set the visibility of all shield cels
		 * @param	isVis		true if visible
		 */
		private function setAllVisible(isVis:Boolean):void
		{
			for each (var mc:MovieClip in shieldsList)
				mc.visible = isVis;
		}
		
		public function onCooldown():Boolean
		{
			return puzzleCooldown >= 60;
		}
		
		public function isPuzzleActive():Boolean
		{
			return puzzleActive;
		}
		
		override public function step():Boolean 
		{
			if (corrupted)		// relinquish control if corrupted
				return consoleFAILS.step();
			
			// replace overridden text with standard message if appropriate
			if (textCooldown > 0)
				if (--textCooldown == 0)
					setRechargeText(true, puzzleCooldown == 0 ? "Ready" : "Recharging");
			
			// update flashing text
			var ui:MovieClip;
			if (closestPlayer != null)
				ui = getHUD();
			
			if (complain > 0)
			{
				complain--;
				if (ui != null)
					ui.tf_cooldown.visible = int(complain / 5) % 2 == 0;
			}
			
			// update cooldown on using the module
			if (puzzleCooldown > 0)
			{
				if (--puzzleCooldown == 0)
					setRechargeText(true, "Ready");
				if (ui != null)
				{
					try {
						ui.tf_charge.text = int((puzzleCooldown / System.SECOND)).toString() + "." + int(((puzzleCooldown % 30) / 30) * 10).toString();
						ui.mc_marker.x = 48 + (puzzleCooldown / COOLDOWN) * 46;
						ui.mc_recharge.visible = puzzleCooldown != 0;
					} catch (e:Error) { };
				}
				return false;
			}
			
			// update the puzzle (reduce shields awarded)
			if (puzzleActive)
			{
				shieldCharge = System.changeWithLimit(shieldCharge, SHIELD_DELTA, SHIELD_MIN);
				if (ui != null)
				{
					ui.tf_charge.text = int(100 * shieldCharge).toString() + "%";
					ui.mc_marker.x = 48 + shieldCharge * 46;
					ui.mc_limit.visible = shieldCharge == SHIELD_MIN;
				}
			}
			
			return false;
		}
		
		override public function onKey(key:int):void 
		{
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.onKey(key);
				return;
			}
			
			// flash text if puzzle unable to start
			if (puzzleCooldown > 0)
			{
				if (key == 4)
					complain = 30;
				return;
			}
			
			// activate puzzle
			if (key == 4 && !puzzleActive)
			{
				complain = 0;
				puzzleActive = true;
				shieldCharge = 1;
				generatePuzzle();
				setRechargeText(false);
				return;
			}
			
			// move cursor around puzzle
			if (puzzleActive)
			{
				if (moveMarker(key))		// if succeeeded
				{
					if (cg.ship.getShieldPercent() == 1)
					{
						stopPuzzle();
						setRechargeText(true, "SP already 100");
						getHUD().tf_charge.text = "0.0";
						getHUD().mc_marker.x = 48;
						complain = 45;
						puzzleCooldown = 0;
					}
					else
					{
						cg.ship.rebootShield(shieldCharge);
						getHUD().mc_recharge.visible = true;
						setRechargeText(true, "Recovered " + int(100 * shieldCharge).toString() + "%");
						stopPuzzle();
					}
					textCooldown = 75;
				}
			}
		}
		
		/**
		 * Stop the puzzle, reset shield charge, and optionally set puzzle cooldown
		 * @param	fullPenalty		true for COOLDOWN; false for 25% of COOLDOWN
		 */
		private function stopPuzzle(fullPenalty:Boolean = true):void
		{
			puzzleActive = false;
			shieldCharge = 0;
			puzzleCooldown = int(COOLDOWN * (fullPenalty ? 1 : .25));
			setAllVisible(false);
		}
		
		/**
		 * Set the information text
		 * @param	vis		if the text should be visible
		 * @param	str		message to display
		 */
		private function setRechargeText(vis:Boolean, str:String = ""):void
		{
			if (closestPlayer == null) return;
			var ui:MovieClip = getHUD();
			if (ui == null) return;
			ui.mc_limit.visible = false;
			ui.tf_cooldown.visible = vis;
			if (textCooldown == 0)
				ui.tf_cooldown.text = str;
		}
		
		/**
		 * Attempt to move the puzzleMarker in the given direction
		 * @param	dir		[0-3] corresponding to R U L D
		 * @return			true if puzzle is solved
		 */
		private function moveMarker(dir:int):Boolean
		{
			if (dir == 4) return false;		// ACCEPT does nothing
			
			var currCel:MovieClip;
			if (markerPos.x == -1)
				currCel = startMC;
			else
				currCel = shields[markerPos.y][markerPos.x];
				
			// can't move out of this cel in this direction
			if (!getOpenEnds(currCel.currentFrame, currCel.rotation)[dir])
			{
				//trace("[ShieldRes]\tCouldn't move out of the current cel", markerPos, dir, getOpenEnds(currCel.currentFrame, currCel.rotation));
				return false;
			}
			
			// find the next position and cel
			var succeeded:Boolean = false;
			var nextCel:MovieClip;
			var nextPos:Point;
			switch (dir)
			{
				case 0:		// right
					if (markerPos.x == 5)				// last col
					{
						if (markerPos.y == endLoc)		// last col and correct row
						{
							nextCel = endMC;
							nextPos = new Point(6, markerPos.y);
							succeeded = true;			// reached the end
						}
						else
							return false;
					}
					else
					{
						nextCel = shields[markerPos.y][markerPos.x + 1];
						nextPos = new Point(markerPos.x + 1, markerPos.y);
					}
				break;
				case 1:		// up
					if (markerPos.y == 0)
						return false;
					else
						nextCel = shields[markerPos.y - 1][markerPos.x];
						nextPos = new Point(markerPos.x, markerPos.y - 1);
				break;
				case 2:		// left
					if (markerPos.x == 0)					// first col
					{
						if (markerPos.y == startLoc)		// first col and correct row
						{
							nextCel = startMC;
							nextPos = new Point(-1, markerPos.y);
						}
						else
							return false;
					}
					else
					{
						nextCel = shields[markerPos.y][markerPos.x - 1];
						nextPos = new Point(markerPos.x - 1, markerPos.y);
					}
				break;
				case 3:		// down
					if (markerPos.y == 2)
						return false;
					else
						nextCel = shields[markerPos.y + 1][markerPos.x];
						nextPos = new Point(markerPos.x, markerPos.y + 1);
				break;
			}
			
			// can't enter next cel in this direction
			if (nextCel == null || !getOpenEnds(nextCel.currentFrame, nextCel.rotation)[int((dir + 2) % 4)])
			{
				//trace("[ShieldRes]\tCouldn't move into the next cel", nextPos, int((dir + 2) % 4), getOpenEnds(nextCel.currentFrame, nextCel.rotation));
				return false;
			}
			
			markerPos = nextPos;
			marker.x = nextCel.x;
			marker.y = nextCel.y;
			
			return succeeded;
		}
		
		/**
		 * Create a new shield maze puzzle
		 */
		private function generatePuzzle():void
		{
			textCooldown = 0;
			complain = 0;
			
			puzzleSolution = [];
			
			// shuffle non-end tiles
			var rand:Number;
			for (var i:int = 0; i < shieldsList.length - 3; i++)
			{
				// pick a random tile with probabilities
				rand = Math.random();
				if (rand > .9)
					shieldsList[i].gotoAndStop(4);		// 10% for +
				else if (rand > .65)
					shieldsList[i].gotoAndStop(3);		// 25% for T
				else if (rand > .35)
					shieldsList[i].gotoAndStop(5);		// 30% for L
				else
					shieldsList[i].gotoAndStop(6);		// 35% for -
				shieldsList[i].rotation = 90 * System.getRandInt(0, 3);
			}
			
			// pick random starting row
			startLoc = System.getRandInt(0, 2);
			startMC.y = -17 + 18 * startLoc;
			
			// place the current position marker at the start
			marker.x = startMC.x;
			marker.y = startMC.y;
			markerPos = new Point( -1, startLoc);
			
			var currPos:Point = new Point( -1, startLoc);
			var dir:int = 0;		// -1 UP; 0 RIGHT; 1 DOWN
			
			// generate a path by going up, right, or down and never going the same way you came from
			while (currPos.x < 6)
			{
				puzzleSolution.push(dir);
				
				var enterDir:int;
				switch (dir)
				{
					case -1:
						currPos.y -= 1;
						enterDir = 3;
					break;
					case 0:	
						currPos.x += 1;
						enterDir = 2;
					break;
					case 1:	
						currPos.y += 1;
						enterDir = 1;
					break;
				}
				
				var exitDir:int;
				dir = pickDir(dir, currPos.y);
				switch (dir)
				{
					case -1:
						exitDir = 1;
					break;
					case 0:	
						exitDir = 0;
					break;
					case 1:	
						exitDir = 3;
					break;
				}
				
				// update the graphics on the tile (unless it's the end tile)
				if (currPos.x != 6)
				{
					var tileSettings:Array = setTile(enterDir, exitDir);
					shields[currPos.y][currPos.x].gotoAndStop(tileSettings[0]);
					shields[currPos.y][currPos.x].rotation = tileSettings[1];
				}
			} 
			
			// place the end tile at the current row
			endLoc = currPos.y;
			endMC.y = -17 + 18 * endLoc;
			
			setAllVisible(true);
		}
		
		/**
		 * Choose the next direction to move the maze solution towards
		 * @param	prevDir		Direction we entered from
		 * @param	yLoc		Current row position
		 * @return				Direction to travel in next, -1 0 or 1 for U R D
		 */
		private function pickDir(prevDir:int, yLoc:int):int
		{
			var nextDir:int;
			do
			{
				nextDir = System.getRandInt( -1, 1);
			} while ((nextDir == -1 && (yLoc == 0 || prevDir == 1)) ||		// don't go the way you came or go out of the grid
					 (nextDir == 1 && (yLoc == 2 || prevDir == -1)));
			return nextDir;
		}
		
		/**
		 * Randomly pick a tile and rotation such that we can enter from prevDir and leave towards nextDir
		 * @param	prevDir		Direction entering from [R U L D]
		 * @param	nextDir		Direction leaving towards [R U L D]
		 * @return				Array of [tileFrame, tileRot]
		 */
		private function setTile(prevDir:int, nextDir:int):Array
		{
			var frame:int;
			var rot:int;
			var validDirs:Array;
			do
			{
				frame = System.getRandInt(3, 6);
				rot = 90 * System.getRandInt(0, 3);
				validDirs = getOpenEnds(frame, rot);
			} while (!validDirs[prevDir] || !validDirs[nextDir] || (frame == 4 && Math.random() < .75));
			// retry if invalid configuration, or 75% chance if a + was chosen
			
			return [frame, rot];
		}
		
		// add the maze to this module
		override public function onAction(p:Player):void 
		{
			if (inUse)
				return;
			super.onAction(p);
			if (corrupted) return;
			if (closestPlayer == null) return;
			var ui:MovieClip = getHUD();
			if (ui == null) return;
			for each (var mc:MovieClip in shieldsList)
				ui.addChild(mc);
			try {
				ui.mc_limit.visible = false;
				ui.mc_recharge.visible = puzzleCooldown != 0;
			setAllVisible(false);
			} catch (e:Error) {}
			setRechargeText(true, puzzleCooldown == 0 ? "Ready" : "Recharging");
		}
		
		// remove the maze from this module
		override public function onCancel():void 
		{
			puzzleSolution = null;
			
			if (corrupted)		// relinquish control if corrupted
				consoleFAILS.onCancel();
			
			if (!inUse) return;
			var ui:MovieClip = getHUD();
			for each (var mc:MovieClip in shieldsList)
				if (ui.contains(mc))
					ui.removeChild(mc);
			setAllVisible(false);
			if (puzzleActive)
				stopPuzzle(false);
			super.onCancel();
		}
		
		override public function disableConsole():void 
		{
			cg.ship.setShieldsEnabled(false);
		}
		
		override public function enableConsole():void 
		{
			cg.ship.setShieldsEnabled(true);
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			var isZero:Boolean = super.changeHP(amt);
			cg.ship.setShieldsEnabled(!corrupted && hp != 0);
			return isZero;
		}
		
		/*	Puzzle Tile reference
		 * 	3: T
		 * 		  0: R U L
		 * 		 90: R U   D
		 * 		180: R   L D
		 * 		270:   U L D
		 *  7: END
		 * 	4: +
		 * 		 ANY: R U L D
		 * 	5: L
		 * 		  0: R U  
		 * 		 90: R     D
		 * 		180:     L D
		 * 		270:   U L  
		 * 	6: -
		 * 		  0: R   L
		 * 		 90:   U   D
		 * 		180: R   L  
		 * 		270:   U   D
		 */
		/**
		 * Given a Shield tile's parameters, return array of open ends
		 * @param	frame	The shield's frame
		 * @param	rot		The shield's rotation
		 * @return			Array of booleans, true if open: [R U L D]
		 */
		private function getOpenEnds(frame:int, rot:int):Array
		{
			switch (frame)
			{
				case 3:
					switch (rot)
					{
						case 0:		return [true, true, true, false];
						case 90:	return [true, true, false, true];
						case 180:	return [true, false, true, true];
						case -90:	return [false, true, true, true];
					}
				break;
				case 4:
				case 7:
					return [true, true, true, true];
				break;
				case 5:
					switch (rot)
					{
						case 0:		return [true, true, false, false];
						case 90:	return [true, false, false, true];
						case 180:	return [false, false, true, true];
						case -90:	return [false, true, true, false];
					}
				break;
				case 6:
					switch (rot)
					{
						case 0:		return [true, false, true, false];
						case 90:	return [false, true, false, true];
						case 180:	return [true, false, true, false];
						case -90:	return [false, true, false, true];
					}
				break;
				default:
					//trace("[ShieldRes] WARNING: Unknown tile", frame, rot);
					return [false, false, false, false];
			}
			//trace("[ShieldRes] WARNING: Something went wrong", frame, rot);
			return [false, false, false, false];
		}
	}
}