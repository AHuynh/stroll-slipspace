package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Generic enemy that just rams
	 * @author Alexander Huynh
	 */
	public class EnemyRammable extends ABST_Enemy 
	{
		private var atkDir:Number;
		private var gib:String;
		
		private var cloud:Boolean = false;
		
		public function EnemyRammable(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["noSpawnFX"] = true;
			super(_cg, _mc_object, attributes);
			setStyle(System.setAttribute("style", attributes, "ice"));
			atkDir = System.setAttribute("atkDir", attributes, "0");
			gib = System.setAttribute("gib", attributes, null);
			
			if (System.setAttribute("random", attributes, false))
				mc_object.base.gotoAndStop(System.getRandInt(1, mc_object.base.totalFrames));
				
			cloud = System.setAttribute("cloud", attributes, false);
			
			// no weapons
			cdCounts = [];
			cooldowns = [];
			
			// ram the ship
			rangeVary = 0;
			orbitX = 0;
			orbitY = 0;
			
			playDeathSFX = false;
		}
		
		override public function getJammingValue():int 
		{
			return 0;
		}

		// move and accelerate towards the ship
		override public function step():Boolean
		{
			if (!completed)
			{
				updatePrevPosition();
				updatePosition(System.forward(spd, atkDir, true), System.forward(spd, atkDir, false));
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateRotation(dR);	
				updateDamageFlash();				
			}
			return completed;
		}
		
		override public function destroy():void 
		{
			var i:int;
			if (gib != null)
				for (i = 3 + System.getRandInt(0, 2); i >= 0; i--)
					cg.addDecor(gib, {
												"x": System.getRandNum(mc_object.x - 5, mc_object.x + 5),
												"y": System.getRandNum(mc_object.y - 5, mc_object.y + 5),
												"dx": System.getRandNum( -1.5, 1.5),
												"dy": System.getRandNum( -1.5, 1.5),
												"dr": System.getRandNum( -5, 5),
												"rot": System.getRandNum(0, 360),
												"scale": System.getRandNum(1, 1.5),
												"alphaDelay": 30 + System.getRandInt(0, 20),
												"alphaDelta": 15,
												"random": true
											});
			if (cloud != false)
				for (i = System.getRandInt(2, 3); i >= 0; i--)
					cg.addDecor("cloud", {
												"x": System.getRandNum(mc_object.x - 45, mc_object.x + 45),
												"y": System.getRandNum(mc_object.y - 45, mc_object.y + 45),
												"dx": System.getRandNum( -0.1, 0.1),
												"dy": System.getRandNum( -0.1, 0.1),
												"rot": System.getRandNum(0, 360),
												"scale": System.getRandNum(1, 1.5),
												"alphaDelay": System.getRandInt(150, 300),
												"alphaDelta": 120,
												"alpha": System.getRandNum(0.7, 1)
											});
			super.destroy();
		}
	}
}