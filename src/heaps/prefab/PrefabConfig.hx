package heaps.prefab;

typedef Field = { name : String, type:String, data:String, original:String, value:String };

typedef PrefabConfig =
{
	var name : String;
	var type : String;
	@:optional var link : String;

	@:optional var children : Array<PrefabConfig>;
	@:optional var parent : String;

	@:optional var field : Array<Field>;

	@:optional var x : Float;
	@:optional var y : Float;
	@:optional var scaleX : Float;
	@:optional var scaleY : Float;
	@:optional var rotation : Float;

	@:optional var blendMode : String;
	@:optional var visible : Bool;
	@:optional var alpha : Float;

	@:optional var src : String;

	@:optional var width : Float;
	@:optional var height : Float;

	@:optional var smooth : Int;
	
	@:optional var dx : Float;
	@:optional var dy : Float;

	@:optional var color : Int;
	@:optional var align : Int;
	@:optional var range : Int;

	@:optional var speed : Int;
	@:optional var loop : Int;

	@:optional var text : String;
	@:optional var atlas : String;
	@:optional var font : String;
	@:optional var path : String;

	@:optional var builderClass : String;
}