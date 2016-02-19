package vgdev.stroll.support 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	
	public class SoundManager 
	{
		private static var bgm:SoundChannel;		
		private static var sounds:Object = new Object();
		
		[Embed(source="../../../../bgm/bgm_battle1.mp3")]
		private static var bgm_battle1:Class;
		
		[Embed(source="../../../../sfx/sfx_bell.mp3")]
		private static var sfx_bell:Class;
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
			
			sounds["sfx_bell"] = new sfx_bell();
			sounds["sfx_explosionlarge1"] = new sfx_explosionlarge1();
			sounds["sfx_hithull1"] = new sfx_hithull1();
			sounds["sfx_hitshield1"] = new sfx_hitshield1();
			sounds["sfx_laser1"] = new sfx_laser1();
			sounds["sfx_shieldrecharge"] = new sfx_shieldrecharge();
			sounds["sfx_sliphit"] = new sfx_sliphit();
			sounds["sfx_slipjump"] = new sfx_slipjump();
		}
		
		public static function playSFX(sfx:String):void
		{
			if (sounds[sfx] == null)
				trace("WARNING: No sound located for " + sfx + "!");
			else
				sounds[sfx].play();
		}
		
		public static function playBGM(music:String):void
		{
			if (currentBGM == music)
				return;
			stopBGM();
			
			var snd:Sound;
			switch (music)
			{
				case "bgm_battle1":					snd = new bgm_battle1();		break;
				default:
					trace("WARNING: No music located for " + music + "!");
					return;
			}
			currentBGM = music;
			
			bgm = snd.play(0, 9999);
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