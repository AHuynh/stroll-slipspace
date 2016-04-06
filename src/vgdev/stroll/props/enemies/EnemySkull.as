package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.projectiles.ABST_EProjectile;
	import vgdev.stroll.props.projectiles.EProjectileFireball;
	import vgdev.stroll.props.projectiles.EProjectileGeneric;
	import vgdev.stroll.System;
	
	/**
	 * Enemy that likes to spit fire
	 * @author Alexander Huynh
	 */
	public class EnemySkull extends ABST_Enemy 
	{
		private var moveTgt:Point = new Point(System.getRandInt(-2, 1), System.getRandInt(-2, 1));
		private var atTgt:Boolean = false;
		
		public var projSizeMult:Number = 1;		// helper for 'fake boss' in FAILS
		
		public function EnemySkull(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["noSpawnFX"] = true;		// do it after updating position
			super(_cg, _mc_object, attributes);
			setStyle("skull");
			
			if (attributes["x"] == null)
			{
				mc_object.x = System.getRandNum( -System.GAME_HALF_WIDTH, System.GAME_HALF_WIDTH);
				mc_object.y = System.getRandNum( -System.GAME_HALF_HEIGHT, System.GAME_HALF_HEIGHT);
			}
			else
			{
				mc_object.x = attributes["x"];
				mc_object.y = attributes["y"];
			}
			var spawnFX:ABST_Object = cg.addDecor("spawn", { "x":mc_object.x, "y":mc_object.y, "rot": System.getRandNum(0, 360), "scale": mc_object.scaleX * 2 } );
			spawnFX.mc_object.base.setTint(attackColor);
			
			spd = 8;
			drift = .6;
			
			setMoveTgt();
		}
		
		/**
		 * Set the next place to move to; usually the opposite quadrant
		 */
		private function setMoveTgt():void
		{
			if (Math.random() < .35)
				moveTgt.x = moveTgt.x * -1;
			if (Math.random() < .35)
				moveTgt.y = moveTgt.y * -1;
			
			moveTgt.x = System.getRandNum(300, System.GAME_HALF_WIDTH) * -System.getSign(moveTgt.x);
			moveTgt.y = System.getRandNum(150, System.GAME_HALF_HEIGHT) * -System.getSign(moveTgt.y);
			
			atTgt = false;
			
			var dirToTgt:Number = System.getAngle(mc_object.x, mc_object.y, moveTgt.x, moveTgt.y);
			dX = System.forward(spd, dirToTgt, true);
			dY = System.forward(spd, dirToTgt, false);
		}
		
		override public function step():Boolean 
		{
			if (!completed)
			{
				updatePrevPosition();
				updatePosition(dX, dY);
				updateRotation(dR);
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateDamageFlash();				
			}
			return completed;
		}
		
		override protected function updateWeapons():void 
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- == 0)
				{
					onFire();
					// cooldown reset by updatePosition
					var proj:ABST_EProjectile = new EProjectileFireball(cg, new SWC_Bullet(),
																	{	 
																		"affiliation":	System.AFFIL_ENEMY,
																		"attackColor":	attackColor,
																		"dir":			mc_object.rotation + System.getRandNum(-5, 5),
																		"dmg":			attackStrength,
																		"life":			300,
																		"pos":			mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y)),
																		"spd":			2,
																		"style":		"fireball",
																		"scale":		projSizeMult
																	});
					cg.addToGame(proj, System.M_EPROJECTILE);
				}
			}
		}
		
		override protected function onShipHit():void 
		{
			// do nothing
		}
		
		override protected function updatePosition(dx:Number, dy:Number):void 
		{			
			var currSpd:Number = 1;
			
			if (System.getDistance(mc_object.x, mc_object.y, moveTgt.x, moveTgt.y) < 25)
			{
				if (!atTgt)		// just arrived at target
				{
					atTgt = true;
					cdCounts[0] = cooldowns[0];
				}
				else if (cdCounts[0] == 5)
					mc_object.base.gotoAndPlay("shoot");
				else if (cdCounts[0] == -1)
					setMoveTgt();
					
				if (atTgt)
				{
					updateWeapons();
					currSpd = drift / spd;
				}
			}
			mc_object.x += dX * currSpd;
			mc_object.y += dY * currSpd;
		}
		
		override protected function updateRotation(dr:Number):void 
		{
			mc_object.rotation = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x + System.getRandNum(-10, 10), cg.shipHitMask.y + System.getRandNum(-10, 10));
		}
		
		override public function destroy():void 
		{
			for (var i:int = 5 + System.getRandInt(0, 3); i >= 0; i--)
				cg.addDecor("gib_skull", {
											"x": System.getRandNum(mc_object.x - 10, mc_object.x + 10),
											"y": System.getRandNum(mc_object.y - 10, mc_object.y + 10),
											"dx": System.getRandNum( -1, 1),
											"dy": System.getRandNum( -1, 1),
											"dr": System.getRandNum( -5, 5),
											"rot": System.getRandNum(0, 360),
											"scale": System.getRandNum(1, 1.5),
											"alphaDelay": 60 + System.getRandInt(0, 20),
											"alphaDelta": 20,
											"random": true
										});
			super.destroy();
		}
	}
}