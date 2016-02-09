package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import vgdev.stroll.ContainerGame;
	
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
		
		public var moveSpeed:Number = 4;
		
		/// Map of key states
		private var keysDown:Object = {UP:false, LEFT:false, RIGHT:false, DOWN:false, TIME:false};
		
		public function Player(_cg:ContainerGame, _mc_object:MovieClip, _validMCs:MovieClip, keyMap:Object)
		{
			super(_cg, _validMCs);
			mc_object = _mc_object;
			
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
			
			hitbox = mc_object.hitbox;
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
			if (keysDown[RIGHT])
				updatePosition(moveSpeed, 0);
			if (keysDown[UP])
				updatePosition(0, -moveSpeed);
			if (keysDown[LEFT])
				updatePosition(-moveSpeed, 0);
			if (keysDown[DOWN])
				updatePosition(0, moveSpeed);
		}
		
		/**
		 * Update state of keys when a key is pressed
		 * @param	e		KeyboardEvent with info
		 */
		public function downKeyboard(e:KeyboardEvent):void
		{
			trace("[" + this + "] Keyboard pressed: " + e.keyCode);
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					keysDown[RIGHT] = true;
				break;
				case KEY_UP:
					keysDown[UP] = true;
				break;
				case KEY_LEFT:
					keysDown[LEFT] = true;
				break;
				case KEY_DOWN:
					keysDown[DOWN] = true;
				break;
				case KEY_ACTION:
					keysDown[ACTION] = true;
				break;
				case KEY_CANCEL:
					keysDown[CANCEL] = true;
				break;
			}
		}
		
		/**
		 * Update state of keys when a key is released
		 * @param	e		KeyboardEvent with info
		 */
		public function upKeyboard(e:KeyboardEvent):void
		{			
			switch (e.keyCode)
			{
				case KEY_RIGHT:
					keysDown[RIGHT] = false;
				break;
				case KEY_UP:
					keysDown[UP] = false;
				break;
				case KEY_LEFT:
					keysDown[LEFT] = false;
				break;
				case KEY_DOWN:
					keysDown[DOWN] = false;
				break;
				case KEY_ACTION:
					keysDown[ACTION] = false;
				break;
				case KEY_CANCEL:
					keysDown[CANCEL] = false;
				break;
			}
		}
		
	}
}