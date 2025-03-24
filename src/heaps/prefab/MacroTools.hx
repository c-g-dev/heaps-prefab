package heaps.prefab;

class MacroTools {
    public static function getTempFolder():String {
        #if sys
            var os = Sys.systemName();
            return switch(os.toLowerCase()) {
                case "windows":
                    Sys.getEnv("TEMP") != null ? Sys.getEnv("TEMP") : Sys.getEnv("TMP");
                case "mac":
                    Sys.getEnv("TMPDIR") != null ? Sys.getEnv("TMPDIR") : "/tmp";
                case "linux":
                    Sys.getEnv("TMPDIR") != null ? Sys.getEnv("TMPDIR") : "/tmp";
                default:
                    "/tmp";
            }
        #else
            throw "Temporary folder access is only available on system targets";
        #end
    }
    
    public static function getPrefabDir():String {
        #if prefab_dir
            return haxe.macro.Context.definedValue("prefab_dir");
        #else
        var projectName = Loader.CURRENT_PROJECT_NAME;
        if( projectName == null ) projectName = "default";
        return getTempFolder() + "/heapsprefab/" + projectName + "/";
        #end
    }
}