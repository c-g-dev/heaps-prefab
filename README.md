# Heaps Prefab System

This document outlines a system for portable prefabs in Heaps.io. I'm focusing on 2D for now since I have never actually used h3d, but the setup should extend to 3D without any difference. 

This is heavily inspired by [nayata's prefab system](https://github.com/nayata/prefab), which works great but still needs resources and scripts to be manually included in the base heaps projects. I will probably use an extended version of his prefab json schema. 

## What "Portable" Means
By "portable," I mean getting a prefab up and running should ideally take just two steps:
1. Drop the prefab into the `/res` folder.
2. Add the init macro to the project.

The prefab itself will be a `.zip` file containing all the assets it needs plus a `prefab.json` config file. Here’s the basic structure:

```
/res
/src
prefab.json
```

## Implementation Plan
The init macro will handle the heavy lifting. It will unzip the prefab’s files and dump everything into a `TEMP` folder, using timestamps and caching to only update the folders on file change. All resources (images, sounds, etc.) will get registered with Heaps’ resource system, and any `/src` folders will be added to the classpaths under specific package names.

### How Objects Get Created
To instantiate Heaps objects from the prefab, there will be a "PrefabRenderer" concept. This takes the `prefab.json` and turns it into an actual object. Since different prefabs might need different rendering logic, there will be a resolution order for picking the right PrefabRenderer:

1. The `prefab.json` can explicitly say which renderer class to use.
2. The `/src` folder can include an optional `Prefab.hx` file defining its own renderer.
3. The system will have some built-in renderers based on prefab type.
4. If nothing else works, it will fall back to a basic Object renderer.

These renderers will be hooked up via macros to a "Prefab" object, so at runtime you can do something like:

```
var myObject = Prefab.MyObject();
```


## Open Questions

### Handling Packages in `/src` Folders
Ideally prefabs would be able to be developed as their own standalone projects, then zipped up into the prefab format with a utility tool. This raises some questions about dependencies and folder structure. We could either bundle all dependencies into `/src` or leave it to the end user to sort out.

If `/src` has subfolders, like this:

```
/src
  /dependencies
  Main.hx
```

`Main.hx` sits at the base classpath and imports from `/dependencies`. But when the macro unzips this into `TEMP` and registers it under a new classpath (say, `heaps.prefabs.MyPrefab.Main` or `heaps.prefabs.MyPrefab.dependencies.DependencyExample`), things get tricky.

Can Haxe even handle this cleanly? One idea is to tweak the files during the "copy to TEMP" step—rewrite packages and imports on the fly. But that could be infeasible. You would need to update not just package declarations and imports but also any inline qualified references, enums, etc. Not even sure if it's doable.

The fallback would be enforcing a strict folder structure on prefab sources, like `heaps.prefabs.MyPrefab` for everything. Not really ideal.
