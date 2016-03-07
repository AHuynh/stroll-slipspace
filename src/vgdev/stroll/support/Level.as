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
		[Embed(source = "../../../../json/en_fire_lite.json", mimeType = "application/octet-stream")]
		private var en_fire_lite:Class;
		[Embed(source="../../../../json/en_fire_eyes.json", mimeType="application/octet-stream")]
		private var en_fire_eyes:Class;
		[Embed(source="../../../../json/en_testSurvive.json", mimeType="application/octet-stream")]
		private var en_testSurvive:Class;
		
		/// A map of level names (ex: "test") to level objects
		private var parsedEncounters:Object;
		
		/// The current sector, [0-12]
		private var sectorIndex:int = 0;
		
		private var waves:Array;			// array of wave Objects, each containing a "time" to spawn and
											//    a list of objects to spawn, "spawnables"
		private var waveIndex:int;			// current wave in waves

		private var counter:int = 0;		// keep track of frames elapsed since current encounter started
		private var counterNext:int = 0;	// the "time" that the next wave spawns
		
		private var TAILSmessage:String;
		
		public function Level(_cg:ContainerGame)
		{
			cg = _cg;
			
			parsedEncounters = new Object();
			
			// add levels here
			var rawEncountersJSON:Array =	[	
												JSON.parse(new en_test()),
												JSON.parse(new en_test2()),
												JSON.parse(new en_fire_lite()),
												JSON.parse(new en_fire_eyes()),
												JSON.parse(new en_testSurvive())
											];
											
											// DEBUGGING A SINGLE ENCOUNTER ONLY
											//rawEncountersJSON = [JSON.parse(new en_testSurvive())];
			
			// parse all the encounters and save them
			for each (var rawEncounter:Object in rawEncountersJSON)
			{
				var parsedEncounter:Object = new Object();
				
				parsedEncounter["id"] = rawEncounter["settings"]["id"];
				parsedEncounter["slip_range"] = rawEncounter["settings"]["slip_range"];
				parsedEncounter["jamming_min"] = rawEncounter["settings"]["jamming_min"];
				parsedEncounter["difficulty_min"] = rawEncounter["settings"]["difficulty_range"][0];
				parsedEncounter["difficulty_max"] = rawEncounter["settings"]["difficulty_range"][1];
				parsedEncounter["TAILS"] = rawEncounter["settings"]["TAILS"];
				
				// set up object waves
				parsedEncounter["spawnables"] = [];
				for each (var waveJSON:Object in rawEncounter["waves"])
				{
					var waveObj:Object = new Object();
					waveObj["time"] = waveJSON["time"];
					waveObj["spawnables"] = waveJSON["spawnables"];
					if (waveJSON["recur"] != null)
						waveObj["recur"] = waveJSON["recur"];
					if (waveJSON["repeat"] != null)
						waveObj["repeat"] = waveJSON["repeat"];
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
			if (++counter >= counterNext)
			{				
				var repeat:int = waves[waveIndex]["repeat"] == null ? 1 : waves[waveIndex]["repeat"];
				var waveColor:uint = System.getRandCol();
				for (var r:int = 0; r < repeat; r++)
				{
					// iterate over things to spawn
					for each (var spawnItem:Object in waves[waveIndex]["spawnables"])
					{
						var type:String = spawnItem["type"];
						var pos:Point = new Point(spawnItem["x"] + System.GAME_OFFSX, spawnItem["y"] + System.GAME_OFFSY);
						var col:uint = System.stringToCol(spawnItem["color"]);

						var spawn:ABST_Object;
						var manager:int;
						switch (type)
						{
							case "Eye":
								spawn = new EnemyEyeball(cg, new SWC_Enemy(), {
																				"x":pos.x,
																				"y":pos.y,
																				"attackColor": col,
																				"hp": 30
																				});
								manager = System.M_ENEMY;
							break;
							case "GeometricAnomaly":
								spawn = new EnemyGeometricAnomaly(cg, new SWC_Enemy(), {
																						"x": System.getRandNum(0, 100) + System.GAME_WIDTH + System.GAME_OFFSX,
																						"y": System.getRandNum( -System.GAME_HALF_HEIGHT, System.GAME_HALF_HEIGHT) + System.GAME_OFFSY,
																						"tint": waveColor,
																						"dx": -3 - System.getRandNum(0, 1),
																						"hp": 12
																						});
								manager = System.M_ENEMY;
							break;
							
						case "Fire":
								pos.x -= System.GAME_OFFSX;
								pos.y -= System.GAME_OFFSY;
								spawn = new InternalFire(cg, new SWC_Decor(), pos, cg.shipInsideMask);
								manager = System.M_FIRE;
							break;
						}
						cg.addToGame(spawn, manager);					
					}
				}
				if (waves[waveIndex]["recur"] != null)			// redo the current wave if "recur" exists
					counterNext = waves[waveIndex]["recur"];
				else if (++waveIndex < waves.length)
					counterNext = waves[waveIndex]["time"];		// prepare to spawn the next wave
				counter = 0;
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
		 * Load the next sector (encounter)
		 * @return			true if this was the last sector in the game
		 */
		public function nextSector():Boolean
		{
			sectorIndex++;
			var choices:Array = [];
			for each (var e:Object in parsedEncounters)
			{
				if (!System.outOfBounds(sectorIndex, e["difficulty_min"], e["difficulty_max"]))
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
			TAILSmessage = encounter["TAILS"];

			counter = 0;					// reset time elapsed in this encounter		
			
			// update progress meter
			cg.gui.mc_progress.setSectorProgress(sectorIndex);
			
			return sectorIndex > 12;		// TODO end state
		}
		
		public function getTAILS():String
		{
			return TAILSmessage;
		}
	}
}