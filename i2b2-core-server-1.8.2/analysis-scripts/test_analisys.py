#!/usr/bin/env python3

from xml.etree.ElementTree import Element, SubElement, register_namespace, tostring

NS = "http://www.i2b2.org/xsd/hive/msg/result/1.1/"
register_namespace("i2b2", NS)

def main() -> int:
    print(build_response())
    return 0

def build_response():
    count = 42 # dummy value
    accuracy = 0.95 # dummy values
    envelope = Element(f"{{{NS}}}i2b2_result_envelope")
    body = SubElement(envelope, f"{{{NS}}}body")
    result = SubElement(body, f"{{{NS}}}result", {"name": "PYTHON_ANALYSIS"})

    SubElement(
        result,
        f"{{{NS}}}data",
        {"column": "count", "type": "int"},
    ).text = str(count)

    SubElement(
        result,
        f"{{{NS}}}data",
        {"column": "accuracy", "type": "double"},
    ).text = str(accuracy)
    return tostring(envelope, encoding="unicode", xml_declaration=True)

if __name__ == "__main__":
    raise SystemExit(main())