package vgdev.stroll.props.projectiles 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import vgdev.stroll.ContainerGame;
	import vgdev.stroll.managers.ManagerEnemy;
	import vgdev.stroll.managers.ManagerProjectile;
	import vgdev.stroll.managers.ManagerGeneric;
	import vgdev.stroll.props.ABST_EMovable;
	import vgdev.stroll.props.ABST_Object;
	import vgdev.stroll.props.enemies.ABST_Enemy;
	import vgdev.stroll.System;
	
	/**
	 * Base class for all projectiles outside of the ship
	 * Supported labels:
	 * 		turret_standard
	 * 		turret_small
	 * 		turret_small_orange
	 * 		pus
	 * @author Alexander Huynh
	 */
	public class ABST_EProjectile extends ABST_EMovable 
	{
		// polar
		protected var spd:Number;
		protected var dir:Number;

		/// Time in frames until this projectile kills itself
		protected var life:int;
		
		/// Base amount of damage to deal
		protected var dmg:Number;
		
		protected var attackColor:uint;
		protected var colorTrans:ColorTransform;
		
		protected var managerProj:ManagerProjectile;
		protected var managerEnem:ManagerEnemy;
												
		public function ABST_EProjectile(_cg:ContainerGame, _mc_object:MovieClip, attributes:Object) 
		{
			super(_cg, _mc_object, System.setAttribute("pos", attributes, new Point()), System.setAttribute("affiliation", attributes, System.AFFIL_ENEMY));
			attackColor = System.setAttribute("attackColor", attributes, System.COL_WHITE);
			dir = System.setAttribute("dir", attributes, 0);
			dmg = System.setAttribute("dmg", attributes, 6.0);
			life = System.setAttribute("life", attributes, 120);
			spd = System.setAttribute("spd", attributes, 2);
			setScale(System.setAttribute("scale", attributes, 1));
			ghost = System.setAttribute("ghost", attributes, false);
			
			managerProj = cg.managerMap[System.M_EPROJECTILE];
			managerEnem = cg.managerMap[System.M_ENEMY];
			
			mc_object.rotation = System.setAttribute("rot", attributes, dir);
			
			// display the correct graphic
			mc_object.gotoAndStop(System.setAttribute("style", attributes, 1));
			if (System.setAttribute("random", attributes, false))
				mc_object.base.gotoAndStop(System.getRandInt(1, mc_object.base.totalFrames));
			
			// tint the graphic if needed
			if (attackColor != System.COL_WHITE && attributes["useTint"] != null)
			{
				colorTrans = new ColorTransform();
				colorTrans.color = attackColor;
				mc_object.transform.colorTransform = colorTrans;
			}
		}
		
		override public function step():Boolean
		{
			if (--life <= 0)
				destroy();
			else
			{
				updatePosition(System.forward(spd, dir, true), System.forward(spd, dir, false));	
				updateCollisions();
			}
			return completed;
		}
		
		/**
		 * Do things based on if this projectile has hit other objects
		 */
		protected function updateCollisions():void
		{
			var collide:ABST_Object = managerProj.collideWithOther(this);
			if (collide != null)								// projectile has collided with another projectile
			{
				destroy();
				(collide as ABST_EProjectile).destroy();
			}
			else if (getAffiliation() == System.AFFIL_PLAYER)	// projectile is a player's; check for hits on enemies
			{
				var hitEnemy:ABST_Enemy = managerEnem.collideWithOther(this, true) as ABST_Enemy;		// check for any hit
				if (hitEnemy != null)
				{
					destroy();
					(hitEnemy as ABST_Enemy).changeHP(-dmg);
				}
			}
		}
		
		override protected function onShipHit():void
		{
			cg.ship.damage(dmg, attackColor);
			addShipDebris();
		}
		
		public function addShipDebris():void
		{
			if (cg.ship.getShields() == 0 && getAffiliation() == System.AFFIL_ENEMY)
			{
				for (var i:int = System.getRandInt(0, 3); i >= 0; i--)
					cg.addDecor("gib_ship", {
												"x": System.getRandNum(mc_object.x - 5, mc_object.x + 5),
												"y": System.getRandNum(mc_object.y - 5, mc_object.y + 5),
												"dx": System.getRandNum( -2, 2),
												"dy": System.getRandNum( -2, 2),
												"dr": System.getRandNum( -9, 9),
												"rot": System.getRandNum(0, 360),
												"scale": System.getRandNum(.5, 1),
												"alphaDelay": 30 + System.getRandInt(0, 60),
												"alphaDelta": 15,
												"random": true
											});
			}
		}
	}
}