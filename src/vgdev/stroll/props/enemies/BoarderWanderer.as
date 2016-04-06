package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Boarder that just floats around the ship
	 * @author Alexander Huynh
	 */
	public class BoarderWanderer extends ABST_Boarder 
	{
		
		public function BoarderWanderer(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, _hitMask, attributes);
			setStyle("FAILSshard");
			cg.addDecor("spawn", { "x": mc_object.x, "y": mc_object.y, "scale": 0.5 } );
		}
		
		override public function destroy():void 
		{
			cg.addSparksAt(1, new Point(mc_object.x, mc_object.y));
			for (var i:int = 3 + System.getRandInt(0, 1); i >= 0; i--)
				cg.addDecor("gib_shard", {
											"x": System.getRandNum(mc_object.x - 2, mc_object.x + 2),
											"y": System.getRandNum(mc_object.y - 2, mc_object.y + 2) - 15,
											"dx": System.getRandNum( -2, 2),
											"dy": System.getRandNum( -2, 2),
											"rot": System.getRandInt(0, 3) * 90,
											"alphaDelay": 1,
											"alphaDelta": 15,
											"random": true
										});
			super.destroy();
		}
	}
}