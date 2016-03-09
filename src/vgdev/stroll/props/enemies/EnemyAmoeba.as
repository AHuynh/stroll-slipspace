package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
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
			ranges = [0, 0];
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
			return super.changeHP(amt);
		}
		
		override public function getJammingValue():int 
		{
			return 1 + amoebaSize * 2;
		}
		
		// if size is > 0, spawn 2 amoebas with size 1 less than current size
		override public function destroy():void 
		{
			SoundManager.playSFX("sfx_explosionlarge1");
			cg.addDecor("explosion_small", { "x":mc_object.x, "y":mc_object.y, "scale":4 } );
			
			if (amoebaSize > 0)
			{
				for (var i:int = 0; i < 2; i++)
				{
					cg.addToGame(new EnemyAmoeba(cg, new SWC_Enemy(), amoebaSize - 1, {
																		"x": mc_object.x + System.getRandNum(-30, 30) + System.GAME_OFFSX,
																		"y": mc_object.y + System.getRandNum( -30, 30) + System.GAME_OFFSY,
																		"knockback": System.getRandNum( -1, -.6)
																		}),
								System.M_ENEMY);
				}
			}
			
			super.destroy();
		}
	}
}