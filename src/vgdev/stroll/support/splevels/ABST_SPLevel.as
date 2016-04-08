package vgdev.stroll.support.splevels 
{
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.*;
	import vgdev.stroll.props.enemies.BoarderAssassin;
	import vgdev.stroll.props.enemies.BoarderSuicider;
	import vgdev.stroll.props.enemies.BoarderWanderer;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	/**
	 * Provides functionality for a slipspace sector that requires code logic
	 * @author Alexander Huynh
	 */
	public class ABST_SPLevel 
	{
		protected var cg:ContainerGame;
		protected var framesElapsed:int = 0;
		
		public function ABST_SPLevel(_cg:ContainerGame) 
		{
			cg = _cg;
		}
		
		public function step():void
		{
			framesElapsed++;
			// -- override this function
		}
		
		public function destroy():void
		{
			// -- override this function
		}

		/**
		 * Spawn some enemy
		 * @param	type		Name of enemy
		 * @param	amt			Amount of enemies
		 * @param	region		Region names to pick from
		 * @param	params		Spawn parameters
		 */
		protected function spawnEnemy(type:String, amt:int, region:Array = null, params:Object = null):void
		{
			if (region == null) region = System.SPAWN_STD;
			if (params == null) params = { };
			var p:Point;
			for (var i:int = 0; i < amt; i++)
			{
				if (params["x"] != null && params["y"] != null)
					p = new Point(params["x"], params["y"]);
				else
					p = cg.level.getRandomPointInRegion(System.getRandFrom(region));
				p.x += System.GAME_OFFSX;
				p.y += System.GAME_OFFSY;
				cg.level.spawn(params, p, type);
			}
		}
		
		/**
		 * Add shards of FAILS randomly around the ship
		 * @param	num		Number of shards to add
		 */
		protected function addShards(num:int):void
		{
			for (var i:int = 0; i < num; i++)
			{
				var bpt:Point = cg.getRandomShipLocation();
				cg.addToGame(new BoarderWanderer(cg, new SWC_Enemy(), cg.shipInsideMask, {"x": bpt.x, "y": bpt.y}), System.M_BOARDER);
			}
		}
		
		/**
		 * Add suiciders randomly around the ship
		 * @param	num		Number of shards to add
		 */
		protected function addSuiciders(num:int):void
		{
			for (var i:int = 0; i < num; i++)
			{
				var bpt:Point = cg.getRandomShipLocation();
				cg.addToGame(new BoarderSuicider(cg, new SWC_Enemy(), cg.shipInsideMask, {"x": bpt.x, "y": bpt.y}), System.M_BOARDER);
			}
		}
		
		/**
		 * Add addAssassins randomly around the ship
		 * @param	num		Number of shards to add
		 */
		protected function addAssassins(num:int):void
		{
			for (var i:int = 0; i < num; i++)
			{
				var bpt:Point = cg.getRandomShipLocation();
				cg.addToGame(new BoarderAssassin(cg, new SWC_Enemy(), cg.shipInsideMask, {"x": bpt.x, "y": bpt.y}), System.M_BOARDER);
			}
		}

		protected function fakeJump():void
		{
			cg.background.setRandomStyle(int(cg.level.sectorIndex / 5), System.getRandCol());
			cg.playJumpEffect();
		}

		/**
		 * 	Pick a random uncorrupted console and perform some harmful effect
		 */
		protected function messWithConsole():void
		{
			var choices:Array = [];
			for each (var c:ABST_Console in cg.consoles)
				if (!c.corrupted)
				{
					if (c is Omnitool && c.closestPlayer != null) continue;
					choices.push(c);
				}
			if (choices.length == 0) return;
			var console:ABST_Console = System.getRandFrom(choices);
			
			if (console.closestPlayer != null)
				cg.hudConsoles[console.closestPlayer.playerID].mc_taunt.taunt();
			
			if (console is ConsoleNavigation)
			{
				cg.tails.show("Navigation? How about FIRE instead?!", System.TAILS_NORMAL, "FAILS_talk");
				cg.addFireAt(new Point(console.mc_object.x, console.mc_object.y));
			}
			else if (console is Omnitool)
			{
				cg.tails.show("Your extinguisher is now ON FIRE! THE IRONY!", System.TAILS_NORMAL, "FAILS_talk");
				cg.addFireAt(new Point(console.mc_object.x, console.mc_object.y));
			}
			else if (console is ConsoleSensors)
			{
				cg.tails.show("Hope you didn't need to see, MORONS!", System.TAILS_NORMAL, "FAILS_talk");
				(console as ConsoleSensors).corrupt(System.SECOND * 9);
			}
			else if (console is ConsoleShieldRe)
			{
				cg.tails.show("Was that the ON/OFF for shields? NOT SORRY!", System.TAILS_NORMAL, "FAILS_talk");
				cg.ship.setShieldsEnabled(false);
				cg.ship.setShieldsEnabled(true);
			}
			else if (console is ConsoleShields)
			{
				cg.tails.show("Colored shields are SO overrated! OFF IT GOES!", System.TAILS_NORMAL, "FAILS_talk");
				(console as ConsoleShields).disableConsole();
			}
			else if (console is ConsoleSlipdrive)
			{
				cg.tails.show("How about a CHANGE IN SCENERY?! JUMP JUMP JUMP!", System.TAILS_NORMAL, "FAILS_talk");
				fakeJump();
				spawnEnemy(System.getRandFrom(["Eye", "Skull", "Slime", "Amoeba"]), System.getRandInt(2, 4));
			}
			else if (console is ConsoleTurret)
			{
				cg.tails.show("Only I'M allowed to be violent! NO GUN FOR YOU!", System.TAILS_NORMAL, "FAILS_talk");
				(console as ConsoleTurret).setActiveCooldown(System.SECOND * 10);
			}
			cg.addSparksAt(2, new Point(console.mc_object.x, console.mc_object.y));
			SoundManager.playSFX("sfx_electricShock", .25);
		}
	}
}