package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.System;
	
	/**
	 * Instance of the player
	 * @author Alexander Huynh
	 */
	public class Player extends ABST_IMovable
	{
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
		
		/// Player 0 or 1
		public var playerID:int;
		
		/// Pixels per frame this unit can move at
		public var moveSpeed:Number = 4;
		
		/// If not null, the instance of ABST_Console this Player is currently paired with
		private var activeConsole:ABST_Console = null;
		
		/// Map of key states
		private var keysDown:Object = {UP:false, LEFT:false, RIGHT:false, DOWN:false, TIME:false};
		
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
		}
		
		/**
		 * Update the player
		 * @return		true if the player is dead
		 */
		override public function step():Boolean
		{
			if (hp != 0)
			{
				handleKeyboard();
			}
			return completed;
		}
		
		override public function changeHP(amt:Number):Boolean
		{
			hp = System.changeWithLimit(hp, amt, 0, hpMax);
			// code omitted here - don't remove object
			mc_object.alpha = .4;
			return hp == 0;
		}
		
		/**
		 * Update state according to keyboard state
		 */
		private function handleKeyboard():void
		{
			if (activeConsole == null)
			{
				if (keysDown[RIGHT])
				{
					updatePosition(moveSpeed, 0);
				}
				if (keysDown[UP])
				{
					updatePosition(0, -moveSpeed);
				}
				if (keysDown[LEFT])
				{
					updatePosition( -moveSpeed, 0);
				}
				if (keysDown[DOWN])
				{
					updatePosition(0, moveSpeed);
				}
			}
			else
			{
				activeConsole.holdKey([keysDown[RIGHT], keysDown[UP], keysDown[LEFT], keysDown[DOWN], keysDown[ACTION]]);
			}
		}
		
		/**
		 * Set this Player's active console to the one provided
		 * @param	console		an ABST_Console that is not in use to be used by this Player
		 */
		public function sitAtConsole(console:ABST_Console):void
		{
			activeConsole = console;
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
			}
		}
		
		/**
		 * Update state of keys when a key is pressed
		 * @param	e		KeyboardEvent with info
		 */
		public function downKeyboard(e:KeyboardEvent):void
		{
			if (hp == 0) return;
			
			var pressed:Boolean = false;
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					if (activeConsole == null)
					{
						mc_object.scaleX = -1;
						pressed = true;
					}
					else if (!keysDown[RIGHT])
					{
						activeConsole.onKey(0);
					}
					keysDown[RIGHT] = true;
				break;
				case KEY_UP:
					if (activeConsole == null)
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
					if (activeConsole == null)
					{
						mc_object.scaleX = 1;
						pressed = true;
					}
					else if (!keysDown[LEFT])
					{
						activeConsole.onKey(2);
					}
					keysDown[LEFT] = true;
				break;
				case KEY_DOWN:
					if (activeConsole == null)
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
					if (activeConsole == null)
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