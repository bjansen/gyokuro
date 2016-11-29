import ceylon.test {
    test,
    assertEquals
}
import net.gyokuro.core {
    mimeParse
}

test void testMimeParse() {
    // direct match
    assertEquals(mimeParse.bestMatch(["application/xbel+xml", "application/xml"],
        "application/xbel+xml"), "application/xbel+xml");
    
    // direct match with a q parameter
    assertEquals(mimeParse.bestMatch(["application/xbel+xml", "application/xml"],
        "application/xbel+xml;q=1"), "application/xbel+xml");
    
    // direct match of our second choice with a q parameter
    assertEquals(mimeParse.bestMatch(["application/xbel+xml", "application/xml"],
        "application/xml;q=1"), "application/xml");

    // match using a subtype wildcard
    assertEquals(mimeParse.bestMatch(["application/xbel+xml", "application/xml"],
        "application/*;q=1"), "application/xml");

    // match using a type wildcard
    assertEquals(mimeParse.bestMatch(["application/xbel+xml", "application/xml"],
        "*/*"), "application/xml");

    // match using a type versus a lower weighted subtype
    assertEquals(mimeParse.bestMatch(["application/xbel+xml", "text/xml"],
        "text/*;q=0.5,*/*;q=0.1"), "text/xml");
    
    // fail to match anything
    assertEquals(mimeParse.bestMatch(["application/xbel+xml", "text/xml"],
        "text/html,application/atom+xml; q=0.9"), null);
    
    // common AJAX scenario
    assertEquals(mimeParse.bestMatch(["application/json", "text/html"],
        "application/json,text/javascript, */*"), "application/json");
    
    // verify fitness ordering
    assertEquals(mimeParse.bestMatch(["application/json", "text/html"],
        "application/json,text/html;q=0.9"), "application/json");
}