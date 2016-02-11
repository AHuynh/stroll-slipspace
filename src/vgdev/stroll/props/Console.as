package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class Console extends ABST_Object 
	{
		private var players:Array;
		private const RANGE:int = 20;
		
		public var inUse:Boolean = false;
		
		/// active/nearest player
		public var closestPlayer:Player;
		
		public function Console(_cg:ContainerGame, _mc_object:MovieClip, _players:Array) 
		{
			super(_cg, _mc_object);
			players = _players;
		}
		
		override public function step():Boolean
		{
			if (!inUse)
			{
				closestPlayer = null;
				var closestDist:Number = 99999;
				var dist:Number;
				var player:Player;
				for (var i:int = 0; i < players.length; i++)
				{
					player = players[i];
					dist = System.getDistance(mc_object.x, mc_object.y, player.mc_object.x, player.mc_object.y + 15);
					if (dist < RANGE && dist < closestDist)
					{
						dist = closestDist;
						closestPlayer = player;
						mc_object.prompt.visible = true;
					}
				}
				
				if (closestPlayer == null)
				{
					mc_object.prompt.visible = false;
				}
			}
			
			return false;
		}
		
		public function onAction(p:Player):void
		{
			if (!inUse)
			{
				if (closestPlayer != null && closestPlayer == p)
				{
					inUse = true;
					closestPlayer.sitAtConsole(this);
					mc_object.gotoAndStop(3);
					mc_object.prompt.visible = false;
				}
			}
		}
		
		public function onCancel():void
		{
			if (inUse)
			{
				inUse = false;
				closestPlayer = null;
				mc_object.gotoAndStop(2);
				mc_object.prompt.visible = true;
			}
		}
	}
}