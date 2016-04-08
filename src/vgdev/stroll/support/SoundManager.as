package vgdev.stroll.support 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import vgdev.stroll.System;
	
	public class SoundManager 
	{
		private static var sounds:Object = new Object();
		/// The currently-playing song (or the one being faded out)
		private static var channelCurr:SoundChannel;			
		/// The song fading in	
		private static var channelNew:SoundChannel;
		
		private static var currVolume:Number = 0;
		private static var fadeVolume:Number = 0;
		private static var fadeVolumeTgt:Number = 0;
		private static const DELTA_VOL:Number = .004;
		private static var currSTF:SoundTransform = new SoundTransform();
		private static var fadeSTF:SoundTransform = new SoundTransform();
		private static var keepAlive:Boolean = false;
		
		/// The name of the currently-playing song (or the one being faded out)
		private static var nameCurr:String = "";
		/// The name of the song fading in
		private static var nameNew:String = "";
		
		private static var isInit:Boolean = false;
		
		[Embed(source="../../../../bgm/bgm_calm.mp3")]
		private static var bgm_calm:Class;
		[Embed(source="../../../../bgm/bgm_boss.mp3")]
		private static var bgm_boss:Class;
		[Embed(source="../../../../bgm/bgm_FAILS.mp3")]
		private static var bgm_FAILS:Class;
		[Embed(source="../../../../bgm/bgm_title.mp3")]
		private static var bgm_title:Class;
		
		[Embed(source="../../../../bgm/bgm_1a_here_we_go.mp3")]
		private static var bgm_1a_here_we_go:Class;
		[Embed(source = "../../../../bgm/bgm_1a2_hey_somethings_wrong.mp3")]
		private static var bgm_1a2_hey_somethings_wrong:Class;
		[Embed(source = "../../../../bgm/bgm_1bc_oh_snap.mp3")]
		private static var bgm_1bc_oh_snap:Class;
		[Embed(source = "../../../../bgm/bgm_1d_nobody_can_save_us.mp3")]
		private static var bgm_1d_nobody_can_save_us:Class;
		[Embed(source = "../../../../bgm/bgm_2a_I_spoke_too_soon.mp3")]
		private static var bgm_2a_I_spoke_too_soon:Class;
		[Embed(source = "../../../../bgm/bgm_2b_your_new_captain_speaking.mp3")]
		private static var bgm_2b_your_new_captain_speaking:Class;
		[Embed(source="../../../../bgm/bgm_the_final_holdout.mp3")]
		private static var bgm_the_final_holdout:Class;
		[Embed(source="../../../../bgm/bgm_victory.mp3")]
		private static var bgm_victory:Class;
		
		[Embed(source="../../../../sfx/sfx_readybeep1B.mp3")]
		private static var sfx_readybeep1B:Class;
		[Embed(source="../../../../sfx/sfx_readybeep2G.mp3")]
		private static var sfx_readybeep2G:Class;
		[Embed(source="../../../../sfx/sfx_readybeep3E.mp3")]
		private static var sfx_readybeep3E:Class;
		
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
		[Embed(source="../../../../sfx/sfx_explosion1.mp3")]
		private static var sfx_explosion1:Class;
		[Embed(source="../../../../sfx/sfx_explosion2.mp3")]
		private static var sfx_explosion2:Class;
		[Embed(source="../../../../sfx/sfx_fire_ignited.mp3")]
		private static var sfx_fire_ignited:Class;
		
		[Embed(source="../../../../sfx/sfx_hithull1.mp3")]
		private static var sfx_hithull1:Class;
		[Embed(source="../../../../sfx/sfx_hitshield1.mp3")]
		private static var sfx_hitshield1:Class;
		
		[Embed(source="../../../../sfx/sfx_laser1.mp3")]
		private static var sfx_laser1:Class;
		[Embed(source="../../../../sfx/sfx_monsterdeath_1.mp3")]
		private static var sfx_monsterdeath_1:Class;
		[Embed(source="../../../../sfx/sfx_monsterdeath_2.mp3")]
		private static var sfx_monsterdeath_2:Class;
		[Embed(source="../../../../sfx/sfx_monsterdeath_3.mp3")]
		private static var sfx_monsterdeath_3:Class;
		[Embed(source="../../../../sfx/sfx_monsterdeath_4.mp3")]
		private static var sfx_monsterdeath_4:Class;
		[Embed(source="../../../../sfx/sfx_monsterdeath_5.mp3")]
		private static var sfx_monsterdeath_5:Class;
		[Embed(source="../../../../sfx/sfx_monsterdeath_6.mp3")]
		private static var sfx_monsterdeath_6:Class;
		[Embed(source="../../../../sfx/sfx_monsterdeath_7.mp3")]
		private static var sfx_monsterdeath_7:Class;
		
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
			sounds["sfx_readybeep3E"] = new sfx_readybeep3E();
			
			sounds["sfx_electricShock"] = new sfx_electricShock();
			
			sounds["sfx_warn2"] = new sfx_warn2();
			sounds["sfx_warn2vitals"] = new sfx_warn2vitals();
			sounds["sfx_ekg"] = new sfx_ekg();
			
			sounds["sfx_explosionlarge1"] = new sfx_explosionlarge1();
			sounds["sfx_explosion1"] = new sfx_explosion1();
			sounds["sfx_explosion2"] = new sfx_explosion2();
			sounds["sfx_hithull1"] = new sfx_hithull1();
			sounds["sfx_hitshield1"] = new sfx_hitshield1();
			sounds["sfx_fire_ignited"] = new sfx_fire_ignited();
			sounds["sfx_laser1"] = new sfx_laser1();
			sounds["sfx_shieldrecharge"] = new sfx_shieldrecharge();
			sounds["sfx_sliphit"] = new sfx_sliphit();
			sounds["sfx_slipjump"] = new sfx_slipjump();
			sounds["sfx_monsterdeath_1"] = new sfx_monsterdeath_1();
			sounds["sfx_monsterdeath_2"] = new sfx_monsterdeath_2();
			sounds["sfx_monsterdeath_3"] = new sfx_monsterdeath_3();
			sounds["sfx_monsterdeath_4"] = new sfx_monsterdeath_4();
			sounds["sfx_monsterdeath_5"] = new sfx_monsterdeath_5();
			sounds["sfx_monsterdeath_6"] = new sfx_monsterdeath_6();
			sounds["sfx_monsterdeath_7"] = new sfx_monsterdeath_7();
			
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
			if (sfx == "sfx_explosionlarge1")
				sfx = System.getRandFrom(["sfx_explosionlarge1", "sfx_explosion1", "sfx_explosion2"]);
			else if (sfx == "sfx_monsterdeath")
				sfx += "_" + System.getRandInt(1, 7).toString();
				
			if (sounds[sfx] == null)
				trace("WARNING: No sound located for " + sfx + "!");
			else
			{
				var volTransform:SoundTransform = new SoundTransform(volume);
				var sc:SoundChannel = sounds[sfx].play();
				sc.soundTransform = volTransform;
			}
		}
		
		public static function playBGM(music:String, volume:Number = 1, once:Boolean = false):void
		{
			//return;	// DEBUGGING - mute BGM
			
			if (nameCurr == music)
				return;
			stopBGM();
			
			var snd:Sound = getBGM(music);
			nameCurr = music;
			
			var volTransform:SoundTransform = new SoundTransform(volume);
			channelCurr = snd.play(0, once ? 1 : 9999);
			channelCurr.soundTransform = volTransform;
			currVolume = volume;
		}
		
		/**
		 * Play a pair of tracks with the same length simultaneously
		 * @param	musicMain			
		 * @param	musicSecondary
		 * @param	volume
		 */
		public static function playBGMpaired(musicMain:String, musicSecondary:String, volume:Number = 1):void
		{			
			playBGM(musicMain, volume);
			
			var snd:Sound = getBGM(musicSecondary);
			nameNew = musicSecondary;
			
			var volTransform:SoundTransform = new SoundTransform(0);
			channelNew = snd.play(0, 9999);
			channelNew.soundTransform = volTransform;
		}
		
		private static function getBGM(music:String):Sound
		{
			switch (music)
			{
				case "bgm_calm":							return new bgm_calm();
				case "bgm_boss":							return new bgm_boss();
				case "bgm_FAILS":							return new bgm_FAILS();	
				case "bgm_1a_here_we_go":					return new bgm_1a_here_we_go();
				case "bgm_1a2_hey_somethings_wrong":		return new bgm_1a2_hey_somethings_wrong();
				case "bgm_1bc_oh_snap":						return new bgm_1bc_oh_snap();
				case "bgm_1d_nobody_can_save_us":			return new bgm_1d_nobody_can_save_us();
				case "bgm_2a_I_spoke_too_soon":				return new bgm_2a_I_spoke_too_soon();
				case "bgm_2b_your_new_captain_speaking":	return new bgm_2b_your_new_captain_speaking();
				case "bgm_the_final_holdout":				return new bgm_the_final_holdout();
				case "bgm_victory":							return new bgm_victory();
				case "bgm_title":							return new bgm_title();
				default:
					return null;
			}
		}
		
		public static function getBGMname():String
		{
			return nameCurr;
		}
		
		/**
		 * Fade out the current music and fade in the new music
		 * @param	music		Name of the new BGM, null is OK (if keepAlive false, new music is nothing; else use 'saved' music)
		 * @param	volume		Target volume (-1 to use same volume as current track)
		 * @param	keepAlive	if true, don't stop the faded BGM (so future fades will resume from a place other than the start)
		 */
		public static function crossFadeBGM(music:String, volume:Number = 1, _keepAlive:Boolean = false):void
		{			
			if (volume == -1)
				volume = currVolume;
			
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
				
				// save a reference to the song that has been faded out
				var nameTemp:String = nameCurr;
				var channelTemp:SoundChannel = channelCurr;
			
				// make the current song the song that was fading in
				nameCurr = nameNew;
				channelCurr = channelNew;
				
				// if keep alive, make the song that will be fade in the song that was faded out
				if (keepAlive)
				{
					nameNew = nameTemp;
					channelNew = channelTemp;
				}
				// otherwise, stop the song that was faded out
				else
				{
					nameNew = "";
					if (channelTemp)
						channelTemp.stop();
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