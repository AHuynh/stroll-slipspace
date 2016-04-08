package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Enemy that generates a cloud and hides in it
	 * @author Alexander Huynh
	 */
	public class EnemySpider extends ABST_Enemy 
	{
		private var cloudCounter:int;
		
		private var tgt:Point;
		private var anchor:Point;
		private const ANCHOR_COUNTER:int = 60;
		private var anchorCounter:int = ANCHOR_COUNTER;
		
		private const RANGE:Number = 10;
		
		private var mult:Number = 1;
		
		public function EnemySpider(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			setStyle("spider");
			mult = System.getRandNum(0.25, 1);
			setScale(mult);
			attackStrength *= mult;
			hpMax *= mult;
			hp = hpMax;
			
			cloudCounter = System.getRandInt(1, 2);		// shots until a cloud is generated
			cdCounts = [190];
			cooldowns = [System.getRandInt(90, 120)];
			
			spd = 4;
									
			anchor = new Point(mc_object.x, mc_object.y);
			tgt = anchor.clone();

			mc_object.rotation = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
			spawnClouds();
		}
		
		// move around in the cloud
		override protected function maintainRange():void
		{		
			if (--anchorCounter <= 0)
			{
				anchorCounter = ANCHOR_COUNTER;
				tgt = new Point(anchor.x + System.getRandNum( -50, 50), anchor.y + System.getRandNum( -50, 50));
			}
			
			if (System.getDistance(mc_object.x, mc_object.y, tgt.x, tgt.y) < RANGE)
				return;
			
			var dist:Number = System.getDistance(mc_object.x, mc_object.y, tgt.x, tgt.y);
			var theta:Number = System.getAngle(mc_object.x, mc_object.y, tgt.x, tgt.y);
			updatePosition(System.forward(spd, theta, true), System.forward(spd, theta, false));
			
			if (mc_object != null)
				mc_object.rotation = System.getAngle(mc_object.x, mc_object.y, cg.shipHitMask.x, cg.shipHitMask.y);
		}
		
		private function spawnClouds():void
		{
			for (var i:int = System.getRandInt(2, 3); i >= 0; i--)
				cg.addDecor("cloud", {
											"x": System.getRandNum(mc_object.x - 45, mc_object.x + 45),
											"y": System.getRandNum(mc_object.y - 45, mc_object.y + 45),
											"dx": System.getRandNum( -0.1, 0.1),
											"dy": System.getRandNum( -0.1, 0.1),
											"rot": System.getRandNum(0, 360),
											"scale": System.getRandNum(0.7, 1.5),
											"alphaDelay": System.getRandInt(150, 300),
											"alphaDelta": 120,
											"alpha": System.getRandNum(0.7, 1)
										});
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
					var proj:EnemyRammable = new EnemyRammable(cg, new SWC_Enemy(),
																	{
																		"collideColor":	attackColor,
																		"hp":			int(mult * System.getRandInt(6, 15)),
																		"attackCollide":attackStrength,
																		"x":			spawn.x,
																		"y":			spawn.y,
																		"scale":		System.getRandNum(0.7, 1.5),
																		"atkDir":		atkAngle,
																		"dr":			System.getRandNum(-3, 3),
																		"spd":			System.getRandNum(0.6, 1.1),
																		"style":		"spider_bullet",
																		"cloud":		cloudCounter == 1,
																		"random":		true
																	});
					if (--cloudCounter <= 0)
					{
						cloudCounter = System.getRandInt(4, 6);
						spawnClouds();
						anchorCounter = 0;
					}
					cg.addToGame(proj, System.M_ENEMY);
				}
			}
		}
		
		override public function destroy():void 
		{
			for (var i:int = 6 + System.getRandInt(0, 3); i >= 0; i--)
				cg.addDecor("gib_spider", {
											"x": System.getRandNum(mc_object.x - 40, mc_object.x + 40),
											"y": System.getRandNum(mc_object.y - 40, mc_object.y + 40),
											"dx": System.getRandNum( -1, 1),
											"dy": System.getRandNum( -1, 1),
											"dr": System.getRandNum( -4, 4),
											"rot": System.getRandNum(0, 360),
											"scale": mult * System.getRandNum(1, 2),
											"alphaDelay": 70 + System.getRandInt(0, 20),
											"alphaDelta": 30,
											"random": true
										});
			super.destroy();
		}
	}
}