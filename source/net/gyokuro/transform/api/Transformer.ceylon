
"A transformer that can convert the body of a Request to an Object,
 or transform an Object to the body of a Response."
shared interface Transformer {
    "Trasnforms an object to a string that will be the body of a Response."
    shared formal String serialize(Object o);
    
    "Tranforms the body of a Request to an Object that can be passed to a Request handler."
    shared formal Instance deserialize<Instance>(String serialized)
            given Instance satisfies Object;
    
    "Specifies which MIME types this transformer supports."
    shared formal [String+] contentTypes;
}
