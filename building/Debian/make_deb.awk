BEGIN {
    FS = ";"
    fieldList["%CONTROL_FIELD_PACKAGE%"] = valuePackage;
    fieldList["%CONTROL_FIELD_DEPENDS%"] = valueDepends;
}
{
    if ( $1 in fieldList )
        print fieldList[$1]
    else
        print $1
} END {
}