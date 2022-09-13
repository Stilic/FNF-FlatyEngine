package ui;

class OptionsMenu extends Page
{
	var items:TextMenuList;

	override public function new()
	{
		super();
		add(items = new TextMenuList());
		createItem('preferences', function()
		{
			onSwitch.dispatch('preferences');
		});
		createItem('controls', function()
		{
			onSwitch.dispatch('controls');
		});
		createItem('exit', exit);
	}

	public function createItem(label:String, ?callback:Void->Void, ?fireInstantly:Bool = false)
	{
		var item:TextMenuItem = items.createItem(0, 100 + 100 * items.length, label, AtlasFont.Bold, callback);
		item.fireInstantly = fireInstantly;
		item.screenCenter(X);
		return item;
	}

	override function set_enabled(state:Bool)
	{
		items.enabled = state;
		return super.set_enabled(state);
	}

	public function hasMultipleOptions()
	{
		return items.length > 2;
	}
}
