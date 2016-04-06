package vgdev.stroll.support 
{
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Helper to apply various image effects
	 * @author Alexander Huynh
	 */
	public class VisualEffects extends ABST_Support 
	{
		private var moduleDistortion:Array = [null, null];
		private var moduleIntensity:Array = [0, 0];
		private const INTENSITY_MAP:Array = [[3, 1, 15], [5, 1, 25], [10, 2, 50], ];		// x, y, translate
		
		private var bgDistortion:DisplacementMapFilter;
		private var bgDistortionID:int = -1;
		
		private var dirHelper:int = 1;
		private var locHelper:int = 0;
		
		private var cooldown:int = 0;
		
		public function VisualEffects(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
		/**
		 * Create a glitchy-screen distortion on a module for FAILS
		 */
		public function applyModuleDistortion(module:int, remove:Boolean = false, intensity:int = 0):void
		{			
			if (remove)
			{
				cg.hudConsoles[module].filters.splice(cg.hudConsoles[module].filters.indexOf(moduleDistortion[module], 1));
				moduleDistortion[module] = null;
				cg.hudConsoles[module].filters = [];
				return;
			}
			
			moduleIntensity[module] = intensity;
			moduleDistortion[module] = System.createDMFilter("module");
			cg.hudConsoles[module].filters = [moduleDistortion[module]];
		}
		
		/**
		 * Create a background distortion
		 */
		public function applyBGDistortion(isOn:Boolean, type:String = null):void
		{
			if (isOn)
			{
				bgDistortion = System.createDMFilter(type);
				switch (type)
				{
					case "bg_squares":
						bgDistortionID = 0;
						bgDistortion.scaleX = 40;
						bgDistortion.scaleY = 40;
						cg.game.mc_ship.filters = [bgDistortion];
					break;
					case "bg_bars":
						bgDistortionID = 1;
						bgDistortion.scaleX = 60;
						cg.game.mc_bg.filters = [bgDistortion];
					break;
				}
			}
			else
			{
				bgDistortion = null;
				bgDistortionID = -1;
				cg.game.mc_ship.filters = [];
				cg.game.mc_bg.filters = [];
			}
		}
		
		override public function step():void 
		{
			var i:int;
			var dmf:DisplacementMapFilter;
			for (i = 0; i < moduleDistortion.length; i++)
			{
				dmf = moduleDistortion[i];
				if (dmf == null) continue;
				dmf.scaleX = System.getRandInt(INTENSITY_MAP[moduleIntensity[i]][0], INTENSITY_MAP[moduleIntensity[i]][1]);
				dmf.mapPoint = new Point(0, System.getRandNum(-INTENSITY_MAP[moduleIntensity[i]][2], INTENSITY_MAP[moduleIntensity[i]][2]));
				cg.hudConsoles[i].filters = [dmf];
			}
			
			if (bgDistortion != null)
			{
				switch (bgDistortionID)
				{
					case 0:
						if (--cooldown > 0)
							return;
						cooldown = System.getRandInt(30, 90);
						bgDistortion.mapPoint = new Point(System.getRandNum(-100, 100), System.getRandNum(-100, 100));
						bgDistortion.scaleX = System.getRandInt(1, 5) * 10;
						bgDistortion.scaleY = System.getRandInt(1, 5) * 10;
						cg.game.mc_ship.filters = [bgDistortion];
					break;
					case 1:
						locHelper += dirHelper * 2;
						if (locHelper < 0)
						{
							locHelper = 0;
							dirHelper *= -1;
						}
						else if (locHelper > 300)
						{
							locHelper = 300;
							dirHelper *= -1;
						}
						bgDistortion.mapPoint = new Point(-cg.background.bg1.x + System.GAME_HALF_WIDTH - 200 - cg.game.x, locHelper - cg.game.y);
						cg.game.mc_bg.filters = [bgDistortion];
					break;
				}
			}
		}
	}
}