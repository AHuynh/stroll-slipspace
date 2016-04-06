package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Debris
	 * @author Alexander Huynh
	 */
	public class EnemyGeometricAnomaly extends EnemyGeneric 
	{
		public function EnemyGeometricAnomaly(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["noSpawnFX"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("geometricAnomaly");
			var frame:int = System.getRandInt(1, mc_object.base.totalFrames);
			mc_object.base.gotoAndStop(frame);
			playDeathSFX = false;
		}
		
		override public function getJammingValue():int 
		{
			return 0;
		}
		
		override public function destroy():void 
		{
			var horiz:Boolean;
			for (var i:int = 5 + System.getRandInt(0, 3); i >= 0; i--)
			{
				horiz = Math.random() > .5;
				cg.addDecor("gib_geometric", {
											"x": System.getRandNum(mc_object.x - 5, mc_object.x + 5),
											"y": System.getRandNum(mc_object.y - 5, mc_object.y + 5),
											"dx": horiz ? (Math.random() > .5 ? 2 : -2) : 0,
											"dy": !horiz ? (Math.random() > .5 ? 2 : -2) : 0,
											"rot": 90 * System.getRandInt(0, 3),
											"alphaDelay": 10,
											"alphaDelta": 30,
											"random": true,
											"tint": selfColor
										});
			}
			super.destroy();
		}
	}
}