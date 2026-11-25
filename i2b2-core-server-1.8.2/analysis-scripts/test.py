import argparse
import os
from xml.etree import ElementTree as ET

import psycopg


def analyse(request_xml: str) -> int:
    definition = ET.fromstring(request_xml)
    parameter = definition.find(
        ".//{*}crc_analysis_input_param/{*}param[@column='value']"
    )
    if parameter is None or parameter.text is None:
        raise ValueError("Analyseparameter 'value' fehlt")

    return 2 * int(parameter.text)


def make_result_xml(value: int) -> str:
    ns = "http://www.i2b2.org/xsd/hive/msg/result/1.1/"
    ET.register_namespace("r", ns)

    envelope = ET.Element(f"{{{ns}}}i2b2_result_envelope")
    header = ET.SubElement(envelope, "header")
    ET.SubElement(header, "version").text = "1.1"
    ET.SubElement(header, "type").text = "XML"

    body = ET.SubElement(envelope, "body")
    result = ET.SubElement(body, f"{{{ns}}}result", name="PYTHON_DOUBLE")
    ET.SubElement(result, "data", column="doubled_value", type="int").text = str(value)
    return ET.tostring(envelope, encoding="unicode")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-project_id", required=True)
    parser.add_argument("-domain_id", required=True)
    parser.add_argument("-user_id", required=True)
    parser.add_argument("-instance_id", required=True, type=int)
    args = parser.parse_args()

    # Dieses Beispiel ist für genau eine Domäne und ein Projekt konfiguriert.
    if (args.domain_id, args.project_id) != (
        os.environ["I2B2_PLUGIN_DOMAIN"],
        os.environ["I2B2_PLUGIN_PROJECT"],
    ):
        raise ValueError("Domäne oder Projekt stimmt nicht mit der Konfiguration überein")

    with psycopg.connect(os.environ["I2B2_PLUGIN_DSN"]) as conn:
        cursor = conn.execute(
            """
            SELECT qm.request_xml
            FROM qt_query_instance AS qi
            JOIN qt_query_master AS qm ON qm.query_master_id = qi.query_master_id
            WHERE qi.query_instance_id = %s
              AND qm.group_id = %s
              AND qm.user_id = %s
              AND qm.master_type_cd = 'PYTHON_DOUBLE'
            FOR UPDATE OF qi
            """,
            (args.instance_id, args.project_id, args.user_id),
        )
        job = cursor.fetchone()
        if job is None:
            raise ValueError("Passender Analyseauftrag fehlt")

        results = conn.execute(
            """
            SELECT ri.result_instance_id, rt.name
            FROM qt_query_result_instance AS ri
            JOIN qt_query_result_type AS rt ON rt.result_type_id = ri.result_type_id
            WHERE ri.query_instance_id = %s
            """,
            (args.instance_id,),
        ).fetchall()
        if len(results) != 1 or results[0][1] != "XML":
            raise ValueError("Genau eine XML-Ausgabe muss angefordert werden")
        result_id = results[0][0]

        xml = make_result_xml(analyse(job[0]))
        completed_id, = conn.execute(
            "SELECT status_type_id FROM qt_query_status_type WHERE name = %s",
            ("COMPLETED",),
        ).fetchone()

        # Bei erneuter Ausführung derselben Instanz das Ergebnis ersetzen.
        conn.execute(
            "DELETE FROM qt_xml_result WHERE result_instance_id = %s",
            (result_id,),
        )
        conn.execute(
            """
            INSERT INTO qt_xml_result (xml_result_id, result_instance_id, xml_value)
            VALUES (nextval('qt_xml_result_xml_result_id_seq'), %s, %s)
            """,
            (result_id, xml),
        )
        conn.execute(
            """
            UPDATE qt_query_result_instance
            SET status_type_id = %s, end_date = CURRENT_TIMESTAMP, set_size = 1
            WHERE result_instance_id = %s
            """,
            (completed_id, result_id),
        )
        conn.execute(
            """
            UPDATE qt_query_instance
            SET status_type_id = %s, end_date = CURRENT_TIMESTAMP
            WHERE query_instance_id = %s
            """,
            (completed_id, args.instance_id),
        )
        # Beim Verlassen des Blocks wird gemeinsam committed.
        # Bei einer Exception wird die Transaktion zurückgerollt.


if __name__ == "__main__":
    main()