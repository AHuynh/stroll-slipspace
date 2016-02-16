package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Adjusts the view
	 * @author Alexander Huynh
	 */
	public class ConsoleSensors extends ABST_Console 
	{
		
		public function ConsoleSensors(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "sensors";
		}
		
		override public function holdKey(keys:Array):void
		{
			if (keys[0])
				cg.camera.moveCameraFocus(new Point(-1, 0));
			if (keys[1])
				cg.camera.moveCameraFocus(new Point(0, 1));
			if (keys[2])
				cg.camera.moveCameraFocus(new Point(1, 0));
			if (keys[3])
				cg.camera.moveCameraFocus(new Point(0, -1));
		
			getHUD().arrow_right.alpha = cg.camera.isAtLimit(0) ? .2 : 1;
			getHUD().arrow_left.alpha = cg.camera.isAtLimit(1) ? .2 : 1;
			getHUD().arrow_down.alpha = cg.camera.isAtLimit(2) ? .2 : 1;
			getHUD().arrow_up.alpha = cg.camera.isAtLimit(3) ? .2 : 1;
		}
	}
}