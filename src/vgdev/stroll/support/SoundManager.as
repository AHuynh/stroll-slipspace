package vgdev.stroll.support 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import vgdev.stroll.System;
	
	public class SoundManager 
	{
		private static var channelCurr:SoundChannel;		
		private static var channelNew:SoundChannel;
		private static var sounds:Object = new Object();
		
		private static var currVolume:Number = 0;
		private static var fadeVolume:Number = 0;
		private static var fadeVolumeTgt:Number = 0;
		private static const DELTA_VOL:Number = .004;
		private static var currSTF:SoundTransform = new SoundTransform();
		private static var fadeSTF:SoundTransform = new SoundTransform();
		private static var keepAlive:Boolean = false;
		
		private static var nameCurr:String = "";
		private static var nameNew:String = "";
		
		private static var isInit:Boolean = false;
		
		[Embed(source="../../../../bgm/bgm_calm.mp3")]
		private static var bgm_calm:Class;
		[Embed(source="../../../../bgm/bgm_boss.mp3")]
		private static var bgm_boss:Class;
		[Embed(source="../../../../bgm/bgm_FAILS.mp3")]
		private static var bgm_FAILS:Class;
		
		[Embed(source="../../../../sfx/sfx_readybeep1B.mp3")]
		private static var sfx_readybeep1B:Class;
		[Embed(source="../../../../sfx/sfx_readybeep2G.mp3")]
		private static var sfx_readybeep2G:Class;
		
		[Embed(source="../../../../sfx/sfx_warn2.mp3")]
		private static var sfx_warn2:Class;
		[Embed(source="../../../../sfx/sfx_warn2vitals.mp3")]
		private static var sfx_warn2vitals:Class;
		[Embed(source="../../../../sfx/sfx_ekg.mp3")]
		private static var sfx_ekg:Class;
		
		[Embed(source="../../../../sfx/sfx_electricShock.mp3")]
		private static var sfx_electricShock:Class;
		
		[Embed(source="../../../../sfx/sfx_explosionlarge1.mp3")]
		private static var sfx_explosionlarge1:Class;
		[Embed(source="../../../../sfx/sfx_hithull1.mp3")]
		private static var sfx_hithull1:Class;
		[Embed(source="../../../../sfx/sfx_hitshield1.mp3")]
		private static var sfx_hitshield1:Class;
		[Embed(source="../../../../sfx/sfx_laser1.mp3")]
		private static var sfx_laser1:Class;	
		[Embed(source="../../../../sfx/sfx_shieldrecharge.mp3")]
		private static var sfx_shieldrecharge:Class;	
		[Embed(source="../../../../sfx/sfx_sliphit.mp3")]
		private static var sfx_sliphit:Class;	
		[Embed(source="../../../../sfx/sfx_slipjump.mp3")]
		private static var sfx_slipjump:Class;	
			
		[Embed(source="../../../../sfx/sfx_servo.mp3")]
		private static var sfx_servo:Class;	
		[Embed(source="../../../../sfx/sfx_servoEnd.mp3")]
		private static var sfx_servoEnd:Class;	
		
		[Embed(source="../../../../sfx/sfx_UI_Beep_B.mp3")]
		private static var sfx_UI_Beep_B:Class;	
		[Embed(source = "../../../../sfx/sfx_UI_Beep_C.mp3")]
		private static var sfx_UI_Beep_C:Class;	
		[Embed(source="../../../../sfx/sfx_UI_Beep_Cs.mp3")]
		private static var sfx_UI_Beep_Cs:Class;
		
		[Embed(source="../../../../sfx/sfx_peeps_yell.mp3")]
		private static var sfx_peeps_yell :Class;
		
		[Embed(source="../../../../sfx/sfx_peeps_phase_change.mp3")]
		private static var sfx_peeps_phase_change :Class;
		
		public function SoundManager() 
		{
			trace("WARNING: Should not instantiate SoundManager class!");
		}
		
		public static function init():void
		{
			if (isInit) return;
			isInit = true;
			
			sounds["sfx_readybeep1B"] = new sfx_readybeep1B();
			sounds["sfx_readybeep2G"] = new sfx_readybeep2G();
			
			sounds["sfx_electricShock"] = new sfx_electricShock();
			
			sounds["sfx_warn2"] = new sfx_warn2();
			sounds["sfx_warn2vitals"] = new sfx_warn2vitals();
			sounds["sfx_ekg"] = new sfx_ekg();
			
			sounds["sfx_explosionlarge1"] = new sfx_explosionlarge1();
			sounds["sfx_hithull1"] = new sfx_hithull1();
			sounds["sfx_hitshield1"] = new sfx_hitshield1();
			sounds["sfx_laser1"] = new sfx_laser1();
			sounds["sfx_shieldrecharge"] = new sfx_shieldrecharge();
			sounds["sfx_sliphit"] = new sfx_sliphit();
			sounds["sfx_slipjump"] = new sfx_slipjump();
			
			sounds["sfx_servo"] = new sfx_servo();
			sounds["sfx_servoEnd"] = new sfx_servoEnd();
			
			sounds["sfx_UI_Beep_B"] = new sfx_UI_Beep_B();
			sounds["sfx_UI_Beep_C"] = new sfx_UI_Beep_C();
			sounds["sfx_UI_Beep_Cs"] = new sfx_UI_Beep_Cs();
			
			sounds["sfx_peeps_yell"] = new sfx_peeps_yell();
			sounds["sfx_peeps_phase_change"] = new sfx_peeps_phase_change();
		}
		
		public static function playSFX(sfx:String, volume:Number = 1):void
		{
			if (sounds[sfx] == null)
				trace("WARNING: No sound located for " + sfx + "!");
			else
			{
				var volTransform:SoundTransform = new SoundTransform(volume);
				var sc:SoundChannel = sounds[sfx].play();
				sc.soundTransform = volTransform;
			}
		}
		
		public static function playBGM(music:String, volume:Number = 1):void
		{
			//return;	// DEBUGGING - mute BGM
			
			if (nameCurr == music)
				return;
			stopBGM();
			
			var snd:Sound = getBGM(music);
			nameCurr = music;
			
			var volTransform:SoundTransform = new SoundTransform(volume);
			channelCurr = snd.play(0, 9999);
			channelCurr.soundTransform = volTransform;
			currVolume = volume;
		}
		
		private static function getBGM(music:String):Sound
		{
			switch (music)
			{
				case "bgm_calm":		return new bgm_calm();
				case "bgm_boss":		return new bgm_boss();
				case "bgm_FAILS":		return new bgm_FAILS();	
				default:
					//trace("WARNING: No music located for " + music + "!");
					return null;
			}
		}
		
		public static function getBGMname():String
		{
			return nameCurr;
		}
		
		/**
		 * Fade out the current music and fade in the new music
		 * @param	music		Name of the new BGM, null is OK
		 * @param	volume		Target volume
		 * @param	keepAlive	if true, don't stop the faded BGM (so future fades will resume from a place other than the start)
		 */
		public static function crossFadeBGM(music:String, volume:Number = 1, _keepAlive:Boolean = false):void
		{
			fadeVolume = 0;
			fadeVolumeTgt = volume;
			keepAlive = _keepAlive;
			
			if (!keepAlive || channelNew == null)
			{
				var newBGM:Sound = getBGM(music);
				nameNew = music;
				if (newBGM != null)
					channelNew = newBGM.play(0, 9999);
			}

			fadeSTF.volume = fadeVolume;
			currSTF.volume = currVolume;
		}
		
		public static function step():void
		{
			if (fadeVolume == fadeVolumeTgt) return;
			
			fadeVolume = System.changeWithLimit(fadeVolume, DELTA_VOL, 0, fadeVolumeTgt);
			currVolume = System.changeWithLimit(currVolume, -DELTA_VOL, 0, 1);
			
			fadeSTF.volume = fadeVolume;
			currSTF.volume = currVolume;
			
			if (channelNew != null)
				channelNew.soundTransform = fadeSTF;
			if (channelCurr != null)
				channelCurr.soundTransform = currSTF;
			
			if (fadeSTF.volume == fadeVolumeTgt && currSTF.volume == 0)
			{				
				currVolume = fadeVolumeTgt;
				
				var nameTemp:String = nameCurr;
				var channelTemp:SoundChannel = channelCurr;
			
				nameCurr = nameNew;
				channelCurr = channelNew;
				
				if (keepAlive)
				{
					nameNew = nameTemp;
					channelNew = channelTemp;
				}
				else
				{
					if (channelCurr)
						channelCurr.stop();
					nameCurr = "";
				}
			}
		}
		
		public static function stopBGM():void
		{
			if (channelCurr != null)
			{
				channelCurr.stop();
				channelCurr = null;
				nameCurr = "";
			}
			if (channelNew != null)
			{
				channelNew.stop();
				channelNew = null;
				nameNew = "";
			}
			fadeVolume = fadeVolumeTgt = 1;
		}
		
		public static function isBGMplaying():Boolean
		{
			return (channelCurr != null || nameNew != null);
		}
		
		/**
		 * Stop ALL sounds
		 */
		public static function shutUp():void
		{
			stopBGM();
			SoundMixer.stopAll();
		}
	}
}