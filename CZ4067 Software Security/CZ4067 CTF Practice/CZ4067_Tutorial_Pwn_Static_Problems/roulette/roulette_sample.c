#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>
#include <string.h>

char player_input[8];

void win(){
    char flag[512];
    // d is the function to deobfuscate the flag and store it within the flag variable. Not part of the challenge.
    // d(flag, "CZ4067{...}");
    printf("CONGRATULATIONS! You really are a prophet! You got seven in a row!\n");
    printf("The flag is: %s\n", flag);
}

void printHeader(){
    printf("==============================================================================\n");
    puts(
        "/$$$$$$$                      /$$             /$$       /$$                            \n"
        "| $$__  $$                    | $$            | $$      | $$                           \n"
        "| $$  \\ $$  /$$$$$$  /$$   /$$| $$  /$$$$$$  /$$$$$$   /$$$$$$    /$$$$$$             \n"
        "| $$$$$$$/ /$$__  $$| $$  $$| $$ /$$__  $$|_  $$_/  |_  $$_/   /$$__  $$             \n"
        "| $$__  $$| $$  \\ $$| $$  | $$| $$| $$$$$$$$  | $$      | $$    | $$$$$$$$            \n"
        "| $$  \\ $$| $$  | $$| $$  | $$| $$| $$_____/  | $$ /$$  | $$ /$$| $$_____/            \n"
        "| $$  | $$|  $$$$$$/|  $$$$$$/| $$|  $$$$$$$  |  $$$$/  |  $$$$/|  $$$$$$$             \n"
        "|__/  |__/ \\______/  \\______/ |__/ \\_______/   \\___/     \\___/   \\______/ \n");
    
    printf("==============================================================================\n");
}

int main(){
    int seed = time(0);
    printHeader();
    printf("Welcome to the CASINO!\n");
    printf("What is your name?\n");
    char name[64];
    gets(name);

    printf("==============================================================================\n");
    printf("Hello %s :) \n", name);
    printf("Fancy trying your luck? We will be playing a game of roulette (1-36).\n");
    printf("Guess correctly SEVEN times in a row and win a prize!\n");
    printf("==============================================================================\n");

    int counter = 0;
    int guess = 0;
    int random_numbers[7];
    srand(seed);

    do {
        printf("Guess a number from 1 to 36: ");
        fgets(player_input, 8, stdin);
        guess = atoi(player_input);

        random_numbers[counter] = (rand() % 36) + 1;

        printf("You guessed %d!\n", guess);
        printf("The number was %d!\n", random_numbers[counter]);
        if (guess == random_numbers[counter]) {
            counter += 1;
            printf("You got it right!\n");
        }
        else {
            counter = 0;
            printf("So close! Try again next time!\n");
            exit(0);
        }
        printf("The counter is now at: %d\n", counter);
        printf("\n"); 
        printf("-----------------------------------------------\n");
        printf("\n");          
    }
    while (counter != 7);

    if (counter == 7){
        win();
    }
}