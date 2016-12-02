import ceylon.http.common {
    Method
}

"Workaround until the SDK contains it."
shared object patch satisfies Method {
    string => "PATCH";
    hash => string.hash;
    equals(Object that) =>
            if (is Method that)
            then that.string == this.string
            else false;
}
