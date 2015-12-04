"gyokuro is a framework written in Ceylon, inspired by Sinatra
 and Spark, for creating web applications with very few boilerplate.
 It is based on the Ceylon SDK and uses ceylon.net."
native("jvm")
module com.github.bjansen.gyokuro "0.1.0" {
	shared import ceylon.net "1.2.0-3";
	import ceylon.logging "1.2.0";
	import ceylon.collection "1.2.0";
	shared import ceylon.json "1.2.0";
	import java.base "7";
}
