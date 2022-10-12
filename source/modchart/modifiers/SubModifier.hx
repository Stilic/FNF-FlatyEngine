package modchart.modifiers;

class SubModifier extends Modifier
{
	var name:String;

	public var parent(default, null):Modifier;

	public function new(name:String, manager:Modchart, ?parent:Modifier)
	{
		super(manager);

		this.name = name;
		this.parent = parent;
	}

	override function getName()
	{
		return name;
	}
}
