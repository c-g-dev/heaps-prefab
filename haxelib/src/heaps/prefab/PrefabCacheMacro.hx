package heaps.prefab;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class PrefabCacheMacro
{
    #if macro
    static function build() : Array<Field>
    {
        var fields = Context.getBuildFields();
        var pos = Context.currentPos();
        var tempFolder = MacroTools.getPrefabDir();
        
        function makeExpr(value:Dynamic, pos:Position) : Expr
        {
            if (value == null) return macro null;
            switch (Type.typeof(value))
            {
                case TInt: return Context.makeExpr(value, pos);
                case TFloat: return Context.makeExpr(value, pos);
                case TBool: return Context.makeExpr(value, pos);
                case TObject:
                    var objFields = new Array<ObjectField>();
                    for (field in Reflect.fields(value))
                    {
                        var fieldValue = Reflect.field(value, field);
                        var fieldExpr = makeExpr(fieldValue, pos);
                        objFields.push({ field: field, expr:fieldExpr });
                    }
                    return { expr: EObjectDecl(objFields), pos:pos };
                case TClass(String) : return Context.makeExpr(value, pos);
                case TClass(Array):
                    var arr = new Array<Expr>();
                    for (item in (value:Array<Dynamic>))
                    {
                        arr.push(makeExpr(item, pos));
                    }
                    return { expr: EArrayDecl(arr), pos:pos };
                default:
                    throw "Unsupported type: " + Type.typeof(value);
            }
        }
        
        var pairList = new Array<Expr>();
        
        if (FileSystem.exists(tempFolder) && FileSystem.isDirectory(tempFolder))
        {
            var subfolders = FileSystem.readDirectory(tempFolder).filter(function(entry)
            {
                return FileSystem.isDirectory(tempFolder + entry);
            });
            
            for (subfolder in subfolders)
            {
                var path = tempFolder + subfolder;
                var jsonPath = path + "/prefab.json";
                
                if (FileSystem.exists(jsonPath))
                {
                    var content = File.getContent(jsonPath);
                    var config : Dynamic = Json.parse(content);
                    
                    var pathExpr = Context.makeExpr(path, pos);
                    var configExpr = makeExpr(config, pos);
                    var entryExpr =
                    {
                        expr: EObjectDecl([
                            { field: "path", expr:pathExpr },
                            { field: "config", expr:configExpr }
                        ]),
                        pos: pos
                    };
                    
                    var keyExpr = Context.makeExpr(subfolder, pos);
                    var pairExpr = { expr: EBinop(OpArrow, keyExpr, entryExpr), pos:pos };
                    
                    pairList.push(pairExpr);
                }
            }
        }
        
        var mapExpr = { expr: EArrayDecl(pairList), pos:pos };
        
        var cacheField : Field =
        {
            name: "CACHE",
            access: [AStatic],
            kind: FVar(
                TPath(
                {
                    name: "Map",
                    pack: [],
                    params: [
                        TPType(TPath({ name: "String", pack: [] })),
                        TPType(TPath({ name: "PrefabCacheEntry", pack: [] }))
                    ]
                }),
                mapExpr
            ),
            pos: pos
        };
        
        fields.push(cacheField);
        
        var getField = (macro class
        {
            public static function get(pName:String) : PrefabCacheEntry {
                if (!CACHE.exists(pName))
                {
                    CACHE[pName] = null;
                }
                return CACHE[pName];
            }
        }).fields[0];
        
        fields.push(getField);

        trace("fields: " + fields);
        return fields;
    }
    #end
}