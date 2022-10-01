package;

#if sys
import sys.FileSystem;
#end
import lime.utils.Assets;
import flixel.util.FlxSave;
import polymod.Polymod;
import polymod.fs.PolymodFileSystem;

typedef Mod =
{
	var metadata:ModMetadata;
	var enabled:Bool;
}

class ModHandler
{
	public static final MOD_DIRECTORY:String = './mods';
	public static final GLOBAL_MOD_ID:String = 'global';

	public static var modList(default, null):Array<Mod> = [];

	static var save:FlxSave;

	public static function init()
	{
		save = new FlxSave();
		save.bind('mod_list', 'ninjamuffin99');
		if (save.data.modList == null)
			save.data.modList = new Map<String, Bool>();

		#if sys
		if (!FileSystem.exists(MOD_DIRECTORY))
			FileSystem.createDirectory(MOD_DIRECTORY);
		#end

		reloadModList();
		reloadPolymod();
	}

	public static function reloadModList()
	{
		modList = [];

		var savedModList:Map<String, Bool> = cast save.data.modList;
		var doSave:Bool = false;
		for (modMetadata in Polymod.scan(MOD_DIRECTORY))
		{
			if (modMetadata.id == GLOBAL_MOD_ID)
				continue;

			if (!savedModList.exists(modMetadata.id))
			{
				doSave = true;
				savedModList.set(modMetadata.id, true);
			}
			modList.push({metadata: modMetadata, enabled: savedModList.get(modMetadata.id)});
		}

		if (doSave)
		{
			save.data.modList = savedModList;
			save.flush();
		}
	}

	public static function saveModList()
	{
		var savedModList:Map<String, Bool> = new Map<String, Bool>();
		for (mod in modList)
			savedModList.set(mod.metadata.id, mod.enabled);
		save.data.modList = savedModList;
		save.flush();
	}

	public static function reloadPolymod()
	{
		var dirs:Array<String> = [];
		if (PolymodFileSystem.makeFileSystem(null, {modRoot: MOD_DIRECTORY}).exists('$MOD_DIRECTORY/$GLOBAL_MOD_ID'))
			dirs.push(GLOBAL_MOD_ID);
		for (mod in modList)
		{
			if (mod.enabled)
				dirs.push(mod.metadata.id);
		}

		var libs:Map<String, String> = new Map<String, String>();
		libs.set('default', './preload');
		libs.set('shared', './');
		@:privateAccess
		for (lib in Assets.libraryPaths.keys())
		{
			if (!libs.exists(lib))
				libs.set(lib, './$lib');
		}

		Polymod.init({
			modRoot: MOD_DIRECTORY,
			dirs: dirs,
			framework: FLIXEL,
			frameworkParams: {
				assetLibraryPaths: libs
			}
		});
	}
}
