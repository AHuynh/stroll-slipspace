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
		
		public function EnemyRammable(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			setStyle(System.setAttribute("style", attributes, "ice"));
			atkDir = System.setAttribute("atkDir", attributes, "0");
			gib = System.setAttribute("gib", attributes, null);
			
			if (System.setAttribute("random", attributes, false))
				mc_object.base.gotoAndStop(System.getRandInt(1, mc_object.base.totalFrames));
			
			// no weapons
			cdCounts = [];
			cooldowns = [];
			
			// ram the ship
			rangeVary = 0;
			orbitX = 0;
			orbitY = 0;
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
			if (gib != null)
				for (var i:int = 3 + System.getRandInt(0, 2); i >= 0; i--)
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
			super.destroy();
		}
	}
}