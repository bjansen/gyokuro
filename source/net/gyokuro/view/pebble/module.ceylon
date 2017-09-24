"An extension of gyokuro that adds support for 
 [Pebble](http://www.mitchellbosecke.com/pebble)."
native("jvm")
module net.gyokuro.view.pebble "0.3.1" {
    shared import net.gyokuro.core "0.3.1";
    shared import maven:"com.mitchellbosecke:pebble" "2.2.0";
    import java.base "7";
    import ceylon.interop.java "1.3.3";
}
