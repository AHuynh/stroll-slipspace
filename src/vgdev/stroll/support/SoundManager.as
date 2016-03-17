package vgdev.stroll.support 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	public class SoundManager 
	{
		private static var bgm:SoundChannel;		
		private static var sounds:Object = new Object();
		
		[Embed(source="../../../../bgm/bgm_battle1.mp3")]
		private static var bgm_battle1:Class;
		[Embed(source="../../../../bgm/bgm_calm.mp3")]
		private static var bgm_calm:Class;
		[Embed(source="../../../../bgm/bgm_boss.mp3")]
		private static var bgm_boss:Class;
		
		[Embed(source="../../../../sfx/sfx_readybeep1B.mp3")]
		private static var sfx_readybeep1B:Class;
		[Embed(source="../../../../sfx/sfx_readybeep2G.mp3")]
		private static var sfx_readybeep2G:Class;
		
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
		
		[Embed(source="../../../../sfx/sfx_UI_Beep_B.mp3")]
		private static var sfx_UI_Beep_B:Class;	
		[Embed(source = "../../../../sfx/sfx_UI_Beep_C.mp3")]
		private static var sfx_UI_Beep_C:Class;	
		[Embed(source="../../../../sfx/sfx_UI_Beep_Cs.mp3")]
		private static var sfx_UI_Beep_Cs:Class;	
		
		private static var currentBGM:String = "";
		private static var isInit:Boolean = false;
		
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
			
			sounds["sfx_explosionlarge1"] = new sfx_explosionlarge1();
			sounds["sfx_hithull1"] = new sfx_hithull1();
			sounds["sfx_hitshield1"] = new sfx_hitshield1();
			sounds["sfx_laser1"] = new sfx_laser1();
			sounds["sfx_shieldrecharge"] = new sfx_shieldrecharge();
			sounds["sfx_sliphit"] = new sfx_sliphit();
			sounds["sfx_slipjump"] = new sfx_slipjump();
			
			sounds["sfx_UI_Beep_B"] = new sfx_UI_Beep_B();
			sounds["sfx_UI_Beep_C"] = new sfx_UI_Beep_C();
			sounds["sfx_UI_Beep_Cs"] = new sfx_UI_Beep_Cs();
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
			return;
			
			if (currentBGM == music)
				return;
			stopBGM();
			
			var snd:Sound;
			switch (music)
			{
				case "bgm_calm":					snd = new bgm_calm();		break;
				case "bgm_boss":					snd = new bgm_boss();		break;
				case "bgm_battle1":					snd = new bgm_battle1();	break;
				default:
					trace("WARNING: No music located for " + music + "!");
					return;
			}
			currentBGM = music;
			
			var volTransform:SoundTransform = new SoundTransform(volume);
			bgm = snd.play(0, 9999);
			bgm.soundTransform = volTransform;
		}
		
		public static function stopBGM():void
		{
			if (bgm)
			{
				bgm.stop();
				bgm = null;
			}
		}
		
		public static function isBGMplaying():Boolean
		{
			return (bgm != null);
		}
		
		public static function shutUp():void
		{
			SoundMixer.stopAll();
		}
		
	}

}