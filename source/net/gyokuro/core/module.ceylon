"gyokuro is a framework written in Ceylon, inspired by Sinatra
 and Spark, for creating web applications with very little boilerplate.
 It is based on the Ceylon SDK and uses ceylon."
native("jvm")
module net.gyokuro.core "0.3-SNAPSHOT" {
    shared import net.gyokuro.view.api "0.3-SNAPSHOT";
    shared import net.gyokuro.transform.api "0.3-SNAPSHOT";
    
    shared import ceylon.http.server "1.3.2-SNAPSHOT";
    shared import ceylon.json "1.3.2-SNAPSHOT";
    
    import ceylon.logging "1.3.2-SNAPSHOT";
    import ceylon.collection "1.3.2-SNAPSHOT";
    import ceylon.io "1.3.2-SNAPSHOT";

    import java.base "7";
}
