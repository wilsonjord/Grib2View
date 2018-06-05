module main;

import std.stdio;
import std.range;
import std.conv : to;
import std.algorithm;
import std.file;
import std.string;
import std.bitmanip : peek;
import std.datetime;

import gribtables;

enum Discipline : ubyte {meteorologicalProducts=0,
                         hydrologicalProducts=1,
                         landSurfaceProducts=2,
                         spaceProducts=3,
                         spaceProductsValidation=4,
                         oceanographicProducts=10,
                         missing=255}

enum SectionType : ubyte {indicator=0, identification, local, gridDefinition, productDefinition, dataRepresentation, bitmap, data}

struct Section {
    immutable SectionType type;
    immutable ubyte[] data;

    this (SectionType t, immutable ubyte[] d){
        type = t;
        data = d;
    }
}

struct Message {
    Section[] sections;

    @property {
        auto length() {
            return sections[0].data[8..16].peek!uint;
        }

        auto products() {
            return sections.filter!(a => a.type==SectionType.productDefinition);
            //return sections[SectionType.productDefinition];
        }
    }
}

auto templateId (Section s){
    assert (s.type == SectionType.productDefinition);
    return s.data[7..9].peek!ushort;
}

//auto discipline (Section s) @safe pure {
//    assert (s.type == SectionType.indicator);
//    return s.data[6].to!Discipline;
//}
//
//auto edition (Section s) @safe pure {
//    assert (s.type == SectionType.indicator);
//    return s.data[7];
//}

//auto originatingCentre (Section s) @safe pure {
//    assert (s.type == SectionType.identification);
//    return getCodeFlag ("C11",s.data[5..7].peek!ushort);
//}

//auto originatingSubCentre (Section s) @safe pure {
//    assert (s.type == SectionType.identification);
//    return getCodeFlag ("C12",s.data[5..7].peek!ushort,s.data[7..9].peek!ushort);
//}

//auto masterTablesVersionNumber (Section s) @safe pure {
//    assert (s.type == SectionType.identification);
//    return getCodeFlag ("1.0",s.data[9]);
//}
//
//auto referenceTimeSignificance (Section s) @safe pure {
//    assert (s.type == SectionType.identification);
//    return getCodeFlag ("1.2",s.data[11]);
//}

auto year (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return s.data[12..14].peek!ushort;
}

auto month (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return s.data[14];
}

auto day (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return s.data[15];
}

auto hour (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return s.data[16];
}

auto minute (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return s.data[17];
}

auto second (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return s.data[18];
}

auto productionStatus (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return getCodeFlag ("1.3",s.data[19]);
}

auto dataType (Section s) @safe pure {
    assert (s.type == SectionType.identification);
    return getCodeFlag ("1.4",s.data[20]);
}

auto gridDefinitionSource (Section s) @safe pure {
    assert (s.type == SectionType.gridDefinition);
    return getCodeFlag ("3.0",s.data[5]);
}

auto numDataPoints (Section s) @safe pure {
    assert (s.type == SectionType.gridDefinition);
    return s.data[6..10].peek!uint;
}

struct Grib2 {
    Message[] messages;
    immutable ubyte[] data;
    immutable DateTime dateTime;

