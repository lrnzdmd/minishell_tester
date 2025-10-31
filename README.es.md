# README - Tester para Minishell

Este script (`minitester.sh`) es un tester para `minishell`. Su objetivo es validar el comportamiento de tu shell comparando su salida, códigos de salida, output stderr y archivos creados con los de `bash`.

---

## Instalación y Estructura

1.  Sitúate en el directorio principal de tu proyecto `minishell` (el que contiene tu `Makefile` y el ejecutable).
2.  Clona este repositorio en un subdirectorio (p. ej., `tester`):
    `git clone git@github.com:lrnzdmd/minishell_tester.git tester`
3.  Da permisos de ejecución al script:
    `chmod +x tester/minitester.sh`

La estructura final del proyecto que requiere el script será la siguiente:

```
minishell/          <-- Raíz de tu proyecto
├── minishell       <-- Tu ejecutable
├── Makefile
├── ... (tus archivos .c y .h)
│
└── tester/         <-- Este repositorio clonado
    ├── minitester.sh
    ├── test_cases/
    │   └── ...
    └── test_files/
        └── ...
```

El script (`minitester.sh`) espera encontrar el ejecutable `minishell` en el directorio padre (`../minishell`).

---

## Requisito Crítico: Manejo de Entrada No Interactiva

Para funcionar, este tester debe enviar comandos a `minishell` a través de una pipe.

La operación que realiza es la siguiente:
`echo "ls -l | wc -l" | ../minishell`

Cuando la entrada proviene de una pipe, la entrada estándar de `minishell` no está conectada a una terminal (TTY). Como resultado:
1.  La función `isatty(STDIN_FILENO)` devolverá `0` (false).
2.  La función `readline()` no está diseñada para este modo y no funcionará correctamente (podría colgarse o fallar).

### Solución Requerida

Es imperativo que `minishell` maneje esta distinción. Debe detectar si la entrada es interactiva o no y seleccionar el método de lettura apropiado.

Cuando `isatty(STDIN_FILENO)` sea falso, la shell debe leer los comandos desde la entrada estándar (descriptor de archivo `0`) usando una función alternativa, como `get_next_line` o un bucle de `read`.

```c
/* Ejemplo de lógica para el manejo de entrada */

#include <unistd.h> // Para isatty

// ...
while (1)
{
    // ...

    if (isatty(STDIN_FILENO))
    {
        // 1. MODO INTERACTIVO (Terminal)
        // Imprime el prompt y usa readline.
        refresh_prompt(data);
        input = readline("minishell$ ");
    }
    else
    {
        // 2. MODO NO-INTERACTIVO (Pipe)
        // No imprimir el prompt. Leer de STDIN con get_next_line.
        input = ft_get_next_line(0);
    }

    // ...
}
```

No implementar esta lógica impedirá que el tester se comunique con `minishell`, lo que provocará que todas las pruebas fallen.

---

## Uso

Ejecuta el script desde su propio directorio:

`cd tester`
`./minitester.sh`

### Opciones

* `./minitester.sh`
    **Modo Estándar**. Ejecuta todas las pruebas. Muestra detalles completos solo para las pruebas fallidas. Las pruebas superadas se indican con una única línea de confirmación.

* `./minitester.sh -v` (o `--verbose`)
    **Modo Verboso**. Muestra detalles completos (Output, Exit Code, Stderr) para *todas* las pruebas, incluidas las superadas.

* `./minitester.sh -h` (o `--help`)
    Muestra un mensaje de ayuda con el resumen de las opciones.

---
lde-medi 42 Madrid