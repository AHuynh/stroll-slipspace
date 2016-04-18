package vgdev.stroll 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.MovieClip;
	import flash.display.NativeMenuItem;
	import flash.display.Stage;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import vgdev.stroll.props.ABST_IMovable;
	
	/**
	 * Helper functionality
	 * @author Alexander Huynh
	 */
	public class System 
	{
		[Embed(source="../../../img/effects/distortion_module.gif")]
		public static var distortion_module:Class;	
		[Embed(source="../../../img/effects/distortion_squares.png")]
		public static var distortion_squares:Class;	
		[Embed(source="../../../img/effects/distortion_bars.png")]
		public static var distortion_bars:Class;	
		
		// keyboard bindings for P1 and P2
		public static var keyMap0:Object = {"RIGHT":Keyboard.D,		"UP":Keyboard.W,
											"LEFT":Keyboard.A,		"DOWN":Keyboard.S,
											"ACTION":Keyboard.F, 	"CANCEL":Keyboard.G };
		public static var keyMap1:Object = {"RIGHT":Keyboard.RIGHT,	"UP":Keyboard.UP,
											"LEFT":Keyboard.LEFT,	"DOWN":Keyboard.DOWN,
											"ACTION":Keyboard.PERIOD,"CANCEL":Keyboard.SLASH };
											
		// default keyboard bindings for P1 and P2
		public static const KEYMAP0:Object = {"RIGHT":Keyboard.D,		"UP":Keyboard.W,
											"LEFT":Keyboard.A,		"DOWN":Keyboard.S,
											"ACTION":Keyboard.F, 	"CANCEL":Keyboard.G };
		public static const KEYMAP1:Object = {"RIGHT":Keyboard.RIGHT,	"UP":Keyboard.UP,
											"LEFT":Keyboard.LEFT,	"DOWN":Keyboard.DOWN,
											"ACTION":Keyboard.PERIOD,"CANCEL":Keyboard.SLASH };
		
		// global constants
		public static const GAME_WIDTH:int = 960;
		public static const GAME_HEIGHT:int = 600;
		public static const GAME_HALF_WIDTH:int = GAME_WIDTH / 2;
		public static const GAME_HALF_HEIGHT:int = GAME_HEIGHT / 2;
		
		// account for game's center registration point
		// NOTE: can be changed by Cam.as
		public static var GAME_OFFSX:int = GAME_HALF_WIDTH;
		public static var GAME_OFFSY:int = GAME_HALF_HEIGHT;

		// constants used in ABST_Projectile
		public static const AFFIL_PLAYER:int = 1;
		public static const AFFIL_ENEMY:int = 2;
		
		// constants used in ContainerGame.managerMap
		public static const M_PLAYER:int = 0;		
		public static const M_ENEMY:int = 1;
		public static const M_BOARDER:int = 2;
		public static const M_CONSOLE:int = 10;
		public static const M_PROXIMITY:int = 11;
		public static const M_EPROJECTILE:int = 20;
		public static const M_IPROJECTILE:int = 21;
		public static const M_DECOR:int = 30;
		public static const M_FIRE:int = 40;
		public static const M_DEPTH:int = 50;
		
		// timing constants
		public static const SECOND:int = 30;
		public static const MINUTE:int = SECOND * 60;
		public static const TAILS_NORMAL:int = SECOND * 5;
		
		// color constants
		public static const COL_WHITE:uint = 0xFFFFFF;
		public static const COL_REDHIT:uint = 0xDD0000;
		public static const COL_RED:uint = 0xFF0000;
		public static const COL_TAILS:uint = 0x00FFFF;
		public static const COL_YELLOW:uint = 0xFFFF00;
		public static const COL_GREEN:uint = 0x00FF00;
		public static const COL_BLUE:uint = 0x0077FF;
		public static const COL_ORANGE:uint = 0xFFA800;
		
		// volume constants
		public static const VOL_BGM:Number = .4;
		
		// range constants
		public static const ORBIT_0_X:Number = 420;		// close orbit; suitable for Easy Sector with no Sensors
		public static const ORBIT_0_Y:Number = 190;
		public static const ORBIT_1_X:Number = 550;		// medium orbit
		public static const ORBIT_1_Y:Number = 300;
		public static const ORBIT_2_X:Number = 700;		// far orbit; suitable for Medium Sector+ with Sensors
		public static const ORBIT_2_Y:Number = 420;
		
		// spawning constants
		public static const SPAWN_STD:Array = ["right", "left", "top", "bottom", "top_left", "bottom_left", "top_right", "bottom_right"];
		public static const SPAWN_SQUID:Array = ["far_left", "far_right"];
		public static const SPAWN_AMOEBA:Array = ["top_right", "bottom_right", "top_left", "bottom_left"];
		
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
		
		/**
		 * Get a random element from the given array
		 * @param	arr		The choices
		 * @return			A random element from arr
		 */
		public static function getRandFrom(arr:Array):*
		{
			return arr[getRandInt(0, arr.length - 1)];
		}
		
		/**
		 * Returns a random color from the 4 main colors (RGYB)
		 * @param	excludes	An Array of colors to exclude, else null
		 * @return				A random color from the 4 main colors, excluding colors in excludes
		 */
		public static function getRandCol(excludes:Array = null):uint
		{
			var choices:Array = [COL_RED, COL_YELLOW, COL_GREEN, COL_BLUE];
			if (excludes != null)
				for each (var col:uint in excludes)
					choices.splice(choices.indexOf(col), 1);
			if (choices.length == 0)
				return System.COL_WHITE;
			return getRandFrom(choices);
		}
		
		/**
		 * Gets the sign of the given number
		 * @param	num			Number to get the sign of
		 * @return				1 if num is non-negative; -1 otherwise
		 */
		public static function getSign(num:Number):int
		{
			return num >= 0 ? 1 : -1;
		}

		/**
		 * Helper to set initial values from an attributes map
		 * @param	key			The key to use in attributes
		 * @param	attributes	A map of keys to values
		 * @param	fallback	Default to use if the attributes object doesn't contain a value for the key
		 * @return				The corresponding attribute from the map, or fallback if none exists
		 */
		public static function setAttribute(key:*, attributes:Object, fallback:* = null):*
		{
			return attributes[key] != null ? attributes[key] : fallback;
		}
		
		/**
		 * Converts degrees to radians
		 * @param	degrees		Value in degrees
		 * @return				Value in radians
		 */
		public static function degToRad(degrees:Number):Number
		{
			return degrees * .0175;
		}
		
		/**
		 * Converts radians to degrees
		 * @param	radians		Value in radians
		 * @return				Value in degrees
		 */
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

		/**
		 * Given a speed and facing, returns the change in x or change in y. Call twice to get both dX and dY.
		 * @param	spd				Pixels per frame the object is moving at
		 * @param	rot				Direction in degrees the object is facing
		 * @param	isX				If the method should return dX (true) or dY (false)
		 * @return					Change in x or y, depending on isX
		 */
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
			return Math.min(orig, limHigh);
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
		
		/**
		 * Determines if val is not between the two limits, with an optional buffer; but only if val is approaching the limit
		 * @param	val				The original value
		 * @param	dVal			The change in the original value
		 * @param	low				The lower limit
		 * @param	high			The upper limit
		 * @param	buffer			Buffer to subtract from low, add to high
		 * @return					val < low - buffer || val > high + buffer
		 */
		public static function directionalOutOfBounds(val:Number, dVal:Number, low:Number, high:Number, buffer:Number = 0):Boolean
		{
			return outOfBounds(val, low, high, buffer) && ((val < low && dVal < 0) || (val > high && dVal > 0))
		}
		
		/**
		 * Place the given value inside the limits using wrapping
		 * @param	val		The value to wrap
		 * @param	limit	The max/min value
		 * @return			The wrapped value
		 */
		public static function wrap(val:Number, limit:Number):Number
		{
			if (val > limit)
				val -= limit * 2;
			else if (val < -limit)
				val += limit * 2;
			return val;
		}
		
		public static function setWithinLimits(newValue:Number, limLow:Number = int.MIN_VALUE, limHigh:Number = int.MAX_VALUE):Number
		{
			return Math.max(Math.min(newValue, limHigh), limLow);
		}
		
		/**
		 * Convert the name of a color to the corresponding uint code
		 * @param	colStr		color name, such as "red"
		 * @return				corespoinding uint (white if not found)
		 */
		public static function stringToCol(colStr:String):uint
		{
			switch (colStr)
			{
				case "red":		return COL_RED;
				case "green":	return COL_GREEN;
				case "blue":	return COL_BLUE;
				case "yellow":	return COL_YELLOW;
				default:		return COL_WHITE;
			}
		}
		
		/**
		 * Tint the given MovieClip
		 * @param	mc		The MovieClip to tint
		 * @param	col		The color to tint the MovieClip
		 * @param	mult	Option to reduce the tint
		 */
		public static function tintObject(mc:MovieClip, col:uint, mult:Number = 1):void
		{
			var ct:ColorTransform = new ColorTransform();
			if (col != COL_WHITE)
			{
				ct.redMultiplier = (col >> 16 & 0x0000FF / 255) * mult;
				ct.greenMultiplier = (col >> 8 & 0x0000FF / 255) * mult;
				ct.blueMultiplier = (col & 0x0000FF / 255) * mult;
			}
			mc.transform.colorTransform = ct;
		}
		
		public static function createDMFilter(type:String):DisplacementMapFilter
		{
			var mapBitmap:BitmapData;
			switch (type)
			{
				case "module":		mapBitmap = new distortion_module().bitmapData;		break;
				case "bg_squares":	mapBitmap = new distortion_squares().bitmapData;	break;
				case "bg_bars":		mapBitmap = new distortion_bars().bitmapData;		break;
				default: "[SYSTEM] Unknown DMfilter for", type;
			}
			var mapPoint:Point       = new Point(); 						// position of the StaticMap image in relation to our button
			var componentX:uint      = BitmapDataChannel.RED;
			var componentY:uint      = BitmapDataChannel.RED;
			var scaleX:Number = 5; 		// the amount of horizontal shift
			var scaleY:Number = 1; 		// the amount of vertical shift
			var mode:String          = DisplacementMapFilterMode.WRAP;
			var color:uint           = 0;
			var alpha:Number         = 0;
			
			return new DisplacementMapFilter(
							mapBitmap,
							mapPoint,
							componentX,
							componentY,
							scaleX,
							scaleY,
							mode,
							color,
							alpha   );
		}

		/**
		 * Determine if a line can be drawn between origin and target without colliding with the ship
		 * @param	anchor		Any instance of an ABST_IMovable; helps with collision detection
		 * @param	origin		Origin of LOS check
		 * @param	target		Target that origin is looking at
		 * @param	offset		Amount to adjust origin
		 * @return				true if origin has LOS on target
		 */
		public static function hasLineOfSight(origin:ABST_IMovable, target:Point, offset:Point = null ):Boolean
		{
			if (offset == null) offset = new Point();
			var angle:Number = getAngle(origin.mc_object.x, origin.mc_object.y, target.x, target.y);
			var distMax:int = int(getDistance(origin.mc_object.x, origin.mc_object.y, target.x, target.y));
			var dist:int = 1;
			const DIST_STEP:int = 2;
			while (dist < distMax)
			{
				var ptL:Point = MovieClip(origin.mc_object.parent).localToGlobal(new Point(origin.mc_object.x + offset.x + forward(dist, angle, true), origin.mc_object.y + offset.y + forward(dist, angle, false)));
				if (origin.hitMask.hitTestPoint(ptL.x, ptL.y, true))
				{
					return false;
				}
				dist += DIST_STEP;
			}
			return true;
		}
		
		public static function calculateAverage(values:Array):Number
		{
			if (!values || values.length == 0)
				return 0;
			var total:Number = 0;
			for each (var n:Number in values)
				total += n;
			return total / values.length;
		}
	}
}