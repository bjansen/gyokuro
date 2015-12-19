"gyokuro is a framework written in Ceylon, inspired by Sinatra
 and Spark, for creating web applications with very little boilerplate.
 It is based on the Ceylon SDK and uses ceylon.net."
native("jvm")
module com.github.bjansen.gyokuro.core "0.2-dev" {
    shared import com.github.bjansen.gyokuro.view.api "0.2-dev";
    shared import com.github.bjansen.gyokuro.transform.api "0.2-dev";
    
    shared import ceylon.net "1.2.0-3";
    shared import ceylon.json "1.2.0";
    
    import ceylon.logging "1.2.0";
    import ceylon.collection "1.2.0";
    
    import java.base "7";
}
