module functions;

import std.exception : assumeUnique;
import std.stdio;
import std.algorithm;
import std.range : array, iota, empty;
import std.conv : to;

import gribtables;

immutable string[int][string] lookupTables;
auto lookupCentre(T) (T[] value...){
    return getCodeFlag ("C11",value);
}

auto lookupSubCentre(T) (T[] value...){
    return getCodeFlag ("C12",value);
}

auto lookupMasterTableVersionNumber(T) (T[] value...){
    return getCodeFlag ("1.0",value);
}

auto lookupReferenceTimeSignificance(T) (T[] value...){
    return getCodeFlag ("1.2",value);
}

auto lookupProductionStatus(T) (T[] value...){
    return getCodeFlag ("1.3",value);
}

auto lookupDataType(T) (T[] value...){
    return getCodeFlag ("1.4",value);
}

//auto getTable (string data){
//    string[int] temp;
//    auto lines = data.splitter("\r\n");
//    lines.popFront;
//    foreach (line; lines){
//        auto firstComma = line.countUntil(",");
//        temp[line[0..firstComma].to!int] = line[firstComma+1..$];
//    }
//    return temp;
//}
//
//static this() {
//    string[int][string] temp;
//    temp["centres"] = getTable(import("centres.txt"));
//    temp["subcentres"] = getTable(import("subcentres.txt"));
//    temp["version_numbers"] = getTable(import("version_numbers.txt"));
//    temp["significance_ref_time"] = getTable(import("significance_ref_time.txt"));
//    temp["production_status"] = getTable(import("production_status.txt"));
//    temp["data_type"] = getTable(import("data_type.txt"));
//
//    lookupTables = temp.assumeUnique;
//
//}

