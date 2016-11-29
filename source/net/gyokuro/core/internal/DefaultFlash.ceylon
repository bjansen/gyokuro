import ceylon.http.server {
    Session
}

import net.gyokuro.core {
    Flash
}

shared class DefaultFlash(Session session) satisfies Flash {
    
    shared actual void add(String key, Object val) {
        session.put("__flash__" + key, val);
    }
    
    shared actual Object? get(String key) {
        if (exists obj = session.get("__flash__" + key)) {
            session.remove("__flash__" + key);
            return obj;
        }
        
        return null;
    }
    
    shared actual Object? peek(String key)
            => session.get("__flash__" + key);
}
