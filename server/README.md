# Itinera Server

Backend di **sincronizzazione** per l'app Itinera (versione remota).

L'app resta **local-first**: il server e' solo il punto d'incontro tra
dispositivi. Conserva l'intero dataset dell'utente come un unico documento
JSON (lo stesso formato del backup), protetto da login.

## API

| Metodo | Path | Auth | Descrizione |
|--------|------|------|-------------|
| GET | `/api/health` | no | Stato del server |
| POST | `/api/login` | no | Body `{username,password}` → `{token,expiresAt}` |
| GET | `/api/data` | Bearer | Ritorna il documento JSON (204 se vuoto) |
| PUT | `/api/data` | Bearer | Salva il documento JSON (sostituisce) |

Il token e' un HMAC-SHA256 firmato con `ITINERA_SECRET`, con scadenza.

## Configurazione (variabili d'ambiente)

| Variabile | Default | Note |
|-----------|---------|------|
| `PORT` | `8080` | Porta di ascolto |
| `ITINERA_USERNAME` | `dgett130` | Utente (deve combaciare con l'app) |
| `ITINERA_PASSWORD` | `password` | **Cambiare in produzione** |
| `ITINERA_SECRET` | *(dev)* | Secret firma token: **stringa lunga e casuale** |
| `ITINERA_DATA_DIR` | `/data` | Dove salvare i documenti |
| `ITINERA_TOKEN_TTL_DAYS` | `7` | Durata del token |

## Esecuzione locale (sviluppo)

```bash
cd server
dart pub get
dart run bin/server.dart          # http://localhost:8080
```

## Docker

```bash
cd server
docker compose up -d --build      # espone :8080, dati nel volume itinera-data
docker compose logs -f
```

L'immagine finale e' minima (`scratch` + runtime Dart), l'eseguibile e' AOT.

---

## Deploy su una VM Proxmox raggiungibile via Tailscale

Obiettivo: un container che gira su una VM Proxmox e che l'app raggiunge dalla
rete **Tailscale** (traffico gia' cifrato WireGuard → HTTP semplice va bene).

### 1. Crea la VM su Proxmox
- Debian 12 o Ubuntu 24.04, 1 vCPU / 1 GB RAM / 8 GB disco bastano.
- IP statico nella LAN (es. `192.168.0.16`), fuori dal pool DHCP.

### 2. Installa Docker sulla VM
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER   # poi ri-login
```

### 3. Installa Tailscale sulla VM
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale ip -4                 # annota l'IP 100.x.y.z della VM
```
> In alternativa la VM e' gia' raggiungibile via il **subnet router** sul NAS
> (`192.168.0.0/24`): in quel caso l'app puo' usare direttamente l'IP LAN
> `192.168.0.16` stando sulla tailnet. Un IP Tailscale dedicato e' comunque
> piu' robusto.

### 4. Copia il codice del server e avvia
```bash
# copia la cartella server/ sulla VM (scp/rsync/git), poi:
cd server
# IMPORTANTE: modifica ITINERA_PASSWORD e ITINERA_SECRET in docker-compose.yml
docker compose up -d --build
curl -s http://localhost:8080/api/health   # {"status":"ok",...}
```

### 5. Punta l'app al server
Nell'app, alla prima apertura scegli **"Accedi al server"** e inserisci:
- **URL server**: `http://<ip-tailscale-o-lan-della-VM>:8080`
  (es. `http://100.x.y.z:8080` oppure `http://192.168.0.16:8080`)
- **Utente / password**: `dgett130` / la password che hai impostato.

Il telefono deve essere sulla stessa **tailnet** (app Tailscale attiva).

### Sicurezza
- Gira **dentro** Tailscale: non esporre la porta 8080 su Internet.
- Cambia `ITINERA_PASSWORD` e `ITINERA_SECRET`.
- I dati sono nel volume Docker `itinera-data` (fai backup del volume).
