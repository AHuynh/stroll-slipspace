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
	public class Alerts extends ABST_Support
	{
		private var alerts:MovieClip;
		
		private var counter:int = -1;
		private var ct:ColorTransform;
		
		public var isCorrupt:Boolean = false;
		
		public function Alerts(_cg:ContainerGame, _alerts:MovieClip) 
		{
			super(_cg);
			alerts = _alerts;
			
			ct = new ColorTransform;
			ct.color = System.COL_WHITE;
			
			alerts.mc_shields.visible = false;
			alerts.mc_hull.visible = false;
			alerts.mc_incap.visible = false;
			alerts.mc_fire.visible = false;
			alerts.mc_intruders.visible = false;
			alerts.mc_corruption.visible = false;
		}
		
		override public function step():void
		{
			if (++counter == 30)
			{
				counter = 0;
				ct.color = System.COL_WHITE;
				ct.alphaMultiplier = .75;
				alerts.transform.colorTransform = ct;
				
				checkForAlert(alerts.mc_shields, cg.ship.getShields() == 0);
				checkForAlert(alerts.mc_hull, cg.ship.getHPPercent() < .3);
				checkForAlert(alerts.mc_incap, cg.players[0].getHP() == 0 || cg.players[1].getHP() == 0);
				checkForAlert(alerts.mc_fire, cg.managerMap[System.M_FIRE].hasObjects());
				checkForAlert(alerts.mc_intruders, cg.managerMap[System.M_BOARDER].hasObjects());
				checkForAlert(alerts.mc_corruption, isCorrupt);
			}
			else if (counter == 15)
			{
				ct.color = System.COL_RED;
				ct.alphaMultiplier = .75;
				alerts.transform.colorTransform = ct;
			}
		}
		
		private function checkForAlert(mc:MovieClip, newState:Boolean):void
		{
			if (!mc.visible && newState && mc != alerts.mc_incap)
				SoundManager.playSFX("sfx_warn2", .7);
			mc.visible = newState;
		}
		
		override public function destroy():void 
		{
			alerts = null;
			ct = null;
			super.destroy();
		}
	}
}