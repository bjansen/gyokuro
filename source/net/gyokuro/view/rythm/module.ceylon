"An extension of gyokuro that adds support for 
 [Rythm](http://rythmengine.org/)."
native("jvm")
module net.gyokuro.view.rythm "0.4-SNAPSHOT" {
    shared import net.gyokuro.view.api "0.4-SNAPSHOT";
    shared import maven:"org.rythmengine:rythm-engine" "1.0.1";
    
    import java.base "7";
    import ceylon.interop.java "1.3.4-SNAPSHOT";
}
