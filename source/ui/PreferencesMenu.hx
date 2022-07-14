package ui;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import haxe.ds.StringMap;

class PreferencesMenu extends Page
{
	public static var preferences:StringMap<Dynamic> = new StringMap<Dynamic>();

	static var defaultPreferences:Array<Array<Dynamic>> = [
		['naughtyness', 'censor-naughty', true],
		['downscroll', 'downscroll', false],
		['ghost tapping', 'ghost-tapping', true],
		['flashing menu', 'flashing-menu', true],
		['camera zooming on beat', 'camera-zoom', true],
		#if !mobile
		['fps counter', 'fps-counter', true], ['memory counter', 'mem-counter', true], ['memory peak counter', 'mem-peak-counter', true],
		#end
		#if (desktop || web)
		['auto pause', 'auto-pause', #if web false #else true #end]
		#end
	];

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;

	override public function new()
	{
		super();
		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = FlxColor.TRANSPARENT;
		camera = menuCamera;
		add(items = new TextMenuList());
		for (pref in defaultPreferences)
		{
			createPrefItem(pref[0], pref[1], pref[2]);
		}
		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
		{
			camFollow.y = items.members[items.selectedIndex].y;
		}
		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;
		items.onChange.add(function(item:TextMenuItem)
		{
			camFollow.y = item.y;
		});
	}

	inline public static function getPref(pref:String)
	{
		return preferences.get(pref);
	}

	inline public static function setPref(identifier:String, value:Dynamic)
	{
		preferences.set(identifier, value);
	}

	public static function initPrefs()
	{
		if (FlxG.save.data.preferences != null)
		{
			preferences = FlxG.save.data.preferences;
		}
		for (pref in defaultPreferences)
		{
			preferenceCheck(pref[1], pref[2]);
			prefUpdate(pref[1]);
		}
		savePrefs();
	}

	public static function savePrefs()
	{
		FlxG.save.data.preferences = preferences;
		FlxG.save.flush();
	}

	public static function preferenceCheck(identifier:String, defaultValue:Dynamic)
	{
		if (getPref(identifier) == null)
		{
			setPref(identifier, defaultValue);
			// trace('set preference!');
		}
		// else
		// {
		// 	trace('found preference: ' + Std.string(getPref(identifier)));
		// }
	}

	public function createPrefItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			preferenceCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				prefToggle(identifier);
			}
			// else
			// {
			// 	trace('swag');
			// }
		});
		if (Type.typeof(value) == TBool)
		{
			createCheckbox(identifier);
		}
		// else
		// {
		// 	trace('swag');
		// }
		// trace(Type.typeof(value));
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), getPref(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		var value:Bool = getPref(identifier);
		value = !value;
		preferences.set(identifier, value);
		savePrefs();
		checkboxes[items.selectedIndex].daValue = value;
		// trace('toggled? ' + Std.string(getPref(identifier)));
		prefUpdate(identifier);
	}

	public static function prefUpdate(identifier:String)
	{
		switch (identifier)
		{
			#if (desktop || web)
			case 'auto-pause':
				FlxG.autoPause = getPref(identifier);
			#end
			#if !mobile
			case 'fps-counter':
				if (Main.fpsCounter != null)
					Main.fpsCounter.showFPS = getPref(identifier);
			case 'mem-counter':
				if (Main.fpsCounter != null)
					Main.fpsCounter.showMemory = getPref(identifier);
			case 'mem-peak-counter':
				if (Main.fpsCounter != null)
					Main.fpsCounter.showMemoryPeak = getPref(identifier);
			#end
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuCamera.followLerp = CoolUtil.camLerpShit(0.05);
		items.forEach(function(item:MenuItem)
		{
			if (item == items.members[items.selectedIndex])
				item.x = 150;
			else
				item.x = 120;
		});
	}

	override public function destroy()
	{
		super.destroy();
		if (FlxG.cameras.list.contains(menuCamera))
			FlxG.cameras.remove(menuCamera);
	}
}
