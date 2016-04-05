package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_IMovable;
	import vgdev.stroll.support.graph.GraphNode;
	import vgdev.stroll.System;
	
	/**
	 * ...
	 * @author Alexander Huynh
	 */
	public class ABST_Boarder extends ABST_IMovable 
	{
		protected var state:int;
		protected const STATE_IDLE:int = 0;
		protected const STATE_MOVE_FREE:int = 1;
		protected const STATE_MOVE_NETWORK:int = 2;
		protected const STATE_MOVE_FROM_NETWORK:int = 3;
		
		protected var pointOfInterest:Point;
		protected const RANGE:Number = 5;
		
		protected var path:Array;
		protected var nodeOfInterest:GraphNode;
		
		protected var speed:Number = 1;
		protected var attackStrength:Number = 5;
		
		protected var BAR_WIDTH:Number;	
		
		public function ABST_Boarder(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, _hitMask);
			
			mc_object.x = System.setAttribute("x", attributes, 0);
			mc_object.y = System.setAttribute("y", attributes, 0);
			
			setScale(System.setAttribute("scale", attributes, 1));
			hp = hpMax = 100;
			
			state = STATE_IDLE;
			
			setStyle("floater");
		}
		
		protected function setStyle(style:String):void
		{
			mc_object.gotoAndStop(style);
			mc_object.spawn.visible = false;
			BAR_WIDTH = mc_object.mc_bar.bar.width;
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			var ret:Boolean = super.changeHP(amt);
			if (hp != 0)
				mc_object.mc_bar.bar.width = (hp / hpMax) * BAR_WIDTH;
			return ret;
		}
		
		override public function step():Boolean 
		{
			if (hp == 0) return completed;
			switch (state)
			{
				case STATE_IDLE:
					pointOfInterest = cg.getRandomShipLocation();
					path = cg.graph.getPath(this, pointOfInterest);
					if (path.length == 0)
						return completed;
					nodeOfInterest = path[0];
					state = STATE_MOVE_NETWORK;
				break;
				case STATE_MOVE_NETWORK:
					moveToPoint(new Point(nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y));
					// arrived at next node	
					if (System.getDistance(mc_object.x, mc_object.y, nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y) < RANGE)
					{
						nodeOfInterest = path.shift();
						if (nodeOfInterest == null)
						{
							state = STATE_MOVE_FROM_NETWORK;
							return completed;
						}
					}
				break;
				case STATE_MOVE_FROM_NETWORK:
					moveToPoint(pointOfInterest);
					// arrived at destination
					if (System.getDistance(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y) < RANGE)
					{
						pointOfInterest = null;
						state = STATE_IDLE;
					}
				break;
			}			
			//var hasLOS:Boolean = System.hasLineOfSight(this, new Point(cg.players[0].mc_object.x, cg.players[0].mc_object.y));
			return completed;
		}
		
		protected function moveToPoint(tgt:Point):void
		{
			var angle:Number = System.getAngle(mc_object.x, mc_object.y, tgt.x, tgt.y)
			updatePosition(System.forward(speed, angle, true), System.forward(speed, angle, false));
			updateDepth();
		}
	}
}