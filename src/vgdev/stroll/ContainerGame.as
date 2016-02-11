package vgdev.stroll
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import vgdev.stroll.props.Console;
	import vgdev.stroll.props.Player;
	
	/**
	 * Primary game container and controller
	 * 
	 * @author Alexander Huynh
	 */
	public class ContainerGame extends ABST_Container
	{		
		public var engine:Engine;		// the game's Engine
		public var game:SWC_Game;		// the Game SWC, containing all the base assets

		public var players:Array;
		private var keyMap0:Object = { "RIGHT":Keyboard.RIGHT,	"UP":Keyboard.UP,
									   "LEFT":Keyboard.LEFT,	"DOWN":Keyboard.DOWN,
									   "ACTION":Keyboard.COMMA, "CANCEL":Keyboard.PERIOD };
		private var keyMap1:Object = { "RIGHT":Keyboard.D,		"UP":Keyboard.W,
									   "LEFT":Keyboard.A,		"DOWN":Keyboard.S,
									   "ACTION":Keyboard.Z, 	"CANCEL":Keyboard.X };
									   
		public var consoles:Array;
		
		/**
		 * A MovieClip containing all of a Stroll level
		 * @param	eng			A reference to the Engine
		 */
		public function ContainerGame(eng:Engine)
		{
			super();
			engine = eng;
			
			game = new SWC_Game();
			addChild(game);
			
			game.mc_bg.gotoAndStop("space");
			//engine.stage.addEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			
			game.mc_ship.mc_interior_hit0.visible = false;
			
			players = [new Player(this, game.mc_ship.mc_player0, game.mc_ship.mc_interior_hit0, 0, keyMap0),
					   new Player(this, game.mc_ship.mc_player1, game.mc_ship.mc_interior_hit0, 1, keyMap1)];
					   
			consoles = [];
			var console:Console;
			for (var i:int = 0; i < game.mc_ship.mc_consoleGroup.numChildren; i++)
			{
				consoles.push(new Console(this, game.mc_ship.mc_consoleGroup.getChildAt(i), players));
			}
		}

		/**
		 * Callback when a key is pressed; i.e. a key goes from NOT PRESSED to PRESSED
		 * @param	e		the associated KeyboardEvent; use e.keyCode
		 */
		private function downKeyboard(e:KeyboardEvent):void
		{			
			switch (e.keyCode)
			{
			}
		}
		
		public function onAction(p:Player):void
		{
			trace("[GAME] Checking action for player", p);
			for (var i:int = 0; i < consoles.length; i++)
				consoles[i].onAction(p);
		}
		
		/**
		 * Called by Engine every frame to update the game
		 * @return		completed, true if this container is done
		 */
		override public function step():Boolean
		{			
			var i:int;
			for (i = 0; i < 2; i++)
				players[i].step();
			for (i = 0; i < consoles.length; i++)
				consoles[i].step();
			
			return completed;			// return the state of the container (if true, it is done)
		}

		/**
		 * Clean-up code
		 * @param	e	the captured Event, unused
		 */
		protected function destroy(e:Event):void
		{			
			if (engine.stage.hasEventListener(KeyboardEvent.KEY_DOWN))
				engine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, downKeyboard);
			
			if (game != null && contains(game))
				removeChild(game);
			game = null;

			engine = null;
		}
	}
}
