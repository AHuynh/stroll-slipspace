package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.System;
	
	/**
	 * Final boss enemy that generates other enemies
	 * @author Alexander Huynh
	 */
	public class EnemyPortal extends ABST_Enemy 
	{
		public var ELLIPSE_A:Number;
		public var ELLIPSE_B:Number;
		
		public var theta:Number;
		public var dTheta:Number;
		
		private var BAR_WIDTH:Number;	
		private var markedForDeath:int = 0;
		
		public function EnemyPortal(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			attributes["noSpawnFX"] = true;
			attributes["customHitbox"] = true;
			super(_cg, _mc_object, attributes);
			setStyle("portal");
			mc_object.mc_bar.visible = true;
			mc_object.mc_bar.scaleX = mc_object.mc_bar.scaleY = 2;
			BAR_WIDTH = mc_object.mc_bar.bar.width;
			
			ELLIPSE_A = System.ORBIT_1_X;
			ELLIPSE_B = System.ORBIT_1_Y;
			
			theta = System.setAttribute("theta", attributes, 0);
			dTheta = System.setAttribute("dTheta", attributes, 0);
			
			mc_object.x = System.setAttribute("x", attributes, 0);
			mc_object.y = System.setAttribute("y", attributes, 0);
			
			dR = Math.random() > .5 ? 1 : -1;
			
			// 0: Eye, 1: Skull, 2: Squid, 3: Spider, 4: Breeder, 5: Amoeba
			cooldowns = [System.SECOND * 25, System.SECOND * 22, System.SECOND * 45, System.SECOND * 36, System.SECOND * 40, System.SECOND * 28];
			cdCounts = [];
			for (var i:int = 0; i < cooldowns.length; i++)
				cdCounts.push(System.getRandInt(System.SECOND * 5, int(cooldowns[i] * .5)));
			cdCounts[System.getRandInt(0, cooldowns.length - 1)] = 30;
		}
		
		public function multiplyCooldowns(m:Number):void
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				cooldowns[i] *= m;
				cdCounts[i] *= m;
			}
		}
		
		override public function getJammingValue():int 
		{
			return 1000;
		}
		
		override protected function updateWeapons():void 
		{
			for (var i:int = 0; i < cooldowns.length; i++)
			{
				if (cdCounts[i]-- <= 0)
				{
					onFire();
					cdCounts[i] = cooldowns[i];
					for (var j:int = 0; j < cooldowns.length; j++)		// add a spawn grace period to other enemies
						if (i != j)
							cdCounts[j] += System.getRandInt(30, 90);
					//var p:Point = new Point(mc_object.x + (mc_object.x > 0 ? -1 : 1) * System.getRandNum(40, 90) + System.GAME_HALF_WIDTH,
					//						mc_object.y + (mc_object.y > 0 ? -1 : 1) * System.getRandNum(40, 90) + System.GAME_HALF_HEIGHT);
					var p:Point = new Point(mc_object.x + System.getRandNum(-50, 50) + System.GAME_HALF_WIDTH,
											mc_object.y + System.getRandNum(-50, 50) + System.GAME_HALF_HEIGHT);
					switch (i)
					{
						case 0:		cg.level.spawn( { }, p, "Eye");			break;
						case 1:		cg.level.spawn( {"x": p.x, "y":p.y }, p, "Skull");		break;
						case 2:		cg.level.spawn( { }, p, "Squid");		break;
						case 3:		cg.level.spawn( { }, p, "Spider");		break;
						case 4:		cg.level.spawn( { }, p, "Breeder");		break;
						case 5:		cg.level.spawn( { }, p, "Amoeba");		break;
					}
				}
			}
		}
		
		// parameters don't matter here
		override protected function updatePosition(dx:Number, dy:Number):void 
		{
			if (dTheta == 0) return;
			
			theta = (theta + dTheta) % 360;
			mc_object.x = ELLIPSE_A * Math.cos(System.degToRad(theta));
			mc_object.y = ELLIPSE_B * Math.sin(System.degToRad(theta));
		}
		
		override public function step():Boolean
		{
			if (!completed)
			{
				if (markedForDeath == 1)
				{
					if (mc_object.base.currentFrame == mc_object.base.totalFrames)
					{
						markedForDeath = 2;
						destroy();
					}
					return completed;
				}				
				
				updatePrevPosition();
				updatePosition(dX, dY);
				if (!isActive())		// quit if updating position caused this to die
					return completed;
				updateRotation(dR);
				updateWeapons();			
			}
			return completed;
		}
		
		override public function changeHP(amt:Number):Boolean 
		{
			var ret:Boolean = super.changeHP(amt);
			if (hp != 0)
				mc_object.mc_bar.bar.width = (hp / hpMax) * BAR_WIDTH;
			else if (markedForDeath == 0)
			{
				markedForDeath = 1;
				mc_object.base.gotoAndPlay("out");
				mc_object.mc_bar.visible = false;
			}
			return ret;
		}
		
		override protected function updateRotation(dr:Number):void 
		{
			super.updateRotation(dr);
			if (mc_object != null)			// keep bar oriented correctly
				mc_object.mc_bar.rotation = -mc_object.rotation;
		}
		
		override public function destroy():void 
		{
			if (markedForDeath != 2) return;
			if (mc_object && MovieClip(mc_object.parent).contains(mc_object))
				MovieClip(mc_object.parent).removeChild(mc_object);
			mc_object = null;
			cg = null;
			completed = true;
		}
	}
}