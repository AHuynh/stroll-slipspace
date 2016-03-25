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
		
		public function EnemyRammable(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, attributes);
			setStyle(System.setAttribute("style", attributes, "ice"));
			atkDir = System.setAttribute("atkDir", attributes, "0");
			
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
	}
}