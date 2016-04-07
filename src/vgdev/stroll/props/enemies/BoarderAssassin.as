package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Boarder that shoots at a player
	 * @author Alexander Huynh
	 */
	public class BoarderAssassin extends BoarderShooter 
	{
		public function BoarderAssassin(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, _hitMask, attributes);
			setStyle("drone");
			
			offY = -15;
		}
		
		override protected function findNewPOI():void
		{
			var hps:Array = [cg.players[0].getHP(), cg.players[1].getHP()];
			if (hps[0] == 0 && hps[1] == 0)
				return;
			if (hps[0] != 0 && hps[0] != 0)
				tgt = System.getRandFrom(cg.players);
			else if (hps[0] == 0)
				tgt = cg.players[1];
			else
				tgt = cg.players[0];
			pointOfInterest = new Point(tgt.mc_object.x, tgt.mc_object.y);
		}
		
		override public function step():Boolean 
		{
			if (tgt != null)
				pointOfInterest = new Point(tgt.mc_object.x, tgt.mc_object.y);			
			return super.step();
		}
	}
}