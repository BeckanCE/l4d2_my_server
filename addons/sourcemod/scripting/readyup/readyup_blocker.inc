#if defined _readyup_blocker_included
 #endinput
#endif
#define _readyup_blocker_included

// --- Definiciones y variables para el bloqueo de 2da ronda ---

#define BLOCK_DURATION 15.0

static int g_iReadyUpRoundCounter = 0;      // Contador de rondas (fases de ready-up)
static bool g_bIsReadyBlocked = false;    // Indica si el !ready está bloqueado
static int g_iReadyBlockEndTime = 0;      // Momento en que termina el bloqueo