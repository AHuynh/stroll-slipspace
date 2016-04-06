package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	/**
	 * Kamikaze enemy that splits into smaller versions of itself upon death
	 * @author Alexander Huynh
	 */
	public class EnemyAmoeba extends ABST_Enemy 
	{
		/// 0 is smallest size
		private var amoebaSize:int;
		
		/// direction to move towards (the ship)
		private var rot:Number;
		
		/// max speed to move towards the ship at
		private var spdMax:Number;
		
		/// rate to increase spd per frame
		private const D_SPD:Number = .02;
		private const MIN_SPEED:Number = -1;
		
		public function EnemyAmoeba(_cg:ContainerGame, _mc_object:MovieClip, _amoebaSize:int, attributes:Object) 
		{
			attackColor = System.COL_GREEN;
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("amoeba");
			amoebaSize = _amoebaSize
			
			setScale(.5 + amoebaSize * .25);
			mc_object.scaleX *= Math.random() > .5 ? 1 : -1;	// randomly mirror the sprite
			mc_object.scaleY *= Math.random() > .5 ? 1 : -1;
			
			attackCollide = (amoebaSize + 1) * 15;
			hp = hpMax = 10 + 30 * amoebaSize;

			dR = System.getRandNum(-1, 1);						// lazily rotate
			
			// no weapons
			cdCounts = [];
			cooldowns = [];
			
			// ram the ship
			rangeVary = 0;
			orbitX = 0;
			orbitY = 0;
			
			spd = drift = System.setAttribute("knockback", attributes, 0.1);		// make the amoeba move away at first if it was spawned
			
			spdMax = Math.max(1.5 - .3 * amoebaSize, 0.5);
			rot = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x + System.getRandNum( -100, 100),
															cg.shipHitMask.y + System.getRandNum( -100, 100));
		}

		// move and accelerate towards the ship
		override public function step():Boolean
		{
			if (!completed)
			{
				updatePrevPosition();
				spd = System.changeWithLimit(spd, D_SPD, MIN_SPEED, spdMax);
				updatePosition(System.forward(spd, rot, true), System.forward(spd, rot, false));
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateRotation(dR);	
				updateDamageFlash();				
			}
			return completed;
		}
		
		// slow/push the amoeba upon hit
		override public function changeHP(amt:Number):Boolean 
		{
			spd = Math.max(spd - 0.5, MIN_SPEED);
			if (Math.random() < .3)
				addGib();
			return super.changeHP(amt);
		}
		
		override public function getJammingValue():int 
		{
			return 1 + amoebaSize * 2;
		}
		
		// if size is > 0, spawn 2 amoebas with size 1 less than current size
		override public function destroy():void 
		{
			SoundManager.playSFX("sfx_explosionlarge1", 0.3);
			var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "scale":1 } );
			spawnFX.mc_object.base.setTint(System.COL_ORANGE);
			var i:int;
			
			if (amoebaSize > 0)
			{
				for (i = 0; i < 2; i++)
				{
					cg.addToGame(new EnemyAmoeba(cg, new SWC_Enemy(), amoebaSize - 1, {
																		"x": mc_object.x + System.getRandNum(-30, 30) + System.GAME_OFFSX,
																		"y": mc_object.y + System.getRandNum( -30, 30) + System.GAME_OFFSY,
																		"knockback": System.getRandNum( -1, -.6),
																		"noSpawnFX": true
																		}),
								System.M_ENEMY);
				}
			}

			for (i = 3 + System.getRandInt(0, amoebaSize); i >= 0; i--)
				addGib();
			
			super.destroy();
		}
		
		private function addGib():void
		{
			cg.addDecor("gib_amoeba", {
									"x": System.getRandNum(mc_object.x - 20, mc_object.x + 20),
									"y": System.getRandNum(mc_object.y - 20, mc_object.y + 20),
									"dx": System.getRandNum( -0.5, 0.5),
									"dy": System.getRandNum( -0.5, 0.5),
									"dr": System.getRandNum( -9, 9),
									"rot": System.getRandNum(0, 360),
									"scale": mc_object.scaleX,
									"alphaDelay": 40 + System.getRandInt(0, 70),
									"alphaDelta": 20,
									"random": true
								});
		}
	}
}