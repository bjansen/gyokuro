native("jvm")
module test.net.gyokuro.core "0.4-SNAPSHOT" {
    value ceylonVersion = "1.3.3";

    import net.gyokuro.core "0.4-SNAPSHOT";
    import ceylon.test ceylonVersion;
    import ceylon.logging ceylonVersion;
    import ceylon.html ceylonVersion;
    import ceylon.http.client ceylonVersion;
    import ceylon.uri ceylonVersion;
}
