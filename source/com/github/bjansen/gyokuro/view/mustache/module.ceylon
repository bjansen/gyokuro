"An extension of gyokuro that adds support for 
 [Mustache.java](https://github.com/spullara/mustache.java)."
native("jvm")
module com.github.bjansen.gyokuro.view.mustache "0.2-dev" {
    shared import com.github.bjansen.gyokuro.view.api "0.2-dev";
    shared import maven:"com.github.spullara.mustache.java:compiler" "0.8.18";
    
    import ceylon.interop.java "1.3.0";
}