    @property {
        // section 0
        auto discipline() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.indicator).front;
            return s.data[6].to!Discipline;
        }

        auto edition() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.indicator).front;
            return s.data[7];
        }

        // section 1
        auto originatingCentre() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.identification).front;
            return getCodeFlag ("C11",s.data[5..7].peek!ushort);
        }

        auto originatingSubCentre() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.identification).front;
            return getCodeFlag ("C12",s.data[5..7].peek!ushort,s.data[7..9].peek!ushort);
        }

        auto masterTablesVersionNumber() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.identification).front;
            return getCodeFlag ("1.0",s.data[9]);
        }

        auto referenceTimeSignificance() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.identification).front;
            return getCodeFlag ("1.2",s.data[11]);
        }

        auto ref time() const { return dateTime; }

        auto productionStatus() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.identification).front;
            return getCodeFlag ("1.3",s.data[19]);
        }

        auto dataType() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.identification).front;
            return getCodeFlag ("1.4",s.data[20]);
        }

        // section 2
        // TODO

        // section 3
        auto gridDefinitionSource() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.gridDefinition).front;
            return getCodeFlag ("3.0",s.data[5]);
        }

        auto numDataPoints() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.gridDefinition).front;
            return s.data[6..10].peek!uint;
        }

        auto listNumbersDefiningNumDataPoints() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.gridDefinition).front;
            return getCodeFlag ("3.11",s.data[11]);
        }

        auto gridDefinitionTemplateNumber() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.gridDefinition).front;
            return s.data[12..14].peek!ushort;
        }

        auto gridDefinitionTemplate() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.gridDefinition).front;
            return getCodeFlag ("3.1",s.data[12..14].peek!ushort);
        }

        // section 4
        auto productDefinitionTemplateNumber() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.productDefinition).front;
            return s.data[7..9].peek!ushort;
        }

        auto productDefinitionTemplate() const {
            auto s = messages[0].sections.filter!(a => a.type==SectionType.productDefinition).front;
            return getCodeFlag ("4.0",s.data[7..9].peek!ushort);
        }

        auto products() {
            return messages.map!(a => a.products);
        }


    }

    void listProducts() {
        foreach (product; products){

        }
    }


    this (string path){
        import std.exception : assumeUnique;
        data = (cast(ubyte[])(path.read)).assumeUnique;


        auto startMessage=true;
        auto offset=0;
        while (offset < data.length){
            Message m;

            m.sections ~= Section (SectionType.indicator, data[0+offset..16+offset]);
            offset += 16;

            while (true){
                if (data[offset..offset+4].equal ("7777")) {
                    offset += 4;
                    break;
                }
                auto sectionLength = data[offset..offset+4].peek!uint;
                m.sections ~= Section (data[offset+4].to!SectionType,data[offset..offset+sectionLength]);
                offset += sectionLength;
            }
            messages ~= m;
        }

        // read date
        dateTime = DateTime (messages[0].sections[1].year,
                             messages[0].sections[1].month,
                             messages[0].sections[1].day,
                             messages[0].sections[1].hour,
                             messages[0].sections[1].minute,
                             messages[0].sections[1].second);
    }
}


void writeValue (immutable ubyte[] v){
    std.stdio.writeln (v.peek!uint);
}

void writeValue (immutable ubyte v){
    std.stdio.writeln (v);
}



void main(string[] args){


//    import functions;
//    foreach (k; table0.keys.sort()){
//        writeln (k, " ",table0[k]);
//    }
//    //return;

    auto gribData = Grib2 (`F:\gfs_fnl\gdas1.fnl0p25.2016110100.f00.grib2`);

    foreach (product; gribData.products){
        getCodeFlag ("4.1",product.front.data[9]).writeln;
        getCodeFlag ("4.2",product.front.data[10]).writeln;
        readln;
    }

    return;

    writeln ("Idenification");
    gribData.originatingCentre.writeln;
    gribData.originatingSubCentre.writeln;
    gribData.masterTablesVersionNumber.writeln;
    gribData.referenceTimeSignificance.writeln;
    gribData.time.writeln;
    gribData.productionStatus.writeln;
    gribData.dataType.writeln;

    writeln ("Grid Definition");
    gribData.gridDefinitionSource.writeln;
    gribData.numDataPoints.writeln;
    gribData.listNumbersDefiningNumDataPoints.writeln;
    gribData.gridDefinitionTemplateNumber.writeln;
    gribData.gridDefinitionTemplate.writeln;

    writeln ("Product Definition");
    gribData.productDefinitionTemplateNumber.writeln;
    gribData.productDefinitionTemplate.writeln;


    auto a = gribData.messages[0].sections.filter!(a => a.type==SectionType.gridDefinition)
                                 .front;

    a.data[30..34].writeValue;
    a.data[34..38].writeValue;

    (a.data[46..50].peek!uint / 1000.0).writeln;
    (a.data[50..54].peek!uint / 1000.0).writeln;

    (a.data[55..59].peek!uint / 1000.0).writeln;
    (a.data[59..63].peek!uint / 1000.0).writeln;



    a.data[63..67].peek!uint.writeln;
    a.data[67..71].peek!uint.writeln;









    return;




	return;
}
