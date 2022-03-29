package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import fpsCounters.*;
#if android //only android will use those
import sys.FileSystem;
import lime.app.Application;
import lime.system.System;
import android.*;
#end
class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

        public static var instance:Main;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;

		super();
		SUtil.gameCrashCheck();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

          

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end     

		ClientPrefs.loadDefaultKeys();
		SUtil.doTheCheck();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		setFpsCounter();
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
	public function setFpsCounter()
	{
		switch (ClientPrefs.FpsCounterType)
		{
			case 'Kade':
				public static var fpsVar:KadeEngineFPS;
				public static var bitmapFPS:Bitmap;
				fpsVar = new KadeEngineFPS(10, 3, 0xFFFFFF);
				bitmapFPS = ImageOutline.renderImage(fpsVar, 1, 0x000000, true);
			        bitmapFPS.smoothing = true;
				addChild(fpsVar);

			case 'PE':
				public static var fpsVar:PE-FPS;
				fpsVar = new PE-FPS(10, 3, 0xFFFFFF);
		                addChild(fpsVar);

			case 'default+':
				public static var fpsVar:FPS;
			        public static var memoryCounter:MemoryCounter;
				fpsVar = new FPS(10, 3, 0xFFFFFF);
		                addChild(fpsVar);

			        memoryCounter = new MemoryCounter(10, 3, 0xFFFFFF);
				addChild(memoryCounter);
				if(memoryCounter != null) {
				memoryCounter.visible = ClientPrefs.memoryCounter;
				}
		}

}
