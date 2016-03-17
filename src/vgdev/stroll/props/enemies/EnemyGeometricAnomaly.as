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
			super(_cg, _mc_object, attributes);
			setStyle("geometricAnomaly");
			var frame:int = System.getRandInt(1, mc_object.base.totalFrames);
			mc_object.base.gotoAndStop(frame);

		}
		
		override public function getJammingValue():int 
		{
			return 0;
		}
		
		override public function destroy():void 
		{
			// TODO geometric anomaly gibs
			/*for (var i:int = 5 + System.getRandInt(0, 3); i >= 0; i--)
				cg.addDecor("gib_eye", {
											"x": System.getRandNum(mc_object.x - 25, mc_object.x + 25),
											"y": System.getRandNum(mc_object.y - 25, mc_object.y + 25),
											"dx": System.getRandNum( -1, 1),
											"dy": System.getRandNum( -1, 1),
											"dr": System.getRandNum( -5, 5),
											"rot": System.getRandNum(0, 360),
											"alphaDelay": 90 + System.getRandInt(0, 30),
											"alphaDelta": 30,
											"random": true
										});*/
			super.destroy();
		}
	}
}