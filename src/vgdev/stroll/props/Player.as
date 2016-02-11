package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	
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
		
		private var KEY_RIGHT:uint;
		private var KEY_UP:uint;
		private var KEY_LEFT:uint;
		private var KEY_DOWN:uint;
		private var KEY_ACTION:uint;
		private var KEY_CANCEL:uint;
		
		public var playerID:int;
		public var moveSpeed:Number = 4;
		
		private var activeConsole:ABST_Console = null;
		
		/// Map of key states
		private var keysDown:Object = {UP:false, LEFT:false, RIGHT:false, DOWN:false, TIME:false};
		
		public function Player(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, _playerID:int, keyMap:Object)
		{
			super(_cg, _mc_object, _hitMask);
			playerID = _playerID;
			
			KEY_RIGHT = keyMap["RIGHT"];
			KEY_UP = keyMap["UP"];
			KEY_LEFT = keyMap["LEFT"];
			KEY_DOWN = keyMap["DOWN"];
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
			handleKeyboard();
			return completed;
		}
		
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

		public function sitAtConsole(console:ABST_Console):void
		{
			activeConsole = console;
		}
		
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
			var pressed:Boolean = false;
			
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					keysDown[RIGHT] = true;
					if (activeConsole == null)
					{
						mc_object.scaleX = -1;
						pressed = true;
					}
					else
					{
						activeConsole.onKey(0);
					}
				break;
				case KEY_UP:
					keysDown[UP] = true;
					if (activeConsole == null)
					{
						pressed = true;
					}
					else
					{
						activeConsole.onKey(1);
					}
				break;
				case KEY_LEFT:
					keysDown[LEFT] = true;
					if (activeConsole == null)
					{
						mc_object.scaleX = 1;
						pressed = true;
					}
					else
					{
						activeConsole.onKey(2);
					}
				break;
				case KEY_DOWN:
					keysDown[DOWN] = true;
					if (activeConsole == null)
					{
						pressed = true;
					}
					else
					{
						activeConsole.onKey(3);
					}
				break;
				case KEY_ACTION:
					keysDown[ACTION] = true;
					if (activeConsole == null)
					{
						cg.onAction(this);
					}
					else
					{
						activeConsole.onKey(4);
					}
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