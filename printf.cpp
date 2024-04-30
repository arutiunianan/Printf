extern "C" void AnishkinPrintf(const char* format, ...);

int main() 
{
    int dec         = 5;
    int hex         = 15;
    int octal       = 8;
    char chr        = ')';
    const char* str = "Anishka";

    AnishkinPrintf("dec: %d hex: %x octal: %o sym: %c str: %s", dec, hex, octal, chr, str);

    return 0;
}