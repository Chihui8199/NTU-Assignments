//
//  main.cpp
//  boyerMoore
//
//  Created by russell leung on 12/9/20.
//  Copyright © 2020 russell leung. All rights reserved.
//

#include <iostream>
#include <cstring>
#include <fstream>
using namespace std;
# define NUM_OF_CHARS 256

void badCharHeuristic(string str, int size,
                        int badChar[NUM_OF_CHARS])
{
    /*str = pat
     size = patSize*/
    
    /* badChar is the character of txt which doesnt match with current character of pat*/
    
    int i;
    /*initialise all values of badChar to be -1*/
    for (i = 0; i < NUM_OF_CHARS; i++)
        badChar[i] = -1;
  
    /* actual last occurance of a character in pat */
    for (i = 0; i < size; i++)
        badChar[int(str[i])] = i;
        
}
  

void search(string txt, string pat)
{
    int patSize = int(pat.size());
    int txtSize = int(txt.size());
  
    int badChar[NUM_OF_CHARS];
  

    badCharHeuristic(pat, patSize, badChar);
  
    int shift = 0;
    while(shift <= (txtSize - patSize))
    {
        int j = patSize-1;
  
        /* match pat and txt, and reduces j */
        while(j >= 0 && pat[j] == txt[shift + j])
            j--;
  
        /* if it's a match at current shift then j = -1 */
        if (j < 0)
        {
            cout << "Pattern occurs at shift/position: " <<  shift+5 << endl;
  
            /* pat shifts to align with next character of txt
            (io+m < i) is incasr pat is at end of txt */
            shift += (shift + patSize < txtSize)? patSize-badChar[txt[shift + patSize]] : 1;
  
        }
  
        else
            /* shift pat so badChar of txt aligns with last occurance of character in pat
             max: positive shift in case last occurance of character in pat is at right side
             of current character (in txt) */
            shift += max(1, j - badChar[txt[shift + j]]);
    }
}
  
int main()
{
    string txt, pat, line, data;
    fstream inFile("/Users/russellleung/Desktop/virus.fna", fstream::in);
    inFile.good();
    if (!inFile)
    {
        cout<<"Unable to open file!";
        exit(1);
    }
    while(!inFile.eof())
    {
        inFile>>data;
        txt = txt + data;
    }
    /*cout<<"Enter Text: ";
    cin>>txt;*/
    cout<<endl;
    cout<<"Enter Pattern: ";
    cin>>pat;
    cout<<endl;
    search(txt, pat);
    inFile.close();
    return 0;
}

