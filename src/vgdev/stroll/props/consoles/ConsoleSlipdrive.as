package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Activates the slipdrive
	 * @author Alexander Huynh
	 */
	public class ConsoleSlipdrive extends ABST_Console 
	{
		private var isSpooling:Boolean = false;
		private var arrows:Array;
		
		private var arrowSpeed:Number = 4;
		private var arrowDifficulty:int = 3;
		private var arrowVarySpacing:Number = 20;
		
		private var currentArrow:int = 0;
		private var anyMiss:Boolean = false;
		
		private const arrowMap:Array = [0, -90, 180, 90];		// map key [0-3] to rotation
		
		private const ARROW_DIST:int = 16;						// max distance between arrow and target to count as a hit
		private const ARROW_TARGET:int = -45;
		
		private var missCounter:int = 0;
		private var complain:Boolean = false;
		
		public var forceOverride:Boolean = false;		// generic slipdrive override; if true, don't spool
		public var fakeJumpNext:Boolean = false;		// if true, next successful jump will be a 'fake jump'
		public var fakeJumpLbl:String = null;			// label to use for fake jump (i.e. to play the longer jump animation)
		
		public function ConsoleSlipdrive(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean = false) 
		{
			super(_cg, _mc_object, _players, locked);
			CONSOLE_NAME = "Slipdrive";
			TUT_SECTOR = 0;
			TUT_TITLE = "Slipdrive Module";
			TUT_MSG = "Once we're in range, use this module to jump to the next slipsector.\n\n" +
					  "Requires Navigation to be on-course. Enemies may jam the slipdrive.";
		}
		
		override public function step():Boolean 
		{
			if (corrupted)		// relinquish control if corrupted
				return consoleFAILS.step();
			
			if (inUse && !isSpooling)
				updateHUD(true);
			
			if (missCounter > 0)
			{
				if (--missCounter == 0)
					complain = false;
				if (complain && inUse)
					getHUD().tf_problem.visible = int(missCounter / 5) % 2 == 0;
			}
				
			updateArrows();
			
			if (!cg.ship.isHeadingGood()) {
				removeArrows();
			}
			return super.step();
		}
		
		override public function onKey(key:int):void
		{		
			if (broken) return;			
			
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.onKey(key);
				return;
			}
			
			// if the slipdrive isn't spooling, start spooling
			if (!isSpooling)
			{				
				if (key == 4)
				{
					if (cg.ship.isJumpReady() == "ready" && !forceOverride)
					{					
						isSpooling = true;
						initArrows();
					}
					else
					{
						complain = true;
						missCounter = 30;
					}
				}
			}
			// else if the slipdrive is spooling and a direction button was pressed and there are more arrows
			else if (isSpooling && key != 4 && arrows != null)
			{
				var mc:MovieClip = arrows[currentArrow];
				if (mc != null && Math.abs(mc.x - ARROW_TARGET) <= ARROW_DIST)
				{
					// if the correct button was pressed
					if (arrowMap[key] == mc.rotation)
					{
						mc.gotoAndStop(3);		// turn green
						if (currentArrow + 1 != arrows.length)
							SoundManager.playSFX("sfx_readybeep3E", .4);
					}
					// else the wrong button was pressed
					else
					{
						mc.gotoAndStop(2);		// turn red
						anyMiss = true;
					}
					// if that was the last arrow and all arrows were hit, jump
					if (++currentArrow == arrows.length && !anyMiss)
					{
						removeArrows();
						if (fakeJumpNext)
						{
							fakeJumpNext = false;
							cg.background.setRandomStyle(int(cg.level.sectorIndex / 5), System.getRandCol());
							cg.playJumpEffect(fakeJumpLbl);
						}
						else
						{
							cg.ship.jump();
							if (cg) updateHUD(true);
						}
					}
				}
			}
		}
		
		public function shouldPress():int
		{
			if (!isSpooling || arrows == null || currentArrow >= arrows.length) return -1;
			if (Math.abs(arrows[currentArrow].x - ARROW_TARGET) > ARROW_DIST) return -1;
			return int(arrows[currentArrow].rotation);
		}
		
		public function getArrows():Array
		{
			return arrows;
		}
		
		public function puzzleActive():Boolean
		{
			return isSpooling;
		}
		
		override public function updateHUD(isActive:Boolean):void 
		{
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.updateHUD(isActive);
				return;
			}
			
			if (isActive && missCounter == 0)
			{
				switch (cg.ship.isJumpReady())
				{
					case "repair":	setText("Repair Nav");		break;
					case "jammed":	setText("Enemy jamming");	break;
					case "heading":	setText("Center Nav");		break;
					case "range":	setText("Not in range");	break;
					case "error":	setText("Malfunction");		break;
					case "ready":	setText("Ready to spool");	break;
				}
				
				if (forceOverride)
					setText("Malfunction");
				
				var hud:MovieClip = getHUD();
				
				hud.mc_range.visible = cg.ship.isJumpReadySpecific("range");
				hud.mc_jam.visible = cg.ship.isJumpReadySpecific("jammed");
				hud.mc_center.visible = cg.ship.isJumpReadySpecific("heading");
				hud.mc_repair.visible = cg.ship.isJumpReadySpecific("repair");
				hud.mc_error.visible = forceOverride || cg.ship.isJumpReadySpecific("error");
				
				hud.mc_nav.y = cg.ship.shipHeading * 23 - 1;
			}
		}
		
		/**
		 * Set how many/fast/the spacing of the arrows
		 * @param	sector		difficulty, 0-12
		 */
		public function setArrowDifficulty(sector:int):void
		{
			// custom stats
			if (cg.shipName == "Kingfisher")
			{
				arrowDifficulty = 4 + int(sector / 3);
				arrowSpeed = 4 + sector * .2;
				arrowVarySpacing = 16 + int(sector * 1.2);
			}
			else
			{
				arrowDifficulty = 3 + int(sector / 3);
				arrowSpeed = 3.5 + sector * .2;
				arrowVarySpacing = 20 + int(sector * 1.2);
			}
		}
		
		/**
		 * Start spooling the slipdrive
		 * Arrows will spawn from the right and move left
		 */
		private function initArrows():void
		{
			removeArrows();
			var mc:MovieClip;
			var anchor:Number = 80;
			arrows = [];
			for (var i:int = 0; i < arrowDifficulty; i++)
			{
				mc = new SWC_SlipdriveArrow();
				mc.x = anchor;
				mc.rotation = 90 * System.getRandInt(0, 3);
				getHUD().mc_container.addChild(mc);
				arrows.push(mc);
				
				anchor += 40 + (arrowDifficulty * 2) + System.getRandNum(0, arrowVarySpacing);
			}
			setText(null);
			missCounter = 0;
			complain = false;
			currentArrow = 0;
			anyMiss = false;
			isSpooling = true;
		}
		
		/**
		 * Update the arrow targets by translating them and checking if they weren't pressed in time
		 */
		private function updateArrows():void
		{
			if (arrows == null)
				return;
			var mc:MovieClip;
			for (var i:int = 0; i < arrows.length; i++)
			{
				mc = arrows[i];
				mc.x -= arrowSpeed;
				
				// if the last arrow makes it past the left (it must be a miss)
				if (i == arrows.length - 1 && arrows[i].x < -85)
				{
					removeArrows();
					setText("Error; retry");
					missCounter = 60;
					return;
				}
				// if the current arrow isn't pressed in time
				else if (i == currentArrow && arrows[i].x < ARROW_TARGET - ARROW_DIST)
				{
					currentArrow++;
					mc.gotoAndStop(2);		// turn red
					anyMiss = true;
				}
			}
		}
		
		private function setText(str:String):void
		{
			if (closestPlayer == null || corrupted) return;
			
			var ui:MovieClip = getHUD();
			if (ui == null) return;
			
			if (str == null)
			{
				ui.tf_problem.visible = false;
				ui.mc_cover.visible = true;
			}
			else
			{
				ui.tf_problem.visible = true;
				ui.tf_problem.text = str;
				ui.mc_cover.visible = false;
			}
		}
		
		override public function onCancel():void 
		{
			if (corrupted)		// relinquish control if corrupted
				consoleFAILS.onCancel();

			removeArrows();
			missCounter = 0;
			setText("");
			super.onCancel();
		}
		
		/**
		 * Check if the console is being spooled
		 * @return		isSpooling
		 */
		public function getIfSpooling():Boolean
		{
			return isSpooling;
		}
		
		/**
		 * Stop the arrow target sequence
		 */
		private function removeArrows():void
		{
			if (arrows != null)
			{
				var mc:MovieClip;
				for (var i:int = 0; i < arrows.length; i++)
				{
					mc = arrows[i];
					if (getHUD().mc_container.contains(mc))
						getHUD().mc_container.removeChild(mc);
					mc = null;
				}
				arrows = null;
			}
			isSpooling = false;
		}
		
		override public function destroy():void 
		{
			removeArrows();
			super.destroy();
		}
	}
}