#!/bin/bash

# Skrypt testowy dla deduplikacji plików
# DIR01 = folder referencyjny ORYGINAŁ (już istnieje, NIGDY nie modyfikujemy!)
# img_test = kopia DIR01 do testowania (odpowiednik DIR011 ziomka)
# DIR02 = kopia DIR01 dla testów z hardlinkami

# Kolory dla output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Przygotowanie testów ===${NC}"

# Sprawdź czy DIR01 istnieje
if [[ ! -d "DIR01" ]]; then
    echo -e "${RED}BŁĄD: DIR01 nie istnieje!${NC}"
    echo "DIR01 powinien już być wypełniony plikami testowymi."
    exit 1
fi

echo -e "${GREEN}✓ DIR01 znaleziony${NC}"

# Czyścimy stare kopie testowe
rm -rf DIR02 img_test

# Tworzymy img_test jako kopię DIR01 (odpowiednik DIR011 ziomka)
echo "Tworzę img_test jako kopię DIR01..."
cp -r DIR01 img_test
echo -e "${GREEN}✓ img_test utworzony jako kopia DIR01${NC}"
echo ""

echo -e "${YELLOW}=== Uruchamiam testy ===${NC}"
echo ""

# Test 1: Podstawowy test bez opcji na img_test
echo -e "${YELLOW}Test 1: Podstawowy test img_test bez opcji${NC}"
./optimizer.sh img_test
echo ""

# Test 2: Test z --max-depth=2 na DIR01 (nie modyfikuje!)
echo -e "${YELLOW}Test 2: DIR01 z --max-depth=2 (tylko odczyt)${NC}"
echo "z --max-depth=2"
./optimizer.sh --max-depth=2 DIR01
echo "du DIR01 -d 0"
du DIR01 -d 0
echo ""

# Test 3: --max-depth=2 z --replace-with-hardlinks
# Kopiujemy DIR01 -> DIR02 i modyfikujemy DIR02!
echo -e "${YELLOW}Test 3: --max-depth=2 --replace-with-hardlinks (na kopii DIR02)${NC}"
echo "Tworzę kopię DIR01 -> DIR02..."
cp -r DIR01 DIR02
echo "z --max-depth=2 --replace-with-hardlinks"
./optimizer.sh --max-depth=2 --replace-with-hardlinks DIR02
echo "du DIR01 -d 0"
du DIR01 -d 0
echo ""

# Test 4: --replace-with-hardlinks na pełnej strukturze
# Znowu kopiujemy DIR01 -> DIR02 (świeża kopia!)
echo -e "${YELLOW}Test 4: --replace-with-hardlinks na pełnej strukturze (na kopii DIR02)${NC}"
echo "Tworzę świeżą kopię DIR01 -> DIR02..."
rm -rf DIR02
cp -r DIR01 DIR02
echo "z --replace-with-hardlinks"
./optimizer.sh --replace-with-hardlinks DIR02
echo "du DIR02 -d 0"
echo ""

echo -e "${GREEN}=== Testy zakończone ===${NC}"
echo ""
echo "Struktura folderów:"
echo "  DIR01    = folder referencyjny ORYGINAŁ (NIGDY nie modyfikowany)"
echo "  img_test = kopia DIR01 do testów (odpowiednik DIR011 ziomka)"
echo "  DIR02    = kopia DIR01 po zastosowaniu hardlinków"
echo ""
echo "Aby zobaczyć czy hardlinki działają:"
echo "  ls -li DIR02/ | head -20  # sprawdź numery inodów"
echo "  # Pliki z tym samym inodem to hardlinki!"
echo ""
echo "Sprawdź różnicę w rozmiarze:"
echo "  du DIR01 -sh  # oryginalny rozmiar"
echo "  du DIR02 -sh  # rozmiar po hardlinkach (powinien być mniejszy)"