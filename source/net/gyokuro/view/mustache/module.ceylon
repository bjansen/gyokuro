"An extension of gyokuro that adds support for 
 [Mustache.java](https://github.com/spullara/mustache.java)."
native("jvm")
module net.gyokuro.view.mustache "0.3-SNAPSHOT" {
    shared import net.gyokuro.view.api "0.3-SNAPSHOT";
    shared import maven:"com.github.spullara.mustache.java:compiler" "0.8.18";
    
    import ceylon.interop.java "1.3.1";
}
