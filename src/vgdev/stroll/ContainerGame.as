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

		private var players:Array;
		
		private var keyMap0:Object = { "RIGHT":Keyboard.RIGHT,	"UP":Keyboard.UP,
									   "LEFT":Keyboard.LEFT,	"DOWN":Keyboard.DOWN,
									   "ACCEPT":Keyboard.COMMA, "CANCEL":Keyboard.PERIOD };
		private var keyMap1:Object = { "RIGHT":Keyboard.D,		"UP":Keyboard.W,
									   "LEFT":Keyboard.A,		"DOWN":Keyboard.S,
									   "ACCEPT":Keyboard.Z, 	"CANCEL":Keyboard.X };
		
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
			
			players = [new Player(this, game.mc_ship.mc_player0, game.mc_ship.mc_interior_hit0, keyMap0),
					   new Player(this, game.mc_ship.mc_player1, game.mc_ship.mc_interior_hit0, keyMap1)];
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
		
		/**
		 * Called by Engine every frame to update the game
		 * @return		completed, true if this container is done
		 */
		override public function step():Boolean
		{			
			var i:int;
			for (i = 0; i < 2; i++)
				players[i].step();
			
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
