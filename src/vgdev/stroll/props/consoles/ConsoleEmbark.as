package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Main menu console that starts the game if both players are at a console.
	 * @author Alexander Huynh
	 */
	public class ConsoleEmbark extends ABST_Console 
	{
		private static var ready:int = 0;
		private var embark:MovieClip;
		
		public function ConsoleEmbark(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, _embark:MovieClip) 
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "menu";
			
			embark = _embark;
		}
		
		override protected function updateHUD(isActive:Boolean):void
		{
			if (isActive())
			{
				if (++ready == 2)
					cg.setComplete();
			}
			else
				ready--;

			embark.gotoAndStop(ready + 1);
		}
	}
}