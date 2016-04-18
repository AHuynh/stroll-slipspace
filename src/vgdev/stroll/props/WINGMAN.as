package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.display.NativeMenuItem;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import vgdev.stroll.ABST_Container;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.*;
	import vgdev.stroll.props.enemies.*;
	import vgdev.stroll.support.graph.GraphNode;
	import vgdev.stroll.System;
	
	/**
	 * AI for playing as a Player
	 * @author Alexander Huynh
	 */
	public class WINGMAN extends Player 
	{
		public var tgtIndicator:MovieClip;
		private var enum:int = 0;
		
		private var state:int;
		private const STATE_IDLE:int = enum++;
		private const STATE_STUCK:int = enum++;
		private const STATE_DEAD:int = enum++;
		private const STATE_MOVE_FREE:int = enum++;
		private const STATE_MOVE_NETWORK:int = enum++;
		private const STATE_MOVE_FROM_NETWORK:int = enum++;
		private const STATE_REVIVE:int = enum++;
		private const STATE_HEAL:int = enum++;
		private const STATE_DOUSE:int = enum++;
		private const STATE_REBOOT:int = enum++;
		private const STATE_TURRET:int = enum++;
		private const STATE_SLIP:int = enum++;
		private const STATE_REPAIR:int = enum++;
		private const STATE_COLOR:int = enum++;
		private const STATE_NAVIGATION:int = enum++;
		private const STATE_FAILS:int = enum++;
		private const STATE_BOARDER:int = enum++;
		
		public var goal:int;
		private const GOAL_IDLE:int = enum++;
		private const GOAL_REVIVE:int = enum++;
		private const GOAL_DEAD:int = enum++;
		private const GOAL_HEAL:int = enum++;
		private const GOAL_DOUSE:int = enum++;
		private const GOAL_REBOOT:int = enum++;
		private const GOAL_TURRET:int = enum++;
		private const GOAL_SLIP:int = enum++;
		private const GOAL_REPAIR:int = enum++;
		private const GOAL_COLOR:int = enum++;
		private const GOAL_NAVIGATION:int = enum++;
		private const GOAL_FAILS:int = enum++;
		private const GOAL_BOARDER:int = enum++;
		
		private var otherPlayer:Player;
		
		private var pointOfInterest:Point;
		private var objectOfInterest:ABST_Object;
		private var enemyOfInterest:ABST_Enemy;
		private var nodeOfInterest:GraphNode;
		
		private var path:Array;
		
		private var range:Number = 5;				// current range
		private const RANGE:Number = 5;			// node clear range
		private const MOVE_RANGE:Number = 2;		// diff on movement
		private const BEELINE_RANGE:Number = 40;
		private const BOARDER_RANGE:Number = 10;
		private const GIMBAL_LENIENCY:int = 4;		// degrees of leniency
		
		private const NORMAL_SPEED:Number = 5;
		private const PRECISE_SPEED:Number = 2;
		
		private const HEAL_THRESHOLD:Number = .7;		// if other player's HP is below this threshold, heal
		private const HEADING_THRESHOLD:Number = 0.02;
		private const SP_THRESHOLD:Number = .4;			// if SP is below this threshold, reboot shields
		
		private var consoleMap:Object = { };
		private var keyMap:Object;
		private var acknowledgeTails:Boolean = false;
		private var setup:Boolean = true;
		
		private var chooseStateCooldown:int = 0;
		private const CHOOSE_CD:int = 20;
		
		private var prevPoint:Point;
		
		private var genericCounter:int = 0;
		private var turrRandCounter:int = 0;
		private var stuckCounter:int = 0;
		private var slipCounter:int = 0;
		private var shieldCounter:int = 0;
		private var failsCounter:int = 0;
		private var repairCounter:int = 0;
		private var movingPOIcounter:int = 0;			// if 0, update POI location, since object could be moving
		private const COUNTER_MAX:int = 15;
		private const TURRET_MAX:int = 75;
		private const SLIP_MAX:int = System.SECOND * 4;
		private const FAILS_MAX:int = System.SECOND * 9;
		private const SHIELD_MAX:int = System.SECOND * 5;
		
		private var turretRandom:Number;
		
		private var display:MovieClip;
		
		// -- ShieldRe --------------------------------------------------------
		private var mazeSolution:Array;
		private var mazeIndex:int;
		// -- ShieldRe --------------------------------------------------------
		// -- Slipdrive--------------------------------------------------------
		private var slipSolution:Array;
		private var slipIndex:int;
		// -- Slipdrive--------------------------------------------------------
		
		public function WINGMAN(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, _playerID:int, keyMap:Object, _display:MovieClip, _tgtIndicator:MovieClip) 
		{
			super(_cg, _mc_object, _hitMask, _playerID, keyMap);
			display = _display;
			tgtIndicator = _tgtIndicator;
			tgtIndicator.visible = true;
			tgtIndicator.gotoAndStop(playerID + 1);
			trace("[WINGMAN " + playerID + "] Waiting to setup...");
		}
		
		private function init():void
		{
			setup = false;
			otherPlayer = cg.players[1 - playerID];
		
			// set up consoleMap
			consoleMap["omnitool"] = [];
			consoleMap["turret"] = [];
			for each (var c:ABST_Console in cg.consoles)
			{
				if (c is Omnitool)
					consoleMap["omnitool"].push(c);
				else if (c is ConsoleTurret)
					consoleMap["turret"].push(c);
				else if (c is ConsoleShieldRe)
					consoleMap["shieldRe"] = c;
				else if (c is ConsoleNavigation)
					consoleMap["navigation"] = c;
				else if (c is ConsoleShields)
					consoleMap["shieldCol"] = c;
				else if (c is ConsoleSlipdrive)
					consoleMap["slipdrive"] = c;
				else if (c is ConsoleSensors)
					consoleMap["sensors"] = c;
			}
			keyMap = playerID == 0 ? System.keyMap0 : System.keyMap1;
			prevPoint = new Point(mc_object.x, mc_object.y);
			updateDisplay();
			
			trace("[WINGMAN " + playerID + "] Ready!");
		}
		
		override public function step():Boolean 
		{
			super.step();
			
			if (!cg || cg.isPaused)
			{
				releaseAllKeys();
				return false;
			}
			
			// acknowledge TAILS
			if (cg.tails.isActive())
			{
				if (!acknowledgeTails)			// do ready check one time
				{
					acknowledgeTails = true;
					cg.onAction(this);
					trace("[WINGMAN " + playerID + "] I hear you, " + cg.gameOverAnnouncer + "!");
				}
				if (!setup)
					return completed;
			}
			else
				acknowledgeTails = false;
			
			if (setup)
			{
				init();
				return false;
			}
				
			updateDisplay();
			
			// check if dead
			if (cg.ship.getHP() == 0 || getHP() == 0)
			{
				state = STATE_DEAD;
				goal = GOAL_DEAD;
				releaseAllKeys();
				return false;
			}
			
			// check if forced off a console
			if (cancelled)
			{
				cancelled = false;
				state = STATE_STUCK;
				goal = GOAL_IDLE;
				releaseAllKeys();
				chooseState(true);
			}
			
			// check if console was killed
			if (objectOfInterest && (objectOfInterest is ABST_Console) && objectOfInterest.getHP() == 0)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				releaseAllKeys();
				chooseState(true);
			}
			
			// update slipcounter
			if (cg.ship.isJumpReady() == "ready")
				slipCounter++;
			else
				slipCounter = 0;
				
			// update FAILS counter
			if (ABST_Console.numCorrupted != 0)
				failsCounter++;
			else
				failsCounter = 0;
				
			// check if stuck
			if (!rooted && state != STATE_IDLE && state != STATE_REVIVE && state != STATE_DOUSE
					&& state != STATE_HEAL && state != STATE_REPAIR && state != STATE_BOARDER)
			{
				if (mc_object.x == prevPoint.x && mc_object.y == prevPoint.y)
				{
					if (++stuckCounter == COUNTER_MAX)
					{
						state = STATE_STUCK;
						goal = GOAL_IDLE;
						trace("[WINGMAN " + playerID + "] Stuck! Trying to get unstuck!");
						trace("\tCurrent node:", (nodeOfInterest ? nodeOfInterest.mc_object.name : null));
						trace("\tCurrent path:", path);
						trace("\tCurrent OOI:", objectOfInterest);
						releaseAllKeys();
						chooseState(true);
					}
				}
				else
				{
					prevPoint = new Point(mc_object.x, mc_object.y);
					stuckCounter = 0;
				}
			}
			
			// update dynamic POI locations
			if (objectOfInterest is Player || objectOfInterest is ABST_Boarder || objectOfInterest is Omnitool)
			{
				if (objectOfInterest.mc_object && --movingPOIcounter <= 0)
				{
					movingPOIcounter = COUNTER_MAX * 3;
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				}
			}
			
			// recalculate nearest fire, account for incap
			if (goal == GOAL_DOUSE && --genericCounter <= 0)
			{
				genericCounter = COUNTER_MAX * 2;
				if (otherPlayer.getHP() == 0)
					chooseState(true);
				else
					handleStateDouse();
			}
			
			// make a beeline
			if (pointOfInterest != null && state == STATE_MOVE_NETWORK)
			{
				if (System.getDistance(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y) < BEELINE_RANGE &&
						extendedLOScheck(pointOfInterest))
				{
					state = STATE_MOVE_FROM_NETWORK;
					path = [];
					trace("[WINGMAN " + playerID + "] Making a beeline!");
				}
			}
			
			switch (state)
			{
				case STATE_IDLE:
					chooseState();
				break;
				case STATE_REVIVE:
					if (!omnitoolCheck()) break;
					if (otherPlayer.getHP() > 0)
						chooseState(true);
				break;
				case STATE_HEAL:
					if (!omnitoolCheck()) break;
					if (otherPlayer.getHP() / otherPlayer.getHPmax() > HEAL_THRESHOLD)
						chooseState(true);
					else if (!extendedLOScheck(pointOfInterest))
					{
						setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
						trace("[WINGMAN " + playerID + "] Trying to heal but lost LOS!");
					}
				break;
				case STATE_BOARDER:
					if (!objectOfInterest.isActive())
					{
						state = STATE_IDLE;
						goal = GOAL_IDLE;
						chooseState();
					}
					else if (System.getDistance(mc_object.x, mc_object.y, objectOfInterest.mc_object.x, objectOfInterest.mc_object.y) < BOARDER_RANGE)
					{
						(objectOfInterest as ABST_Boarder).changeHP( -9999);
						state = STATE_IDLE;
						goal = GOAL_IDLE;
						chooseState(true);
					}
					else if (!extendedLOScheck(pointOfInterest))
						setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				break;
				case STATE_DOUSE:	
					if (!omnitoolCheck()) break;			
					if (objectOfInterest == null || !objectOfInterest.isActive() ||
						System.getDistance(mc_object.x, mc_object.y, objectOfInterest.mc_object.x, objectOfInterest.mc_object.y) > range)
					{
						trace("[WINGMAN " + playerID + "] Fire doused.");
						handleStateDouse();
					}
					else if (!extendedLOScheck(pointOfInterest))
					{
						setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
						trace("[WINGMAN " + playerID + "] Trying to douse but lost LOS!");
					}
				break;
				case STATE_REPAIR:
					if (!omnitoolCheck()) break;
					if (objectOfInterest.getHP() == objectOfInterest.getHPmax())
					{
						trace("[WINGMAN " + playerID + "] Console repaired.");
						handleStateRepair();
					}
					else if (!extendedLOScheck(pointOfInterest))
						setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				break;
				case STATE_TURRET:
					handleStateTurret();
				break;
				case STATE_REBOOT:
					handleStateReboot();
				break;
				case STATE_COLOR:
					handleStateColor();
				break;
				case STATE_NAVIGATION:
					handleStateNavigation();
				break;
				case STATE_SLIP:
					handleStateSlipdrive();
				break;
				case STATE_FAILS:
					handleStateFails();
				break;
				case STATE_MOVE_NETWORK:
					if (nodeOfInterest == null)
					{
						trace("[WINGMAN " + playerID + "] Node of interest was null! Cancelling!");
						state = STATE_MOVE_FROM_NETWORK;
						return completed;
					}
					moveToPoint(new Point(nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y));
					// arrived at next node	
					if (System.getDistance(mc_object.x, mc_object.y, nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y) < RANGE)
					{
						nodeOfInterest = path.shift();
						if (nodeOfInterest == null)
						{
							trace("[WINGMAN " + playerID + "] Leaving path network.");
							state = STATE_MOVE_FROM_NETWORK;
							return completed;
						}
					}
				break;
				case STATE_MOVE_FROM_NETWORK:
					moveToPoint(pointOfInterest);
					// arrived at destination
					if (System.getDistance(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y) < range)
					{
						releaseAllKeys();
						onArrive();
					}
				break;
			}
			
			return false;
		}
		
		/**
		 * Set the POI and calculate a new path
		 * @param	p		new POI
		 */
		private function setPOI(p:Point):void
		{
			pointOfInterest = p;
			path = cg.graph.getPath(this, pointOfInterest);
			if (path.length != 0)
				nodeOfInterest = path[0];
			range = RANGE;
			state = STATE_MOVE_NETWORK;
		}
		
		/**
		 * Check LOS normally and from 4 different points around the player
		 * @param	tgt		Target of LOS check
		 * @return			true if LOS between player and tgt
		 */
		private function extendedLOScheck(tgt:Point):Boolean
		{
			return System.hasLineOfSight(this, pointOfInterest) &&
				   System.hasLineOfSight(this, pointOfInterest, new Point(-2, 0)) && System.hasLineOfSight(this, pointOfInterest, new Point( 2, 0)) &&
				   System.hasLineOfSight(this, pointOfInterest, new Point(0, -2)) && System.hasLineOfSight(this, pointOfInterest, new Point(0, 2));
		}
		
		/**
		 * Check if should be holding an Omnitool but actually isn't; if false set state to IDLE
		 * @return		true if holding Omnitool
		 */
		private function omnitoolCheck():Boolean
		{
			var ret:Boolean = activeConsole && activeConsole is Omnitool;
			if (!ret)
			{
				if (activeConsole)
					onCancel();
				state = STATE_IDLE;
				goal = GOAL_IDLE;
			}
			return ret;
		}
		
		/**
		 * Perform the ShieldReboot maze
		 */
		private function handleStateReboot():void
		{
			releaseKey("ACTION");
			if (objectOfInterest == null)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			var c:ConsoleShieldRe = objectOfInterest as ConsoleShieldRe;
			if (c.closestPlayer == null || c.closestPlayer != this)
			{
				trace("[WINGMAN " + playerID + "] Couldn't use the reboot module!");
				onCancel();
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			if (c.onCooldown())
			{
				chooseState();
				return;
			}
			if (!c.isPuzzleActive())
			{
				mazeSolution = null;
				pressKey("ACTION");
				trace("[WINGMAN " + playerID + "] Starting maze.");
				return;
			}
			if (!mazeSolution)
			{
				mazeSolution = c.puzzleSolution;
				mazeIndex = 0;
				releaseKey("ACTION");
				genericCounter = System.getRandInt(20, 36);
				return;
			}
			if (--genericCounter > 0)
			{
				releaseMovementKeys();
				return;
			}
			genericCounter = System.getRandInt(3, 8);
			switch (mazeSolution[mazeIndex++])
			{
				case -1:	pressKey("UP");			break;
				case  0:	pressKey("RIGHT");		break;
				case  1:	pressKey("DOWN");		break;
			}
			if (mazeIndex == mazeSolution.length)
			{
				trace("[WINGMAN " + playerID + "] Finished with maze.");
				releaseMovementKeys();
				onCancel();
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
			}
		} 
		
		private function handleStateColor():void
		{
			if (objectOfInterest == null)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			var console:ConsoleShields = objectOfInterest as ConsoleShields;
			if (console.onCooldown())
				return;
			if (!cg.ship.isShieldOptimal())
			{
				switch (cg.ship.getMostDamagingColor())
				{
					case System.COL_GREEN:	pressKey("RIGHT");		return;
					case System.COL_RED:	pressKey("UP");			return;
					case System.COL_YELLOW:	pressKey("LEFT");		return;
					case System.COL_BLUE:	pressKey("DOWN");		return;
				}
			}
			trace("[WINGMAN " + playerID + "] Finished with shield color.");
			releaseAllKeys();
			onCancel();
			chooseState(true);		
		}
		
		private function handleStateDouse():void
		{
			if (!omnitoolCheck()) return;
			var near:Array = cg.managerMap[System.M_FIRE].getNearby(this, 9999);
			if (near.length == 0)
			{
				chooseState(true);
				return;
			}
			objectOfInterest = near[0];
			setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
			range = Omnitool.RANGE_EXTINGUISH * .9;
			trace("[WINGMAN " + playerID + "] Heading to douse fire.");
		}
				
		private function handleStateRepair():void
		{
			if (!omnitoolCheck()) return;
			objectOfInterest = getNearestDamagedConsole();
			if (objectOfInterest == null)
			{
				chooseState(true);
				return;
			}
			setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
			range = Omnitool.RANGE_REPAIR * .9;
			trace("[WINGMAN " + playerID + "] Heading to repair console.");
		}
		
		private function handleStateTurret():void
		{
			if (objectOfInterest == null)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			if (chooseState())
			{
				enemyOfInterest = null;
				releaseAllKeys();
				onCancel();
				trace("[WINGMAN " + playerID + "] There's something else more important to do!");
				return;
			}
			if (++genericCounter >= TURRET_MAX)
			{
				enemyOfInterest = null;
				releaseAllKeys();
				onCancel();
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				trace("[WINGMAN " + playerID + "] Enemies out of range!");
				return;
			}
			if (enemyOfInterest == null || !enemyOfInterest.isActive() ||
				(enemyOfInterest.getHP() == 0 && !(enemyOfInterest is EnemyPeepsEye)) ||
				(enemyOfInterest.getHP() == 0 && (enemyOfInterest is EnemyPeepsEye) && (enemyOfInterest as EnemyPeepsEye).getIfMainIsIncapacitated()) ||
				(enemyOfInterest is EnemyPeeps && !(enemyOfInterest as EnemyPeeps).isIncapacitated()) ||
				(enemyOfInterest is EnemyPeepsEye && !(enemyOfInterest as EnemyPeepsEye).getIsActive()) ||
				(enemyOfInterest is EnemyPeepsEye) && int((enemyOfInterest as EnemyPeepsEye).getEyeNo() / 2) != playerID)
			{
				releaseAllKeys();
				trace("[WINGMAN " + playerID + "] Enemy no longer valid.");
				enemyOfInterest = getValidEnemy();
				if (enemyOfInterest == null)
					chooseState(true);
				return;
			}
			
			var turret:ConsoleTurret = objectOfInterest as ConsoleTurret;
			var trot:Number = turret.trot;
			var rotOff:Number = turret.rotOff;
			var tgt:Point = new Point(enemyOfInterest.mc_object.x, enemyOfInterest.mc_object.y);
			//var origin:Point = new Point(turret.mc_object.x, turret.mc_object.y);
			var origin:Point = turret.getSpawnPoint();
			var limits:Array = [270 - trot + turret.gimbalLimits[0], 270 - trot + turret.gimbalLimits[1]];	
			var rawAngle:Number = System.getAngle(origin.x, origin.y, tgt.x, tgt.y);
			var tgtAngle:Number = (270 - trot + rawAngle) - rotOff;
			if (rawAngle < 0)
				tgtAngle += rotOff * 2;
			var turrAngle:Number = 270;
			var diffAngle:Number = tgtAngle - turrAngle;
			
			if (tgtAngle < limits[0] - GIMBAL_LENIENCY || tgtAngle > limits[1] + GIMBAL_LENIENCY)
			{
				enemyOfInterest = getValidEnemy();
				releaseKey("ACTION");
				return;
			}
			
			pressKey("ACTION");
			genericCounter = 0;
			
			var dist:Number = System.getDistance(turret.mc_object.x, turret.mc_object.y, enemyOfInterest.mc_object.x, enemyOfInterest.mc_object.y) * turret.distAmt;
			var delta:Point = enemyOfInterest.getDelta();
			var lead:Point = new Point(enemyOfInterest.mc_object.x + delta.x * dist * turret.leadAmt, enemyOfInterest.mc_object.y + delta.y * dist * turret.leadAmt);
			rawAngle = System.getAngle(origin.x, origin.y, lead.x, lead.y);
			tgtAngle = (270 - trot + rawAngle) - rotOff;
			if (rawAngle < 0)
				tgtAngle += rotOff * 2;
			
			// account for overshooting/undershooting based on if trot is + or -
			//diffAngle = tgtAngle - turrAngle + (System.getSign(trot) * (Math.abs(Math.abs(trot) - 90))) / 20 + turretRandom;
			diffAngle = tgtAngle - turrAngle + turretRandom;
			
			if (++turrRandCounter >= COUNTER_MAX)
			{
				turrRandCounter = 0;
				turretRandom = System.getRandNum( -3, 3);
			}
			
			if (diffAngle > 2)
			{
				pressKey("RIGHT");
				releaseKey( "LEFT");
			}
			else if (diffAngle < -2)
			{
				pressKey("LEFT");
				releaseKey("RIGHT");
			}
			else
			{
				releaseKey("LEFT");
				releaseKey("RIGHT");
			}
		}
		
		/**
		 * Return the angle in range (-180, 180]
		 * @param	angle
		 * @return
		 */
		private function normalizeAngle(angle:Number):Number
		{
			if (angle > 180 || angle < -180)
			{
				angle %= 360;
				if (angle > 180)
					angle -= 360;
				else if (angle < -180)
					angle += 360;
			}
			return angle;
		}
		
		private function handleStateNavigation():void
		{
			if (objectOfInterest == null)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			if (chooseState() || (Math.abs(cg.ship.shipHeading) < HEADING_THRESHOLD))
			{
				releaseAllKeys();
				onCancel();
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				if (cg.ship.isHeadingGood())
					trace("[WINGMAN " + playerID + "] Navigation fixed!");
				else
					trace("[WINGMAN " + playerID + "] There's something else more important to do!");
				return;
			}
			if (cg.ship.shipHeading < 0)
			{
				releaseKey("LEFT");
				pressKey("RIGHT");
			}
			else
			{
				releaseKey("RIGHT");
				pressKey("LEFT");
			}
		}
		
		private function handleStateSlipdrive():void
		{
			if (objectOfInterest == null)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			if (cg.ship.isJumpReady() != "ready" || consoleMap["slipdrive"].forceOverride)
			{
				releaseAllKeys();
				onCancel();
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				trace("[WINGMAN " + playerID + "] Done with Slipdrive!");
				return;
			}
			var slip:ConsoleSlipdrive = (objectOfInterest as ConsoleSlipdrive);
			if (!slip.puzzleActive())
			{
				pressKey("ACTION");
				return;
			}
			if (slipSolution == null)
			{
				slipSolution = slip.getArrows();
				slipIndex = 0;
				return;
			}
			releaseAllKeys();
			var dir:int = slip.shouldPress();
			if (dir != -1)
			{
				switch (dir)
				{
					case 0:		pressKey("RIGHT");		break;
					case -90:	pressKey("UP");			break;
					case 180:	pressKey("LEFT");		break;
					case 90:	pressKey("DOWN");		break;
				}
			}
		}
		
		private function handleStateFails():void
		{
			if (objectOfInterest == null)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			var c:ABST_Console = (objectOfInterest as ABST_Console);
			if (!c.corrupted || !c.debuggable)
			{
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				chooseState(true);
				return;
			}
			if (!ConsoleFAILS.puzzleActive)
			{
				releaseAllKeys();
				pressKey("ACTION");
				return;
			}
			releaseKey("ACTION");
			Math.random() > .85 ? pressKey("RIGHT") : releaseKey("RIGHT");
			Math.random() > .6 ? pressKey("LEFT") : releaseKey("LEFT");
			Math.random() > .2 ? pressKey("UP") : releaseKey("UP");
		}
		
		/**
		 * Determine the next thing to do
		 * @param	force		ignore the cooldown
		 * @return				true if the check went through (false if on cooldown)
		 */
		private function chooseState(force:Boolean = false):Boolean
		{
			++repairCounter;
			if (!force && --chooseStateCooldown > 0)
				return false;
			chooseStateCooldown = CHOOSE_CD;
			var toRepair:ABST_Console;
			if (repairCounter >= COUNTER_MAX * 2)
			{
				toRepair = getNearestDamagedConsole();
				repairCounter = 0;
			}
			var toFormat:ABST_Console;
			if (failsCounter >= FAILS_MAX)
				toFormat = getNextCorruptedConsole();
			if (state == STATE_STUCK)
			{
				var node:GraphNode = cg.graph.getNearestValidNode(this, new Point(mc_object.x, mc_object.y));
				if (node != null)
					setPOI(new Point(node.mc_object.x, node.mc_object.y));
				else
				{
					state = STATE_IDLE;
					goal = GOAL_IDLE; 
				}
				trace("[WINGMAN " + playerID + "] Heading to a valid node.");
			}
			else if (cg.managerMap[System.M_FIRE].hasObjects() && !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_DOUSE))
			{
				if (goal == GOAL_DOUSE) return false;
				goal = GOAL_DOUSE;
				if (activeConsole is Omnitool)		// head to fire
					handleStateDouse();
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN " + playerID + "] Heading to pick up Omnitool to douse fires.");
				}				
			}
			else if (otherPlayer.getHP() == 0)
			{
				if (goal == GOAL_REVIVE) return false;
				goal = GOAL_REVIVE;
				if (activeConsole is Omnitool)		// head to player
				{
					objectOfInterest = otherPlayer;
					setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
					range = Omnitool.RANGE_REVIVE * .9;
					trace("[WINGMAN " + playerID + "] Heading to revive teammate.");
				}
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN " + playerID + "] Heading to pick up Omnitool to revive teammate.");
				}
			}
			else if (otherPlayer.getHP() / otherPlayer.getHPmax() < HEAL_THRESHOLD)
			{
				if (goal == GOAL_HEAL) return false;
				goal = GOAL_HEAL;
				if (activeConsole is Omnitool)		// head to player
				{
					objectOfInterest = otherPlayer;
					setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
					range = Omnitool.RANGE_REVIVE * .9;
					trace("[WINGMAN " + playerID + "] Heading to heal teammate.");
				}
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN " + playerID + "] Heading to pick up Omnitool to heal teammate.");
				}				
			}
			else if (failsCounter >= FAILS_MAX && ABST_Console.numCorrupted != 0 && !ABST_Console.beingUsed &&
					toFormat != null && toFormat.debuggable && !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_FAILS))
			{
				if (goal == GOAL_FAILS) return false;
				objectOfInterest = getNextCorruptedConsole();
				if (!objectOfInterest) return false;
				failsCounter = 0;
				goal = GOAL_FAILS;
				onCancel();
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to format system.");
			}
			else if (cg.ship.getShieldPercent() < System.getRandNum(SP_THRESHOLD * .9, SP_THRESHOLD * 1.1) && isValidConsole(consoleMap["shieldRe"]) && !consoleMap["shieldRe"].onCooldown() &&
					!(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_REBOOT))
			{
				if (goal == GOAL_REBOOT) return false;
				goal = GOAL_REBOOT;
				if (activeConsole != null && !(activeConsole is ConsoleShieldRe)) onCancel();
				objectOfInterest = consoleMap["shieldRe"];
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to shield reboot module.");
			}
			else if (cg.managerMap[System.M_BOARDER].hasObjects() && !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_BOARDER))
			{
				if (goal == GOAL_BOARDER) return false;
				objectOfInterest = getClosestBoarder();
				if (!objectOfInterest) return false;
				goal = GOAL_BOARDER;	
				onCancel();
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to fight boarder.");
			}
			else if (cg.ship.isJumpReady() == "ready" && slipCounter >= SLIP_MAX && !consoleMap["slipdrive"].forceOverride && isValidConsole(consoleMap["slipdrive"])
					&& !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_SLIP) && !((cg.level.sectorIndex == 0 || cg.level.sectorIndex == 4) && !cg.engine.isAllAI()))
			{
				if (goal == GOAL_SLIP) return false;
				goal = GOAL_SLIP;
				if (activeConsole != null && !(activeConsole is ConsoleSlipdrive)) onCancel();
				objectOfInterest = consoleMap["slipdrive"];
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to Slipdrive.");
			}
			else if (++shieldCounter >= SHIELD_MAX && isValidConsole(consoleMap["shieldCol"]) && !cg.ship.isShieldOptimal() && !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_COLOR))
			{
				if (goal == GOAL_COLOR) return false;
				goal = GOAL_COLOR;
				shieldCounter = 0;
				if (activeConsole != null && !(activeConsole is ConsoleShields)) onCancel();
				objectOfInterest = consoleMap["shieldCol"];
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to shield color.");
			}
			// chance to fix Nav even if enemies are present
			else if (!cg.ship.isHeadingGood() && Math.random() > .7 && cg.ship.getShieldPercent() > 0 && !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_NAVIGATION))
			{
				if (goal == GOAL_NAVIGATION) return false;
				goal = GOAL_NAVIGATION;
				if (activeConsole != null && !(activeConsole is ConsoleNavigation)) onCancel();
				objectOfInterest = consoleMap["navigation"];
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to navigation.");
			}
			else if (cg.managerMap[System.M_ENEMY].hasObjects())
			{
				if (goal == GOAL_TURRET) return false;
				goal = GOAL_TURRET;
				if (activeConsole != null && !(activeConsole is ConsoleTurret)) onCancel();
				enemyOfInterest = getValidEnemy();
				if (enemyOfInterest == null)
				{
					trace("[WINGMAN " + playerID + "] Enemies detected but no valid one found.");
					goal = GOAL_IDLE;
					state = STATE_IDLE;
					return false;
				}
				objectOfInterest = getValidTurret(enemyOfInterest);
				if (objectOfInterest == null)
				{
					trace("[WINGMAN " + playerID + "] Enemies detected but no valid turret found.");
					goal = GOAL_IDLE;
					state = STATE_IDLE;
					return false;
				}
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to turret.");
			}
			// normal Nav priority
			else if (!cg.ship.isHeadingGood() && !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_NAVIGATION))
			{
				if (goal == GOAL_NAVIGATION) return false;
				goal = GOAL_NAVIGATION;
				if (activeConsole != null && !(activeConsole is ConsoleNavigation)) onCancel();
				objectOfInterest = consoleMap["navigation"];
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN " + playerID + "] Heading to navigation.");
			}
			else if (otherPlayer.getHP() != otherPlayer.getHPmax())		// top off HP
			{
				if (goal == GOAL_HEAL) return false;
				goal = GOAL_HEAL;
				if (activeConsole is Omnitool)		// head to player
				{
					objectOfInterest = otherPlayer;
					setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
					range = Omnitool.RANGE_REVIVE * .9;
					trace("[WINGMAN " + playerID + "] Heading to heal teammate.");
				}
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN " + playerID + "] Heading to pick up Omnitool to heal teammate.");
				}	
			}
			else if (toRepair != null && !(otherPlayer is WINGMAN && (otherPlayer as WINGMAN).goal == GOAL_REPAIR))
			{
				if (goal == GOAL_REPAIR) return false;
				goal = GOAL_REPAIR;
				if (activeConsole is Omnitool)		// head to console
				{
					objectOfInterest = toRepair;
					setPOI(new Point(toRepair.mc_object.x, toRepair.mc_object.y));
					range = Omnitool.RANGE_REPAIR * .9;
					trace("[WINGMAN " + playerID + "] Heading to repair console.");
				}
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN " + playerID + "] Heading to pick up Omnitool to repair console.");
				}	
			}
			else
			{
				if (state != STATE_IDLE)
				{
					releaseAllKeys();
					objectOfInterest = null;
					pointOfInterest = null;
					trace("[WINGMAN " + playerID + "] Doing nothing.");
				}
				if (activeConsole) onCancel();
				goal = GOAL_IDLE;
				state = STATE_IDLE;
				moveSpeedX = moveSpeedY = NORMAL_SPEED;
				if (Math.random() > .7)
					setPOI(cg.getRandomShipLocation());
			}
			return true;
		}
		
		private function isValidConsole(c:ABST_Console):Boolean
		{
			return !c.isBroken() && c.isUnlocked() && !c.corrupted && (!c.inUse || c.closestPlayer == this);
		}
		
		/**
		 * Determine what to do once at the destination
		 */
		private function onArrive():void
		{
			trace("[WINGMAN " + playerID + "] Arrived at destination.");
			switch (goal)
			{
				case GOAL_REVIVE:
					if (objectOfInterest is Omnitool)		// pick up omnitool
					{
						(objectOfInterest as ABST_Console).onAction(this);
						objectOfInterest = otherPlayer;
						setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
						trace("[WINGMAN " + playerID + "] Heading to revive teammate.");
					}
					else									// revive the player
					{
						state = STATE_REVIVE;
						releaseMovementKeys();
						pressKey("ACTION");
						trace("[WINGMAN " + playerID + "] Reviving teammate.");
					}
				break;
				case GOAL_HEAL:
					if (objectOfInterest is Omnitool)		// pick up omnitool
					{
						if (!getOnConsole(objectOfInterest as Omnitool))
						{
							state = STATE_IDLE;
							goal = GOAL_IDLE;
							chooseState(true);
							return;
						}
						objectOfInterest = otherPlayer;
						setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
						trace("[WINGMAN " + playerID + "] Heading to heal teammate.");
					}
					else									// revive the player
					{
						state = STATE_HEAL;
						releaseMovementKeys();
						pressKey("ACTION");
						trace("[WINGMAN " + playerID + "] Healing teammate.");
					}
				break;
				case GOAL_DOUSE:
					if (objectOfInterest is Omnitool)		// pick up omnitool
					{
						if (!getOnConsole(objectOfInterest as Omnitool))
						{
							state = STATE_IDLE;
							goal = GOAL_IDLE;
							chooseState(true);
							return;
						}
						handleStateDouse();
					}
					else									// douse the fire
					{
						state = STATE_DOUSE;
						releaseMovementKeys();
						pressKey("ACTION");
						trace("[WINGMAN " + playerID + "] Dousing fire.");
					}
				break;
				case GOAL_REPAIR:
					if (objectOfInterest is Omnitool)		// pick up omnitool
					{
						if (!getOnConsole(objectOfInterest as Omnitool))
						{
							state = STATE_IDLE;
							goal = GOAL_IDLE;
							chooseState(true);
							return;
						}
						handleStateRepair();
					}
					else									// repair
					{
						state = STATE_REPAIR;
						releaseMovementKeys();
						pressKey("ACTION");
						trace("[WINGMAN " + playerID + "] Repairing console.");
					}
				break;
				case GOAL_TURRET:
					if (!getOnConsole(objectOfInterest as ABST_Console)) return;
					state = STATE_TURRET;
					genericCounter = 0;
				break;
				case GOAL_NAVIGATION:
					if (!getOnConsole(objectOfInterest as ABST_Console)) return;
					state = STATE_NAVIGATION;
				break;
				case GOAL_REBOOT:
					if (!getOnConsole(objectOfInterest as ABST_Console)) return;
					state = STATE_REBOOT;
				break;
				case GOAL_COLOR:
					if (!getOnConsole(objectOfInterest as ABST_Console)) return;
					state = STATE_COLOR;
				break;
				case GOAL_SLIP:
					if (!getOnConsole(objectOfInterest as ABST_Console)) return;
					slipSolution = null;
					state = STATE_SLIP;
				break;
				case GOAL_FAILS:
					if (!getOnConsole(objectOfInterest as ABST_Console)) return;
					state = STATE_FAILS;
					releaseAllKeys();
				break;
				case GOAL_BOARDER:
					state = STATE_BOARDER;
				break;
				default:
					trace("[WINGMAN " + playerID + "] Arrived at destination but couldn't figure out what to do.");
					state = STATE_IDLE;
					goal = GOAL_IDLE;
			}
		}
		
		private function getOnConsole(c:ABST_Console):Boolean
		{
			if (c == null)
			{
				trace("[WINGMAN " + playerID + "] Couldn't get on a null console!");
				return false;
			}
			if (c.corrupted && goal != GOAL_FAILS)
			{
				trace("[WINGMAN " + playerID + "] Couldn't get on a corrupted console!");
				return false;
			}
			if (c.inUse && c.closestPlayer != this)
			{
				trace("[WINGMAN " + playerID + "] Arrived at", c, "but it's in use!");
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				return false;
			}
			if (activeConsole != null) onCancel();
			c.closestPlayer = this;
			c.onAction(this);
			trace("[WINGMAN " + playerID + "] Getting on console:", c);
			return true;
		}
		
		private function pressKey(key:String):void
		{
			cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyMap[key]));
		}
		
		private function releaseKey(key:String):void
		{
			cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyMap[key]));
		}
		
		private function releaseAllKeys():void
		{
			releaseMovementKeys();
			releaseKey("ACTION");
			releaseKey("CANCEL");
		}
		
		private function releaseMovementKeys():void
		{
			releaseKey("UP");
			releaseKey("DOWN");
			releaseKey("LEFT");
			releaseKey("RIGHT");
		}
		
		private function getClosestBoarder():ABST_Object
		{
			if (!cg.managerMap[System.M_BOARDER].hasObjects()) return null;
			var closest:Number = 9999;
			var dist:Number;
			var enemy:ABST_Object = null;
			for each (var b:ABST_Boarder in cg.managerMap[System.M_BOARDER].getAll())
			{
				if (!b.isActive()) continue;
				dist = System.getDistance(mc_object.x, mc_object.y, b.mc_object.x, b.mc_object.y);
				if (dist < closest)
				{
					closest = dist;
					enemy = b;
				}
			}
			return enemy;
		}
		
		private function getClosestOmnitool():ABST_Object
		{
			var closest:Number = 9999;
			var dist:Number;
			var tool:ABST_Object = null;
			for each (var c:ABST_Console in consoleMap["omnitool"])
			{
				if (c.inUse && c.closestPlayer != this) continue;
				dist = System.getDistance(mc_object.x, mc_object.y, c.mc_object.x, c.mc_object.y);
				if (dist < closest)
				{
					closest = dist;
					tool = c;
				}
			}
			return tool;
		}
		
		/**
		 * Get the first valid turret that can shoot at enemy
		 * @param	enemy		The target enemy
		 * @return				Turret that can shoot at the enemy
		 */
		private function getValidTurret(enemy:ABST_Enemy):ConsoleTurret
		{
			if (enemy == null || !enemy.isActive()) return null;
			var ai:WINGMAN;
			if (otherPlayer is WINGMAN)
				ai = otherPlayer as WINGMAN;
				
			var tgt:Point = new Point(enemy.mc_object.x, enemy.mc_object.y);
			var turrets:Array = consoleMap["turret"];
			turrets.sort(randomize);
			for each (var t:ConsoleTurret in turrets)
			{
				if (t.inUse || t.isBroken() || t.corrupted) continue;
				if (ai && ai.objectOfInterest == t) continue;
				
				var trot:Number = t.trot;
				var rotOff:Number = t.rotOff;
				var origin:Point = t.getSpawnPoint();
				var limits:Array = [270 - trot + t.gimbalLimits[0], 270 - trot + t.gimbalLimits[1]];	
				var rawAngle:Number = System.getAngle(origin.x, origin.y, tgt.x, tgt.y);
				var tgtAngle:Number = (270 - trot + rawAngle) - rotOff;
				if (rawAngle < 0)
					tgtAngle += rotOff * 2;
				
				//trace("[WINGMAN " + playerID + "] Target", enemy, "is in range", limits[0], tgtAngle, limits[1], "of turret", t.turretID);
				
				if (tgtAngle >= limits[0] && tgtAngle <= limits[1])
					return t;
				
				/*var pt:Point = t.getSpawnPoint();
				var angle:Number = System.getAngle(pt.x, pt.y, enemy.mc_object.x, enemy.mc_object.y);
				if (angle >= t.gimbalLimits[0] - t.rotOff && angle <= t.gimbalLimits[1] + t.rotOff)
					return t;*/
			}
			return null;
		}
		
		private function getValidEnemy():ABST_Enemy
		{
			var enemies:Array = cg.managerMap[System.M_ENEMY].getAll();
			if (enemies.length == 0) return null;
			var mostThreateningEnemy:ABST_Enemy;
			var specialEnemy:ABST_Enemy;
			var maxThreat:int = -1;
			enemies.sort(randomize);
			var useThreat:Boolean = Math.random() < .7;
			for each (var enemy:ABST_Enemy in enemies)
			{
				if (enemy is EnemyPortal)
				{
					if (Math.random() > .7)
						return enemy;
					else
						continue;
				}
				if (enemy is EnemySwipe)
					continue;
				if (enemy is EnemyPeeps)
				{
					if ((enemy as EnemyPeeps).isIncapacitated())
						specialEnemy = enemy;
					continue;
				}
				if (enemy is EnemyPeepsEye)
				{
					if ((enemy as EnemyPeepsEye).getIsActive() && int((enemy as EnemyPeepsEye).getEyeNo() / 2) == playerID)
						specialEnemy = enemy;
					continue;
				}
				var threat:int = enemy.getJammingValue();
				if (threat >= maxThreat || !useThreat)
				{
					if (threat > maxThreat)
						maxThreat = threat;
					mostThreateningEnemy = enemy;
				}
			}
			if (!mostThreateningEnemy)
				return specialEnemy;
			return mostThreateningEnemy;
		}
		
		private function getNearestDamagedConsole():ABST_Console
		{
			var nearest:ABST_Console = null;
			var nearestDist:Number = 9999;
			var dist:Number;
			for each (var c:ABST_Console in cg.consoles)
			{
				if (c is Omnitool) continue;
				if (c.getHP() != c.getHPmax())
				{
					dist = System.getDistance(mc_object.x, mc_object.y, c.mc_object.x, c.mc_object.y);
					if (dist < nearestDist)
					{
						nearestDist = dist;
						nearest = c;
					}
				}
			}
			return nearest;
		}
		
		private function getNextCorruptedConsole():ABST_Console
		{
			if (ABST_Console.numCorrupted == 0) return null;
			var c:ABST_Console;
			if (consoleMap["shieldRe"].corrupted) return consoleMap["shieldRe"];
			for each (c in consoleMap["turret"])
				if (c.corrupted) return c;
			if (consoleMap["shieldCol"].corrupted) return consoleMap["shieldCol"];
			if (consoleMap["sensors"].corrupted) return consoleMap["sensors"];
			if (consoleMap["slipdrive"].corrupted) return consoleMap["slipdrive"];
			if (consoleMap["navigation"].corrupted) return consoleMap["navigation"];
			return null;
		}
		
		private function randomize(a:*, b:*):int
		{
			return Math.random() > .5 ? 1 : -1;
		}
		
		private function moveToPoint(tgt:Point):void
		{			
			if (Math.abs(mc_object.x - tgt.x) < NORMAL_SPEED)
				moveSpeedX = PRECISE_SPEED;
			else
				moveSpeedX = NORMAL_SPEED;
			if (Math.abs(mc_object.y - tgt.y) < NORMAL_SPEED)
				moveSpeedY = PRECISE_SPEED;
			else
				moveSpeedY = NORMAL_SPEED;
			
			if (mc_object.y > tgt.y + MOVE_RANGE)
			{
				if (!keysDown[UP])
					cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyMap["UP"]));
			}
			else if (keysDown[UP])
				cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyMap["UP"]));
			if (mc_object.y < tgt.y - MOVE_RANGE)
			{
				if (!keysDown[DOWN])
					cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyMap["DOWN"]));
			}
			else if (keysDown[DOWN])
				cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyMap["DOWN"]));
			if (mc_object.x < tgt.x - MOVE_RANGE)
			{
				if (!keysDown[RIGHT])
					cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyMap["RIGHT"]));
			}
			else if (keysDown[RIGHT])
				cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyMap["RIGHT"]));
			if (mc_object.x > tgt.x + MOVE_RANGE)
			{
				if (!keysDown[LEFT])
					cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, keyMap["LEFT"]));
			}
			else if (keysDown[LEFT])
				cg.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keyMap["LEFT"]));
		}
		
		private function updateDisplay():void
		{
			display.mc_arrowA.alpha = (keysDown[ACTION] ? 1 : .2);
			display.mc_arrowC.alpha = (keysDown[CANCEL] ? 1 : .2);
			display.mc_arrowU.alpha = (keysDown[UP] ? 1 : .2);
			display.mc_arrowL.alpha = (keysDown[LEFT] ? 1 : .2);
			display.mc_arrowR.alpha = (keysDown[RIGHT] ? 1 : .2);
			display.mc_arrowD.alpha = (keysDown[DOWN] ? 1 : .2);
			
			if (enemyOfInterest && enemyOfInterest.isActive())
			{
				tgtIndicator.visible = true;
				tgtIndicator.x = enemyOfInterest.mc_object.x;
				tgtIndicator.y = enemyOfInterest.mc_object.y;
			}
			else if (objectOfInterest && objectOfInterest.isActive())
			{
				tgtIndicator.visible = true;
				tgtIndicator.x = objectOfInterest.mc_object.x;
				tgtIndicator.y = objectOfInterest.mc_object.y;
			}
			else
				tgtIndicator.visible = false;
			
			
			switch (state)
			{
				case STATE_DOUSE:				display.tf_status.text = "Extinguishing fire";		break;
				case STATE_DEAD:				display.tf_status.text = "Needs help!";				break;
				case STATE_HEAL:				display.tf_status.text = "Healing ally";			break;
				case STATE_IDLE:				display.tf_status.text = "Waiting";					break;
				case STATE_SLIP:				display.tf_status.text = "Spooling Slipdrive";		break;
				case STATE_MOVE_FREE:
				case STATE_MOVE_FROM_NETWORK:
				case STATE_MOVE_NETWORK:
					switch (goal)
					{
						case GOAL_DOUSE:		display.tf_status.text = "Extinguishing fire";		break;
						case GOAL_DEAD:			display.tf_status.text = "Needs help!";				break;
						case GOAL_HEAL:			display.tf_status.text = "Healing ally";			break;
						case GOAL_IDLE:			display.tf_status.text = "Moving";					break;
						case GOAL_REBOOT:		display.tf_status.text = "Rebooting shields";		break;
						case GOAL_REVIVE:		display.tf_status.text = "Reviving ally";			break;
						case GOAL_TURRET:		display.tf_status.text = "Engaging enemies";		break;
						case GOAL_NAVIGATION:	display.tf_status.text = "Correcting course";		break;
						case GOAL_SLIP:			display.tf_status.text = "Spooling Slipdrive";		break;
						case GOAL_COLOR:		display.tf_status.text = "Switching Shield Color";	break;
						case GOAL_REPAIR:		display.tf_status.text = "Repairing systems";		break;
						case GOAL_FAILS:		display.tf_status.text = "Formatting system";		break;
						case GOAL_BOARDER:		display.tf_status.text = "Engaging boarder";		break;
					}
				break;
				case STATE_REBOOT:				display.tf_status.text = "Rebooting shields";		break;
				case STATE_REVIVE:				display.tf_status.text = "Reviving ally";			break;
				case STATE_STUCK:				display.tf_status.text = "Confused";				break;
				case STATE_TURRET:				display.tf_status.text = "Engaging enemies";		break;
				case STATE_REPAIR:				display.tf_status.text = "Repairing systems";		break;
				case STATE_COLOR:				display.tf_status.text = "Switching Shield Color";	break;
				case STATE_NAVIGATION:			display.tf_status.text = "Correcting course";		break;
				case STATE_FAILS:				display.tf_status.text = "Formatting system";		break;
				case STATE_BOARDER:				display.tf_status.text = "Engaging boarder";		break;
			}
		}
	}
}