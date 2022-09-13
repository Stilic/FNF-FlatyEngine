package;

import haxe.ds.StringMap;
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

	static var save:FlxSave;

	public static var loadedMods(default, null):Array<Mod> = [];

	public static function init()
	{
		if (save == null)
		{
			save = new FlxSave();
			save.bind('mod_list', 'ninjamuffin99');
			if (save.data.modList == null)
				save.data.modList = new StringMap<Bool>();
		}
		reloadMods();
		applyChanges();
	}

	public static function applyChanges()
	{
		var modList:StringMap<Bool> = new StringMap<Bool>();
		for (mod in loadedMods)
			modList.set(mod.metadata.id, mod.enabled);
		save.data.modList = modList;
		save.flush();

		var dirs:Array<String> = [];
		for (mod in loadedMods)
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

	public static function reloadMods()
	{
		var modList:StringMap<Bool> = cast save.data.modList;
		loadedMods = [];
		for (modMetadata in Polymod.scan(MOD_DIRECTORY))
		{
			if (!modList.exists(modMetadata.id))
				modList.set(modMetadata.id, true);
			loadedMods.push({metadata: modMetadata, enabled: modList.get(modMetadata.id)});
		}
	}
}
