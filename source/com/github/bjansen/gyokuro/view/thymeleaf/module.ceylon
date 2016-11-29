"An extension of gyokuro that adds support for 
 [Thymeleaf](http://www.thymeleaf.org/)."
native("jvm")
module com.github.bjansen.gyokuro.view.thymeleaf "0.2" {
    shared import com.github.bjansen.gyokuro.view.api "0.2";
    shared import maven:"org.thymeleaf:thymeleaf" "3.0.0.BETA01";
    
    import java.base "7";
    import ceylon.interop.java "1.3.1";
}
