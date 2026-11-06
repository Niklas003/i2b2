# i2b2 lokale Entwicklungsumgebung

Diese README beschreibt das lokale i2b2-Setup unter Windows mit Docker Desktop.

## Verzeichnisstruktur

```text
i2b2\
|-- i2b2-core-server-1.8.2\   Java-/Ant-Quellcode des Backends
|-- i2b2-webclient-1.8.2\     Quellcode des Frontends
|-- i2b2-nl-dev\              Docker Compose und Konfiguration
|   |-- docker-compose.yml
|   |-- .env
|   |-- custom_datasource.txt
|   `-- restart_containers.sh
`-- README.md
```

Alle relativen Pfade in `i2b2-nl-dev/docker-compose.yml` beziehen sich auf den Ordner `i2b2-nl-dev`.

## Voraussetzungen

- Docker Desktop mit laufender Linux-Container-Engine
- Docker Compose v2 (`docker compose`)
- PowerShell
- Fuer den Backend-Build: Ant und ein passendes Java werden im Core-Container verwendet

## Container starten

PowerShell oeffnen und in den Compose-Ordner wechseln:

```powershell
cd i2b2\i2b2-nl-dev

docker compose up -d
```

Status pruefen:

```powershell
docker compose ps
```

Das Frontend ist erreichbar unter:

```text
http://localhost:8080
```

Logs anzeigen:

```powershell
docker compose logs -f i2b2-core-server
docker compose logs -f i2b2-webclient
```

Container stoppen:

```powershell
docker compose down
```

## Lokale Quellcode-Mounts

Die Compose-Datei bindet die lokalen Quellcodeordner in die Container:

```yaml
# Frontend
../i2b2-webclient-1.8.2:/var/www/html/webclient

# Backend
../i2b2-core-server-1.8.2:/opt/jboss/wildfly/i2b2-core-server
```

Der Backend-Mount stellt den Quellcode und die Build-Dateien bereit. Er ersetzt
nicht automatisch das von WildFly geladene Deployment. Dafuer muss das lokal
gebaute WAR zusaetzlich nach `standalone/deployments` gemountet werden:

```yaml
volumes:
	- ../i2b2-core-server-1.8.2:/opt/jboss/wildfly/i2b2-core-server
	- ../i2b2-core-server-1.8.2/edu.harvard.i2b2.server-common/dist/i2b2.war:/opt/jboss/wildfly/standalone/deployments/i2b2.war
```

### Frontend entwickeln

Aenderungen an HTML, CSS, JavaScript und Bildern werden direkt aus dem lokalen Ordner verwendet. Ein Container-Neustart ist normalerweise nicht erforderlich. Die Browserseite neu laden, bei Cache-Problemen mit `Strg + F5`.

Ein Neustart ist erforderlich, wenn `docker-compose.yml`, Ports, Umgebungsvariablen oder Container-Befehle geaendert wurden.

## Backend mit Ant bauen

Der Core-Server wird im laufenden Container gebaut. Das laufende WildFly
laedt `/opt/jboss/wildfly/standalone/deployments/i2b2.war`; der Quellcode-Mount
allein aktiviert keinen lokalen Build.

### 1. WAR-Mount aktivieren

Nach dem Eintragen des WAR-Mounts den Backend-Container neu erstellen:

```powershell
cd i2b2\i2b2-nl-dev
docker compose up -d --force-recreate i2b2-core-server
```

### 2. Java und Ant pruefen

Java ist im Core-Server-Container enthalten. Das aktuell verwendete Image
enthaelt Ant jedoch nicht standardmaessig. Ant muss daher nach dem Erstellen
des Containers einmal installiert werden:

```powershell
docker exec -u 0 -it i2b2-core-server bash -lc "apt-get update && apt-get install -y ant"
docker exec -it i2b2-core-server bash -lc "ant -version && java -version"
```

Die Installation gilt nur fuer den aktuellen Container. Nach
`--force-recreate` muss sie wiederholt werden; fuer eine dauerhafte Loesung
sollte ein eigenes Core-Server-Image mit Ant gebaut werden.

### 3. Backend bauen

Der Build muss zuerst das gemeinsame `i2b2Common-core.jar` erzeugen und danach
das vollstaendige WAR zusammenstellen. `ant clean war` reicht nicht aus, weil
dabei das gemeinsame JAR vor dem CRC-Build fehlt.

```powershell
docker exec -u 0 -it i2b2-core-server bash -lc "apt-get update && apt-get install -y ant"
docker exec -it i2b2-core-server bash -lc "cd /opt/jboss/wildfly/i2b2-core-server/edu.harvard.i2b2.server-common && ant clean all war"
docker compose restart i2b2-core-server
```

Das WAR wird lokal erzeugt unter:

```text
i2b2-core-server-1.8.2/edu.harvard.i2b2.server-common/dist/i2b2.war
```

Bei jeder Backend-Aenderung muss das WAR erneut gebaut und der Core-Server
neu gestartet werden. Der komplette Build kann wiederholt werden, wenn unklar
ist, welche Abhaengigkeiten betroffen sind.

## Datenbank

Der PostgreSQL-Container heisst `i2b2-data-pgsql` und ist im Docker-Netzwerk unter diesem Namen erreichbar. Die Datenbankparameter befinden sich in `i2b2-nl-dev/.env`.

Die verwendeten Schemas sind unter anderem:

- `i2b2demodata` fuer CRC
- `i2b2metadata` fuer Ontology
- `i2b2pm` fuer Project Management
- `i2b2hive` fuer Hive und IM
- `i2b2workdata` fuer Workplace

Der PostgreSQL-Port ist standardmaessig nur innerhalb des Docker-Netzwerks erreichbar. Der Container-Port `5432` wird aktuell nicht auf den Windows-Host weitergeleitet.

## Umgebungsvariablen

Die Datei `i2b2-nl-dev/.env` steuert Image-Tags, Datenbankverbindung und Passwoerter. Bei Aenderungen an `.env` die Container neu erstellen:

```powershell
cd i2b2\i2b2-nl-dev
docker compose up -d --force-recreate
```