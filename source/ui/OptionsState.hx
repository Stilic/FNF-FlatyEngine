package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.ds.StringMap;

class OptionsState extends MusicBeatState
{
	static final defaultPage:String = 'options';

	public var pages:StringMap<Page> = new StringMap<Page>();
	public var currentName:String = defaultPage;
	public var currentPage(get, never):Page;

	inline function get_currentPage()
		return pages.get(currentName);

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFEA71FD;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);
		var optionsmenu:OptionsMenu = addPage(defaultPage, new OptionsMenu());
		var preferencesmenu:PreferencesMenu = addPage('preferences', new PreferencesMenu());
		var controlsmenu:ControlsMenu = addPage('controls', new ControlsMenu());
		if (optionsmenu.hasMultipleOptions())
		{
			optionsmenu.onExit.add(exitToMainMenu);
			controlsmenu.onExit.add(resetPage);
			preferencesmenu.onExit.add(resetPage);
		}
		else
		{
			controlsmenu.onExit.add(exitToMainMenu);
			setPage('controls');
		}
		super.create();
	}

	function addPage(name:String, page:Page):Dynamic
	{
		page.onSwitch.add(setPage);
		pages.set(name, page);
		add(page);
		page.exists = name == currentName;
		return page;
	}

	function setPage(name:String)
	{
		if (pages.exists(currentName))
		{
			currentPage.exists = false;
		}
		currentName = name;
		if (pages.exists(currentName))
		{
			currentPage.exists = true;
		}
	}

	function resetPage()
	{
		setPage(defaultPage);
	}

	function exitToMainMenu()
	{
		currentPage.enabled = false;
		MusicBeatState.switchState(new MainMenuState());
	}
}
