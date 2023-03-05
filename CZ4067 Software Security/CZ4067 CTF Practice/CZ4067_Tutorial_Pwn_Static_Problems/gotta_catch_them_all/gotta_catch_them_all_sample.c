#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> 
#include <stdarg.h>

// source code to be passed to the players

short enemy_health = 20000;
short player_health = 10000;
char player_input[10];
int player_choice;
int is_player_turn;
int is_player_defending;
int heal_next_turn = 0;

void win()
{
    char flag[512];
    // d is the function to deobfuscate the flag and store it within the flag variable. Not part of the challenge.
    // d(flag, "CZ4067{...}");
    printf("Chikaphu fainted!\n");
    printf("The flag is: %s\n", flag);
    exit(0);
}

void lose(){
    printf("You fainted!\n");
    printf("Try Harder!\n");
    exit(0);
}

void printMenuFooter()
{
    printf("===========================================\n");
    sleep(1.5);
    printf("\n");
    printf("\n");
    printf("\n");
}

void printMainMenu(){
    printf("===========================================\n");
    // ASCII Art adapted from poketerm repo - Copyright (c) 2020 Devarshi Aggarwal
    puts("|\\_                  _\n" 
 "\\ \\               _/_|\n"
  "\\ \\_          __/ /\n"
   "\\  \\________/   /\n"
    "|              |\n"
    "/              |\n"
   "|   0       0   |\n"
   "|       _       |\n"
   "|()    __    () |\n"
    "\\    (__)      |\n");
    printf("===========================================\n");
    printf("A Wild Chikaphu appears!!!\n");
    printf("Type: Electric\n");
    printf("WARNING: Chikaphu ABSORBS electric attacks!\n");
    printf("Max Health: 20000 HP\n");
    printf("Defeat Chikaphu to get the flag!!!\n");
    printMenuFooter();
}

void printPlayerMenu()
{
    printf("===========================================\n");
    printf("*************** Player Turn ***************\n");
    printf("---------------------------------------\n");
    printf("Player Health: %d/10000 HP\n", player_health);
    printf("Chikaphu Health: %d/20000 HP\n", enemy_health);
    printf("---------------------------------------\n");
    printf("What will you do?\n");
    printf("1. ATTACK - SPLASH (Type: Normal)\n");
    printf("2. ATTACK - FIRE PUNCH (Type: Fire)\n");
    printf("3. ATTACK - FLAMETHROWER (Type: Fire)\n");
    printf("4. ATTACK - LIGHTNING BOLT (Type: Electric)\n");
    printf("5. DEFEND\n");
    printf("6. RUN\n");
    printf("Please input a valid choice (1-6):\n");
    printf("===========================================\n");
}


void printEnemyMenu()
{
    printf("===========================================\n");
    printf("*************** Chikaphu Turn *************\n");
    printf("---------------------------------------\n");
    printf("Player Health: %d/10000 HP\n", player_health);
    printf("Chikaphu Health: %d/20000 HP\n", enemy_health);
    printf("---------------------------------------\n");
}

void playerTrashAttack()
{
    printf("You used Splash!\n");
    printf("...............!\n");
    printf("Nothing interesting happened...\n");
}

void playerWeakAttack()
{
    printf("You used Rapid Punch!\n");
    enemy_health -= 2000;
    printf("It's slightly effective!\n");
    printf("2000 HP deducted from Chikaphu!\n");
}

void playerStrongAttack()
{
    printf("You used Flamethrower!\n");
    enemy_health -= 4000;
    printf("It's super effective!\n");
    printf("4000 HP deducted from Chikaphu!\n");
}

void playerDefend()
{
    printf("Afraid of Chikaphu, you defend!\n");
    is_player_defending = 1;
}

void playerFeed()
{
    printf("You used Lighning Bolt!\n");
    printf("Chikaphu absorbs the lightning you shoot at it!\n");
    if (enemy_health != 20000){
        printf("Chikaphu eats the berries and heals for 2000 HP!!\n");
        printf("Shouldn't you be fighting it?\n");
        enemy_health += 2000;
    }
}

void playerRun()
{
    printf("You flee and look to fight another day...\n");
    exit(0);
}

void playerTurn()
{
    printPlayerMenu();
    is_player_defending = 0;
    fgets(player_input,10,stdin);
    player_choice = atoi(player_input);
    switch (player_choice){
        case 1:
            playerTrashAttack();
            break;
        case 2:
            playerWeakAttack();
            break;
        case 3:
            playerStrongAttack();
            break;
        case 4:
            playerFeed();
            break;
        case 5:
            playerDefend();
            break;
        case 6: 
            playerRun();
            break;
        default:
            printf("Looks like you did not input 1-6!\n");
            printf("You did nothing this turn!\n");    
    }
    printMenuFooter();
}

void enemyTurn(){   
    printEnemyMenu();
    if (enemy_health > 0){
        if (heal_next_turn){
             printf("Chikaphu is healing!!!\n");
             enemy_health += 12000;
             printf("This guy is unbeatable!\n");
             printf("Chikaphu Health: %d/20000\n", enemy_health); 
             heal_next_turn = 0;
        }

        printf("Chikaphu uses Thunder!\n");
        if (is_player_defending){
            printf("Your defence is rock solid! You do not lose any HP!\n");
            printf("Does defending really help you though?\n");
        }
        else {
            printf("You lose 1000 HP!\n");
            player_health -= 1000;
        }
        if (enemy_health < 10000){
            printf("Chikaphu begins to growl! Oh no!\n");
            heal_next_turn = 1;
            }
    }
    printMenuFooter();
}


int main(){
    printMainMenu();
    while (enemy_health > 0 && player_health > 0){
        playerTurn();
        enemyTurn();
    }
    if (enemy_health <= 0){
         win();
    }
    if (player_health <= 0){
        lose();
    }
    return 0;
}