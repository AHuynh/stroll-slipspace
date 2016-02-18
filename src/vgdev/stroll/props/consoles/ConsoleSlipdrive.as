package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Activates the slipdrive
	 * @author Alexander Huynh
	 */
	public class ConsoleSlipdrive extends ABST_Console 
	{
		
		public function ConsoleSlipdrive(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "slipdrive";
		}
		
		override public function step():Boolean 
		{
			if (inUse)
				updateHUD(true);
			return super.step();
		}
		
		override public function onKey(key:int):void
		{
			if (key == 4 && cg.ship.jump())
				if (cg)		// TODO remove temp
					updateHUD(true);
		}
		
		override protected function updateHUD(isActive:Boolean):void 
		{
			if (isActive)
				getHUD().gotoAndStop(cg.ship.isJumpReady() ? 2 : 1);
		}
	}
}