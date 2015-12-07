import ceylon.collection {
    HashMap
}
import ceylon.file {
    Directory,
    File,
    Nil,
    createFileIfNil
}
import ceylon.html {
    Div,
    Html,
    Head,
    Body,
    H1,
    P,
    InlineElement,
    Em,
    Span,
    Link,
    stylesheet,
    H2,
    Table,
    Th,
    Td,
    Tr
}
import ceylon.language.meta.declaration {
    Package,
    FunctionDeclaration,
    AnnotatedDeclaration,
    ValueDeclaration,
    InterfaceDeclaration,
    OpenType,
    OpenUnion,
    FunctionOrValueDeclaration
}
import ceylon.net.http {
    AbstractMethod
}
import ceylon.net.http.server {
    Request,
    Response
}

import com.github.bjansen.gyokuro.core.internal {
    annotationScanner
}

shared class GyokuroApiGenerator(Package controllersPkg, Directory output) {
    
    value routes = HashMap<String,[FunctionDeclaration, {AbstractMethod+}]>();
    value exludedTypes =
            [`interface Request`, `interface Response`].map(InterfaceDeclaration.openType);
    
    shared void run() {
        print("Scanning controllers...");
        annotationScanner.scanControllersInPackage("/", controllersPkg, addRoute);
        
        print("Generating report...");
        generateReport();
        
        print("Done.");
    }
    
    void addRoute(String path, [Object, FunctionDeclaration] controllerHandler,
        {AbstractMethod+} methods) {
        
        routes.put(path, [controllerHandler[1], methods]);
    }
    
    void writeReport(Html html) {
        value resource = output.childResource("report.html");
        value file = if (is File resource)
        then resource.Overwriter()
        else if (is Nil resource) then resource.createFile().Overwriter()
            else null;
        if (exists file) {
            file.write(html.string);
            file.flush();
            file.close();
        } else {
            print("Can't write to file ``resource.path.string``");
        }
        if (exists css = `module`.resourceByPath("style.css")) {
            if (is File|Nil target = output.childResource("style.css")) {
                value outCss = createFileIfNil(target).Overwriter();
                outCss.write(css.textContent());
                outCss.flush();
                outCss.close();
            } else {
                print("Couldn't copy style.css");                
            }
        } else {
            print("Couldn't find style.css");
        }
    }
    
    void generateReport() {
        value html = Html {
            head = Head {
                title = "gyokuro app API";
                headChildren = {
                    Link(stylesheet, "style.css")
                };
            };
            body = Body {
                H1 {
                    "API for package \```controllersPkg.qualifiedName``\`"
                },
                P {
                    getDocumentation(controllersPkg)
                },
                for (path->[func, methods] in routes)
                    for (method in methods)
                        generateRoute(path, method.string, func)
            };
        };
        
        writeReport(html);
    }
    
    function generateRouteHeader(String method, String path, FunctionDeclaration func) {
        return Div {
            classNames = "route-header";
            nonstandardAttributes =
                    ["onclick"->"this.nextElementSibling.classList.toggle('collapsed')"];
            children = {
                Span {
                    method.string;
                },
                Span {
                    path
                },
                Span {
                    getDocumentation(func)
                }
            };
        };
    }
    
    Div generateRouteBody(String method, String path, FunctionDeclaration func) {
        value parameters = {
            for (p in func.parameterDeclarations)
                if (is ValueDeclaration p, !exludedTypes.contains(p.openType))
                    Tr {
                        Td(p.name),
                        Td { getDocumentation(p) },
                        Td(prettifyType(p.openType))
                    }
        };
        
        return Div {
            classNames = "collapsed route-params";
            children = {
                H2("Parameters"),
                if (parameters.empty)
                then Em("No parameters")
                else Table {
                        header = { Th("Parameter"), Th("Description"), Th("Parameter type") };
                        rows = parameters;
                    },
                H2("Returns"),
                Div(prettifyType(func.openType)),
                if (!parameters.empty)
                then {
                    H2("Response messages"),
                    Table {
                        header = { Th("HTTP status code"), Th("Reason") };
                        rows = {
                            if (hasRequiredParameters(func))
                            then Tr {
                                    Td("400"),
                                    Td("Missing required parameter")
                                }
                            else null,
                            Tr {
                                Td("400"),
                                Td("Invalid parameter value")
                            }
                        };
                    }
                }
                else {}
            };
        };
    }
    
    String prettifyType(OpenType type)
            => type.string.replace("ceylon.language::", "");
    
    Div generateRoute(String path, String method, FunctionDeclaration func) {
        return Div {
            classNames = "method-" + method.lowercased;
            generateRouteHeader(method, path, func),
            generateRouteBody(method, path, func)
        };
    }
    
    String|InlineElement getDocumentation(AnnotatedDeclaration decl) {
        if (exists ann = decl.annotations<DocAnnotation>().first) {
            return ann.description;
        }
        
        return Em("No description");
    }
    
    Boolean hasRequiredParameters(FunctionDeclaration func) {
        for (p in func.parameterDeclarations) {
            if (is ValueDeclaration p,
                !exludedTypes.contains(p.openType),
                !isOptional(p)) {
                
                return true;
            }
        }
        
        return false;
    }
    
    Boolean isOptional(FunctionOrValueDeclaration param) {
        if (is OpenUnion paramType = param.openType, paramType.caseTypes.size == 2) {
            if (exists nullType = paramType.caseTypes.find((elem) => elem == `class Null`.openType)) {
                return true;
            }
        }
        return false;
    }
}
