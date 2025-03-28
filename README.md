# Heaps Prefabs

Bundle full Heaps objects into reusable prefabs, including necessary resources and scripts. 

This allows you to bundle code as a resource without having to use something like hscript, and as far as I can tell, there are no restrictions. 

## Usage

Installing:

```
haxelib install heaps-prefab
```

Including in Heaps project:

```haxe
//place loader macro in hxml
--macro heaps.prefab.Loader.init()

//access prefab resources
var z = Prefabs.MyCustomPrefab(); //assuming MyCustomPrefab.prefab is in your /res folder
s2d.addChild(z);
```

Creating prefab:

```haxe
var prefab = new Prefab("MyCustomBitmapPrefab"); //prefab builder object
prefab.config.src = "MyCustomPrefab_Resource.png"; //name of resource in local /res folder
prefab.config.type = "heaps.prefabs.custom.MyCustomBitmapPrefab"; //path of class to build
prefab.config.builderClass = "heaps.prefab.builders.BitmapBuilder"; //builder for the class, either use a built in one or make one yourself
prefab.build(); //writes MyCustomBitmapPrefab.prefab ready to use
```

This is heavily inspired by [nayata's prefab system](https://github.com/nayata/prefab), which works great but still needs resources and scripts to be manually included in the base heaps projects. This repo uses an extended version of his prefab json schema.

- For further guidance check out the [Guide](https://github.com/c-g-dev/heaps-prefab/wiki/Guide).
- I also have a [HEXE fork](https://github.com/c-g-dev/hexe-fork) which outputs prefabs for this system.
