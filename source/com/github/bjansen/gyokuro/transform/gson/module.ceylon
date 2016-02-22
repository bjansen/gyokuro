native("jvm")
module com.github.bjansen.gyokuro.transform.gson "0.2-dev" {
    shared import com.github.bjansen.gyokuro.transform.api "0.2-dev";
    shared import "com.google.code.gson:gson" "2.5";
    
    import ceylon.interop.java "1.2.1";
}
