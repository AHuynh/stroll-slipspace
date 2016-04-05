package vgdev.stroll.props.consoles 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.Player;
	import vgdev.stroll.System;
	import vgdev.stroll.support.SoundManager;
	
	/**
	 * Adjusts the view
	 * @author Alexander Huynh
	 */
	public class ConsoleSensors extends ABST_Console 
	{
		private var corruptTimer:int = -1;
		private var isMoving:Boolean = false;
		
		public function ConsoleSensors(_cg:ContainerGame, _mc_object:MovieClip, _players:Array, locked:Boolean = false) 
		{
			super(_cg, _mc_object, _players, locked);
			CONSOLE_NAME = "Sensors";
			TUT_SECTOR = 4;
			TUT_TITLE = "Sensors Module";
			TUT_MSG = "Adjust the ship's sensors to get a better view of outside."
		}
		
		override public function step():Boolean 
		{
			if (corruptTimer != -1)
			{
				corruptTimer--;
				if (corruptTimer % 60 == 0)
					cg.camera.setCameraFocus(new Point(System.getRandNum( -System.GAME_HALF_WIDTH, System.GAME_HALF_WIDTH) * .7,
														System.getRandNum(-System.GAME_HALF_HEIGHT, System.GAME_HALF_HEIGHT) * .7));
			}
			return super.step();
		}
		
		public function corrupt(time:int):void
		{
			corruptTimer = time;
		}
		
		override public function updateHUD(isActive:Boolean):void 
		{
			if (isActive)
			{
				if (corrupted)		// relinquish control if corrupted
				{
					consoleFAILS.updateHUD(isActive);
					return;
				}
				holdKey([false, false, false, false]);
			}
		}
		
		override public function onAction(p:Player):void 
		{
			isMoving = false;
			super.onAction(p);
		}
		
		override public function onCancel():void 
		{
			if (corrupted)		// relinquish control if corrupted
				consoleFAILS.onCancel();
			isMoving = false;
			super.onCancel();
		}
		
		override public function holdKey(keys:Array):void
		{
			if (broken) return;
			
			if (corrupted)		// relinquish control if corrupted
			{
				consoleFAILS.holdKey(keys);
				return;
			}
			
			if (keys[0])
				cg.camera.moveCameraFocus(new Point(-1, 0));
			if (keys[1])
				cg.camera.moveCameraFocus(new Point(0, 1));
			if (keys[2])
				cg.camera.moveCameraFocus(new Point(1, 0));
			if (keys[3])
				cg.camera.moveCameraFocus(new Point(0, -1));
				
			if (!isMoving && (keys[0] || keys[1] || keys[2] || keys[3]))
			{
				isMoving = true;
				SoundManager.playSFX("sfx_servo", .5);
			} else if (isMoving && !keys[0] && !keys[1] && !keys[2] && !keys[3])
			{
				isMoving = false;
				SoundManager.playSFX("sfx_servoEnd", .5);
			}
		
			var hud:MovieClip = getHUD();
				
			// set UI arrows to be faded out if the camera can't move any further in that direction
			hud.mc_arrowR.gotoAndStop(cg.camera.isAtLimit(0) ? 2 : 1);
			hud.mc_arrowL.gotoAndStop(cg.camera.isAtLimit(1) ? 2 : 1);
			hud.mc_arrowD.gotoAndStop(cg.camera.isAtLimit(2) ? 2 : 1);
			hud.mc_arrowU.gotoAndStop(cg.camera.isAtLimit(3) ? 2 : 1);
			
			hud.mc_limitX.visible = cg.camera.isAtLimit(0) || cg.camera.isAtLimit(1);
			hud.mc_limitY.visible = cg.camera.isAtLimit(2) || cg.camera.isAtLimit(3);
			
			hud.tf_x.text = Math.round(-cg.camera.focusTgt.x * .25).toString();
			hud.tf_y.text = Math.round(cg.camera.focusTgt.y * .25).toString();
			
			hud.mc_markerX.x = -71 + 48 * (-cg.camera.focusTgt.x / (cg.camera.lim_x_max - cg.camera.lim_x_min));
			hud.mc_markerY.x = 74 + 48 * (cg.camera.focusTgt.y / (cg.camera.lim_y_max - cg.camera.lim_y_min));
		}
	}
}