package vgdev.stroll.props.consoles 
{
	/**
	 * Dictates how on-course the ship is to the next slipsector
	 * @author Alexander Huynh
	 */
	public class ConsoleNavigation extends ABST_Console 
	{
		
		public function ConsoleNavigation(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object, _players);
			CONSOLE_NAME = "navigation";
		}
	}
}