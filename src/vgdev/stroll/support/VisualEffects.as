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
		private const INTENSITY_MAP:Array = [[5, 1, 25], [10, 2, 50], [25, 4, 100],];		// x, y, translate
		
		public function VisualEffects(_cg:ContainerGame) 
		{
			super(_cg);
		}
		
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
			moduleDistortion[module] = System.createDMFilter();
			cg.hudConsoles[module].filters = [moduleDistortion[module]];
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
		}
	}
}