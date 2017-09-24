"gyokuro is a framework written in Ceylon, similar to Sinatra
 and Spark, for creating web applications with very little boilerplate.
 It is based on the Ceylon SDK and uses `ceylon.http.server`."
native("jvm")
module net.gyokuro.core "0.3.1" {
    value ceylonVersion = "1.3.3";

    shared import net.gyokuro.view.api "0.3.1";
    shared import net.gyokuro.transform.api "0.3.1";
    
    shared import ceylon.http.server ceylonVersion;
    shared import ceylon.json ceylonVersion;
    
    import ceylon.logging ceylonVersion;
    import ceylon.collection ceylonVersion;
    import ceylon.io ceylonVersion;

    import java.base "7";
}
