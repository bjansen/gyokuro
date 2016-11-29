import ceylon.collection {
    HashMap,
    MutableMap,
    LinkedList
}

"Adapted from [MIMEParse](https://code.google.com/p/mimeparse/source/browse/trunk/java/MIMEParse.java)."
shared object mimeParse {
    
    "Takes a list of supported mime-types and finds the best match for all the
     media-ranges listed in header. The value of header must be a string that
     conforms to the format of the HTTP Accept: header. The value of
     `supported` is a list of mime-types.
      
         mimeParse.bestMatch([\"application/xbel+xml\", \"text/xml\"],
            \"text/*;q=0.5,*; q=0.1\") == \"text/xml\"
      "
    shared String? bestMatch(String[] supported, String header) {
        value parseResults = header.split(','.equals).map(parseMediaRange);

        value weightedMatches = LinkedList<FitnessAndQuality>();
        
        for (s in supported) {
            weightedMatches.add(fitnessAndQualityParsed(s, parseResults));
        }

        if (exists last = sort(weightedMatches).last) {
            return last.quality != 0.0 then last.mimeType else null;
        }
        
        //FitnessAndQuality lastOne = weightedMatches
        //        .get(weightedMatches.size() - 1);
        //return NumberUtils.compare(lastOne.quality, 0) != 0 ? lastOne.mimeType
        //        : "";
        return null;
    }

    FitnessAndQuality fitnessAndQualityParsed(String mimeType, {ParseResults+} parsedRanges) {
        variable Integer bestFitness = -1;
        variable Float bestFitQ = 0.0;
        ParseResults target = parseMediaRange(mimeType);
        
        for (range in parsedRanges) {
            if ((target[0] == range[0] || range[0] == "*" || target[0] == "*")
                && (target[1] == range[1] || range[1] == "*" || target[1] == "*")) {

                for (k -> v in target[2]) {
                    variable Integer paramMatches = 0;
                    if (!k.equals("q"), exists v2 = range[2].get(k), v == v2) {
                        paramMatches++;
                    }
                    
                    variable Integer fitness = if (range[0] == target[0]) then 100 else 0;
                    fitness += if (range[1] == target[1]) then 10 else 0;
                    fitness += paramMatches;

                    if (fitness > bestFitness) {
                        bestFitness = fitness;
                        bestFitQ = if (is Float f = Float.parse(range[2].get("q") else "0"))
                        then f
                        else 0.0;
                    }
                }
            }
        }
        
        return FitnessAndQuality(bestFitness, bestFitQ, mimeType);
    }

    class FitnessAndQuality(shared Integer fitness, shared Float quality, shared String mimeType)
            satisfies Comparable<FitnessAndQuality> {
        
        shared actual Comparison compare(FitnessAndQuality o) {
            if (fitness == o.fitness) {
                return quality.compare(o.quality);
            } else {
                return fitness.compare(o.fitness);
            }
        }
    }
    
    alias ParseResults => [String, String, Map<String, String>];
    
    ParseResults parseMediaRange(String header) {
        value results = parseMimeType(header);
        value q = results[2].get("q") else "1.0";
        value f = if (is Float _f = Float.parse(q))
                  then if (_f < 0.0 || _f > 1.0)
                    then 1.0
                    else _f
                  else 1.0;
        
        assert(is MutableMap<String, String> m = results[2]);
        m.put("q", f.string);
        
        return results;
    }
    
    ParseResults parseMimeType(String mimeType) {
        value parts = mimeType.split(';'.equals);
        value params = HashMap<String,String>();

        for (p in parts) {
            value subParts = p.split('='.equals);
            value seq = subParts.sequence();
            if (exists first = seq[0],
                exists second = seq[1]) {
                
                params.put(first.trimmed, second.trimmed);
            }
        }
        
        value fullType = parts.first.trimmed == "*" then "*/*" else parts.first.trimmed;
        value types = fullType.split('/'.equals);
        
        return [types.first.trimmed, types.sequence()[1]?.trimmed else "", params];
    }

}