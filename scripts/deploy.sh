#!/bin/bash
# =============================================================================
#  ██████╗  ██████╗  ██████╗██╗  ██╗███████╗████████╗     ██████╗ ██╗   ██╗██╗     ██╗
#  ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝╚══██╔══╝    ██╔════╝ ██║   ██║██║     ██║
#  ██████╔╝██║   ██║██║     █████╔╝ █████╗     ██║       ██║  ███╗██║   ██║██║     ██║
#  ██╔═══╝ ██║   ██║██║     ██╔═██╗ ██╔══╝     ██║       ██║   ██║██║   ██║██║     ██║
#  ██║     ╚██████╔╝╚██████╗██║  ██╗███████╗   ██║       ╚██████╔╝╚██████╔╝███████╗███████╗
#  ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝        ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
#
#  Pocket Gull — Cloud Run Deployment Orchestrator
#  Real-time Medical Care Plan Strategy & Live AI Consult Engine
# =============================================================================

set -euo pipefail

# ─── ANSI Color & Style Palette ──────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Spectral palette (matches app brand)
RED="\033[38;5;202m"       # Spectral 640nm #ff4500
ORANGE="\033[38;5;208m"
GOLD="\033[38;5;220m"
GREEN="\033[38;5;82m"
CYAN="\033[38;5;51m"
BLUE="\033[38;5;39m"
VIOLET="\033[38;5;135m"
GRAY="\033[38;5;245m"
WHITE="\033[38;5;255m"

BG_DARK="\033[48;5;232m"
BG_ORANGE="\033[48;5;202m"

# ─── Origami Gull ASCII Art ──────────────────────────────────────────────────
print_gull() {
  echo -e "${GRAY}"
  echo -e "          ${WHITE}  ╱▔▔╲  ${DIM}${GRAY}                              "
  echo -e "          ${WHITE} ╱    ╲  ${DIM}${GRAY}╲                            "
  echo -e "          ${WHITE}╱  ∧∧  ╲${GRAY}──╲${ORANGE}▲${GRAY}──────────────────────"
  echo -e "          ${WHITE}▏  ╲╱  ╱${GRAY}───╱${ORANGE}▼${GRAY}    ${RED}◀${RESET}"
  echo -e "          ${WHITE} ╲    ╱  ${DIM}${GRAY}╱                            "
  echo -e "          ${WHITE}  ╲__╱  ${DIM}${GRAY}╱                             "
  echo -e "${RESET}"
}

# ─── Banner ──────────────────────────────────────────────────────────────────
print_banner() {
  clear
  echo -e ""
  echo -e "${BG_DARK}${RED}${BOLD}  ▸ POCKET GULL — DEPLOY SEQUENCE INITIATED  ${RESET}"
  echo -e ""
  print_gull
  echo -e "  ${BOLD}${WHITE}Service  ${RESET}${CYAN}${SERVICE_NAME}${RESET}"
  echo -e "  ${BOLD}${WHITE}Project  ${RESET}${CYAN}${PROJECT_ID}${RESET}"
  echo -e "  ${BOLD}${WHITE}Region   ${RESET}${CYAN}${REGION}${RESET}"
  echo -e "  ${BOLD}${WHITE}Image    ${RESET}${GRAY}${IMAGE_TAG}${RESET}"
  echo -e "  ${BOLD}${WHITE}Time     ${RESET}${GRAY}$(date '+%Y-%m-%d %H:%M:%S %Z')${RESET}"
  echo -e ""
  echo -e "  ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e ""
}

# ─── Spinner ─────────────────────────────────────────────────────────────────
SPINNER_PID=""
spinner_frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

start_spinner() {
  local label="$1"
  (
    local i=0
    while true; do
      printf "\r  ${VIOLET}${spinner_frames[$((i % ${#spinner_frames[@]}))]}${RESET}  ${GRAY}${label}${RESET}   "
      sleep 0.08
      ((i++))
    done
  ) &
  SPINNER_PID=$!
  disown $SPINNER_PID 2>/dev/null || true
}

stop_spinner() {
  local status="$1"   # "ok" | "fail"
  local label="$2"
  local elapsed="$3"
  if [[ -n "$SPINNER_PID" ]]; then
    kill "$SPINNER_PID" 2>/dev/null || true
    SPINNER_PID=""
  fi
  if [[ "$status" == "ok" ]]; then
    printf "\r  ${GREEN}✔${RESET}  ${WHITE}${label}${RESET}  ${DIM}${GRAY}(${elapsed}s)${RESET}\n"
  else
    printf "\r  ${RED}✘${RESET}  ${WHITE}${label}${RESET}\n"
  fi
}

