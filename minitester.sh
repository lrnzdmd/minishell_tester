#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;36m'
DEFAULT='\033[0m'

make -C ../

print_usage() {
    echo -e "${YELLOW}Usage: ./tester.sh [options]${DEFAULT}"
    echo ""
    echo -e "Options:"
    echo -e "  ${ORANGE}-v, --verbose${DEFAULT}    Show full deatils for all tests (success and fail)."
    echo -e "  ${ORANGE}-h, --help${DEFAULT}       Display this help message."
    echo ""
}

VERBOSE=false
CHECK_LEAKS=false
for arg in "$@"; do
    case $arg in
        -v|--verbose)
        VERBOSE=true
        shift
        ;;
        -h|--help)
        print_usage
        exit 0
        ;;
    esac
done

TOTAL=0
PASSED=0
FAILED=0
TEST_NUM=0

mkdir -p ./outfiles
echo ""

for test_file in ./test_cases/*; do

    mkdir -p ./mini_outfiles
    mkdir -p ./bash_outfiles
    echo -e "${BLUE}[${YELLOW} Executing test: ${ORANGE}$test_file ${BLUE}]${DEFAULT}\n"

    while IFS= read -r COMMAND || [[ -n "$COMMAND" ]]; do
        if [[ -z "$COMMAND" || "$COMMAND" =~ ^\s*# ]]; then
            continue
        fi
        TOTAL=$((TOTAL + 1))
        TEST_NUM=$((TEST_NUM + 1))
        TEST_HEADER="${BLUE}[${YELLOW}Test ${ORANGE}#$(($TEST_NUM)):${DEFAULT} $COMMAND${BLUE}]${DEFAULT}"
        HEADER_PRINTED=false
        BASH_OUTPUT=$(echo -e "$COMMAND" | bash 2> ./outfiles/error_bash)
        BASH_EXIT_CODE=$?
        ERROR_BASH=$(cat ./outfiles/error_bash 2>/dev/null | head -1 | grep -o '[^:]*$')
        rm -f ./outfiles/error_bash
        if [ "$(ls -A ./outfiles 2>/dev/null)" ]; then
            cp ./outfiles/* ./bash_outfiles/ 2>/dev/null || true
        fi
        rm -rf ./outfiles/*
        MINI_OUTPUT=$(echo -e "$COMMAND" | ../minishell 2> ./outfiles/error_mini)
        MINI_EXIT_CODE=$?
        ERROR_MINI=$(cat ./outfiles/error_mini 2>/dev/null | head -1 | grep -o '[^:]*$')
        rm -f ./outfiles/error_mini
        if [ "$(ls -A ./outfiles 2>/dev/null)" ]; then
            cp ./outfiles/* ./mini_outfiles/ 2>/dev/null || true
        fi
        rm -rf ./outfiles/* OUTFILES_DIFF=""
        if [ -d "./mini_outfiles" ] && [ -d "./bash_outfiles" ]; then
            OUTFILES_DIFF=$(diff --brief ./mini_outfiles ./bash_outfiles 2>/dev/null)
        fi
        TEST_PASSED=true
        if [ "$BASH_OUTPUT" != "$MINI_OUTPUT" ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi # Stampa header al primo fail
            echo -e "  ${RED}✗${DEFAULT} Output FAIL"
            echo "    Bash: $BASH_OUTPUT"
            echo "    Mini: $MINI_OUTPUT"
            TEST_PASSED=false
        elif [ "$VERBOSE" = true ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi # Stampa header in verbose
            echo -e "  ${GREEN}✓${DEFAULT} Output OK"
        fi
        if [ "$BASH_EXIT_CODE" != "$MINI_EXIT_CODE" ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi
            echo -e "  ${RED}✗${DEFAULT} Exit code FAIL (mini:$MINI_EXIT_CODE bash:$BASH_EXIT_CODE)"
            TEST_PASSED=false
        elif [ "$VERBOSE" = true ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi
            echo -e "  ${GREEN}✓${DEFAULT} Exit code OK ($BASH_EXIT_CODE)"
        fi
        if [ "$ERROR_BASH" != "$ERROR_MINI" ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi
            echo -e "  ${YELLOW}!${DEFAULT} Stderr DIFF!"
            echo "    Bash: $ERROR_BASH"
            echo "    Mini: $ERROR_MINI"
        elif [ "$VERBOSE" = true ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi
            echo -e "  ${GREEN}✓${DEFAULT} Stderr OK"
        fi
        if [ "$OUTFILES_DIFF" ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi
            echo -e "  ${RED}✗${DEFAULT} Outfiles DIFF"
            echo "$OUTFILES_DIFF"
            TEST_PASSED=false
        elif [ -d "./mini_outfiles" ] && [ -d "./bash_outfiles" ] && [ "$VERBOSE" = true ]; then
            if [ "$HEADER_PRINTED" = false ]; then echo -e "$TEST_HEADER"; HEADER_PRINTED=true; fi
            echo -e "  ${GREEN}✓${DEFAULT} Outfiles OK"
        fi
        if [ "$TEST_PASSED" = true ]; then
            PASSED=$((PASSED + 1))
            if [ "$VERBOSE" = true ]; then
                echo -e "  ${GREEN}PASSED${DEFAULT}"
            else
                echo -e "$TEST_HEADER ${GREEN}✓ OK${DEFAULT}"
            fi
        else
            FAILED=$((FAILED + 1))
            echo -e "  ${RED}FAILED${DEFAULT}"
        fi
        
        rm -rf ./mini_outfiles/*
        rm -rf ./bash_outfiles/*
    done < "$test_file"
done

echo ""
echo "Tested:  $TOTAL"
echo -e "${GREEN}Pass: $PASSED${DEFAULT}"
echo -e "${RED}Fail: $FAILED${DEFAULT}"

rm -rf outfiles

if [ $FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi