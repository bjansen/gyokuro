native("jvm")
module com.github.bjansen.gyokuro.view.pebble "0.2-dev" {
	shared import com.github.bjansen.gyokuro.core "0.2-dev";
	shared import "com.mitchellbosecke:pebble" "1.6.0";
    import java.base "7";
    import ceylon.interop.java "1.2.0";
}
