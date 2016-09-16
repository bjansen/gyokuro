"An extension of gyokuro that adds support for 
 [Rythm](http://rythmengine.org/)."
native("jvm")
module com.github.bjansen.gyokuro.view.rythm "0.2-dev" {
    shared import com.github.bjansen.gyokuro.view.api "0.2-dev";
    shared import maven:"org.rythmengine:rythm-engine" "1.0.1";
    
    import java.base "7";
    import ceylon.interop.java "1.3.0";
}
