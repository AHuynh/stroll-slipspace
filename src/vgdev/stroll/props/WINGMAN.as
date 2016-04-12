package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import vgdev.stroll.ABST_Container;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleNavigation;
	import vgdev.stroll.props.consoles.ConsoleShieldRe;
	import vgdev.stroll.props.consoles.ConsoleShields;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.consoles.ConsoleTurret;
	import vgdev.stroll.props.consoles.Omnitool;
	import vgdev.stroll.props.enemies.ABST_Boarder;
	import vgdev.stroll.support.graph.GraphNode;
	import vgdev.stroll.System;
	
	/**
	 * AI for playing as a Player
	 * @author Alexander Huynh
	 */
	public class WINGMAN extends Player 
	{
		private var enum:int = 0;
		
		private var state:int;
		private const STATE_IDLE:int = enum++;
		private const STATE_STUCK:int = enum++;
		private const STATE_MOVE_FREE:int = enum++;
		private const STATE_MOVE_NETWORK:int = enum++;
		private const STATE_MOVE_FROM_NETWORK:int = enum++;
		private const STATE_REVIVE:int = enum++;
		private const STATE_HEAL:int = enum++;
		private const STATE_DOUSE:int = enum++;
		private const STATE_REBOOT:int = enum++;
		
		private var goal:int;
		private const GOAL_IDLE:int = enum++;
		private const GOAL_REVIVE:int = enum++;
		private const GOAL_HEAL:int = enum++;
		private const GOAL_DOUSE:int = enum++;
		private const GOAL_REBOOT:int = enum++;
		
		private var otherPlayer:Player;
		
		private var pointOfInterest:Point;
		private var objectOfInterest:ABST_Object;
		
		private var path:Array;
		private var nodeOfInterest:GraphNode;
		
		protected var range:Number = 5;			// current range
		protected const RANGE:Number = 5;		// node clear range
		protected const MOVE_RANGE:Number = 2;	// diff on movement
		
		private const NORMAL_SPEED:Number = 5;
		private const PRECISE_SPEED:Number = 2;
		
		private const HEAL_THRESHOLD:Number = .7;		// if other player's HP is below this threshold, heal
		private const SP_THRESHOLD:Number = .4;			// if SP is below this threshold, reboot shields
		
		private var consoleMap:Object = { };
		private var keyMap:Object;
		private var acknowledgeTails:Boolean = false;
		private var setup:Boolean = true;
		
		private var chooseStateCooldown:int = 0;
		private const CHOOSE_CD:int = 30;
		
		private var prevPoint:Point;
		private var ignoreStuck:Boolean = true;
		
		private var genericCounter:int = 0;
		private var stuckCounter:int = 0;
		private var movingPOIcounter:int = 0;			// if 0, update POI location, since object could be moving
		private const COUNTER_MAX:int = 15;
		
		private var display:MovieClip;
		
		// -- ShieldRe --------------------------------------------------------
		private var mazeSolution:Array;
		private var mazeIndex:int;
		// -- ShieldRe --------------------------------------------------------
		
		public function WINGMAN(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, _playerID:int, keyMap:Object, _display:MovieClip) 
		{
			super(_cg, _mc_object, _hitMask, _playerID, keyMap);
			display = _display;
			trace("[WINGMAN] Waiting to setup...");
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
			}
			keyMap = playerID == 0 ? System.keyMap0 : System.keyMap1;
			prevPoint = new Point(mc_object.x, mc_object.y);
			updateDisplay();
			trace("[WINGMAN] Ready!");
		}
		
		override public function step():Boolean 
		{
			super.step();
			
			if (setup)
			{
				init();
				return false;
			}
			
			// acknowledge TAILS
			if (cg.tails.isActive())
			{
				if (!acknowledgeTails)			// do ready check one time
				{
					acknowledgeTails = true;
					cg.onAction(this);
				}
				return completed;
			}
			else
				acknowledgeTails = false;
				
			updateDisplay();
				
			// check if stuck
			if (!ignoreStuck && state != STATE_IDLE)
			{
				if (mc_object.x == prevPoint.x && mc_object.y == prevPoint.y)
				{
					if (++stuckCounter == COUNTER_MAX)
					{
						state = STATE_STUCK;
						goal = GOAL_IDLE;
						trace("[WINGMAN] Stuck! Trying to get unstuck!");
						trace("\tCurrent node:", nodeOfInterest.mc_object.name);
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
				if (--movingPOIcounter <= 0)
				{
					movingPOIcounter = COUNTER_MAX;
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				}
			}
			if (goal == GOAL_DOUSE && --genericCounter <= 0)		// recalculate nearest fire
			{
				genericCounter = COUNTER_MAX * 2;
				handleStateDouse();
			}
			
			// make a beeline
			if (pointOfInterest != null && state == STATE_MOVE_NETWORK)
			{
				if (extendedLOScheck(pointOfInterest))
				{
					state = STATE_MOVE_FROM_NETWORK;
					path = [];
				}
			}
			
			switch (state)
			{
				case STATE_IDLE:
					chooseState();
				break;
				case STATE_REVIVE:
					if (otherPlayer.getHP() > 0)
						chooseState(true);
				break;
				case STATE_HEAL:
					if (otherPlayer.getHP() / otherPlayer.getHPmax() > HEAL_THRESHOLD)
						chooseState(true);
					else if (!extendedLOScheck(pointOfInterest))
						setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				break;
				case STATE_DOUSE:				
					if (objectOfInterest == null || !objectOfInterest.isActive() ||
						System.getDistance(mc_object.x, mc_object.y, objectOfInterest.mc_object.x, objectOfInterest.mc_object.y) > range)
					{
						trace("[WINGMAN] Fire doused.");
						handleStateDouse();
					}
					else if (!extendedLOScheck(pointOfInterest))
						setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				break;
				case STATE_REBOOT:
					handleStateReboot();
				break;
				case STATE_MOVE_NETWORK:
					ignoreStuck = false;
					moveToPoint(new Point(nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y));
					// arrived at next node	
					if (System.getDistance(mc_object.x, mc_object.y, nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y) < RANGE)
					{
						nodeOfInterest = path.shift();
						if (nodeOfInterest == null)
						{
							trace("[WINGMAN] Leaving path network.");
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
						ignoreStuck = true;
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
		 * Perform the ShieldReboot maze
		 */
		private function handleStateReboot():void
		{
			var c:ConsoleShieldRe = objectOfInterest as ConsoleShieldRe;
			if (c.closestPlayer != this)
			{
				trace("[WINGMAN] Couldn't use the reboot module!");
				onCancel();
				state = STATE_IDLE;
				chooseState(true);
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
				trace("[WINGMAN] Starting maze.");
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
				trace("[WINGMAN] Finished with maze.");
				onCancel();
				chooseState(true);
			}
		} 
		
		private function handleStateDouse():void
		{
			if (!(activeConsole is Omnitool)) return;
			var near:Array = cg.managerMap[System.M_FIRE].getNearby(this, 9999);
			if (near.length == 0)
			{
				chooseState(true);
				return;
			}
			objectOfInterest = near[0];
			setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
			range = Omnitool.RANGE_EXTINGUISH * .9;
			trace("[WINGMAN] Heading to douse fire.");
		}
		
		/**
		 * Determine the next thing to do
		 */
		private function chooseState(force:Boolean = false):void
		{
			if (!force && --chooseStateCooldown > 0)
				return;
			chooseStateCooldown = CHOOSE_CD;
			ignoreStuck = true;
			if (state == STATE_STUCK)
			{
				var node:GraphNode = cg.graph.getNearestValidNode(this, new Point(mc_object.x, mc_object.y));
				setPOI(new Point(node.mc_object.x, node.mc_object.y));
				trace("[WINGMAN] Heading to a valid node.");
			}
			else if (otherPlayer.getHP() == 0)
			{
				if (goal == GOAL_REVIVE) return;
				goal = GOAL_REVIVE;
				if (activeConsole is Omnitool)		// head to player
				{
					objectOfInterest = otherPlayer;
					setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
					range = Omnitool.RANGE_REVIVE * .9;
					trace("[WINGMAN] Heading to revive teammate.");
				}
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN] Heading to pick up Omnitool to revive teammate.");
				}
			}
			else if (otherPlayer.getHP() / otherPlayer.getHPmax() < HEAL_THRESHOLD)
			{
				if (goal == GOAL_HEAL) return;
				goal = GOAL_HEAL;
				if (activeConsole is Omnitool)		// head to player
				{
					objectOfInterest = otherPlayer;
					setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
					range = Omnitool.RANGE_REVIVE * .9;
					trace("[WINGMAN] Heading to heal teammate.");
				}
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN] Heading to pick up Omnitool to heal teammate.");
				}				
			}
			else if (cg.ship.getShieldPercent() < SP_THRESHOLD && isValidConsole(consoleMap["shieldRe"]))
			{
				if (goal == GOAL_REBOOT) return;
				goal = GOAL_REBOOT;
				if (activeConsole != null && !(activeConsole is ConsoleShieldRe)) onCancel();
				objectOfInterest = consoleMap["shieldRe"];
				setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
				trace("[WINGMAN] Heading to shield reboot module.");
			}
			else if (cg.managerMap[System.M_FIRE].hasObjects())
			{
				if (goal == GOAL_DOUSE) return;
				goal = GOAL_DOUSE;
				if (activeConsole is Omnitool)		// head to fire
				{
					handleStateDouse();
				}
				else								// head to closest Omnitool
				{
					onCancel();
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN] Heading to pick up Omnitool to douse fires.");
				}				
			}
			else
			{
				if (state != STATE_IDLE)
				{
					releaseAllKeys();
					objectOfInterest = null;
					pointOfInterest = null;
					trace("[WINGMAN] Doing nothing.");
				}
				if (activeConsole) onCancel();
				goal = GOAL_IDLE;
				state = STATE_IDLE;
				moveSpeedX = moveSpeedY = NORMAL_SPEED;
			}			
		}
		
		private function isValidConsole(c:ABST_Console):Boolean
		{
			return !c.isBroken() && (!c.inUse || c.closestPlayer == this);
		}
		
		/**
		 * Determine what to do once at the destination
		 */
		private function onArrive():void
		{
			trace("[WINGMAN] Arrived at destination.");
			switch (goal)
			{
				case GOAL_REVIVE:
					if (objectOfInterest is Omnitool)		// pick up omnitool
					{
						(objectOfInterest as ABST_Console).onAction(this);
						objectOfInterest = otherPlayer;
						setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
						trace("[WINGMAN] Heading to revive teammate.");
					}
					else									// revive the player
					{
						state = STATE_REVIVE;
						releaseMovementKeys();
						pressKey("ACTION");
						trace("[WINGMAN] Reviving teammate.");
					}
				break;
				case GOAL_HEAL:
					if (objectOfInterest is Omnitool)		// pick up omnitool
					{
						if (!getOnConsole(objectOfInterest as Omnitool)) return;
						objectOfInterest = otherPlayer;
						setPOI(new Point(otherPlayer.mc_object.x, otherPlayer.mc_object.y));
						trace("[WINGMAN] Heading to heal teammate.");
					}
					else									// revive the player
					{
						state = STATE_HEAL;
						releaseMovementKeys();
						pressKey("ACTION");
						trace("[WINGMAN] Healing teammate.");
					}
				break;
				case GOAL_DOUSE:
					if (objectOfInterest is Omnitool)		// pick up omnitool
					{
						if (!getOnConsole(objectOfInterest as Omnitool)) return;
						handleStateDouse();
					}
					else									// douse the fire
					{
						state = STATE_DOUSE;
						releaseMovementKeys();
						pressKey("ACTION");
						trace("[WINGMAN] Dousing fire.");
					}
				break;
				case GOAL_REBOOT:
					if (!getOnConsole(objectOfInterest as ABST_Console)) return;
					state = STATE_REBOOT;
				break;
				default:
					trace("[WINGMAN] Arrived at destination but couldn't figure out what to do.");
					state = STATE_IDLE;
					goal = GOAL_IDLE;
			}
		}
		
		private function getOnConsole(c:ABST_Console):Boolean
		{
			if (c == null)
			{
				trace("[WINGMAN] Couldn't get on a null console!");
				return false;
			}
			if (c.inUse && c.closestPlayer != this)
			{
				trace("[WINGMAN] Arrived at", c, "but it's in use!");
				state = STATE_IDLE;
				goal = GOAL_IDLE;
				return false;
			}
			if (activeConsole != null) onCancel();
			c.closestPlayer = this;
			c.onAction(this);
			trace("[WINGMAN] Getting on console:", c);
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
		
		private function getClosestOmnitool():ABST_Object
		{
			var closest:Number = 9999;
			var dist:Number;
			var tool:ABST_Object = null;
			for each (var c:ABST_Console in consoleMap["omnitool"])
			{
				dist = System.getDistance(mc_object.x, mc_object.y, c.mc_object.x, c.mc_object.y);
				if (dist < closest)
				{
					closest = dist;
					tool = c;
				}
			}
			return tool;
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
			
			switch (state)
			{
				case STATE_DOUSE:				display.tf_status.text = "Extinguishing fire";		break;
				case STATE_HEAL:				display.tf_status.text = "Healing ally";			break;
				case STATE_IDLE:				display.tf_status.text = "Waiting";					break;
				case STATE_MOVE_FREE:
				case STATE_MOVE_FROM_NETWORK:
				case STATE_MOVE_NETWORK:
					switch (goal)
					{
						case GOAL_DOUSE:		display.tf_status.text = "Extinguishing fire";		break;
						case GOAL_HEAL:			display.tf_status.text = "Healing ally";			break;
						case GOAL_IDLE:			display.tf_status.text = "Getting unstuck";			break;
						case GOAL_REBOOT:		display.tf_status.text = "Rebooting shields";		break;
						case GOAL_REVIVE:		display.tf_status.text = "Reviving ally";			break;
					}
				break;
				case STATE_REBOOT:				display.tf_status.text = "Rebooting shields";		break;
				case STATE_REVIVE:				display.tf_status.text = "Reviving ally";			break;
				case STATE_STUCK:				display.tf_status.text = "Confused";				break;
			}
		}
	}
}