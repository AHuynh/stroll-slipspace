package vgdev.stroll.props.enemies 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.consoles.Omnitool;
	import vgdev.stroll.props.projectiles.ABST_IProjectile;
	import vgdev.stroll.props.projectiles.IProjectileGeneric;
	import vgdev.stroll.System;
	
	/**
	 * Boarder that shoots at a console
	 * @author Alexander Huynh
	 */
	public class BoarderShooter extends ABST_Boarder 
	{
		protected var cooldown:int = 0;
		protected const COOLDOWN:int = 40;
		
		protected var dmg:int = 5;
		protected var tgt:ABST_Object;
		
		protected var offY:int = 0;
		
		public function BoarderShooter(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, _hitMask, attributes);
			setStyle("bslime");
			cg.addDecor("spawn", { "x": mc_object.x, "y": mc_object.y, "scale": 0.5 } );
			speed = 1.2;
			
			hp = hpMax = 90;
		}
		
		override protected function findNewPOI():void
		{
			var giveUp:int = 4;
			do {
				tgt = System.getRandFrom(cg.consoles);
				pointOfInterest = new Point(tgt.mc_object.x, tgt.mc_object.y);
				giveUp--;
			} while (giveUp > 0 &&
					(tgt is Omnitool ||
					System.getDistance(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y) < POI_RANGE ||
					!System.hasLineOfSight(this, pointOfInterest)));
		}
		
		override public function step():Boolean 
		{
			if (hp == 0) return completed;
			
			if (pointOfInterest != null)
			{
				var los:Boolean = System.hasLineOfSight(this, pointOfInterest);
				if (state != STATE_ATTACK && los &&
					System.getDistance(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y) < RANGE * 5 && 
					System.hasLineOfSight(this, pointOfInterest, new Point(-2, 0)) && System.hasLineOfSight(this, pointOfInterest, new Point( 2, 0)) &&
					System.hasLineOfSight(this, pointOfInterest, new Point(0, -2)) && System.hasLineOfSight(this, pointOfInterest, new Point(0, 2)))
				{
					state = STATE_ATTACK;
					path = [];
				}
				else if (state == STATE_ATTACK && !los)
					state = STATE_IDLE;
			}

			switch (state)
			{
				case STATE_IDLE:
					findNewPOI();
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
						state = STATE_IDLE;
						onArrive();
					}
				break;
				case STATE_ATTACK:
					if (tgt == null || tgt.getHP() <= 0)
					{
						state = STATE_IDLE;
						tgt = null;
						pointOfInterest = null;
						return completed;
					}
					if (--cooldown <= 0)
					{
						cooldown = COOLDOWN;
						var shot:ABST_IProjectile = new IProjectileGeneric(cg, new SWC_Bullet(), hitMask,
																	{	 
																		"affiliation":	System.AFFIL_ENEMY,
																		"dir":			System.getAngle(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y),
																		"dmg":			dmg,
																		"life":			30,
																		"pos":			new Point(mc_object.x, mc_object.y + offY),
																		"spd":			4,
																		"style":		"small_laser",
																		"scale":		0.75
																	});
						cg.addToGame(shot, System.M_IPROJECTILE);
					}
				break;
			}			
			return completed;
		}
		
		override public function destroy():void 
		{
			if (cg != null)
				cg.addSparksAt(1, new Point(mc_object.x, mc_object.y));
			super.destroy();
		}
	}
}