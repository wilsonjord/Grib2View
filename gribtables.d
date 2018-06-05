module gribtables;

import std.typecons : Tuple;
import std.conv : to;

alias Key = ushort;
alias TemplatePairMap = Tuple!(string,"name",uint[2]);

struct CodeFlag {
    string description;
    string note;
    string unit;
    string status;

    alias description this;
}


struct Table {
    string title;
    CodeFlag[Key[]] data;

    void add (CodeFlag cf, Key[] keys ...){
        data[keys.idup] = cf;
    }

    auto immutable get(T) (T[] key...){
        return data.get (key.to!(Key[]),CodeFlag("empty","","",""));
    }
}

immutable Table[string] tables;
immutable TemplatePairMap[][string] templateOctectDefinitions;

static this() {
    import std.stdio;
    import std.range;
    import std.csv;
    import std.algorithm;
    import std.typecons : Tuple;
    import std.file;
    import std.conv : to;

    Table[string] tempTable;
    TemplatePairMap[][string] tempTemplate;

    auto text = readText (`C:\development\GRIB2_19_0_0\GRIB2_19_0_0_CodeFlag_en.txt`);

    foreach (record; csvReader!(string[string],Malformed.ignore)(text, null)){
        auto tableId = record["Title_en"].splitter(" ")
                                         .drop(2)
                                         .front;

        auto cf = CodeFlag (record["MeaningParameterDescription_en"],record["Note_en"],record["UnitComments_en"],record["Status"]);
        if (!cf.description.startsWith("Reserved")){
            auto cfRange = record["CodeFlag"].splitter("-").array;
            if (!cfRange.empty){
                if (tableId !in tempTable) tempTable[tableId] = Table(record["Title_en"],(CodeFlag[Key[]]).init);

                //foreach (key; iota(cfRange.front.to!int, cfRange.back.to!int+1)){
                foreach (key; cfRange.front.to!Key..cfRange.back.to!Key+1){
                    tempTable[tableId].add (cf,key.to!Key);
                }
            }
        }
    }

    text = readText (`C:\development\Common_20170503\Common_C11_20170503_en.txt`);
    foreach (record; csvReader!(string[string],Malformed.ignore)(text, null)){
        auto tableId = "C11";

        auto cf = CodeFlag (record["OriginatingGeneratingCentre_en"],"","",record["Status"]);
        auto cfRange = record["GRIB2_BUFR4"].splitter("-").array;
        if (!cfRange.empty && !cfRange.front.equal("Not applicable")){
            if (tableId !in tempTable) tempTable[tableId] = Table(tableId,(CodeFlag[Key[]]).init);

            foreach (key; iota(cfRange.front.to!ushort, cfRange.back.to!ushort+1)){
                tempTable[tableId].add (cf, key.to!Key);
            }
        }
    }

    text = readText (`C:\development\Common_20170503\Common_C12_20170503_en.txt`);
    tempTable["C12"] = Table.init;
    foreach (record; csvReader!(string[string],Malformed.ignore)(text, null)){
        auto centreId = record["CodeFigure_OriginatingCentres"];
        if (!centreId.empty){
            auto centreKey = centreId.to!Key;
            auto subCentreKey = record["CodeFigure_SubCentres"].to!Key;
            tempTable["C12"].add (CodeFlag (record["Name_SubCentres_en"],"","",record["Status"]),centreKey,subCentreKey);
        }
    }

    text = readText (`C:\development\GRIB2_19_0_0\GRIB2_19_0_0_Template_en_utf8.txt`);
    foreach (record; csvReader!(string[string],Malformed.ignore)(text, null)){
        auto tableId = record["Title_en"].splitter(" -")
                                         .front;

        auto cfRange = record["OctetNo"].splitter("-").array;
        try {
            if (!cfRange.empty){
                if (!cfRange.back.equal("nn") && !cfRange.back.equal("ii") && !cfRange.back.equal("jj") ){
                    tempTemplate[tableId] ~= TemplatePairMap (record["Contents_en"],[cfRange.front.to!uint,cfRange.back.to!uint+1]);
                    if (tableId == "Grid definition template 3.0"){
                        tempTemplate["Grid definition template 3.1"] ~= TemplatePairMap (record["Contents_en"],[cfRange.front.to!uint,cfRange.back.to!uint+1]);
                    }
                }
            }
        } catch (Exception ex){
            // ignore
        }
    }







    import std.exception : assumeUnique;
    tables = tempTable.assumeUnique;
    templateOctectDefinitions = tempTemplate.assumeUnique;



}

auto getCodeFlag(T) (string tableId, T[] key...){
    return tables[tableId].get(key);
}

auto getTable (string tableId){
    return tables[tableId];
}
