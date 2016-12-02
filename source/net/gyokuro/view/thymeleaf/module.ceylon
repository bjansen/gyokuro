"An extension of gyokuro that adds support for 
 [Thymeleaf](http://www.thymeleaf.org/)."
native("jvm")
module net.gyokuro.view.thymeleaf "0.3-SNAPSHOT" {
    shared import net.gyokuro.view.api "0.3-SNAPSHOT";
    shared import maven:"org.thymeleaf:thymeleaf" "3.0.0.BETA01";
    
    import java.base "7";
    import ceylon.interop.java "1.3.1";
}
