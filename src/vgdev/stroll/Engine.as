package vgdev.stroll 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import vgdev.stroll.support.SoundManager;

	/**
	 * Primary game 'holder' and updater
	 * @author Alexander Huynh
	 */
	public class Engine extends MovieClip
	{		
		private const STATE_MENU:int = 0;
		private const STATE_GAME:int = 1;
		
		private var gameState:int = STATE_MENU;
		private var container:MovieClip;
		
		public var superContainer:SWC_Mask;
		
		public const RET_NORMAL:int = 0;
		public const RET_RESTART:int = 1;
		public var returnCode:int = RET_NORMAL;
		
		// session-specific code
		public var shipName:String = "Eagle";
		public var shipColor:uint = 0xFFFFFF;
		public var maxSector:int = 0;			// furthest sector arrived at
		public var savedHP:Number = 0;			// ship hull points at maxSector
		public var wingman:Array = [false, false];
		
		public function Engine() 
		{			
			addEventListener(Event.ENTER_FRAME, step);					// primary game loop firer
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			SoundManager.init();
		}
		
		/**
		 * Helper to init the global keyboard listener (quality buttons)
		 * @param	e	the captured Event, unused
		 */
		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			superContainer = new SWC_Mask();
			superContainer.x += System.GAME_OFFSX;
			superContainer.y += System.GAME_OFFSY;
			addChild(superContainer);
			
			superContainer.addEventListener(Event.ADDED_TO_STAGE, onReady);			
		}
		
		private function onReady(e:Event):void
		{
			superContainer.removeEventListener(Event.ADDED_TO_STAGE, onReady);
			switchToContainer(new ContainerMenu(this), 0, 0);
		}
		
		/**
		 * Primary game loop event firer. Steps the current container, and advances
		 * 	to the next one if the current container is complete
		 * @param	e	the captured Event, unused
		 */
		public function step(e:Event):void
		{
			if (container != null && container.step())
			{
				SoundManager.shutUp();	
				switch (gameState)			// determine which new container to go to next
				{
					case STATE_MENU:
						maxSector = 0;
						savedHP = 0;
						if (isAllAI())
							shipName = Math.random() > .5 ? "Eagle" : "Kingfisher";
						switchToContainer(new ContainerGame(this, shipName), 0, 0);
						gameState = STATE_GAME;
					break;
					case STATE_GAME:
						if (returnCode == RET_NORMAL)
						{
							switchToContainer(new ContainerMenu(this), 0, 0);
							gameState = STATE_MENU;
						}
						else if (returnCode == RET_RESTART)
						{
							switchToContainer(new ContainerGame(this, shipName, true), 0, 0);
							gameState = STATE_GAME;
						}
					break;
				}
			}
		}
		
		/**
		 * Helper to switch from the current container to the new, given one
		 * @param	containerNew		The container to switch to
		 * @param	offX				Offset x to translate the new container by
		 * @param	offY				Offset y to translate the new container by
		 */
		private function switchToContainer(containerNew:ABST_Container, offX:Number = 0, offY:Number = 0):void
		{
			if (container != null && superContainer.mc_container.contains(container))
			{
				superContainer.mc_container.removeChild(container);
				container = null;
			}
			container = containerNew;
			container.x += offX;
			container.y += offY;
			superContainer.mc_container.addChild(container);
			container.tabChildren = false;
			container.tabEnabled = false;
			
			returnCode = RET_NORMAL;
		}
		
		public function saveProgress(sector:int, sp:Number):void
		{
			maxSector = sector;
			savedHP = sp;
		}
		
		public function isAllAI():Boolean
		{
			return wingman[0] && wingman[1];
		}
	}
}