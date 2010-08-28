/* Copyright (c) 2010 Shlomi Fish
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * black_hole_solver.c - a solver for Black Hole Solitaire.
 */

#include <stdlib.h>
#include <string.h>

#include "black_hole_solver.h"
#include "state.h"
#include "fcs_hash.h"

typedef struct 
{
    /*
     * TODO : rename from board_values.
     *
     * This is the ranks of the cards in the columns. It remains constant
     * for the duration of the game.
     * */
    bhs_rank_t board_values[MAX_NUM_COLUMNS][MAX_NUM_CARDS_IN_COL];

    bhs_rank_t initial_foundation;

    fc_solve_hash_t hash;

    bhs_card_string_t initial_foundation_string;
    bhs_card_string_t initial_board_card_strings[MAX_NUM_COLUMNS][MAX_NUM_CARDS_IN_COL];
    int initial_lens[MAX_NUM_COLUMNS];

} bhs_solver_t;

int black_hole_solver_create(
    black_hole_solver_instance_t * * ret_instance
)
{
    bhs_solver_t * ret;

    ret = (bhs_solver_t *)malloc(sizeof(*ret));

    if (! ret)
    {
        *ret_instance =  NULL;
        return BLACK_HOLE_SOLVER__OUT_OF_MEMORY;
    }
    else
    {
        fc_solve_hash_init(&(ret->hash), 256);
        *ret_instance = (black_hole_solver_instance_t *)ret;
        return BLACK_HOLE_SOLVER__SUCCESS;
    }
}

static int parse_card(
    const char * * s,
    bhs_rank_t * foundation,
    bhs_card_string_t card
)
{
    strncpy(card, (*s), 2);
    card[2] = '\0';

    switch(*(*s))
    {
        case 'A':
            *foundation = 0;
            break;
        
        case '2':
            *foundation = 1;
            break;

        case '3':
            *foundation = 2;
            break;

        case '4':
            *foundation = 3;
            break;

        case '5':
            *foundation = 4;
            break;
 
        case '6':
            *foundation = 5;
            break;
 
        case '7':
            *foundation = 6;
            break;
 
        case '8':
            *foundation = 7;
            break;
 
        case '9':
            *foundation = 8;
            break;
 
        case 'T':
            *foundation = 9;
            break;

        case 'J':
            *foundation = 10;
            break;

        case 'Q':
            *foundation = 11;
            break;

        case 'K':
            *foundation = 12;
            break;

        default:
            return BLACK_HOLE_SOLVER__UNKNOWN_RANK;
    }

    (*s)++;

    switch (*(*s))
    {
        case 'H':
        case 'S':
        case 'D':
        case 'C':
            break;
        default:
            return BLACK_HOLE_SOLVER__UNKNOWN_SUIT;
    }
    (*s)++;

    return BLACK_HOLE_SOLVER__SUCCESS;
}


extern int black_hole_solver_read_board(
    black_hole_solver_instance_t * instance_proto,
    const char * board_string,
    int * error_line_number
)
{
    const char * s, * match;
    bhs_solver_t * solver;
    int ret_code, col_idx;
    
    solver = (bhs_solver_t *)instance_proto;

    s = board_string;

    /* Read the foundations. */

    while ((*s) == '\n')
    {
        s++;
    }

    match = "Foundations: ";
    if (!strcmp(s, match))
    {
        *error_line_number = 1;
        return BLACK_HOLE_SOLVER__FOUNDATIONS_NOT_FOUND_AT_START;
    }

    s += strlen(match);

    ret_code =
        parse_card(&s,
            &(solver->initial_foundation),
            solver->initial_foundation_string
        );

    if (ret_code)
    {
        *error_line_number = 1;
        return ret_code;
    }

    if (*(s++) != '\n')
    {
        *error_line_number = 1;
        return BLACK_HOLE_SOLVER__TRAILING_CHARS;
    }

    for(col_idx = 0; col_idx < MAX_NUM_COLUMNS; col_idx++)
    {
        int pos_idx = 0;
        while ((*s != '\n') && (*s != '\0'))
        {
            if (pos_idx == MAX_NUM_CARDS_IN_COL)
            {
                *error_line_number = 2+col_idx;
                return BLACK_HOLE_SOLVER__TOO_MANY_CARDS;
            }

            ret_code =
                parse_card(&s,
                    &(solver->board_values[col_idx][pos_idx]),
                    solver->initial_board_card_strings[col_idx][pos_idx]
                );
            
            if (ret_code)
            {
                *error_line_number = 2+col_idx;
                return ret_code;
            }
            
            while ((*s) == ' ')
            {
                s++;
            }

            pos_idx++;
        }

        solver->initial_lens[col_idx] = pos_idx;

        if (*s == '\0')
        {
            *error_line_number = 2+col_idx;
            return BLACK_HOLE_SOLVER__NOT_ENOUGH_COLUMNS;
        }
        else
        {
            s++;
        }
    }

    return BLACK_HOLE_SOLVER__SUCCESS;
}

extern int black_hole_solver_run(
    black_hole_solver_instance_t * ret_instance
)
{
    bhs_solver_t * solver;
    bhs_state_key_t init_state;
    int four_cols_idx, four_cols_offset;

    solver = (bhs_solver_t *)ret_instance;

    memset(&init_state, '\0', sizeof(init_state));
    init_state.foundations = solver->initial_foundation;

    for (four_cols_idx = 0, four_cols_offset = 0; four_cols_idx < 4; four_cols_idx++, four_cols_offset += 4)
    {
        init_state.data[four_cols_idx] =
            (unsigned char)
            (
              (solver->initial_lens[four_cols_offset]) 
            | (solver->initial_lens[four_cols_offset+1] << 2)    
            | (solver->initial_lens[four_cols_offset+2] << 4)    
            | (solver->initial_lens[four_cols_offset+3] << 6)    
            )
            ;
    }
    /* Only one left. */
    init_state.data[four_cols_idx] = (unsigned char)(solver->initial_lens[four_cols_offset]);


    return BLACK_HOLE_SOLVER__NOT_SOLVABLE;
}
