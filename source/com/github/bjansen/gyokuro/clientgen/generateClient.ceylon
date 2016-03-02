import ceylon.collection {
    HashMap,
    MutableMap,
    ArrayList
}
import ceylon.file {
    Directory,
    Nil,
    File,
    createFileIfNil,
    Writer
}
import ceylon.language.meta.declaration {
    FunctionDeclaration,
    Package,
    ValueDeclaration,
    OpenClassType
}
import ceylon.net.http {
    AbstractMethod
}

import com.github.bjansen.gyokuro.core.internal {
    annotationScanner
}

"Run the module `com.github.bjansen.gyokuro.clientgen`."
shared void generateClient(String contextRoot, Package pkg, String moduleName, Directory output) {
    value outResource = output.childResource(moduleName.replace(".", "/"));
    Directory moduleDir;
    
    if (is Directory outResource) {
        moduleDir = outResource;
    } else if (is Nil outResource) {
        moduleDir = outResource.createDirectory(true);
    } else {
        throw Exception("Can't write to directory ``outResource.path.absolutePath``");
    }
    
    createModuleCeylon(moduleName, moduleDir);
    createClientCeylon(contextRoot, pkg, moduleDir);
}

void createModuleCeylon(String moduleName, Directory outDir) {
    doWithFile(outDir, "module.ceylon", (writer) {
        writer.write("native(\"js\")
                      module ``moduleName`` \"0.1.0\" {
                          import ceylon.interop.browser \"1.2.1\";
                      }                    
                      "
        );
    });
}

alias Route => [String, [Object, FunctionDeclaration], {AbstractMethod+}];

void createClientCeylon(String contextRoot, Package pkg, Directory outDir) {
    doWithFile(outDir, "client.ceylon", (writer) {
        value routesByObject = Multimap<String, Route>();
        
        annotationScanner.scanControllersInPackage(contextRoot, pkg, (path, handler, methods) {
            routesByObject.put(className(handler[0]), [path, handler, methods]);
        });

        writer.writeLine("import ceylon.interop.browser {
                              newXMLHttpRequest
                          }
                          import ceylon.interop.browser.dom {
                              Event
                          }

                          ");

        for (obj -> routes in routesByObject) {
            value objName = obj.spanFrom(obj.lastOccurrence('.')?.plus(1) else 0);

            writer.writeLine("shared object ``uncapitalize(objName)`` {
                              ");
            
            for (route in routes) {
                value [path, handler, methods] = route;
                methods.each((meth) {
                    value name = methods.size == 1
                                 then handler[1].name
                                 else meth.string.lowercased + capitalize(handler[1].name);
                    
                    value params = ", ".join(handler[1].parameterDeclarations.map((p) {
                        if (is ValueDeclaration p, is OpenClassType t = p.openType) {
                            return t.declaration.name + " " + p.name;
                        }
                        return null;
                    }).coalesced);
                    
                    writer.write("    shared void ``name``(``params``) {
                                          myServer.makeRequest(\"``path``\", \"``meth``\"");

                    value text = ",\n".join(handler[1].parameterDeclarations.map(
                        (el) {
                            if (is ValueDeclaration el, is OpenClassType t = el.openType) {
                                return "            \"``el.name``\"->``el.name``";
                            }
                            return null;
                        }
                    ).coalesced);
                    if (!text.empty) {
                        writer.write(", {\n");
                        writer.write(text);
                        writer.write("\n        }");
                    }
                    writer.write(");
                                      }

                                  "
                    );
                    
                });
            }
            writer.writeLine("}");
        }
        
        writer.writeLine("
                          object myServer {
                              shared void makeRequest(String url, String method, {<String->Anything>*} params = {}) {
                                  value xhr = newXMLHttpRequest();
                                  xhr.open(method, url + getParams(method, params));
                                  xhr.onload = void (Event evt) {

                                  };
                                  xhr.send();
                              }

                              String getParams(String method, {<String->Anything>*} params) {
                                  if (method == \"GET\", !params.empty) {
                                      return \"?\" + \"&\".join(params.map((el) => el.key + \"=\" + getValue(el.item)));
                                  }
                                  return \"\";
                              }

                              String getValue(Anything val) {
                                  if (is Object val) {
                                      return val.string;
                                  }
                                  return \"null\";
                              }
                          }
                          ");

    });    
}

String capitalize(String str) {
    return str.spanTo(0).uppercased + str.rest;
}

String uncapitalize(String str) {
    return str.spanTo(0).lowercased + str.rest;
}

void doWithFile(Directory where, String name, Anything(Writer) callback) {
    if (is Nil|File mod = where.childResource(name)) {
        value writer = createFileIfNil(mod).Overwriter();
        writer.writeLine("// GENERATED BY com.github.bjansen.gyokuro.clientgen, DO NOT EDIT!\n");

        callback(writer);

        writer.close();
    } else {
        throw Exception("Can't write module.ceylon");
    }
}

class Multimap<Key,Value>() satisfies Map<Key, List<Value>> given Key satisfies Object {

    value delegate = HashMap<Key, ArrayList<Value>>();
    
    shared actual MutableMap<Key,List<Value>> clone() => nothing;
    
    shared actual Boolean defines(Object key) => delegate.defines(key);
    
    shared actual List<Value>? get(Object key) => delegate.get(key);
    
    shared actual Iterator<Key->List<Value>> iterator() => delegate.iterator();
    
    shared List<Value>? put(Key key, Value item) {
        value list = delegate.getOrDefault(key, ArrayList<Value>());
        list.add(item);
        delegate.put(key, list);
        return list;
    }
    
    shared List<Value>? remove(Key key) => delegate.get(key);
    
    shared actual Integer hash => 1;
    
    shared actual Boolean equals(Object that) => false;
}