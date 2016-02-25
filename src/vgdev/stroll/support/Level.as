package vgdev.stroll.support 
{
	import flash.geom.Point;	
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.*;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Support functionality related to the level
	 * @author Alexander Huynh
	 */
	public class Level 
	{
		private var cg:ContainerGame;
		private var timeline:int = 0;
		
		[Embed(source = "../../../../json/en_test.json", mimeType = "application/octet-stream")]
		private var en_test:Class;
		[Embed(source="../../../../json/en_test2.json", mimeType="application/octet-stream")]
		private var en_test2:Class;
		
		/// A map of level names (ex: "test") to level objects
		private var parsedEncounters:Object;
		
		/// The current difficulty rating, used to determine from which encounters to choose from
		private var difficultyLevel:int = 0;
		
		private var waves:Array;			// array of wave Objects, each containing a "time" to spawn and
											//    a list of objects to spawn, "spawnables"
		private var waveIndex:int;			// current wave in waves

		private var counter:int = 0;		// keep track of frames elapsed since current encounter started
		private var counterNext:int = 0;	// the "time" that the next wave spawns
		
		public function Level(_cg:ContainerGame)
		{
			cg = _cg;
			
			parsedEncounters = new Object();
			
			// add levels here
			var rawEncountersJSON:Array =	[	
												JSON.parse(new en_test()),
												JSON.parse(new en_test2())
											];
			
			// parse all the encounters and save them
			for each (var rawEncounter:Object in rawEncountersJSON)
			{
				var parsedEncounter:Object = new Object();
				
				parsedEncounter["id"] = rawEncounter["settings"]["id"];
				parsedEncounter["slip_range"] = rawEncounter["settings"]["slip_range"];
				parsedEncounter["jamming_min"] = rawEncounter["settings"]["jamming_min"];
				parsedEncounter["difficulty_min"] = rawEncounter["settings"]["difficulty_range"][0];
				parsedEncounter["difficulty_max"] = rawEncounter["settings"]["difficulty_range"][1];
				
				// set up object waves
				parsedEncounter["spawnables"] = [];
				for each (var waveJSON:Object in rawEncounter["waves"])
				{
					var waveObj:Object = new Object();
					waveObj["time"] = waveJSON["time"];
					waveObj["spawnables"] = waveJSON["spawnables"];
					parsedEncounter["spawnables"].push(waveObj);
				}
			
				parsedEncounters[parsedEncounter["id"]] = parsedEncounter;
			}
		}
	
		/**
		 * Handle the spawning of objects in the current encounter
		 */
		public function step():void
		{
			// quit if there are no more things happening
			if (waves == null || waveIndex == waves.length)
				return;
			
			// if we're at the next time to spawn things
			if (++counter == counterNext)
			{				
				// iterate over things to spawn
				for each (var spawnItem:Object in waves[waveIndex]["spawnables"])
				{
					var type:String = spawnItem["type"];
					var pos:Point = new Point(spawnItem["x"], spawnItem["y"]);
					var col:uint = System.stringToCol(spawnItem["color"]);

					var spawn:ABST_Object;
					var manager:int;
					switch (type)
					{
						case "Eye":
							spawn = new EnemyGeneric(cg, new SWC_Enemy(), pos, { "attackColor": col } );
							manager = System.M_ENEMY;
						break;
					}
					
					cg.addToGame(spawn, manager);
				}
				if (++waveIndex < waves.length)
					counterNext = waves[waveIndex]["time"];		// prepare to spawn the next wave
			}

			/*switch (timeline)
			{
				case 1:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(200, 200), {"attackColor":System.COL_RED}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(180, 190), {"attackColor":System.COL_RED}), System.M_ENEMY);
				break;
				case 2:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-100, -250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(100, -250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-100, 250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(100, 250), {"attackColor":System.COL_BLUE}), System.M_ENEMY);
				break;
				case 3:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(300, -320), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(330, -300), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(360, -340), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(360, -240), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(380, -250), {"attackColor":System.COL_GREEN}), System.M_ENEMY);
					cg.ship.jammable = 3;
				break;
				case 4:
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-400, 320), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-330, 300), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-460, 340), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-520, 240), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-380, 250), {"attackColor":System.COL_YELLOW}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(-120, 230), {"attackColor":System.COL_RED}), System.M_ENEMY);
					cg.addToGame(new EnemyGeneric(cg, new SWC_Enemy(), new Point(120, 270), {"attackColor":System.COL_RED}), System.M_ENEMY);
				break;
				case 4:
					var e:ABST_Enemy = new EnemyColorSwapper(cg, new SWC_Enemy, new Point(500, System.getRandNum(-100, 100)), {"attackColor":System.getRandCol(), "attackStrength":10, "hp":300});
					e.setScale(2);
					cg.addToGame(e, System.M_ENEMY);
					cg.ship.jammable = 1;
				break;
			}*/
		}

		/**
		 * Load the next wave (encounter)
		 * @param	addDiff		amount of difficulty to add to the ongoing difficulty counter
		 * @return				true if this was the last wave in the game
		 */
		public function nextWave(addDiff:int = 1):Boolean
		{
			difficultyLevel += addDiff;
			var choices:Array = [];
			for each (var e:Object in parsedEncounters)
			{
				if (!System.outOfBounds(difficultyLevel, e["difficulty_min"], e["difficulty_max"]))
					choices.push(e);
			}
			
			if (choices.length == 0)		// TODO something when there are no valid encounters
				return false;
			
			var encounter:Object = choices[int(System.getRandInt(0, choices.length - 1))];
			trace("Starting encounter called: '" + encounter["id"] + "'");
			
			waves = encounter["spawnables"];
			
			waveIndex = 0;
			counterNext = waves[0]["time"];
			
			cg.ship.slipRange = encounter["slip_range"];
			cg.ship.jammable = encounter["jamming_min"];

			counter = 0;			
			
			return difficultyLevel > 5;
		}
	}
}