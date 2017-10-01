"An extension point for gyokuro to provide support for 
 a template engine."
native("jvm")
module net.gyokuro.view.api "0.4-SNAPSHOT" {
    value ceylonVersion = "1.3.4-SNAPSHOT";

    shared import ceylon.http.server ceylonVersion;
    shared import ceylon.interop.java ceylonVersion;
}
