package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	
	/**
	 * Object that can move inside the spaceship.
	 * @author Alexander Huynh
	 */
	public class ABST_IMovable extends ABST_Object 
	{
		public var hitbox:MovieClip;
		protected var validMCs:Array;
		
		protected var debug:SWC_Debug;
		
		public function ABST_IMovable(_cg:ContainerGame, _validMCs:MovieClip) 
		{
			super(_cg);
			validMCs = [];
			for (var i:int = 0; i < _validMCs.numChildren; i++)
			{
				validMCs.push(_validMCs.getChildAt(i));
			}
			
			debug = new SWC_Debug();
			cg.addChild(debug);
			//debug.visible = true;
		}
		
		/**
		 * Move the obstacle's x and y
		 */
		override protected function updatePosition(dx:Number, dy:Number):void
		{
			//trace("[" + this + "] Trying to move!");
			var ptNew:Point = new Point(changeWithLimit(mc_object.x, dx), changeWithLimit(mc_object.y, dy));
			if (isPointValid(ptNew.add(new Point(dx * 0, dy * 0))))
			{
				mc_object.x = ptNew.x;
				mc_object.y = ptNew.y;
				//debug.visible = false;
			}
			else
				trace("[" + this + "]\tcouldn't move!");
		}
		
		public function isPointValid(pt:Point):Boolean
		{
			if (hitbox == null)
				return false;
				
			hitbox.x += pt.x;
			hitbox.y += pt.y;
			
			debug.x = pt.x;
			debug.y = pt.y;
			//debug.visible = true;
				
			var mc:MovieClip;
			for (var i:int = 0; i < validMCs.length; i++)
			{
				if (hitbox.hitTestObject(validMCs[i]))// && validMCs[i].hitTestPoint(pt.x, pt.y))
				//var ptL:Point = validMCs[i].localToGlobal(pt);
				//if (validMCs[i].hitTestPoint(ptL.x, ptL.y))
				{
					trace("[" + this + "]\tFound a valid MC at:", validMCs[i].x, validMCs[i].y);
					hitbox.x -= pt.x;
					hitbox.y -= pt.y;
					return true;
				}
			}
			
			hitbox.x -= pt.x;
			hitbox.y -= pt.y;
			return false;
		}
	}
}