package vgdev.stroll.support 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Helper that shows warnings
	 * @author Alexander Huynh
	 */
	public class Alerts 
	{
		private var cg:ContainerGame;
		private var alerts:MovieClip;
		
		private var counter:int = -1;
		private var ct:ColorTransform;
		
		public function Alerts(_cg:ContainerGame, _alerts:MovieClip) 
		{
			cg = _cg;
			alerts = _alerts;
			
			ct = new ColorTransform;
			ct.color = System.COL_WHITE;
			
			alerts.mc_shields.visible = false;
			alerts.mc_hull.visible = false;
			alerts.mc_incap.visible = false;
			alerts.mc_fire.visible = false;
			alerts.mc_intruders.visible = false;
		}
		
		public function step():void
		{
			if (++counter == 30)
			{
				counter = 0;
				ct.color = System.COL_WHITE;
				ct.alphaMultiplier = .75;
				alerts.transform.colorTransform = ct;
			
				alerts.mc_shields.visible = cg.ship.getShields() == 0;
				alerts.mc_hull.visible = cg.ship.getHPPercent() < .3;
				alerts.mc_incap.visible = cg.players[0].getHP() == 0 || cg.players[1].getHP() == 0;
				alerts.mc_fire.visible = cg.managerMap[System.M_FIRE].numObjects() != 0;
				//alerts.mc_intruders.visible = cg.managerMap[System.M_BOARDERS].numObjects() != 0;
				alerts.mc_intruders.visible = false;
			}
			else if (counter == 15)
			{
				ct.color = System.COL_RED;
				ct.alphaMultiplier = .75;
				alerts.transform.colorTransform = ct;
			}
		}
	}
}