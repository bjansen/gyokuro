native("jvm")
module net.gyokuro.transform.gson "0.4-SNAPSHOT" {
    shared import net.gyokuro.transform.api "0.4-SNAPSHOT";
    shared import maven:"com.google.code.gson:gson" "2.5";
    
    import ceylon.interop.java "1.3.4-SNAPSHOT";
}
