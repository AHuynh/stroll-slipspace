package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.managers.ManagerProximity;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.props.projectiles.ABST_IProjectile;
	import vgdev.stroll.props.projectiles.IProjectileGeneric;
	import vgdev.stroll.System;
	
	/**
	 * Instance of the player
	 * @author Alexander Huynh
	 */
	public class Player extends ABST_IMovable
	{
		/// Pointer to the proximity manager, so this Player can tell the manager to update
		public var manProx:ManagerProximity;
		
		// keys for use in keysDown
		private const RIGHT:int = 0;
		private const UP:int = 1;
		private const LEFT:int = 2;
		private const DOWN:int = 3;
		private const ACTION:int = 10;
		private const CANCEL:int = 11;
		
		// stored Keyboard keycodes
		private var KEY_RIGHT:uint;
		private var KEY_UP:uint;
		private var KEY_LEFT:uint;
		private var KEY_DOWN:uint;
		private var KEY_ACTION:uint;
		private var KEY_CANCEL:uint;
		
		/// Map of key states
		private var keysDown:Object = { UP:false, LEFT:false, RIGHT:false, DOWN:false, TIME:false };
		
		/// Direction player last moved in (RULD, 0-3)
		public var facing:int = 0;
		
		/// Player 0 or 1
		public var playerID:int;
		
		/// Pixels per frame this unit can move at
		public var moveSpeed:Number = 4;
		
		/// If not null, the instance of ABST_Console this Player is currently paired with
		private var activeConsole:ABST_Console = null;
		
		/// If true, the console being used prevents player movement
		private var rooted:Boolean = false;
		
		// PWD variables
		private var countPDW:int = 0;			// current PDW status
		private var cooldownPDW:int = 5;		// cooldown time in frames between PDW shots
		private var damagePDW:int = 7;
		
		private var BAR_WIDTH:Number;
		
		public function Player(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, _playerID:int, keyMap:Object)
		{
			super(_cg, _mc_object, _hitMask);
			playerID = _playerID;
			hp = hpMax = 100;
			
			KEY_RIGHT = keyMap["RIGHT"];
			KEY_UP = keyMap["UP"];
			KEY_DOWN = keyMap["DOWN"];
			KEY_LEFT = keyMap["LEFT"];
			KEY_ACTION = keyMap["ACTION"];
			KEY_CANCEL = keyMap["CANCEL"];
			
			mc_object.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * Helper to init the keyboard listener
		 * 
		 * @param	e	the captured Event, unused
		 */
		private function onAddedToStage(e:Event):void
		{
			mc_object.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			cg.stage.addEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			cg.stage.addEventListener(KeyboardEvent.KEY_UP, upKeyboard);
			
			mc_object.mc_bar.visible = false;		// hide the HP bar
			BAR_WIDTH = mc_object.mc_bar.bar.width;
			
			mc_object.mc_omnitool.visible = false;
		}
		
		/**
		 * Update the player
		 * @return		false; player will never be complete
		 */
		override public function step():Boolean
		{
			if (hp != 0)
			{
				handleKeyboard();
				if (countPDW > 0)
					countPDW--;
			}
			return false;
		}
		
		/**
		 * Revive an incapacitated player by setting its HP to something > 0
		 */
		public function revive():void
		{
			if (hp != 0) return;
			changeHP(hpMax * .4);
			mc_object.alpha = 1;
		}
		
		override public function changeHP(amt:Number):Boolean
		{
			hp = System.changeWithLimit(hp, amt, 0, hpMax);		
						
			// stop using consoles/items if incapacitated
			if (hp == 0)
			{
				onCancel();
				mc_object.gotoAndStop("idle");
				mc_object.alpha = .4;		// TODO incap sprite
			}
			
			if (hp != hpMax)
			{
				mc_object.mc_bar.visible = true;
				mc_object.mc_bar.bar.width = (hp / hpMax) * BAR_WIDTH;
			}
			else
				mc_object.mc_bar.visible = false;
				
			return hp == 0;
		}
		
		/**
		 * Update state according to keyboard state
		 */
		private function handleKeyboard():void
		{
			if (!rooted)
			{
				if (keysDown[RIGHT])
				{
					updatePosition(moveSpeed, 0);
					facing = RIGHT;
				}
				if (keysDown[UP])
				{
					updatePosition(0, -moveSpeed);
					facing = UP;
				}
				if (keysDown[LEFT])
				{
					updatePosition( -moveSpeed, 0);
					facing = LEFT;
				}
				if (keysDown[DOWN])
				{
					updatePosition(0, moveSpeed);
					facing = DOWN;
				}
				if (keysDown[CANCEL] && countPDW == 0)
				{
					handlePDW();
				}
			}
			if (activeConsole != null)
			{
				activeConsole.holdKey([keysDown[RIGHT], keysDown[UP], keysDown[LEFT], keysDown[DOWN], keysDown[ACTION]]);
			}
		}
		
		/**
		 * Fire the PDW
		 */
		private function handlePDW():void
		{
			var shot:ABST_IProjectile = new IProjectileGeneric(cg, new SWC_Bullet(), hitMask,
																	{	 
																		"affiliation":	System.AFFIL_PLAYER,
																		"dir":			facing * -90 + System.getRandNum(-2, 2),
																		"dmg":			damagePDW,
																		"life":			30,
																		"pos":			new Point(mc_object.x, mc_object.y - 20),
																		"spd":			9,
																		"style":		null,
																		"scale":		0.75
																	});
			cg.addToGame(shot, System.M_IPROJECTILE);
			countPDW = cooldownPDW;
		}
		
		// tell ManagerDepth to update all depth-managed object's depths when this Player moves
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			if (activeConsole == null)
				manProx.updateProximities(this);
			super.updatePosition(dx, dy);
		}
		
		/**
		 * Set this Player's active console to the one provided
		 * Called by ABST_Console
		 * @param	console		an ABST_Console that is not in use to be used by this Player
		 * @param	isRooted	true if the player shouldn't be able to move when using the console
		 */
		public function sitAtConsole(console:ABST_Console, isRooted:Boolean = true):void
		{
			activeConsole = console;
			rooted = isRooted;
		}
		
		/**
		 * Set this Player's active console to none, and if there was an active console, free it
		 */
		public function onCancel():void
		{
			if (activeConsole != null)
			{
				activeConsole.onCancel();
				activeConsole = null;
				rooted = false;
				manProx.updateProximities(this);
				updateDepth();
			}
		}
		
		/**
		 * Update state of keys when a key is pressed
		 * @param	e		KeyboardEvent with info
		 */
		public function downKeyboard(e:KeyboardEvent):void
		{
			if (cg.isPaused)		
			{
				if (e.keyCode == KEY_ACTION && cg.tails.isActive())		// only allow acknowledgement to go through
					cg.onAction(this);
				return;
			}
			
			if (hp == 0) return;
			
			var pressed:Boolean = false;
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					if (!rooted)
					{
						mc_object.scaleX = -1;
						mc_object.mc_bar.scaleX = -1;
						pressed = true;
					}
					else if (!keysDown[RIGHT])
					{
						activeConsole.onKey(0);
					}
					keysDown[RIGHT] = true;
				break;
				case KEY_UP:
					if (!rooted)
					{
						pressed = true;
					}
					else if (!keysDown[UP])
					{
						activeConsole.onKey(1);
					}
					keysDown[UP] = true;
				break;
				case KEY_LEFT:
					if (!rooted)
					{
						mc_object.scaleX = 1;
						mc_object.mc_bar.scaleX = 1;
						pressed = true;
					}
					else if (!keysDown[LEFT])
					{
						activeConsole.onKey(2);
					}
					keysDown[LEFT] = true;
				break;
				case KEY_DOWN:
					if (!rooted)
					{
						pressed = true;
					}
					else if (!keysDown[DOWN])
					{
						activeConsole.onKey(3);
					}
					keysDown[DOWN] = true;
				break;
				case KEY_ACTION:
					if (!rooted)
					{
						cg.onAction(this);
					}
					else if (!keysDown[ACTION])
					{
						activeConsole.onKey(4);
					}
					keysDown[ACTION] = true;
				break;
				case KEY_CANCEL:
					keysDown[CANCEL] = true;
					onCancel();
				break;
			}
			if (pressed && mc_object.currentLabel == "idle")
				mc_object.gotoAndPlay("walk");
		}
		
		/**
		 * Update state of keys when a key is released
		 * @param	e		KeyboardEvent with info
		 */
		public function upKeyboard(e:KeyboardEvent):void
		{
			if (hp == 0) return;
			
			var released:Boolean = false;
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					keysDown[RIGHT] = false;
					released = true;
				break;
				case KEY_UP:
					keysDown[UP] = false;
					released = true;
				break;
				case KEY_LEFT:
					keysDown[LEFT] = false;
					released = true;
				break;
				case KEY_DOWN:
					keysDown[DOWN] = false;
					released = true;
				break;
				case KEY_ACTION:
					keysDown[ACTION] = false;
				break;
				case KEY_CANCEL:
					keysDown[CANCEL] = false;
				break;
			}
			
			if (released && !keysDown[RIGHT] && !keysDown[UP] && !keysDown[LEFT] && !keysDown[DOWN])
				mc_object.gotoAndStop("idle");
		}
		
	}
}