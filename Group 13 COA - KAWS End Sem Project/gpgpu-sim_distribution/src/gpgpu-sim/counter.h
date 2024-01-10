#ifndef COUNTER_H_INCLUDED
#define COUNTER_H_INCLUDED

// To validate whether the total simulation cycles match with expected result.
extern int cycle_cnt; 

extern int debug;

// To capture 5 different states of warps at broader level.
extern int Waiting, XMEM, XALU, Others, Issued; 

// Substate breakdown of waiting warps
extern int wait_controlHazard, wait_scoreboard, wait_divergentWarps ;

// Substate breakdown of issued warps
extern int issued_mem, issued_sp, issued_int, issued_dp, issued_sfu, issued_tensorCore, issued_spec;

// Substate breakdown of XALU warps
extern int xalu_sp_int, xalu_dp, xalu_sfu, xalu_tensorCore, xalu_spec ;

// Substate breakdown of other state
    // ibe -> instruction buffer empty 
    // wb -> waiting for barrier
extern int other_ibe, other_wb;

// Max issue warps - To capture state of warps after some warps are issued in a cycle
extern int wait_maxIssue, xalu_maxIssue, xmem_maxIssue, other_maxIssue;

// To account for invalid warps
extern int invalid;

#endif;