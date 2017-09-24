"Shows how to inject Spring beans in gyokuro controllers."
native ("jvm")
module gyokuro.demo.spring "0.3.1" {
    import ceylon.logging "1.3.3";

    import net.gyokuro.core "0.3.1";

    import maven:"org.springframework:spring-core" "4.3.5.RELEASE";
    import maven:"org.springframework:spring-beans" "4.3.5.RELEASE";
    import maven:"org.springframework:spring-context" "4.3.5.RELEASE";
    import maven:"commons-logging:commons-logging" "1.2";
}