# ─── Phase Banner ────────────────────────────────────────────────────────────
print_phase() {
  local num="$1"
  local total="$2"
  local label="$3"
  local icon="$4"
  echo -e ""
  echo -e "  ${GOLD}${BOLD}PHASE ${num}/${total}${RESET}  ${icon}  ${BOLD}${WHITE}${label}${RESET}"
  echo -e "  ${GRAY}  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·${RESET}"
}

# ─── Timer utility ───────────────────────────────────────────────────────────
run_timed() {
  local label="$1"
  shift
  local t0=$SECONDS
  start_spinner "$label"
  if "$@"; then
    local elapsed=$(( SECONDS - t0 ))
    stop_spinner "ok" "$label" "$elapsed"
    return 0
  else
    stop_spinner "fail" "$label" "—"
    return 1
  fi
}

# ─── Error handler ───────────────────────────────────────────────────────────
on_error() {
  echo -e ""
  echo -e "  ${BG_ORANGE}${WHITE}${BOLD}  DEPLOYMENT FAILED  ${RESET}"
  echo -e "  ${RED}An error occurred on line ${BASH_LINENO[0]}.${RESET}"
  echo -e "  ${GRAY}Run with CLOUDSDK_CORE_VERBOSITY=debug for details.${RESET}"
  echo -e ""
  exit 1
}
trap on_error ERR

# ─── Configuration ───────────────────────────────────────────────────────────
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "$PROJECT_ID" ]]; then
  echo -e ""
  echo -e "  ${RED}${BOLD}✘  No active GCP project found.${RESET}"
  echo -e "  ${GRAY}Run: gcloud auth login && gcloud config set project <PROJECT_ID>${RESET}"
  echo -e ""
  exit 1
fi

SERVICE_NAME="pocket-gull"
REGION="us-west1"
IMAGE_TAG="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:latest"
DEPLOY_START=$SECONDS

# ─── Print the grand header ──────────────────────────────────────────────────
print_banner

# ─── PHASE 1: Pre-flight checks ──────────────────────────────────────────────
print_phase 1 3 "Pre-flight Checks" "🔍"

run_timed "Verifying gcloud authentication" \
  gcloud auth print-identity-token --quiet > /dev/null

run_timed "Confirming Cloud Build API is enabled" \
  gcloud services list --filter="config.name:cloudbuild.googleapis.com" --format="value(name)" > /dev/null

run_timed "Confirming Cloud Run API is enabled" \
  gcloud services list --filter="config.name:run.googleapis.com" --format="value(name)" > /dev/null

# ─── PHASE 2: Build ──────────────────────────────────────────────────────────
print_phase 2 3 "Building Container Image" "📦"
echo -e "  ${GRAY}  Submitting Dockerfile to Cloud Build — live output below:${RESET}"
echo -e ""

gcloud builds submit --tag "$IMAGE_TAG" 2>&1 | \
  sed "s/^/  ${DIM}${GRAY}│  /" | \
  sed "s/$/${RESET}/"

echo -e ""
echo -e "  ${GREEN}✔${RESET}  ${WHITE}Image pushed to Container Registry${RESET}  ${GRAY}${IMAGE_TAG}${RESET}"

# ─── PHASE 3: Deploy ─────────────────────────────────────────────────────────
print_phase 3 3 "Deploying to Cloud Run" "🌐"

run_timed "Rolling out service revision" \
  gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE_TAG" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --memory 1Gi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 5 \
    --set-secrets=GEMINI_API_KEY=GEMINI_API_KEY:latest \
    --quiet

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
  --region "$REGION" \
  --format="value(status.url)" 2>/dev/null)

TOTAL_ELAPSED=$(( SECONDS - DEPLOY_START ))

# ─── Victory sequence ────────────────────────────────────────────────────────
echo -e ""
echo -e "  ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e ""
echo -e "  ${GREEN}${BOLD}▸ DEPLOYMENT SUCCESSFUL${RESET}"
echo -e ""
echo -e "  ${BOLD}${WHITE}Live URL     ${RESET}${CYAN}${SERVICE_URL}${RESET}"
echo -e "  ${BOLD}${WHITE}Service      ${RESET}${GRAY}${SERVICE_NAME} @ ${REGION}${RESET}"
echo -e "  ${BOLD}${WHITE}Image        ${RESET}${GRAY}${IMAGE_TAG}${RESET}"
echo -e "  ${BOLD}${WHITE}Total time   ${RESET}${GOLD}${TOTAL_ELAPSED}s${RESET}"
echo -e "  ${BOLD}${WHITE}Deployed at  ${RESET}${GRAY}$(date '+%Y-%m-%d %H:%M:%S %Z')${RESET}"
echo -e ""

print_gull

echo -e "  ${GRAY}Pocket Gull is airborne. ${RED}♥${RESET}${GRAY}  Run${RESET} ${CYAN}npm run logs${RESET} ${GRAY}to tail live output.${RESET}"
echo -e ""
echo -e "  ${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e ""
