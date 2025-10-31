# README - Tester per Minishell

Questo script (`minitester.sh`) è un framework di test per `minishell`. Il suo scopo è validare il comportamento della vostra shell confrontando il suo output, i codici di uscita, lo standard error e i file creati con quelli di `bash`.

---

## Installazione e Struttura

1.  Posizionatevi nella directory principale del vostro progetto `minishell` (quella che contiene il vostro `Makefile` e l'eseguibile).
2.  Clonate questa repository in una sottocartella (es. `tester`):
    `git clone git@github.com:lrnzdmd/minishell_tester.git tester`
3.  Rendete lo script eseguibile:
    `chmod +x tester/minitester.sh`

La struttura finale del progetto richiesta dallo script sarà la seguente:

```
minishell/          <-- Root del vostro progetto
├── minishell       <-- Il vostro eseguibile
├── Makefile
├── ... (vostri file .c e .h)
│
└── tester/         <-- Questa repository clonata
    ├── minitester.sh
    ├── test_cases/
    │   └── ...
    └── test_files/
        └── ...
```

Lo script (`minitester.sh`) si aspetta di trovare l'eseguibile `minishell` nella directory genitore (`../minishell`).

---

## Requisito Fondamentale: Input Non-Interattivo

Per poter funzionare, questo tester deve inviare comandi alla `minishell` tramite pipe.

L'operazione eseguita è la seguente:
`echo "ls -l | wc -l" | ../minishell`

Quando l'input proviene da una pipe, lo standard input della `minishell` non è collegato a un terminale (TTY). Di conseguenza:
1.  La funzione `isatty(STDIN_FILENO)` restituirà `0` (false).
2.  La funzione `readline()` non è progettata per questa modalità e non funzionerà correttamente (potrebbe bloccarsi o fallire).

### Soluzione Richiesta

È imperativo che la `minishell` gestisca questa distinzione. Deve rilevare se l'input è interattivo o meno e selezionare il metodo di lettura appropriato.

Quando `isatty(STDIN_FILENO)` è falso, la shell deve leggere i comandi dallo standard input (file descriptor `0`) utilizzando una funzione alternativa come `get_next_line` o un loop su `read`.

```c
/* Esempio di logica per la gestione dell'input */

#include <unistd.h> // Per isatty

// ...
while (1)
{
    // ...

    if (isatty(STDIN_FILENO))
    {
        // 1. MODALITÀ INTERATTIVA (Terminale)
        // Stampa il prompt e usa readline.
        refresh_prompt(data);
        input = readline("minishell$ ");
    }
    else
    {
        // 2. MODALITÀ NON-INTERATTIVA (Pipe)
        // Non stampare il prompt. Leggi da STDIN con get_next_line.
        input = ft_get_next_line(0);
    }

    // ...
}
```

La mancata implementazione di questa logica impedirà al tester di comunicare con la `minishell`, causando il fallimento di tutti i test.

---

## Utilizzo

Eseguire lo script dalla sua directory:

`cd tester`
`./minitester.sh`

### Opzioni

* `./minitester.sh`
    **Modalità Standard**. Esegue tutti i test. Mostra i dettagli completi solo per i test falliti. I test superati sono indicati da una singola riga di conferma.

* `./minitester.sh -v` (o `--verbose`)
    **Modalità Verbosa**. Mostra i dettagli completi (Output, Exit Code, Stderr) per *tutti* i test, inclusi quelli superati.

* `./minitester.sh -h` (o `--help`)
    Mostra un messaggio di aiuto con il riepilogo delle opzioni.

---
lde-medi 42 Madrid