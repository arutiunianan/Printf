extern "C" void AnishkinPrintf(const char* format, ...);
#include <cstdlib>

int main() 
{
    const char* name = "Anishka";
    int age          = -20;
    int course       = 3;
    char first_word  = 'M';
    char second_word = 'I';
    char third_word  = 'P';
    char fourth_word = 'T';

    AnishkinPrintf("Hello! My name is %s. I am %d years old. I am a %xrd year student at %c%c%c%c.", 
                   name, age, course, first_word, second_word, third_word, fourth_word);
    
    return 0;
}