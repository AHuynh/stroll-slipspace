package vgdev.stroll.props 
{
	import flash.display.MovieClip;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * A non-interactive decoration piece that removes itself once its animation is done
	 * @author Alexander Huynh
	 */
	public class Decor extends ABST_Object 
	{		
		/// If true, calculate when to remove the decor dynamically
		private var codeAnimation:Boolean = false;
		
		private var dx:Number = 0;
		private var dy:Number = 0;
		private var dr:Number = 0;
		
		private var alphaDelay:int = 0;
		private var alphaDelta:Number = 0;		// should be non-positive
		
		/**
		 * Constructor
		 * @param	_cg			ContainerGame
		 * @param	_mc_object	SWC_Decor
		 * @param	style		String, the label of the frame to use
		 * @param	params		Optional extra flags
		 * 							alphaDelay		frames to wait before fading out
		 * 							alphaDelta		frames it takes to go from 1 to 0 alpha
		 * 							random			if true, pick a random frame from mc_object.base
		 */
		public function Decor(_cg:ContainerGame, _mc_object:MovieClip = null, style:String = null, params:Object = null)
		{
			super(_cg, _mc_object);
			if (style == null)
			{
				completed = true;
				mc_object.visible = false;
				return;
			}
			mc_object.gotoAndStop(style);
			
			if (params != null)
			{
				mc_object.x = System.setAttribute("x", params, 0);
				mc_object.y = System.setAttribute("y", params, 0);
				dx = System.setAttribute("dx", params, 0);
				dy = System.setAttribute("dy", params, 0);
				dr = System.setAttribute("dr", params, 0);
				mc_object.alpha = System.setAttribute("alpha", params, 1);
				mc_object.rotation = System.setAttribute("rot", params, 0);
				setScale(System.setAttribute("scale", params, 1));
				
				alphaDelay = System.setAttribute("alphaDelay", params, 0);
				alphaDelta = -1 / System.setAttribute("alphaDelta", params, 30);
				codeAnimation = alphaDelay != 0;
				
				if (System.setAttribute("random", params, false))
					mc_object.base.gotoAndStop(System.getRandInt(1, mc_object.base.totalFrames));
					
				if (params["tint"] != null)
					System.tintObject(mc_object, params["tint"]);
			}
		}
		
		// remove self when animation is complete
		override public function step():Boolean 
		{
			if (!isActive())
				return completed;
			updatePosition(dx, dy);
			if (codeAnimation)
			{
				if (alphaDelay > 0)
					alphaDelay--;
				else
				{
					mc_object.alpha += alphaDelta;
					if (mc_object.alpha <= 0)
						destroy();
				}
			}
			else if (mc_object.base.currentFrame == mc_object.base.totalFrames)
			{
				destroy();
			}
			return completed;
		}
	}
}