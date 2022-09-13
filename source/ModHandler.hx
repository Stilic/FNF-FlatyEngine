package;

import flixel.util.FlxSave;
import polymod.Polymod;

typedef Mod =
{
	var metadata:ModMetadata;
	var enabled:Bool;
}

class ModHandler
{
	static final MOD_DIRECTORY:String = './mods';

	public static var modList(default, null):Array<Mod> = [];

	static var save:FlxSave;

	public static function init()
	{
		if (save == null)
		{
			save = new FlxSave();
			save.bind('mod_list', 'ninjamuffin99');
			if (save.data.modList == null)
				save.data.modList = new Map<String, Bool>();
		}
		reloadModList();
		saveModList();
		reloadPolymod();
	}

	public static function reloadModList()
	{
		modList = [];
		var savedModList:Map<String, Bool> = cast save.data.modList;
		for (modMetadata in Polymod.scan(MOD_DIRECTORY))
			modList.push({metadata: modMetadata, enabled: savedModList.exists(modMetadata.id) ? savedModList.get(modMetadata.id) : true});
	}

	public static function saveModList()
	{
		var savedModList:Map<String, Bool> = new Map<String, Bool>();
		for (mod in modList)
			savedModList.set(mod.metadata.id, mod.enabled);
		save.data.modList = modList;
		save.flush();
	}

	public static function reloadPolymod()
	{
		var dirs:Array<String> = [];
		for (mod in modList)
		{
			// trace(mod.metadata.id, mod.enabled);
			if (mod.enabled)
				dirs.push(mod.metadata.id);
		}
		Polymod.init({
			modRoot: MOD_DIRECTORY,
			dirs: dirs,
			framework: FLIXEL,
			frameworkParams: {
				assetLibraryPaths: [
					'default' => './preload',
					'songs' => 'songs',
					'shared' => './',
					'week2' => './week2',
					'week3' => './week3',
					'week4' => './week4',
					'week5' => './week5',
					'week6' => './week6',
					'week7' => './week7'
				]
			}
		});
	}
}
