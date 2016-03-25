package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Long-range passive enemy that spawns rammables
	 * @author Alexander Huynh
	 */
	public class EnemyBreeder extends ABST_Enemy 
	{
		private const HEAL:Number = 0.2;		// amount to heal per frame
		
		public function EnemyBreeder(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			setStyle("breeder");
			mc_object.scaleX = Math.random() > .5 ? 1 : -1;
			mc_object.scaleY = Math.random() > .5 ? 1 : -1;
			
			dR = System.getRandNum( -2, 2);
			
			cdCounts = [60, 100, 150];
			cooldowns = [System.getRandInt(90, 120), System.getRandInt(110, 130), System.getRandInt(160, 200)];
		}
		
		override public function getJammingValue():int
		{
			return 3;
		}
		
		override public function step():Boolean
		{
			if (!completed)
			{
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateRotation(dR);
				updateWeapons();		
				updateDamageFlash();				
				changeHP(HEAL);
			}
			return completed;
		}
		
		override protected function updateWeapons():void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					var spawn:Point = mc_object.localToGlobal(new Point(mc_object.spawn.x, mc_object.spawn.y))
					var atkAngle:Number = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x + System.getRandNum( -40, 40), cg.shipHitMask.y + System.getRandNum( -30, 30));
					var mult:Number = System.getRandNum(.6, 1.5);
					var proj:EnemyRammable = new EnemyRammable(cg, new SWC_Enemy(),
																	{
																		"collideColor":	attackColor,
																		"hp":			System.getRandInt(4, 12),
																		"attackCollide":attackStrength * mult,
																		"scale":		mult,
																		"x":			spawn.x + System.getRandNum( -40, 40),
																		"y":			spawn.y + System.getRandNum( -40, 40),
																		"atkDir":		atkAngle,
																		"dr":			System.getRandNum(-2, 2),
																		"spd":			System.getRandNum(0.7, 1.1),
																		"style":		"glob",
																		"random":		true
																	});
					cg.addToGame(proj, System.M_ENEMY);
				}
			}
		}
		
		override public function destroy():void 
		{
			/*for (var i:int = 5 + System.getRandInt(0, 3); i >= 0; i--)
				cg.addDecor("gib_slime", {
											"x": System.getRandNum(mc_object.x - 20, mc_object.x + 20),
											"y": System.getRandNum(mc_object.y - 20, mc_object.y + 20),
											"dx": System.getRandNum( -2, 2),
											"dy": System.getRandNum( -2, 2),
											"dr": System.getRandNum( -11, 11),
											"rot": System.getRandNum(0, 360),
											"alphaDelay": 70 + System.getRandInt(0, 20),
											"alphaDelta": 30,
											"random": true
										});*/
			super.destroy();
		}
	}
}