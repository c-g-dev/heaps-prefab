package heaps.prefab;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class PrefabsMacro {
    #if macro

    static function convertTypes(value: String): String {
        switch(value) {
            case "prefab": return "h2d.Object";
            case "bitmap": return "h2d.Bitmap";
            case "object": return "h2d.Object";
            default : return value;
        }
    }

    static function build(): Array<Field> {
        
        var fields = Context.getBuildFields();
        var pos = Context.currentPos();

        var tempFolder = MacroTools.getPrefabDir();

        
        function parseTypePath(typeStr: String): TypePath {
            var parts = typeStr.split(".");
            var name = parts.pop();
            var pack = parts;
            return {pack: pack, name: name};
        }

        
        function makeExpr(value: Dynamic, pos: Position): Expr {
            if (value == null) return macro null;
            switch (Type.typeof(value)) {
                case TInt: return Context.makeExpr(value, pos);
                case TFloat: return Context.makeExpr(value, pos);
                case TBool: return Context.makeExpr(value, pos);
                case TObject:
                    var objFields = new Array<ObjectField>();
                    for (field in Reflect.fields(value)) {
                        if( field == "type" ) {
                            var fieldValue = convertTypes(Reflect.field(value, field));
                            var fieldExpr = makeExpr(fieldValue, pos);
                            objFields.push({field: field, expr: fieldExpr});
                        }
                        else {
                            var fieldValue = Reflect.field(value, field);
                            var fieldExpr = makeExpr(fieldValue, pos);
                            objFields.push({field: field, expr: fieldExpr});
                        }
                    }
                    return {expr: EObjectDecl(objFields), pos: pos};
                case TClass(String): return Context.makeExpr(value, pos);
                case TClass(Array):
                    var arr = new Array<Expr>();
                    for (item in (value : Array<Dynamic>)) {
                        arr.push(makeExpr(item, pos));
                    }
                    return {expr: EArrayDecl(arr), pos: pos};
                default:
                    throw "Unsupported type: " + Type.typeof(value);
            }
        }

        
        if (FileSystem.exists(tempFolder) && FileSystem.isDirectory(tempFolder)) {
            
            var subfolders = FileSystem.readDirectory(tempFolder).filter(function(entry) {
                return FileSystem.isDirectory(tempFolder + entry);
            });

            for (subfolder in subfolders) {
                var prefabJsonPath = tempFolder + subfolder + "/prefab.json";
                if (FileSystem.exists(prefabJsonPath)) {
                    
                    var content = File.getContent(prefabJsonPath);
                    var config: Dynamic = Json.parse(content);

                    
                    if (Reflect.hasField(config, "type") && Std.is(config.type, String)) {
                        var typeStr: String = convertTypes(config.type);
                        var typePath = parseTypePath(typeStr);

                        
                        var fieldType = TFunction([], TPath(typePath));
                        
                        var pathExpr = Context.makeExpr(tempFolder + subfolder, pos);

                        var configExpr = makeExpr(config, pos);

                        var typeExpr = Context.parse(typeStr, pos);
                        
                        var getBuilderExpr = {
                            expr: ECall(
                                {expr: EField({expr: EConst(CIdent("PrefabBuilders")), pos: pos}, "getBuilder"), pos: pos},
                                [
                                    typeExpr,
                                    pathExpr,
                                    configExpr
                                ]
                            ),
                            pos: pos
                        };

                        // .createConstructor()
                        var callExpr = {
                            expr: ECall(
                                {expr: EField(getBuilderExpr, "createConstructor"), pos: pos},
                                []
                            ),
                            pos: pos
                        };

                        // Define the field
                        var field: Field = {
                            name: subfolder,
                            access: [APublic, AStatic],
                            kind: FVar(fieldType, callExpr),
                            pos: pos
                        };

                        fields.push(field);
                    }
                }
            }
        }

        return fields;
    }
    #end
}

