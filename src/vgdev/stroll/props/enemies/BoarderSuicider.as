package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.consoles.ABST_Console;
	import vgdev.stroll.System;
	
	/**
	 * Boarder that picks a target and suicides it with fire
	 * @author Alexander Huynh
	 */
	public class BoarderSuicider extends ABST_Boarder 
	{		
		public function BoarderSuicider(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, _hitMask, attributes);
			setStyle("floater");
			cg.addDecor("spawn", { "x": mc_object.x, "y": mc_object.y, "scale": 0.5 } );
			speed = 0.5;
		}
		
		override protected function findNewPOI():void
		{
			var giveUp:int = 10;
			var c:ABST_Console;
			do {
				c = System.getRandFrom(cg.consoles);
				pointOfInterest = new Point(c.mc_object.x, c.mc_object.y);
				giveUp--;
			} while (giveUp > 0 && 
					System.getDistance(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y) < POI_RANGE &&
					!System.hasLineOfSight(this, pointOfInterest));
		}
		
		override protected function onArrive():void 
		{
			if (cg == null) return;
			for (var i:int = 0; i < 2; i++)
				cg.addFireAt(new Point(mc_object.x + System.getRandNum( -10, 10), mc_object.y + System.getRandNum( -10, 10)));
			changeHP( -hpMax);
		}
		
		override public function destroy():void 
		{
			if (cg != null)
			{
				cg.addFireAt(new Point(mc_object.x + System.getRandNum( -10, 10), mc_object.y + System.getRandNum( -10, 10)));
				cg.addSparksAt(1, new Point(mc_object.x, mc_object.y));
			}
			super.destroy();
		}
	}
}