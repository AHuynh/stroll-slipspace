package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.consoles.ConsoleNavigation;
	import vgdev.stroll.props.consoles.ConsoleShieldRe;
	import vgdev.stroll.props.consoles.ConsoleShields;
	import vgdev.stroll.props.consoles.ConsoleSlipdrive;
	import vgdev.stroll.props.consoles.ConsoleTurret;
	import vgdev.stroll.props.consoles.Omnitool;
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
		
		private var goal:int;
		private const GOAL_IDLE:int = enum++;
		private const GOAL_REVIVE:int = enum++;
		
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
		
		private var consoleMap:Object = { };
		private var keyMap:Object;
		private var acknowledgeTails:Boolean = false;
		private var setup:Boolean = true;
		
		private var chooseStateCooldown:int = 0;
		private const CHOOSE_CD:int = 30;
		
		private var prevPoint:Point;
		private var ignoreStuck:Boolean = true;
		private var stuckCounter:int = 0;
		private const STUCK_MAX:int = 15;
		
		private var display:MovieClip;
		
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
				
			if (!ignoreStuck && state != STATE_IDLE)
			{
				if (mc_object.x == prevPoint.x && mc_object.y == prevPoint.y)
				{
					if (++stuckCounter == STUCK_MAX)
					{
						state = STATE_STUCK;
						goal = GOAL_IDLE;
						trace("[WINGMAN] Stuck! Trying to get unstuck!");
						releaseAllKeys();
						chooseState();
					}
				}
				else
				{
					prevPoint = new Point(mc_object.x, mc_object.y);
					stuckCounter = 0;
				}
			}
			
			switch (state)
			{
				case STATE_IDLE:
					if (chooseStateCooldown > 0)
					{
						chooseStateCooldown--;
						break;
					}
					chooseState();
				break;
				case STATE_REVIVE:
					if (otherPlayer.getHP() > 0)
						chooseState();
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
		 * Set the POI and start using the network
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
		 * Determine the next thing to do
		 */
		private function chooseState():void
		{
			chooseStateCooldown = CHOOSE_CD;
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
					objectOfInterest = getClosestOmnitool();
					setPOI(new Point(objectOfInterest.mc_object.x, objectOfInterest.mc_object.y));
					trace("[WINGMAN] Heading to pick up Omnitool.");
				}
			}
			else
			{
				if (state != STATE_IDLE)
				{
					releaseAllKeys();
					trace("[WINGMAN] Doing nothing.");
				}
				if (activeConsole)
					onCancel();
				goal = GOAL_IDLE;
				state = STATE_IDLE;
				moveSpeedX = moveSpeedY = NORMAL_SPEED;
			}			
		}
		
		/**
		 * Determine what to do once at the destination
		 */
		private function onArrive():void
		{
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
				default:
					state = STATE_IDLE;
					goal = GOAL_IDLE;
					trace("[WINGMAN] Arrived at destination but couldn't figure out what to do.");
			}
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
		}
	}
}