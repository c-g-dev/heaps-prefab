# Heaps Prefab System

This document outlines a system for portable prefabs in Heaps.io. I'm focusing on 2D for now since I have never actually used h3d, but the setup should extend to 3D without any difference. 

This is heavily inspired by [nayata's prefab system](https://github.com/nayata/prefab), which works great but still needs resources and scripts to be manually included in the base heaps projects. I will probably use an extended version of his prefab json schema. 

## Current Status
Implementation complete. Prefabs work front-to-back, rendering in Heaps, with contained resources and behaviors. Definitely going to be edge cases that don't work, but basic functionality is fine. After a bit of cleanup this will be ready for public release.

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