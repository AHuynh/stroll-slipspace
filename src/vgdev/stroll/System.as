package vgdev.stroll 
{
	/**
	 * Helper functionality
	 * @author Alexander Huynh
	 */
	public class System 
	{
		// global constants
		public static const GAME_WIDTH:int = 960;
		public static const GAME_HEIGHT:int = 600;
		public static const GAME_OFFSX:int = 480;		// offsets
		public static const GAME_OFFSY:int = 300;
		
		// constants used in ABST_Projectile
		public static const AFFIL_PLAYER:int = 0;
		public static const AFFIL_ENEMY:int = 1;
		
		// constants used in ContainerGame.managerMap
		public static const M_PLAYER:int = 0;		
		public static const M_ENEMY:int = 1;
		public static const M_CONSOLE:int = 10;
		public static const M_EPROJECTILE:int = 20;
		
		// timing constants
		public static const SECOND:int = 30;
		public static const MINUTE:int = SECOND * 60;
		
		// color constants
		public static const COL_WHITE:uint = 0xFFFFFF;
		public static const COL_REDHIT:uint = 0xDD0000;
		public static const COL_RED:uint = 0xFF0000;
		public static const COL_YELLOW:uint = 0xFFFF00;
		public static const COL_GREEN:uint = 0x00FF00;
		public static const COL_BLUE:uint = 0x0077FF;
		
		/**
		 * Returns a random int between min and max
		 * @param	min		The lower bound
		 * @param	max		The upper bound
		 * @return			A random int between min and max
		 */
		public static function getRandInt(min:int, max:int):int   
		{  
			return (int(Math.random() * (max - min + 1)) + min);
		}
		
		/**
		 * Returns a random Number between min and max
		 * @param	min		The lower bound
		 * @param	max		The upper bound
		 * @return			A random Number between min and max
		 */
		public static function getRandNum(min:Number, max:Number):Number
		{
			return Math.random() * (max - min) + min;
		}

		public static function degToRad(degrees:Number):Number
		{
			return degrees * .0175;
		}

		public static function radToDeg(radians:Number):Number
		{
			return radians * 57.296;
		}

		/**
		 * Gets the distance in px between 2 points
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @return
		 */
		public static function getDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt(dx * dx + dy * dy);
		}

		/**
		 * Gets the angle between 2 points, returned in degrees
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @return					The angle between (x1, y1) and (x2, y2)
		 */ 
		public static function getAngle(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return radToDeg(Math.atan2(dy,dx));
		}
		
		// takes degrees; returns dX or dY
		public static function forward(spd:Number, rot:Number, isX:Boolean):Number
		{
			return (isX ? Math.cos(degToRad(rot)) : Math.sin(degToRad(rot))) * spd;
		}
		
		/**
		 * Helper to change the value of a variable restricted within limits
		 * @param	original		The original value
		 * @param	change			The amount to change by
		 * @param	limLow			The minimum amount
		 * @param	limHigh			The maximum amount
		 * @return					The original plus change, with respect to limits
		 */
		public static function changeWithLimit(orig:Number, chng:Number,
										  	   limLow:Number = int.MIN_VALUE, limHigh:Number = int.MAX_VALUE):Number
		{
			orig += chng;
			orig = Math.max(orig, limLow);
			orig = Math.min(orig, limHigh);
			return orig;
		}
		
		/**
		 * Determines if val is not between the two limits, with an optional buffer
		 * @param	val				The original value
		 * @param	low				The lower limit
		 * @param	high			The upper limit
		 * @param	buffer			Buffer to subtract from low, add to high
		 * @return					val < low - buffer || val > high + buffer
		 */
		public static function outOfBounds(val:Number, low:Number, high:Number, buffer:Number = 0):Boolean
		{
			return (val < low - buffer || val > high + buffer);
		}
		
		public static function formatDecimal(num:Number, places:int):Number
		{
			if (places >= 0)
			{
				var temp:Number = Math.pow(10, places);
				return (Math.round(num * temp) / temp)
			}
			return int(num);
		} 
		
		// ray and line segment
	/*	public static function calculateLineIntersect(p1:Point, p2:Point, p3:Point, p4:Point):Point
		{
			//trace("Calculate intersection between ray", p1, p2, "and line seg", p3, p4);
			
			var s1:Point = p2.subtract(p1);
			var s2:Point = p4.subtract(p3);
			
			var s:Number = (-s1.y * (p1.x - p3.x) + s1.x * (p1.y - p3.y)) / (-s2.x * s1.y + s1.x * s2.y);
			var t:Number = (s2.x * (p1.y - p3.y) - s2.y * (p1.x - p3.x)) / (-s2.x * s1.y + s1.x * s2.y);
			
			//trace("s, t", s, t);
			
			//if (s >= 0 && s <= 1 && t <= 0 && t >= 1)
				return new Point(p1.x + (t * s1.x), p1.y + (t * s1.y));
			return null;
		}	*/
	}
}