"gyokuro is a framework written in Ceylon, similar to Sinatra
 and Spark, for creating web applications with very little boilerplate.
 It is based on the Ceylon SDK and uses `ceylon.http.server`."
native("jvm")
module net.gyokuro.core "0.3-SNAPSHOT" {
    shared import net.gyokuro.view.api "0.3-SNAPSHOT";
    shared import net.gyokuro.transform.api "0.3-SNAPSHOT";
    
    shared import ceylon.http.server "1.3.1";
    shared import ceylon.json "1.3.1";
    
    import ceylon.logging "1.3.1";
    import ceylon.collection "1.3.1";
    import ceylon.io "1.3.1";

    import java.base "7";
}
